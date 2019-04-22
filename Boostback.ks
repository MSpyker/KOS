//Maurits Spijker
//Changes the direction of the vessel so that it will crash at the KSC
//parameters: none

//startstatus
clearscreen.
RCS on.
SAS off.
set BBdone to 0.

print "BOOSTBACKSCRIPT      SpykerX-technologies" at (0,0).
FUNCTION BB_ETA_ALT //!!STOLEN FROM REDDIT
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

FUNCTION BB_Impact_data //!!STOLEN FROM REDDIT
{
	LOCAL currentPosition IS positionat(ship, time:seconds).

	SET impact_time TO BB_ETA_ALT.
	LOCAL impact_pos IS body:geopositionof(positionat(ship, time:seconds + impact_time) - currentPosition).
	LOCAL impact_lng IS impact_pos:lng - 360 / body:rotationperiod * impact_time.
	LOCAL impact_location IS latlng(impact_pos:lat, impact_lng).

	set ImpactVector to impact_location:ALTITUDEPOSITION(impact_location:TERRAINHEIGHT).
} 

Function BB_landingssiteInfo
{
  declare global launchpad to LATLNG(-0.09696635151219,-74.5435243923809).                                   // Location of launchpad
  set launchpadvector to launchpad:ALTITUDEPOSITION(launchpad:TERRAINHEIGHT).                                // Vector above launchpad
}

function Compare_BBVector 
{
  //Checks if you're chrashing near landings site.
  set DifferenceVector to 100*((Launchpadvector/Launchpadvector:mag)-(ImpactVector/ImpactVector:mag)).
  set Difference to DifferenceVector:mag.
  print "Angle between vectors:     " + round(Difference,2) at (0,2).
  
  //Check if you're pointing to landings site.
  set pointVector to ship:facing:forevector*100.
  set DifferenceHeading to ((DifferenceVector/DifferenceVector:mag)-(pointVector/pointVector:mag)).
  print "Misalignment in vectors:   " + round(DifferenceHeading:mag,2) at (0,4).
  if DifferenceHeading:mag<0.25 
  {set correctHeading to "true".}
  else
  {set correctHeading to "false".lock steering to DifferenceVector.}
}

function DrawBBVector
{
  Clearvecdraws().
	VECDRAW(v(0,0,0),ImpactVector,red,"Impact",1.0,TRUE).
  VECDRAW(v(0,0,0),pointVector,blue,"Pointing",1.0,TRUE).
  VECDRAW(v(0,0,0),Launchpadvector,green,"Landings-site",1.0,TRUE).
  VECDRAW(v(0,0,0),DifferenceVector,white,"Difference",1.0,TRUE).
}

function BBtoLS
{
  lock steering to DifferenceVector.
  until Difference < 0.50
  {
    BB_ETA_ALT.
    BB_Impact_data.
    BB_landingssiteInfo.
    Compare_BBVector.
    DrawBBVector.
    if correctHeading = "true"
    {
      lock throttle to 1.
    } 
    else
    {
      unlock throttle.
    }
    
  }
  unlock throttle.
  unlock steering.
  set BBdone to 1.
  run guide.
  
}

until BBdone = 1
{
	BB_ETA_ALT.
	BB_Impact_data.
	BB_landingssiteInfo.
  Compare_BBVector.
  DrawBBVector.
  BBtoLS.

}