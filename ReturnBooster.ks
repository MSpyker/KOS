set Configured to false.
//Script By Spyker
//Script will run on your Boosters computer
//Will try to land your booster near the Landingssite.

Function Configure
{
    if Configured = false
    {
        set Landingssite to          LATLNG(-0.09696635151219,-74.5435243923809).                                   // Location of Landingssite

        SAS off.
        Brakes off.
        RCS on.
        set SteeringManager:MAXSTOPPINGTIME to 4.

        set BBdone to           false.
        
        set EaroguideDone to    false.

        set Configured to true.
    }
}

Function ImpactData
{
    set targetheight to             altitude / 2.
    set LandingssiteVector to    Landingssite:ALTITUDEPOSITION(Landingssite:TERRAINHEIGHT).
    set LandingssiteTrench to       Landingssite:ALTITUDEPOSITION(Landingssite:TERRAINHEIGHT+targetheight).

    Function CalcImpactTime
    {
        SET r TO body:radius.
        if (periapsis + body:radius) < r and (apoapsis + body:radius) > r 
            {
                set a to    Orbit:semimajoraxis.
                set e to    Orbit:eccentricity.
                set t to    Orbit:trueanomaly.
                set TA to   arccos((a * (1 - e^2) - r) / (e * r)).

                if (altitude + body:radius) > r 
                { 
                    set TA to 360 - TA. 
                }
                Set currentEA to    arctan2(sqrt(1 - e^2) * sin(t), e + cos(t)).
                Set currentMA to    currentEA - e * sin(currentEA) * constant:radtodeg.
                Set targetEA to     arctan2(sqrt(1 - e^2) * sin(TA), e + cos(TA)).
                Set targetMA to     targetEA - e * sin(targetEA) * constant:radtodeg.

                set ImpactTime to   mod(((targetMA - currentMA) / 360) * Orbit:period + Orbit:period, Orbit:period).
            } 
        else 
        {    
            set ImpactTime to 0.
        }
    }

    Function CalcImpactLocation 
    {
        Set currentPosition to  positionat(ship, time:seconds).
        Set ImpactPos to        body:geopositionof(positionat(ship, time:seconds + ImpactTime) - currentPosition).
        Set ImpactLng to        ImpactPos:lng - 360 / body:rotationperiod * ImpactTime.
        Set ImpactLocation to   latlng(ImpactPos:lat, ImpactLng).

        set ImpactVector to     ImpactLocation:ALTITUDEPOSITION(ImpactLocation:TERRAINHEIGHT).
    }
    
    CalcImpactTime.
    CalcImpactLocation.
}

Function Boostback
{
    function CheckHeading 
    {
        //Checks if you're chrashing near landings site.
       
        set DifferenceVector to 100*((LandingssiteVector/LandingssiteVector:mag)-(ImpactVector/ImpactVector:mag)).
        set Difference to DifferenceVector:mag.
        print "Angle between vectors:     " + round(Difference,2) at (0,2).
        
        //Check if you're pointing to landings site.
        set Forevector to ship:facing:forevector*100.
        set DifferenceHeading to ((DifferenceVector/DifferenceVector:mag)-(Forevector/Forevector:mag)).
        print "Misalignment in vectors:   " + round(DifferenceHeading:mag,2) at (0,4).
        if DifferenceHeading:mag<0.25 
        {
            set correctHeading to true.
        }
        else
        {
            set correctHeading to false.
        }
    }

    function PerformBoostBack
    {
        lock steering to DifferenceVector.

        if correctHeading = true and DifferenceHeading:mag<0.25 
        {
            lock throttle to 1.
        } 
        else
        {
            lock throttle to 0.
        }
    }

    function DrawBBVector
    {
        Clearvecdraws().
        VECDRAW(v(0,0,0),ImpactVector,          red,    "Impact",       1.0,TRUE).
        VECDRAW(v(0,0,0),Forevector,           blue,   "Forevector",     1.0,TRUE).
        VECDRAW(v(0,0,0),LandingssiteVector,       green,  "Landings-site",1.0,TRUE).
        VECDRAW(v(0,0,0),DifferenceVector,      white,  "Difference",   1.0,TRUE).
    }
    
    Configure.
    Impactdata.
    CheckHeading.
    DrawBBVector.

    if Difference > 0.5
    {
        PerformBoostBack.
    }
    else
    {
        set BBdone to true.
        Clearvecdraws().
        set throttle to 0.
        unlock throttle.
        unlock steering.
    }
}

Function minStopDistance
{
    set stopRadar to        LandingssiteVector:mag.					                                            
	declare global g to     constant:g * body:mass / body:radius^2.			                                                
    set maxDecel to         (ship:availablethrust / ship:mass) - g.	                                                        
	
    set maxDecelVector to   ship:srfprograde:vector * maxDecel.
    set HorizontalDecel to  vxcl(up:vector,(maxDecelVector)).
    set VerticalDecel to    vxcl(HorizontalDecel,maxDecelVector).
    set stopDist to         (ship:verticalspeed^2)/ (2 * VerticalDecel:mag).
}

Function Earoguide
{
    ImpactData.
    set Forevector to ship:facing:forevector*100.
    function DrawEaroGuideVectors
    {   
        Clearvecdraws().
        VECDRAW(v(0,0,0),ImpactVector,          red,"Impact",1.0,TRUE).
        VECDRAW(v(0,0,0),EaroguideVector,       white,"EaroGuide",2.0,TRUE).
        VECDRAW(v(0,0,0),Forevector,           blue,   "Forevector",     1.0,TRUE).
        VECDRAW(v(0,0,0),LandingssiteVector,    green,"Landings-site",1.0,TRUE).
        VECDRAW(v(0,0,0),HorizontalMissVector,  Yellow,"hzMiss",1.0,TRUE).
    }
    brakes on.
    minStopDistance.


    set DirectionVector to          ship:srfprograde:vector*LandingssiteVector:mag.
    set oppositeVector to           (((LandingssiteVector / LandingssiteVector:mag )* 2*DirectionVector:mag) - DirectionVector).
    set HorizontalMissVector to     vxcl(up:vector,(LandingssiteVector-ImpactVector)).

    set EaroguideVector to          -(HorizontalMissVector + LandingssiteTrench).
    DrawEaroGuideVectors.
    if Stopradar < stopDist
    {
        //set EaroguideDone to true.
        print "YOU'RE GONNA DIE!!!!!!!".
        print "YOU'RE GONNA DIE!!!!!!!".
        print "YOU'RE GONNA DIE!!!!!!!".
        print "YOU'RE GONNA DIE!!!!!!!".
        print "YOU'RE GONNA DIE!!!!!!!".
    }
    
    lock steering to EaroguideVector.
}

Function SuicideBurn
{

}

Function ReturnBooster
{
    Configure.
    wait 1.
    until BBdone = true
    {    
        Boostback.
    }
    until EaroguideDone = true
    {
        Earoguide.
    }
}



    ReturnBooster.


