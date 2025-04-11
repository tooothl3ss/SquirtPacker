# TODO: Implement this module
import pe_types, dos_stub, pe_readers, utils


# Rewrite a DOSStub 
proc updateSectionHeader*(fileStream: File, header:ImageSectionHeader, offset:int) =
  fileStream.setFilePos(offset)
  var arr: seq[byte] = newSeq[byte](sizeof(header))
  for fName, fieldValue in header.fieldPairs:
   echo fieldValue 
  #discard fileStream.writeBuffer(header, sizeof(header))