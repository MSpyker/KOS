//Maurits Spijker
//program takes vehicle to given altitude
//parameters: prefered altitude, quantity of sideboosters

//startstatus
clearscreen.
set StatusSet to 0.
parameter Pref_Apoapsis.
parameter sideboosters.

//functions
function doSafeStage
{
    wait until stage:ready.
    stage.
}

function liftoff
{
    set throttle to 1.
    lock steering to up.

    wait 1.

    HUDTEXT("Ignition", 2, 2, 20, white, false).

    doSafeStage.
    doSafeStage.
}

function SetKnownState                                                                  
{
    if StatusSet = 0
    {
        print "parameters set.".
        SAS off.
        RCS off.
        set throttle to 0.
        set totalStages to Stage:number.
        set StartAltidtude to ship:altitude.
        set TurnAltitude to 100.
        set pitch to 90.

        liftoff.
        set StatusSet to 1.
    }
}

function info_Fuel_in_stage
{
    FOR item IN STAGE:RESOURCES 
    {
        IF item:NAME = "LiquidFuel" 
        {
            set Fuel_tanks TO item.
        }
    }
    set Fuel_tanks_Amount to Fuel_tanks:AMOUNT.
    set Fuel_tanks_capacity to Fuel_tanks:CAPACITY.
    if Fuel_tanks_capacity > 0
    { 
        set Fuel_tanks_percent to (Fuel_tanks_Amount/Fuel_tanks_capacity *100).
    }
    else
    {
        HUDTEXT("SENSOR ERROR!", 1, 5, 20, RED, false).
    }
}

//perform gravityturn at 100 m/s
function gravityturn                                                
{
    
    SET Meter_per_Angle to ((Pref_Apoapsis - StartAltidtude)/90).               //gives meter(altitude) per degree(pitch)

    if Apoapsis > TurnAltitude
    {
        set steering to heading (90, pitch).
        set TurnAltitude to (TurnAltitude + Meter_per_Angle).      
        set pitch to (pitch - 1).
    }
}

function EarodynamicInfo
{   
    if Altitude < 43000                                                                 
    {
        set Airpressure to (1 - 2.25577 * 10^(-5)*(Altitude))^(5.25588).
    }
    else
    {
        set Airpressure to 0.
    }
    
}

function ThrustInfo
{
    LIST ENGINES IN MyShip.
    FOR engine IN MyShip 
    {
        set CurrentThrust to engine:thrust.
    }
    set Shipmass to ship:mass.
    set g to constant:g * body:mass / body:radius^2. 
    set TWR to (CurrentThrust)/(Shipmass*g).
    set AvailableThrust to ship:AvailableThrust.
    set TWR to (CurrentThrust)/(Shipmass*g).
}

function speedcontrol
{   
    EarodynamicInfo.
    ThrustInfo.
    set minimalTWR      to 1.25.
    set IncreaseTWR     to (0.8-Airpressure).
    set PreferedTWR     to minimalTWR + IncreaseTWR.
    //
    // TWR = Currentthust/(shipmass*g) --> Currentthust =  (shipmass*g) * PreferedTWR
    // Throttlevalve [0 <-> 1] = (availableThrust/Currentthrust)
    //
    set PreferedThrust  to ((shipmass*g)*PreferedTWR).
    set Throttlevalve   to (PreferedThrust)/(AvailableThrust).
    
    if airspeed > 100 and Airpressure > 0.01
    {
        set throttle to Throttlevalve.
    }
    if Airpressure < 0.01
    {
        set throttle to 1.
    }
}

function decouple
{
   
    if Fuel_tanks_percent < 35 and (stage:number >= (TotalStages - (3 + sideboosters)))
    {
        HUDTEXT("DECOUPLING", 1, 5, 20, white, false).
        lock throttle to 0.
        wait 1.
        doSafeStage.
        wait 1.
        doSafeStage.
        lock throttle to 1.
    }
    
}

function InflightInfo
{
    speedcontrol.
    ThrustInfo.
    print "|      SPYKERX      |"                                                   at (0,0). 

    print "Target Apoapsis:     " + round(Pref_Apoapsis,2)                          at (0,2).
    print "Current Apoapsis:    " + round(ship:Apoapsis,2)                          at (0,3).

    print "Air pressure:        " + round(Airpressure,3) + " ATM"                   at (0,5).
    print "Velocity:            " + round(ship:airspeed) + " m\s"                   at (0,6).
    if airspeed > 103
    {
    print "Throttle:            " + round(Throttlevalve*100,2) +  " percent"        at (0,7).
    }
    print "Prefered TWR:        " + round(PreferedTWR,2)                            at (0,8).
    print "Current TWR:         " + round(TWR,2)                                    at (0,9).
}

//main loop
until Ship:Apoapsis > Pref_Apoapsis
{
    SetKnownState.
    info_Fuel_in_stage.
    gravityturn.
    EarodynamicInfo.
    ThrustInfo.
    speedcontrol.
    decouple.
    InflightInfo.
}

//end
lock throttle to 0.
HUDTEXT("APOAPSIS REACHED", 1, 5, 20, white, false).
run circularize.ks.