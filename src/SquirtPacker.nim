import os, streams, strutils, tables
import pe_types, dos_stub, pe_readers, utils, pe_header_updater

proc main() =
  let filename = paramStr(1)
  if not fileExists(filename):
    echo "File not found: ", filename
    quit(1)

  var peFile = PE_File
  var peFile.file = open(filename, fmReadWriteExisting)
  defer: fileStream.close()

  discard readDosHeader(peFile)
  if peFile.dosHeader.e_magic != 0x5A4D:  # 'MZ'
    echo "Invalid file: missing MZ signature"
    quit(1)
  echo peFile.dosHeader
  
  #[
  #echo "DOS Stub: "
  #echo readDosStub(fileStream, sizeof(dosHeader), dosHeader.e_lfanew)

  #rewriteDosStub(fileStream, sizeof(dosHeader), dosHeader.e_lfanew)

  let coffHeader = readCOFFHeader(fileStream, dosHeader.e_lfanew + 4)
  echo repeat("=", 8)
  echo "COFF Header:"
  for fieldName, fieldValue in coffHeader.fieldPairs:
    echo fieldName, " - ", toHex(fieldValue)
  echo repeat("=", 8)
  
  case coffHeader.machine
  of 0x014C: echo "32-bit"
  of 0x8664: echo "64-bit"
  else:    echo "Unknown format"

  echo repeat("=", 8)
  var optionalHeader = object 
  if coffHeader.machine == 0x014C:
    let optionalHeader = read32OptionalHeader(fileStream, dosHeader)
  else:
    let optionalHeader = read64OptionalHeader(fileStream, dosHeader)

  echo "Optional Header:"
  for fieldName, fieldValue in optionalHeader.fieldPairs:
    echo fieldName, " - ", toHex(fieldValue)
  echo repeat("=", 8)

  # Create a table mapping headers to names.
  var sectionHeaders = initTable[string, ImageSectionHeader]()

  var sectionOffset = 0
  for i in 0..<int(coffHeader.numberOfSections):
    let sectionHeader = readSectionHeader(fileStream, dosHeader.e_lfanew + 24 +
      int(coffHeader.sizeOfOptionalHeader) + sectionOffset)
    sectionOffset += sizeof(sectionHeader)
    sectionHeaders.add(readString(sectionHeader.name), sectionHeader)
    echo "Section Header:"
    for fieldName, fieldValue in sectionHeader.fieldPairs:
      #[echo fieldName, " - ", typeof(fieldValue)
      if typeof(fieldValue) == typeof(array[0..7, char]):
        echo fieldName, " - ", readString(fieldValue)
      else:]#
      echo fieldName, " - ", fieldValue
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
  ]#
when isMainModule:
  main()
