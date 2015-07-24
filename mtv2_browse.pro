;+
;NAME:
;  MTV2_BROWSE
;PURPOSE:
;  Science telemetry browser (MTV_browse) Provides the ability to step through 
;  image data from the MOSES rocket payload. The image log (XML) format is read,
;  and the most recent image is loaded first. Keyboard is used to interactively
;  step through the images in the XML catalog. The keystroke menu is
;  displayed in the terminal window:
;     [S]up  [X]down [A]top [Z]bottom [B]byteorder [Q]quit
;
;CALLING SEQUENCE:
;  MTV2_BROWSE [, directory [, xfile]]
;INPUTS:
;  directory --- where the images and XML file live. If not
;     supplied, the current working directory is used.
;  xfile --- (optional) name of XML log file. Path should be relative
;     to the supplied directory. Default = moses.xml
;KEYWORDS:
;  byteorder --- as conventionally used by IDL. default 0.
;  histeq --- hist_equal the display instead of tvscl.
;DEPENDENCIES:
;  MTV2 --- image display program
;  MXML2 --- parses XML log file.
;MODIFICATION HISTORY:
;  2005-Jul-22 CCK
;  2005-Nov-30 CCK fixed bug affecting DIRECTORY input.
;  2015-Jul-24 JRR added GS laptop compatibility
;-
pro MTV2_BROWSE, directory, xfile, byteorder=byteorder, histeq=histeq

gamma = 1 ;initialize contrast

if not keyword_set(byteorder) then byteorder = 0
if not keyword_set(histeq) then histeq = 0

if n_elements(directory) eq 0 then directory = '/media/moses/Data/TM_data'
if n_elements(xfile) eq 0 then xfile="imageindex.xml"

log = mxml2(xfile, directory)
N = n_elements(log.filename)
print, N,' exposures indexed.',log.filename[N-1]
i=N-1

quit=0
while(not quit) do begin
   mtv2, log, i, byteorder=byteorder, directory=directory, histeq=histeq, $
      gamma=gamma
   print,'Exposure '+strcompress(string(i))+' '+$
      '[S]up  [X]down [A]top [Z]bottom [B]byteorder [C]color table [<>]gamma [Q]quit'
   key = get_kbrd(1)
   case key of
      's':i = (i-1) > 0
      'S':i = (i-1) > 0
      'x':i = (i+1) < (N-1)
      'X':i = (i+1) < (N-1)
      'a':i = 0
      'A':i = 0
      'z':i = N-1
      'Z':i = N-1
      'b':if(byteorder) then byteorder = 0 else byteorder=1
      'B':if(byteorder) then byteorder = 0 else byteorder=1
      'q':quit=1
      'Q':quit=1
      'h':if(histeq) then histeq=0 else histeq=1
      'H':if(histeq) then histeq=0 else histeq=1      
      'c':xloadct,/block
      'C':xloadct,/block
      '<':begin
         gamma = (gamma - 0.1)  
         print,'gamma = ',gamma
         end
      ',':begin
         gamma = (gamma - 0.1)
         print,'gamma = ',gamma
         end
      '>':begin
         gamma = (gamma + 0.1)
         print,'gamma = ',gamma
         end
      '.':begin
         gamma = (gamma + 0.1)
         print,'gamma = ',gamma
         end
      else:message,'Invalid key. Read the menu!',/informational
   endcase 
endwhile

end
