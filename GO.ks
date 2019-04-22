//Maurits Spijker
//Initiates program takes vehicle to given altitude
//parameters: prefered altitude, quantity of sideboosters

//startstatus
clearscreen.
parameter givenApoapsis.
parameter sideboosters.
set Mode to 0.

until false
{   
    if Mode = 0
    {
        HUDTEXT("Go for launch", 11.5, 2, 20, white, false).
        set Mode to 1.
        wait 1.
  
        set countdown to 10.
        until countdown = 0
        {   
            HUDTEXT(countdown, 1, 2, 20, white, false).
            set countdown to (countdown -1).
            wait 1.
        }
        
        run launch(givenApoapsis, sideboosters).
    }

    if mode = 1
    {   
        print mode at (0,0).
        HUDTEXT("Launchprogram running", 1, 5, 20, white, false).
    }


}