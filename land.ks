//Maurits Spijker
//Changes the direction of the vessel so that it will crash at the KSC
//parameters: none

//startstatus
clearscreen.
print "LANDINGSSCRIPT				SpykerX-technologies" at (0,0).

function Mainland
{
	StartState.
	UpdateLandInfo2.
	GetVectors2.
	DrawVectors2.
	PerformSuicideBurn.
	HoverDown.
	SafeState.
	LogInfo.
}

function StartState
{
	sas off.
	rcs on.
	brakes off.
	//toggle brakes.
}

function GetVectors2
{
  declare global launchpad to LATLNG(-0.09696635151219,-74.5435243923809).                                            	// Location of launchpad
  set spot TO SHIP:GEOPOSITION.                                                                                          	// Location underneath the ship

  set launchpadvector to launchpad:ALTITUDEPOSITION(launchpad:TERRAINHEIGHT+70).                                          	// Vector to launchpad
  declare global g to constant:g * body:mass / body:radius^2.			                                                    // Gravity (m/s^2)
  set gravityVector to ship:up:vector*10.                                                                                   // Vector of gravity(kerbin) 
  set DirectionVector to (ship:srfprograde:vector*airspeed).                                                             	// ProgradeVector
  set PathDirectionVector to DirectionVector + gravityVector.                                                            	// Direction ship relative to kerbin / Where the ship is falling towards
  set RealPathVector to (PathDirectionVector / PathDirectionVector:mag)*launchpadvector:mag.
  set oppositeVector to (((Launchpadvector / Launchpadvector:mag )* 2*RealPathVector:mag) - RealPathVector).             	// Calculates the opposite vector relative to the launchpadvector. Using bissectrice formula
  set Groundcorrectionvector to (Launchpadvector:normalized-RealPathVector:normalized).                                   	// Calculates by how much the fallingpath will miss the launchpad
  set CheckVector to ((RealPathVector * oppositeVector:Mag)+(oppositeVector * RealPathVector:mag)).                       	// makes sure that oppositeVector and RealPathVector make a bissectrice that looks like LaunchpadVector
  
  set spot to SHIP:BODY:GEOPOSITIONOF(ship:position+((RealPathVector/RealPathVector:mag)*Alt:radar) ).               		// stretches Realpathvector to ground and makes GeoLoc. underneath it
  set spotVector to spot:ALTITUDEPOSITION(spot:TERRAINHEIGHT+10).                                                         	// makes a vector to Spot

  set undershootVector to launchpadvector - spotVector.                                                                		// makes sure that when pointing retrograde, ship will land at Launchpad
  set PointVector to (oppositeVector) + 5*(undershootvector).                                                               // Vector the ship must point to, to hit the launchpad

  set LandVector to DirectionVector + (-1.2*undershootvector).
	set HoverVector to up:vector*alt:radar + (0.5*undershootvector).
}

function DrawVectors2
{
  Clearvecdraws().
	VECDRAW(v(0,0,0),Hovervector,grey,"Hoverdown",1.0,TRUE).

  VECDRAW(v(0,0,0),LandVector,grey,"landvector",1.0,TRUE).

  VECDRAW(v(0,0,0),launchpadvector,red,"launchpad",1.0,TRUE).
}

function UpdateLandInfo2
{
	GetVectors2.
	set Hoverheight to 50.
	
	lock stopRadar to alt:radar - Hoverheight.																// Offset radar to get distance from gear to ground
	lock g to constant:g * body:mass / body:radius^2.													// Gravity (m/s^2)
	lock maxDecel to  (ship:availablethrust) / ship:mass - g.									// Maximum deceleration possible (m/s^2)

	lock stopDist to (ship:verticalspeed^2)/ (2 * maxDecel).									// The distance the burn will require
	lock idealThrottle to (stopDist / stopRadar).															// Throttle required for perfect hoverslam`
	print "trottle is:		" + round(idealThrottle,1) at (0,3).
	lock impactTime to stopRadar / abs(ship:verticalspeed).										// Time until impact, used for landing gear

}

function PerformSuicideBurn
{
	print "1".
	UNTIL stopRadar  < stopDist + 5
	{	
		GetVectors2.
		DrawVectors2.
		UpdateLandInfo2.
		print"performing hoverslam." at (0,9).
		lock steering to -LandVector.
		lock throttle to idealThrottle.
		if impactTime < 3
		{gear on.}
	}
	set InitiateHover to "true".
}

function HoverDown
{
	if InitiateHover = "true"
	{
		print "2".
		until ship:status = "landed"
		{	
			GetVectors2.
			DrawVectors2.
			lock steering to HoverVector.
			
			if ship:verticalspeed > -25
			{
				declare global acceleration to (throttle * ship:availablethrust) / ship:mass.

				if ship:verticalspeed > -5  
				{
					set throttle to (throttle - 0.15).
					print "             " at (12,20).
					print "throttle down" at (12,20).
				}

				if ship:verticalspeed < -3
				{
					set throttle to (throttle + 0.15).
					print "             " at (12,20).
					print "throttle up" at (12,20).
				}
			}
		}
		SET SHIP:CONTROL:PILOTMainTHROTTLE TO 0.
	}
}

function SafeState
{
	if ship:status = "landed"
	{
		RCS off.
		SAS off.
		unlock all.
		wait 1.
		lock steering to up.
		SET SHIP:CONTROL:PILOTMainTHROTTLE TO 0.
		shutdown.
	}
}
function LogInfo
{
	HUDtext("Landing Programm started", 4, 2, 20, white, false).
	print "Distance to ground:		" + round(alt:RADAR) + "	meters" at (0,0).
	print "Time to impact:			" + round(impactTime) + "	seconds" at (0,1).

	

}

until false
{
	print "running	" at (0,7).
	
	Mainland.
}
SET SHIP:CONTROL:PILOTMainTHROTTLE TO 0.