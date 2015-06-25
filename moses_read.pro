;NAME:
;  MOSES_READ
;PURPOSE:
;  Read .roe files from MOSES, as written by MSSL's EGSE computer. Orientation
;  of image[i,j] is in detector plane, facing detector from secondary mirror 
;  with connectors up:
;     increasing first index, i:   payload +y
;     increasing second index, j:  payload +z
;  These are focal plane coordinates, not plane-of-sky coordinates! 
;  If a dark image file is specified, then dark subtraction is done auto-
;  matically.
;CALLING SEQUENCE:
;  moses_read, filename, minus, zero, plus, noise [, dark=dark]
;     [, /byteorder] [, /auto] [sizes=sizes] [error=error]
;INPUTS:
;  filename --- name of .roe file, including extension.
;OUTPUTS:
;  minus, zero, plus --- images from the 3 detector orders.
;  noise --- image from the zeroth channel, which contains only read noise.
;OPTIONAL KEYWORD INPUTS:
;  dark --- filename of a dark image. If given, then dark subtraction is
;     done automatically.
;  byteorder --- if set, then switch byte order. This helps when reading
;     data written by the Windows EGSE on a Mac (or Linux?) machine.
;  auto --- if set, attempt to get the byte order right automatically.
;     This somewhat experimental feature is intended to make moses_read
;     completely platform independent. If auto is set, then the byteorder
;     keyword is superseded and may come back modified.
;  sizes --- 4-element long integer array containing the number of pixels
;     stored in channels 0, 1, 2 and 3.
;  directory --- a string to prepend to the filename.
;OPTIONAL KEYWORD OUTPUTS:
;  error --- value of the error keyword from openr. Nonzero is an error.
;HISTORY:
;  2005-Mar-15 CCK, based on MARF.PRO by RJT.
;  2005-Jul-24 CCK, SIZES keyword to handle incomplete data transfers.
;  2005-Nov-19 CCK, trap for nonexistent file; added ERROR keyword.
;  2005-Nov-30 CCK, trap for missing ('noise') channel 0,
;     trap for possible leading '/mdata/' in filename, and added
;     optional directory keyword.

pro moses_read,filename,m,z,p,n, dark=dark, byteorder=byteorder, $
   auto=auto, sizes=sizes, error=error, directory=directory


if keyword_set(auto) then begin
   ;This assumes the .roe file was written by the Windows EGSE, which
   ;shares the same architecture as most Linux boxes but differes from
   ;the Macintosh, which has the opposite order for the bytes in a
   ;16-bit word.
   if (!version.arch eq "ppc") then byteorder=1 else byteorder=0
endif


;Read the raw data into unsigned integer (16 bit) arrays, sized
;to account for the number of pixels actually obtained in each
;channel according to the size keyword.
if n_elements(sizes) ne 4 then sizes = replicate(2097152L,4)
if sizes[0] ne 0 then n_read = uintarr(sizes[0])
m_read = uintarr(sizes[1])
z_read = uintarr(sizes[2])
p_read = uintarr(sizes[3])
if n_elements(directory) eq 0 then directory=""

;Open the file for reading.
openr,1,directory+"/"+filename, error = error
if error ne 0 then begin
   ;Might need to strip leading /mdata/ from filename.
   filename2 = strmid(filename, 7)
   message,"Can't find "+directory+"/"+filename+"; trying "+filename2, $
      /informational
   openr,1,directory+filename2, error = error
   if error eq 0 then filename=filename2
endif
if error eq 0 then begin
   if sizes[0] ne 0 then readu,1,n_read,m_read,z_read,p_read $
      else readu,1, m_read,z_read,p_read
   close,1
   ;Now reformat the data into image arrays
   n = uintarr(2048,1024) & m=n & z=n & p=n
   if sizes[0] ne 0 then n[0:sizes[0]-1] = n_read
   m[0:sizes[1]-1] = m_read
   z[0:sizes[2]-1] = z_read
   p[0:sizes[3]-1] = p_read

   ;Save memory space
   n_read=0
   m_read=0
   z_read=0
   p_read=0

   if keyword_set(byteorder) then begin
      if sizes[0] ne 0 then byteorder,n
      byteorder,m
      byteorder,z
      byteorder,p
   endif

   ;Our data occupies the lower 14 bits of the 16-bit word.
   ;Mask out the channel addresses, which occupy the leading two bits.
   if sizes[0] ne 0 then n = n AND '3FFF'X
   m = m AND '3FFF'X
   z = z AND '3FFF'X
   p = p AND '3FFF'X

   if keyword_set(dark) then begin
      message,"DARK keyword needs rethinking. Sorry."
      ;Read the raw dark data into unsigned integers (16 bits)
      nd = uintarr(2048,1024) & md=nd & zd=nd & pd=nd
      openr,1,dark
      readu,1,nd,md,zd,pd
      close,1

      if keyword_set(byteorder) then begin
         byteorder,nd
         byteorder,md
         byteorder,zd
         byteorder,pd
      endif

      ;Our data occupies the lower 14 bits of the 16-bit word.
      ;Mask out the channel addresses, which occupy the leading two bits.
      nd = nd AND '3FFF'X
      md = md AND '3FFF'X
      zd = zd AND '3FFF'X
      pd = pd AND '3FFF'X

      ;Perform dark subtraction
      n = long(n) - nd
      m = long(m) - md
      z = long(z) - zd
      p = long(p) - pd

   endif

   m = long(rotate(m,2))   ; View of detector face with connectors up
   z = long(rotate(z,2))
   p = long(rotate(p,2))
endif else begin
   ;file not valid
   print,"Read error = ",error
   m=0
   z=0
   p=0
   n=0
endelse


end
