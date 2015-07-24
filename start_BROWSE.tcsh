#!/bin/tcsh
#
#initializes and starts SSW (via ~/.cshrc)
#needed to initalize

#Catch interrupt to exit gracefully
onintr interrupt

#start idl
cd /media/moses/Data/MTV_EGSE_2
idl "browse_compiler"

#start SSW - (not necessary?)
#idl -e "sswidl" -args 'idl_script'

interrupt:
    #exit procedure
    #'exit'
    echo ""
    #reset
    echo "Remeber to close the mtv display BEFORE this window!"
    echo ""
    

