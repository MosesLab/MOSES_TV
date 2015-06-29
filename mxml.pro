;+
;NAME:
;  tagtext
;PURPOSE:
;  Extract text from an XML DOM element based on *first* occurrence
;  of a tag of a specified name.
;CALLING SEQUENCE:
;  result = foo->tagtext(tagname)
;INPUTS:
;  foo --- Object of class IDLffXMLDOMELEMENT.
;  tagname --- name of tag (plain text)
;OUTPUTS:
;  result --- plain text enclosed within the tags.
;EXAMPLE:
;  See mxml.pro
;HISTORY:
;  2005-Jul-23 CCK
;-
function IDLffXMLDOMELEMENT::tagtext, tagname

oFooList = self->GetElementsByTagName(tagname)
oFoo = oFooList->Item(0)
oFooChild = oFoo->GetFirstChild()
result = oFooChild->GetNodeValue()

return, result
end


;+
;NAME:
;  MXML
;PURPOSE:
;  Parser for the MOSES XML log file. Returns a structure containing
;  all the parsed log entries.
;CALLING SEQUENCE:
;  index = MXML( [, xfile [, directory]] )
;  index = MXML( xfile, curdir() )
;***WARNING***
;  IDL 6.1 bug in Mac OS X:
;  IDL's XML parser has problems working with the current working
;  directory. If you need to get a file from the current directory,
;  use curdir() as the second argument so that the pathname will be 
;  fully qualified.
;OUTPUT:
;  index --- A structure containing the index data. Not all tags
;     are supported. See the source code to see what's available,
;     or do a "help, index, /struct". Each index gives you an array
;     with as many elements as there are image files, similar to
;     index arrays in SolarSoft.
;INPUTS:
;  directory --- where the XML file lives. If not supplied, then
;     xfile is assumed to be a fully qualified path. See WARNING above.
;  xfile --- name of XML log file. Default is "imageindex.xml".
;KEYWORDS:
;  verbose --- if set, MXML prints a table of all parsed elements.
;DEPENDENCIES:
;  MOSES_READ --- reads raw MOSES image data.
;MODIFICATION HISTORY:
;  2005-Jul-22 CCK
;-
function mxml, xfile, directory, verbose=verbose

filename = xfile
if n_elements(directory) ne 0 then $
   filename = directory + "/" + xfile

;Parse the XML file, recover list of exposures.
oDocument = obj_new('IDLffXMLDOMDocument')

repeat begin

oDocument->Load, FILENAME=filename, /exclude_ignorable_whitespace
oLog = oDocument->GetFirstChild() 	;The root element of the XML file
oExposureList = oLog->GetElementsByTagName('ROEIMAGE')				;loop waits until image is detected
N = oExposureList->GetLength()   	;Number of exposure records
wait, 0.5
;print, "number of exposures found: "+string(N)

endrep until N gt 0

;Create the index structure that will be returned.
index = {filename:replicate('<empty>',N),   $
             date:replicate('<empty>',N),   $
             time:replicate('<empty>',N),   $
          seqname:replicate('<empty>',N),   $
          exptime:fltarr(N),   $
         chansize:lonarr(N,4) }


;var = oExposureList->Item(0)
;print, var->tagtext('FILENAME')
;wait, 10

for i=0, N-1 do begin
   oExp = oExposureList->Item(i) ;Record for the last exposure
   index.filename[i] = oExp->tagtext('FILENAME')           ;Filename
   index.seqname[i] = oExp->tagtext('NAME')                ;Sequence/image name
   index.time[i] = oExp->tagtext('TIME')                   ;Time
   index.date[i] = oExp->tagtext('DATE')                   ;Date
   index.exptime[i] = float( oExp->tagtext('DURATION') )   ;Exposure Duration

   ;Channel size is encoded with channel number as an attribute, so...
   oChanSizeList = oExp->GetElementsByTagName('CHANNEL_SIZE')
   Nchan = oChanSizeList->GetLength()   ;Number of channels
   for j=0,Nchan-1 do begin
      oChanSize = oChanSizeList->Item(j)
      channel = fix( oChanSize->GetAttribute("ch") )
      oChanSizeChild = oChanSize->GetFirstChild()
      index.chansize[i,channel] = long( oChanSizeChild->GetNodeValue() )
   endfor
   
   if keyword_set(verbose) then begin
      print,'---------------------------------------------------------'
      print, index.filename[i],',   ',index.date[i],',   ',index.time[i]
      print, "exposure time:          ",index.exptime[i]
      print, "channel sizes 0/1/2/3:  ",reform(index.chansize[i,*])
   endif
   
endfor

;print, "done displaying images;"

return, index


end
