;+
;NAME:
;  MTV2_EGSE
;PURPOSE:
;  Science Telemetry Image Monitor (MTV_EGSE) Provides real-time monitoring 
;  of image data from the MOSES rocket payload. Operationally, the computer
;  running MTV_EGSE would mount the drive of an EGSE computer where the
;  science data is being deposited. The image log (XML) format is read,
;  and the latest available image is displayed with continuous update
;  as long as MTV_EGSE is running. 
;  Added compatibility for GS laptop
;CALLING SEQUENCE:
;  MTV2_EGSE [, directory [, xfile]]
;INPUTS:
;  directory --- where the images and XML file live. If not
;     supplied, the current working directory is used.
;  xfile --- (optional) name of XML log file. Path should be relative
;     to the supplied directory. Default = imageindex.xml
;DEPENDENCIES:
;  MTV2 --- image display program
;  MXML2 --- parses XML log file.
;MODIFICATION HISTORY:
;  2005-Jul-22 CCK
;  2005-Nov-30 CCK fixed bug affecting DIRECTORY input.
;  2015-Jul-24 JRR altered to work automatically with GS laptop
;-

function MTV2_EGSE, directory, xfile, byteorder=byteorder

N_old = 0L
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;changed default path to match EGSE laptop
if n_elements(directory) eq 0 then directory = '/media/moses/Data/TM_data'
if n_elements(xfile) eq 0 then xfile="imageindex.xml"

print, ""
spawn, 'clear'
print, ""
print, "********************************************************"
print, "*                       MOSES TV                       *"
print, "********************************************************"
print, ""
print, "DO NOT close terminal window before MTV display window"
print, ""
print, "Searching for new images in " + directory + "/....."
print, ""

foo = file_search(directory+'/*.roe',count=total_N_old)
window, 13, xpos=10, ypos=30, xsize=2048, ysize=1280, $
   title='<MTV>------- M O S E S -------<MTV>'

while(1) do begin
   ;log = mxml2(xfile, directory)
   ;N = n_elements(log.filename)
   ;print, N
   foo = file_search(directory+'/*.roe',count=total_N)
   if total_N gt total_N_old then begin
      wait, 0.1   
      log = mxml2(xfile, directory)
      N = n_elements(log.filename)
      print, N,' exposures indexed. Displaying latest: ',log.filename[N-1]
      mtv2, log, N-1, byteorder=byteorder, directory=directory
      total_N_old = total_N
      wshow, 13
   endif else begin
      ;check if window has been closed by user:
      device, window_state=check_open
      if check_open[13] eq 0 then return, check_open[13]
      
      ;check if program interrupted by user:
      ;killswitch = uint(IDL_bailout(stop))
      ;if uint(killswitch) eq 1 then wdelete, 13

      ;wait, .5
   endelse
endwhile

end



