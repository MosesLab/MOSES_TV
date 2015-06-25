;NAME:
;  MTV_CUBE
;PURPOSE:
;  Load up the entire raw data cubes associated with a particular index file.
;CALLING SEQUENCE:
;  cube = MTV_CUBE([, directory [, xfile]] [, minus=minus] [, zero=zero] [, plus=plus])
;OPTIONAL INPUTS:
;  directory --- where the images and XML file live. If not
;     supplied, the current working directory is used.
;  xfile --- (optional) name of XML log file. Path should be relative
;     to the supplied directory. Default = moses.xml
;OPTIONAL INPUT KEYWORDS:
;  byteorder --- as conventionally used by IDL. default 0.
;OPTIONAL OUTPUT KEYWORDS:
;  minus, zero, plus, noise --- data cubes for each of the 4 MOSES channels. They are
;     optional, but why would you run this code if not to use them??
;  log --- index structure
;DEPENDENCIES:
;  MTV --- image display program
;  MXML --- parses XML log file.
;MODIFICATION HISTORY:
;  2015-Apr-28 CCK based on MTV_BROWSE.
pro mtv_cube, directory, xfile, minus=minus, plus=plus, zero=zero, noise=noise, $
   log=log, byteorder=byteorder

if not keyword_set(byteorder) then byteorder = 0
if n_elements(directory) eq 0 then directory = curdir()
if n_elements(xfile) eq 0 then xfile="imageindex.xml"

log = mxml(xfile, directory)
N = n_elements(log.filename)
print, N,' exposures indexed.',log.filename[N-1]

;Data storage:
minus = intarr(2048,1024,N)
plus  = intarr(2048,1024,N)
zero  = intarr(2048,1024,N)
noise = intarr(2048,1024,N)

;Read in all the data:
!p.charsize=2
for i=0, N-1 do begin
   sizes = log.chansize[i,*]
   moses_read, log.filename[i], m, z, p, n, $
      sizes=sizes, byteorder=byteorder, error=error, directory=directory
   minus[*,*,i] = m
   plus[*,*,i] = p
   zero[*,*,i] = z
   noise[*,*,i] = n
endfor

end