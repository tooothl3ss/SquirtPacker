import os, streams, strutils

type
  ImageDosHeader* {.packed.} = object
    e_magic*: uint16
    e_cblp*: uint16
    e_cp*: uint16
    e_crlc*: uint16
    e_cparhdr*: uint16
    e_minalloc*: uint16
    e_maxalloc*: uint16
    e_ss*: uint16
    e_sp*: uint16
    e_csum*: uint16
    e_ip*: uint16
    e_cs*: uint16
    e_lfarlc*: uint16
    e_ovno*: uint16
    e_res*: array[4, uint16]
    e_oemid*: uint16
    e_oeminfo*: uint16
    e_res2*: array[10, uint16]
    e_lfanew*: int32

  ImageOptionalHeader* {.packed.} = object
    magic*: uint16
    majorLinkerVersion*: uint8
    minorLinkerVersion*: uint8
    sizeOfCode*: uint32
    sizeOfInitializedData*: uint32
    sizeOfUninitializedData*: uint32
    addressOfEntryPoint*: uint32  # Entry point (in .text section)
    baseOfCode*: uint32           # Base address of .text section
    baseOfData*: uint32           # Base address of .data section
    imageBase*: uint32
    sectionAlignment*: uint32
    fileAlignment*: uint32
    majorOperatingSystemVersion*: uint16
    minorOperatingSystemVersion*: uint16
    majorImageVersion*: uint16
    minorImageVersion*: uint16
    majorSubsystemVersion*: uint16
    minorSubsystemVersion*: uint16
    win32VersionValue*: uint32
    sizeOfImage*: uint32
    sizeOfHeaders*: uint32
    checkSum*: uint32
    subsystem*: uint16          # Subsystem (e.g., WINDOWS_GUI)
    dllCharacteristics*: uint16
    sizeOfStackReserve*: uint32
    sizeOfStackCommit*: uint32
    sizeOfHeapReserve*: uint32
    sizeOfHeapCommit*: uint32
    loaderFlags*: uint32
    numberOfRvaAndSizes*: uint32

  ImageSectionHeader* {.packed.} = object
    name*: array[8, char]
    virtualSize*: uint32
    virtualAddress*: uint32
    sizeOfRawData*: uint32
    pointerToRawData*: uint32
    pointerToRelocations*: uint32
    pointerToLinenumbers*: uint32
    numberOfRelocations*: uint16
    numberOfLinenumbers*: uint16
    characteristics*: uint32

  ImageFileHeader* {.packed.} = object
    machine*: uint16
    numberOfSections*: uint16
    timeDateStamp*: uint32
    pointerToSymbolTable*: uint32
    numberOfSymbols*: uint32
    sizeOfOptionalHeader*: uint16
    characteristics*: uint16

# Reads the DOS header from the file
proc readDosHeader(fileStream: File): ImageDosHeader =
  var dosHeader: ImageDosHeader
  discard fileStream.readBuffer(addr dosHeader, sizeof(dosHeader))
  return dosHeader

# Reads the image (file) header from the file at the given offset
proc readImageHeader(fileStream: File, offset: int): ImageFileHeader =
  var imgHeader: ImageFileHeader
  fileStream.setFilePos(offset)
  discard fileStream.readBuffer(addr imgHeader, sizeof(imgHeader))
  return imgHeader

# Reads the optional header from the file using the DOS header to locate the PE header
proc readOptionalHeader(fileStream: File, dosHeader: ImageDosHeader): ImageOptionalHeader =
  var optionalHeader: ImageOptionalHeader
  # e_lfanew - start of the PE header
  fileStream.setFilePos(dosHeader.e_lfanew + 24)
  discard fileStream.readBuffer(addr optionalHeader, sizeof(optionalHeader))
  return optionalHeader

# Reads a section header from the file at the given offset
proc readSectionHeader(fileStream: File, offset: int): ImageSectionHeader =
  var sectionHeader: ImageSectionHeader
  fileStream.setFilePos(offset)
  discard fileStream.readBuffer(addr sectionHeader, sizeof(sectionHeader))
  return sectionHeader

# Reads a section 
proc readSection(fileStream: File, header: ImageSectionHeader): seq[byte] =
  var sectionSize = int(header.sizeOfRawData)
  var dataAdress = int(header.pointerToRawData)
  echo dataAdress
  var arr: seq[byte] = newSeq[byte](sectionSize)
  fileStream.setFilePos(dataAdress)
  discard fileStream.readBuffer(addr arr[0], sectionSize)
  return arr

proc main() =
  let filename = paramStr(1)
  if not fileExists(filename):
    echo "File not found: ", filename
    quit(1)

  var fileStream = open(filename, fmRead)
  defer: fileStream.close()

  let dosHeader = readDosHeader(fileStream)
  if dosHeader.e_magic != 0x5A4D:  # 'MZ'
    echo "Invalid file: missing MZ signature"
    quit(1)
  
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
  
  var sectionOffset = 0
  for i in 0..<int(imageHeader.numberOfSections):
    let sectionHeader = readSectionHeader(fileStream, dosHeader.e_lfanew + 24 +
      int(imageHeader.sizeOfOptionalHeader) + sectionOffset)
    sectionOffset += sizeof(sectionHeader)
    echo "Section Header:"
    for fieldName, fieldValue in sectionHeader.fieldPairs:
      echo fieldName, " - ", fieldValue
    echo repeat("=", 8)
    echo readSection(fileStream, sectionHeader)

  case optionalHeader.magic
  of 0x10B: echo "32-bit"
  of 0x20B: echo "64-bit"
  of 0x107: echo "ROM image"
  else:    echo "Unknown format"

when isMainModule:
  main()
