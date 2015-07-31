;+
;NAME:
;  idl_compiler
;PURPOSE:
;IDL needs to compile each of its procedures before running them
;CALLING SEQUENCE:
;  IDL_COMPILER
;MODIFICATION HISTORY:
;  2015-July-10
;-
pro browse_compiler

resolve_routine, 'moses2_read'
resolve_routine, 'mxml2', /IS_FUNCTION
resolve_routine, 'mtv2'
resolve_routine, 'mtv2_browse'
;resolve_routine, 'mtv2_cube'
;resolve_routine, 'mtv2_egse', /IS_FUNCTION

mtv2_browse

exit
end
