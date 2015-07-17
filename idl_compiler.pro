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
resolve_routine, 'mtv_egse', /IS_FUNCTION

result = mtv_egse()

;while(1) do begin

      ;print, result
      ;bar = idl_bailout(stop)

      ;if (bar eq 1) then begin
          ;wdelete, 13
          ;print, 'interrupt detected'
      ;endif

    if (result eq 0) then print, 'MTV window closed...'
    
    ;wait, 0.5

;endwhile

exit
