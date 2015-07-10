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
pro idl_compiler

resolve_routine, 'moses_read'
resolve_routine, 'mxml', /IS_FUNCTION
resolve_routine, 'mtv'
;resolve_routine, 'mtv_browse'
;resolve_routine, 'mtv_cube'
resolve_routine, 'mtv_egse'

mtv_egse

end
