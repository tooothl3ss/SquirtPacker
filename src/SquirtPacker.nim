import os, streams, strutils, tables
import pe_types, dos_stub, pe_readers, utils

proc main() =
  let filename = paramStr(1)
  if not fileExists(filename):
    echo "File not found: ", filename
    quit(1)

  var fileStream = open(filename, fmReadWriteExisting)
  defer: fileStream.close()

  let dosHeader = readDosHeader(fileStream)
  if dosHeader.e_magic != 0x5A4D:  # 'MZ'
    echo "Invalid file: missing MZ signature"
    quit(1)
  
  echo "DOS Stub: "
  echo readDosStub(fileStream, sizeof(dosHeader), dosHeader.e_lfanew)

  rewriteDosStub(fileStream, sizeof(dosHeader), dosHeader.e_lfanew)

  let optionalHeader = readOptionalHeader(fileStream, dosHeader)
  let imageHeader = readImageHeader(fileStream, dosHeader.e_lfanew + 4)
  echo repeat("=", 8)
  echo "Image Header:"
  for fieldName, fieldValue in imageHeader.fieldPairs:
    echo fieldName, " - ", toHex(fieldValue)
  echo repeat("=", 8)
  
  echo "Optional Header:"
  for fieldName, fieldValue in optionalHeader.fieldPairs:
    echo fieldName, " - ", toHex(fieldValue)
  echo repeat("=", 8)

  # Create a table mapping headers to names.
  var sectionHeaders = initTable[string, ImageSectionHeader]()

  var sectionOffset = 0
  for i in 0..<int(imageHeader.numberOfSections):
    let sectionHeader = readSectionHeader(fileStream, dosHeader.e_lfanew + 24 +
      int(imageHeader.sizeOfOptionalHeader) + sectionOffset)
    sectionOffset += sizeof(sectionHeader)
    sectionHeaders.add(readString(sectionHeader.name), sectionHeader)
    echo "Section Header:"
    for fieldName, fieldValue in sectionHeader.fieldPairs:
      echo fieldName, " - ", typeof(fieldValue)
      if typeof(fieldValue) == typeof(array[0..7, char]):
        echo fieldName, " - ", readString(fieldValue)
      else:
        echo fieldName, " - ", toHex(fieldValue)
    echo repeat("=", 8)
    echo readString(sectionHeader.name)
    #echo readSection(fileStream, sectionHeader)
  
  
  #echo hexDump(fileStream, 1, 256)
  let headsEnd = dosHeader.e_lfanew + 4 + int(optionalHeader.sizeOfHeaders)
  let textSectionHead = sectionHeaders[".text"]
  echo "Size of headers: ", optionalHeader.sizeOfHeaders
  echo ".text pointerToRawData: ", textSectionHead.pointerToRawData
  echo "Headers ending: ", headsEnd
  let freespace = int(textSectionHead.pointerToRawData) - headsEnd
  echo "Free space: ", freespace
  #[for key, value in sectionHeaders:
    echo key 
  ]#


  case optionalHeader.magic
  of 0x10B: echo "32-bit"
  of 0x20B: echo "64-bit"
  of 0x107: echo "ROM image"
  else:    echo "Unknown format"

when isMainModule:
  main()
