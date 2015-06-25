This altered version of mtv_egse.pro is called by receiveTM.c during startup in a new terminal window.
It will wait for any new xml files in the directory: "/media/moses/Data/TM_data/" and will open any images catalogued therein.

Closing the newly-opened IDL window WILL NOT close receiveTM.
Closing receiveTM WILL also close the instance of mtv_egse.
# MTV_EGSE
