*********************************************************************
THIS IS NO LONGER THE MASTER COPY OF IDLffXMLDOMELEMENT__tagtext.pro.
Look inside mxml.pro !!!
*********************************************************************


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
