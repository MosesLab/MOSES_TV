;+
;NAME:
;  MTV
;PURPOSE:
;  Display images from a MOSES exposure, with all 3 orders on the same screen, 
;  some image statistics, and useful info from the log file.
;CALLING SEQUENCE:
;  mtv, index, number, byteorder=byteorder
;INPUTS:
;  index --- exposure index structure from mxml().
;  number --- desired image number from the index.
;OPTIONAL KEYWORD INPUTS:
;  directory --- string to prepend to filename.
;  histeq --- hist_equal the display instead of tvscl.
;  sqrt --- square root scale
;MODIFICATION HISTORY:
;  Written by CCK, Summer 2005
;  2005-Nov-30 CCK added directory keyword.
;-
pro mtv, index, number, byteorder=byteorder, directory=directory, $
   histeq=histeq, gamma=gamma

!p.charsize=2
sizes = index.chansize[number,*]


moses_read, index.filename[number], minus, zero, plus, noise, $
   sizes=sizes, byteorder=byteorder, error=error, directory=directory

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;added the following for debug:
gamma=1

;Make the big window, and put it in a good place.
window, 13, xpos=10, ypos=30, xsize=1024, ysize=640, $
   title='<MTV>------- M O S E S -------<MTV>'

if error eq 0 then begin
   if keyword_set(histeq) then begin
      ;Resize and scale images for display
      zd = rebin(hist_equal(zero), 1024, 512)
      md = rebin(hist_equal(minus), 256, 128)
      pd = rebin(hist_equal(plus),  256, 128)
      nd = rebin(bytscl(noise), 256, 128) ;noise is always bytscl'd.  
   endif else begin
      ;Resize and scale images for display
      zd = rebin(bytscl(zero^gamma), 1024, 512)
      md = rebin(bytscl(minus^gamma), 256, 128)
      pd = rebin(bytscl(plus^gamma),  256, 128)
      nd = rebin(bytscl(noise^gamma), 256, 128)
   endelse
   
   ;Display images
   tv, zd, 0,128
   tv, md, 256,0
   tv, pd, 512,0
   tv, nd, 768,0

   ;Create & display histogram
   hist_z = histogram(zero,  Nbins=256, min=0, max=16383)
   hist_m = histogram(minus, Nbins=256, min=0, max=16383)
   hist_p = histogram(plus,  Nbins=256, min=0, max=16383)
   kcounts = findgen(256) * (16384/256)/1000

   plot, kcounts, hist_m, /noerase, linestyle=1, /ylog, $
      /device, position = [20,20, 255,127], charsize=1, $
      xrange=[0,16384]/1000, yrange=[1,max(hist_m)], /xstyle
   oplot, kcounts, hist_p, linestyle=2
   oplot, kcounts, hist_z


   ;Saturated pixel count:
   ss = where(zero ge 16383)
   if (ss[0] eq -1) then sat=0 else sat = n_elements(ss)
   sat_z = strcompress('#sat: '+string(sat))

   ss = where(minus ge 16383)
   if (ss[0] eq -1) then sat=0 else sat = n_elements(ss)
   sat_m = strcompress('#sat: '+string(sat))

   ss = where(plus ge 16383)
   if (ss[0] eq -1) then sat=0 else sat = n_elements(ss)
   sat_p = strcompress('#sat: '+string(sat))

   ss = where(noise ge 16383)
   if (ss[0] eq -1) then sat=0 else sat = n_elements(ss)
   sat_n = strcompress('#sat: '+string(sat))


   ;Display annotations
   left = 0.0
   right = 1.0
   center = 0.5

   ;Saturated pixel count in LL corner of each image
   xyouts, 2,135, sat_z, align=left, /device
   xyouts, 257,2, sat_m, align=left, /device
   xyouts, 514,2, sat_p, align=left, /device
   xyouts, 770,2, sat_n, align=left, /device

   ;Channel label, LR corner of each image
   xyouts, 1021,135, "m = 0",  align=right, /device
   xyouts, 509,2,    "m = -1", align=right, /device
   xyouts, 765,2,    "m = +1", align=right, /device
   xyouts, 1021,2,   "noise",  align=right, /device

   ;Date, time, filename, exp time at top
   xyouts, 2,620, index.date[number]+" "+index.time[number], $
      align=left, /device
   xyouts, 512,620, index.filename[number], align=center, /device
   duration_string = strcompress("exp time: "+string(index.exptime[number]))
   xyouts, 1021,620, duration_string, align=right, /device

endif else begin
   ;Display file not found error
   mesg = "IMAGE "+string(number)+" NOT FOUND: "+index.filename[number]
   if n_elements(directory) ne 0 then mesg=mesg+" in directory "+directory
   xyouts,10,10,mesg, /device
endelse

end
