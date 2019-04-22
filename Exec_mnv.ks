//Maurits Spijker
//executets any given manouver.
//parameters: *Existing manouver node*

//startstatus
clearscreen.
set mnv to Nextnode.

//functions
function calculateStartTime 
{
  parameter mnv.
  return time:seconds + mnv:eta - maneuverBurnTime(mnv) / 2.
}

function maneuverBurnTime 
{
  parameter mnv.
  local dV is mnv:deltaV:mag.
  lock g0 to constant:g * body:mass / body:radius^2.
  local isp is 0.

  list engines in myEngines.
  for en in myEngines 
  {
    if en:ignition and not en:flameout 
    {
      set isp to isp + (en:isp * (en:availableThrust / ship:availableThrust)).
    }
  }

  local mf is ship:mass / constant():e^(dV / (isp * g0)).
  local fuelFlow is ship:availableThrust / (isp * g0).
  local t is (ship:mass - mf) / fuelFlow.

  return t.
}

function isManeuverComplete 
{ 
  parameter mnv.
  print round(mnv:DeltaV:mag,2) at (0,1).
  if mnv:DeltaV:mag < 1
  {
    print "Maneuver complete" at (0,3).
    return true.
  }
  return false.
}

function removeManeuverFromFlightPlan 
{
  parameter mnv.
  remove mnv.
}

print "Waiting for burn" at (5, 5).

//calculates duration of 'timewarp'
local startTime is calculateStartTime(mnv). 
local TimeToBurn is ((startTime) - (time:seconds)).
warpto((time:seconds) + TimeToBurn - 15).

//main loop
until isManeuverComplete(mnv)
{   
    local TimeToBurn is ((startTime) - (time:seconds)).
    print "Time untill burn: " + round(TimeToBurn) + " seconds" at (5,8). 
    SAS off.
    lock steering to mnv:burnvector.
    if TimeToBurn < 0
    {
        lock throttle to 1.
    }
}

//end
print"done".
lock throttle to 0.
unlock steering.
removeManeuverFromFlightPlan(mnv).