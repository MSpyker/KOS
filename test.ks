clearscreen.
Clearvecdraws().
toggle brakes.
sas off.
rcs on.


function Main
{
  UpdateLandInfo.
  GetVectors.
  DrawVectors.
  Slowdown.
  lock steering to -PointVector.
  InitiateLand.
}

function Slowdown
{
  if airspeed > 400 and altitude < 20000
  {
    set steering to up.
    set throttle to 0.5.
  }
  if airspeed < 300 and altitude < 20000
  {
    unlock steering.
    set throttle to 0.0.
  }

}

function UpdateLandInfo
{
  set LegHeight to 44.63.
  set Hoverheight to 10.
	set radarOffset to LegHeight.				                                                                          // The value of alt:radar when landed (on gear)
	lock stopRadar to alt:radar - (radarOffset + Hoverheight) .					                                          // Offset radar to get distance from gear to ground
	declare global g to constant:g * body:mass / body:radius^2.			                                              // Gravity (m/s^2)
	lock maxDecel to (ship:availablethrust / ship:mass) - g.	                                                    // Maximum deceleration possible (m/s^2)
	lock stopDist to (ship:verticalspeed^2)/ (2 * maxDecel).		                                                  // The distance the burn will require

  print "StopRadar is     "  + stopRadar   at (0,0).
  print "StopDistance is  "  + stopDist    at (0,1).
  print "if StopRadar is Lower then StopDistance, then initiate Landing" at (0,3).
}

Function GetVectors
{
  declare global launchpad to LATLNG(-0.0972092543643722, -74.557706433623).                                              // Location of launchpad
  set spot TO SHIP:GEOPOSITION.                                                                                           // Location underneath the ship

  set launchpadvector to launchpad:ALTITUDEPOSITION(launchpad:TERRAINHEIGHT+50).                                          // Vector to launchpad
  declare global g to constant:g * body:mass / body:radius^2.			                                                        // Gravity (m/s^2)
  set gravityVector to ship:up:vector*10.                                                                                          // Vector of gravity(kerbin) 
  set DirectionVector to (ship:srfprograde:vector*airspeed).                                                              // ProgradeVector
  set PathDirectionVector to DirectionVector + gravityVector.                                                             // Direction ship relative to kerbin / Where the ship is falling towards
  set RealPathVector to (PathDirectionVector / PathDirectionVector:mag)*launchpadvector:mag.
  set oppositeVector to (((Launchpadvector / Launchpadvector:mag )* 2*RealPathVector:mag) - RealPathVector).              // Calculates the opposite vector relative to the launchpadvector. Using bissectrice formula
  set Groundcorrectionvector to (Launchpadvector:normalized-RealPathVector:normalized).                                   // Calculates by how much the fallingpath will miss the launchpad
  set CheckVector to ((RealPathVector * oppositeVector:Mag)+(oppositeVector * RealPathVector:mag)).                       // makes sure that oppositeVector and RealPathVector make a bissectrice that looks like LaunchpadVector
  
  set spot to SHIP:BODY:GEOPOSITIONOF(ship:position+((RealPathVector/RealPathVector:mag)*Alt:radar) ).                // stretches Realpathvector to ground and makes GeoLoc. underneath it
  set spotVector to spot:ALTITUDEPOSITION(spot:TERRAINHEIGHT+50).                                                         // makes a vector to Spot

  set undershootVector to launchpadvector - spotVector.                                                                // makes sure that when pointing retrograde, ship will land at Launchpad
  

  set PointVector to (oppositeVector) + 5*(undershootvector).                                                               // Vector the ship must point to, to hit the launchpad

}

function DrawVectors
{
  Clearvecdraws().

  VECDRAW
    (
      v(0,0,0),
      undershootVector,
      grey,
      "overshoot",
      1.0,
      TRUE  
    ).

  VECDRAW
    (
      v(0,0,0),
      PointVector,
      green,
      "point here",
      1.0,
      TRUE  
    ).

    VECDRAW
    (
      v(0,0,0),
      20*RealPathVector,
      white,
      "going here",
      1.0,
      TRUE 
    ).

    VECDRAW
    (
      v(0,0,0),
      launchpadvector,
      red,
      "launchpad",
      1.0,
      TRUE 
    ).

}

function InitiateLand
{
  if stopRadar < stopDist +100
  {
    print "check".
    run land.
  }
}


until false
{
  main.
}






















// SET VD TO VECDRAWARGS(
//               launchpad:ALTITUDEPOSITION(launchpad:TERRAINHEIGHT+100),
//               launchpad:POSITION - launchpad:ALTITUDEPOSITION(Launchpad:TERRAINHEIGHT+100),
//               red, "THIS IS THE LAUNCHPAD", 1, true).


// print "Moving the arrow up and down for a few seconds.".
// set vd:startupdater to { return ship:up:vector*3*sin(time:seconds*180). }.
// wait 5.
// print "Stopping the arrow movement.".
// set vd:startupdater to DONOTHING.
// wait 3.
// print "Removing the arrow.".
// set vd to 0.












// LIST ENGINES IN SHIP.
// FOR AbortEngineA IN SHIP:PARTSTAGGED("AbortEngineA") 
// {
//    declare global AbortEngineA to AbortEngineA.
//    declare global flameoutA to AbortEngineA:thrust.
// }

// LIST ENGINES IN SHIP.
// FOR AbortEngineB IN SHIP:PARTSTAGGED("AbortEngineB") 
// {
//    declare global AbortEngineB to AbortEngineB.
//    declare global flameoutB to AbortEngineB:thrust.
// }

// LIST ENGINES IN SHIP.
// FOR AbortEngineC IN SHIP:PARTSTAGGED("AbortEngineC") 
// {
//    declare global AbortEngineC to AbortEngineC.
//    declare global flameoutC to AbortEngineC:thrust.
// }

// LIST ENGINES IN SHIP.
// FOR AbortEngineD IN SHIP:PARTSTAGGED("AbortEngineD") 
// {
//    declare global AbortEngineD to AbortEngineD.
//    declare global flameoutD to AbortEngineD:thrust.
// }



// until false
// {
//    print "running" at (0,0).
//    print AbortEngineA:ignition at (0,1).
//    wait 0.1.
//    if AbortEngineA:ignition="false" and AbortEngineA:thrust=0
//    {
      
//    }
// }


























// until false
// {
//   FOR item IN STAGE:RESOURCES 
//     {
//        IF item:NAME = "LiquidFuel" 
//         {
//            declare global Fuel_Stage TO item.
//         }.
//     }.
//      declare global Fuel_Stage_Amount to Fuel_Stage:AMOUNT.
//     declare global Fuel_Stage_capacity TO Fuel_Stage:CAPACITY.
 

//     print Fuel_Stage_capacity at (5,5).
// }


























// clearscreen.
// wait 1.
// function Circularize
// {   
//     until false
//     {   
        
//         if not(defined PerfectDeltaV)
//         {
//             global PerfectDeltaV is 1. //temporairy to allow maneuver
//         }

//         global mnv is node(time:seconds + ETA:apoapsis, 0, 0, PerfectDeltaV).
        
//         add mnv.

//         print "expected apoapsis is        " + round(mnv:orbit:apoapsis) at (5,10).
//         print "apoasis now is              " + round(apoapsis) at (5,11).

//         if round(mnv:orbit:apoapsis) <= round(apoapsis)
//         {
            
//             declare global PerfectDeltaV to (PerfectDeltaV + 0.1).
//             print "adding DeltaV" at (5, 5).
//             print "             " at (5, 5).
//             wait 0.01.
//         }
        
//         else
//         {   
//             print "found it!" at (5, 2).
//             break.
//         }

        
//         print "Perfect deltaV is " + round(PerfectDeltaV) at (5,6).
//         print "expected apoapsis is        " + round(mnv:orbit:apoapsis) at (5,10).
//         print "apoasis now is               " + round(apoapsis) at (5,11).

//         remove mnv.
        
//     }
//     print "Waiting for burn" at (5, 5).

//     local startTime is calculateStartTime(mnv).

//     wait until time:seconds > startTime - 30.

//     lock steering to mnv:burnvector.
//     wait until time:seconds > startTime.
//     lock throttle to 1.
//     until isManeuverComplete(mnv)
//     {

//     }
//     lock throttle to 0.
//     unlock steering.
//     removeManeuverFromFlightPlan(mnv).
// }

// function fPerfectDeltaV
// {
    
    
// }

// function calculateStartTime {
//   parameter mnv.
//   return time:seconds + mnv:eta - maneuverBurnTime(mnv) / 2.
// }

// function maneuverBurnTime {
//   parameter mnv.
//   local dV is mnv:deltaV:mag.
//   lock g0 to constant:g * body:mass / body:radius^2.
//   local isp is 0.

//   list engines in myEngines.
//   for en in myEngines {
//     if en:ignition and not en:flameout {
//       declare global isp to isp + (en:isp * (en:availableThrust / ship:availableThrust)).
//     }
//   }

//   local mf is ship:mass / constant():e^(dV / (isp * g0)).
//   local fuelFlow is ship:availableThrust / (isp * g0).
//   local t is (ship:mass - mf) / fuelFlow.

//   return t.
// }

// function isManeuverComplete {
//   parameter mnv.
//   if not(defined originalVector) or originalVector = -1 {
//     declare global originalVector to mnv:burnvector.
//   }
//   if vang(originalVector, mnv:burnvector) > 90 {
//     declare global originalVector to -1.
//     return true.
//   }
//   return false.
// }

// function removeManeuverFromFlightPlan {
//   parameter mnv.
//   remove mnv.
// }

// Circularize.



































//code by xeger, modified to take alt in kilometers
//https://github.com/xeger/kos-ramp

// // parameter alt.

// // local mu is body:mu.
// // local br is body:radius.

// // // present orbit properties
// // local vom is velocity:orbit:mag.               // actual velocity
// // local r is br + altitude.                      // actual distance to body
// // local ra is br + apoapsis.                     // radius at burn apsis
// // local v1 is sqrt( vom^2 + 2*mu*(1/ra - 1/r) ). // velocity at burn apsis

// // local sma1 is (periapsis + 2*br + apoapsis)/2. // semi major axis present orbit

// // // future orbit properties
// // local r2 is br + apoapsis.               // distance after burn at apoapsis
// // local sma2 is ((alt * 1000) + 2*br + apoapsis)/2. // semi major axis target orbit
// // local v2 is sqrt( vom^2 + (mu * (2/r2 - 2/r + 1/sma1 - 1/sma2 ) ) ).

// // // create node
// // local deltav is v2 - v1.
// // local nd is node(time:seconds + eta:apoapsis, 0, 0, deltav).
// // add nd.

// // lock steering to target.





// // lock g to constant:g * body:mass / body:radius^2.

// // function info_Fuel_in_stage
// // {
// //     FOR item IN STAGE:RESOURCES
// //     {
// //         IF item:NAME = "LiquidFuel"
// //         {
// //             declare global Fuel_Stage to item.
// //         }
// //     }
// //     declare global Fuel_Stage_Amount to Fuel_Stage:AMOUNT.
// //     declare global Fuel_Stage_capacity to Fuel_Stage:CAPACITY.
// // }

// // function doAutostage
// // {
// //     print Fuel_Stage_Amount.
// //     print Fuel_Stage_capacity.
// //     // if Fuel_Stage:Amount < (Fuel_Stage:capacity/2.2) and Stage:NUMBER > 0
// //     // {
// //     //    print "JAAAA".
// //     // }

// //     // if Fuel_Stage_Amount < 1 and Stage:NUMBER = 0
// //     // {
// //     //     HUDTEXT("[FUEL EMPTY]", 60, 4, 40, RED, false).
// //     // }

// // }

// // until false
// // {
// //     doAutostage.
// // }


















// // lock steering to up.
// // until false
// // {
// //     declare global acceleration to (throttle * ship:availablethrust) / ship:mass.
// //     declare global HoverThrottle to (acceleration).

// //     if ship:verticalspeed > 0
// //         {
// //             declare global throttle to (throttle - 0.02).
// //         }

// //     if ship:verticalspeed < 0
// //         {
// //             declare global throttle to (throttle + 0.012).
// //         }

// // }









//  until false

//  {
//      LIST ENGINES IN myVariable.
//      FOR eng IN myVariable
//      {
//          declare global Thrust to eng:THRUST.
//      }
//      //twr = thrust / m g
//      declare global TWR to (Thrust / (ship:mass * g)).

//      if TWR > 2.0
//          {
//              declare global throttle to (throttle - 0.005).
//          }

//      if TWR < 2.0
//          {
//              declare global throttle to (throttle + 0.005).
//          }
//  }







// // parameter PreferedTWR.

// // until false
// // {

// // PreferedTWR to
// // lock g to constant:g * body:mass / body:radius^2.

// // // use equation thrust = twr * mg
// // declare global throttle to PreferedTWR * ship:mass * g.
// // declare global PreferedTWR to 1.
// // print
// // }