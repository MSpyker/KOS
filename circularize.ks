//Maurits Spijker
//Program finds and creates a manouver node at a given apoapsis
//parameters: none

//startstatus
clearscreen.
global PerfectDeltaV is 1. //temporary to allow maneuver
if defined mnv { remove mnv. }

//main loop --> one of my first scripts, hence the lack of functions.
until false
{  
    lock steering to srfprograde.
    wait until altitude > 60000.
    global mnv is node(time:seconds + ETA:apoapsis, 0, 0, PerfectDeltaV).
    
    add mnv.
    wait 0.01.

    set difference to (apoapsis - (mnv:orbit:periapsis)).

    if round(mnv:orbit:apoapsis,3) <= round(apoapsis+10,3)
    {
        
        if difference > (apoapsis/0.5) 
        {
            set dVfactor to 100.
            print "dVfactor is " + dVfactor at (5,12).
        }

        if difference <  (apoapsis/0.5) and difference >  (apoapsis/6)
        {
            set dVfactor to 25.
            print "                         " + dVfactor at (5,12).
            print "dVfactor is " + dVfactor at (5,12).
        }

        if difference <  (apoapsis/0.75) and difference >  (apoapsis/25)
        {
            set dVfactor to 10.
            print "                         " + dVfactor at (5,12).
            print "dVfactor is " + dVfactor at (5,12).
        }

        if difference <  (apoapsis/2) and difference >  (apoapsis/1.25)
        {
            set dVfactor to 1.
            print "                         " + dVfactor at (5,12).
            print "dVfactor is " + dVfactor at (5,12).
        }

        if difference <  (apoapsis/5)
        {
            set dVfactor to 0.075.
            print "                         " + dVfactor at (5,12).
            print "dVfactor is " + dVfactor at (5,12).
        }


        set PerfectDeltaV to (PerfectDeltaV + dVfactor).
        print "adding DeltaV" at (5, 5).
    }
    
    else
    {   
        print "found it!" at (5, 2).
        print "             " at (5, 5).
        break.
    }
    
    
    print "Perfect deltaV is " + round(PerfectDeltaV) at (5,6).

    remove mnv.
    
}
wait 0.1.
runpath("0:/Exec_mnv.ks").
    