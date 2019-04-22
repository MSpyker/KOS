//Maurits Spijker
//Changes the direction of the vessel so that it will crash at the KSC
//parameters: none

//startstatus
clearscreen.
SAS off.
RCS on.
brakes on.
set reentrycomplete to 0.


FUNCTION eta_altitude 
{
    SET r TO body:radius.

    IF (periapsis + body:radius) < r AND (apoapsis + body:radius) > r 
		{
			LOCAL a IS obt:semimajoraxis.
			LOCAL e IS obt:eccentricity.
			LOCAL t IS obt:trueanomaly.
			LOCAL TA IS arccos((a * (1 - e^2) - r) / (e * r)).

			IF (altitude + body:radius) > r { SET TA TO 360 - TA. }
			LOCAL currentEA IS arctan2(sqrt(1 - e^2) * sin(t), e + cos(t)).
			LOCAL currentMA IS currentEA - e * sin(currentEA) * constant:radtodeg.
			LOCAL targetEA IS arctan2(sqrt(1 - e^2) * sin(TA), e + cos(TA)).
			LOCAL targetMA IS targetEA - e * sin(targetEA) * constant:radtodeg.

			RETURN mod(((targetMA - currentMA) / 360) * obt:period + obt:period, obt:period).
    } 
		ELSE 
		{    RETURN 0. 		}
}

Function Landingssite_vectors
{
    set launchpad to LATLNG(-0.09696635151219,-74.5435243923809).                                               // Location of launchpad
    set targetheight to altitude/1.25.                                                                             
    set LandingssiteVector to launchpad:ALTITUDEPOSITION(launchpad:TERRAINHEIGHT+70).                              //vector to Launchpad
    set LandingssiteTrench to launchpad:ALTITUDEPOSITION(launchpad:TERRAINHEIGHT+targetheight).                    // Vector above launchpad
}

FUNCTION GetVectors 
{
	set currentPosition to positionat(ship, time:seconds).

	set impact_time to eta_altitude.
	set impact_pos to body:geopositionof(positionat(ship, time:seconds + impact_time) - currentPosition).
	set impact_lng to impact_pos:lng - 360 / body:rotationperiod * impact_time.
	set impact_location to latlng(impact_pos:lat, impact_lng).
    
	set ImpactVector to impact_location:ALTITUDEPOSITION(impact_location:TERRAINHEIGHT).
    set DirectionVector to ship:srfprograde:vector*LandingssiteVector:mag.
    set oppositeVector to (((LandingssiteTrench / LandingssiteTrench:mag )* 2*DirectionVector:mag) - DirectionVector).
    set DifferenceVector to vxcl(up:vector,(LandingssiteVector-DirectionVector)).


    set pointVector to oppositeVector + 4*DifferenceVector.
} 

function compare_vector 
{
    //Checks if you're chrashing near landings site.
    set DifferenceVector to 100*((LandingssiteTrench/LandingssiteTrench:mag)-(ImpactVector/ImpactVector:mag)).
    set Difference to DifferenceVector:mag.
    print "Angle between vectors:   " + round(Difference,2) at (0,2).
}

function Drawvectors
{   
    Clearvecdraws().
    VECDRAW(v(0,0,0),ImpactVector,red,"Impact",1.0,TRUE).
    VECDRAW(v(0,0,0),pointVector,white,"Pointing",2.0,TRUE).
    VECDRAW(v(0,0,0),LandingssiteTrench,green,"Landings-site",1.0,TRUE).
}

function LockSteering
{
    lock steering to -pointVector.
}

function reentry
{
    if reentrycomplete = 0
    {
        if altitude < 25000 and airspeed > 250
        {   
            set kuniverse:timewarp:warp to 0.
            wait 1.
            until airspeed < 250
            {   
                GetVectors.
                Drawvectors.
                
                lock steering to (LandingssiteVector/LandingssiteVector:mag)-2*(ImpactVector/ImpactVector:mag).
               
                set throttle to 1.
                
            }
            set reentrycomplete to 1.  
        }
        lock throttle to 0.
    }
}

function InitiateLand
{   
    set Hoverheight to 250.
	lock stopRadar to alt:radar - Hoverheight.					                                                          // Offset radar to get distance from gear to ground
	declare global g to constant:g * body:mass / body:radius^2.			                                              // Gravity (m/s^2)
	lock maxDecel to (ship:availablethrust / ship:mass) - g.	                                                    // Maximum deceleration possible (m/s^2)
	lock stopDist to (ship:verticalspeed^2)/ (2 * maxDecel).		                                                  // The distance the burn will require

    if stopRadar < stopDist +75
    {
        print "check".
        run land.
    }
}

function GuidetoLandingsSite
{
    Landingssite_vectors.
    eta_altitude.
    GetVectors.
    Landingssite_vectors.
    compare_vector.
    Drawvectors.
    LockSteering.
    reentry.
    InitiateLand.
}

until false
{   
    GuidetoLandingsSite.
}