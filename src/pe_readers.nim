# pe_readers.nim
# This module contains procedures for reading and modifying different parts of a PE file.

import os, streams, strutils
import pe_types

# Reads the DOS header from the file stream
proc readDosHeader*(fileStream: File): ImageDosHeader =
  var dosHeader: ImageDosHeader
  discard fileStream.readBuffer(addr dosHeader, sizeof(dosHeader))
  return dosHeader

# Reads the COFF file header from the file stream at the given offset
proc readCOFFHeader*(fileStream: File, offset: int): COFFFileHeader =
  var imgHeader: COFFFileHeader
  fileStream.setFilePos(offset)
  discard fileStream.readBuffer(addr imgHeader, sizeof(imgHeader))
  return imgHeader

# Reads the optional header from the file stream using the DOS header to locate the PE header
proc read32OptionalHeader*(fileStream: File, dosHeader: ImageDosHeader): PE32_OptionalHeader =
  var optionalHeader: PE32_OptionalHeader
  # e_lfanew is the start of the PE header
  fileStream.setFilePos(dosHeader.e_lfanew + 24)
  discard fileStream.readBuffer(addr optionalHeader, sizeof(optionalHeader))
  return optionalHeader

# Reads the optional header from the file stream using the DOS header to locate the PE header
proc read64OptionalHeader*(fileStream: File, dosHeader: ImageDosHeader): PE64_OptionalHeader =
  var optionalHeader: PE64_OptionalHeader
  # e_lfanew is the start of the PE header
  fileStream.setFilePos(dosHeader.e_lfanew + 24)
  discard fileStream.readBuffer(addr optionalHeader, sizeof(optionalHeader))
  return optionalHeader

# Reads a section header from the file stream at the given offset
proc readSectionHeader*(fileStream: File, offset: int): ImageSectionHeader =
  var sectionHeader: ImageSectionHeader
  fileStream.setFilePos(offset)
  discard fileStream.readBuffer(addr sectionHeader, sizeof(sectionHeader))
  return sectionHeader

# Reads section data from the file stream based on the provided section header
proc readSection*(fileStream: File, header: ImageSectionHeader): seq[byte] =
  var sectionSize = int(header.sizeOfRawData)
  var dataAddress = int(header.pointerToRawData)
  echo dataAddress
  var arr: seq[byte] = newSeq[byte](sectionSize)
  fileStream.setFilePos(dataAddress)
  discard fileStream.readBuffer(addr arr[0], sectionSize)
  return arr

proc readDOSHeaderIntoPEFile*(peFile: var PE_File): bool =
  try:
    peFile.dosHeader = readDosHeader(peFile.file)
    return true
  except:
    return false

proc readCOFFHeaderIntoPEFile*(peFile: var PE_File): bool =
  try:
    peFile.coffHeader = readCOFFHeader(peFile.file, peFile.dosHeader.e_lfanew + 4)
    return true
  except:
    return false

proc readOptionalHeaderIntoPEFile*(peFile: var PE_File): bool =
  try:
    if peFile.is64bit:
      peFile.optionalHeader.kind = ohk64
      peFile.optionalHeader.header64 = read64OptionalHeader(peFile.file, peFile.dosHeader)
    else:
      peFile.optionalHeader.kind = ohk32
      peFile.optionalHeader.header32 = read32OptionalHeader(peFile.file, peFile.dosHeader)
    
    return true
  except:
    return false

proc readSectionsIntoPEFile*(peFile: var PE_File): bool =
  try:
    let sectionStartOffset = peFile.dosHeader.e_lfanew + 4 + peFile.coffHeader.sizeOfOptionalHeader
    for i in 0..<int(peFile.coffHeader.numberOfSections):
      let offset = sectionStartOffset + i * sizeof(ImageSectionHeader)
      let header = readSectionHeader(peFile.file, offset)
      peFile.sectionHeaders.add(readString(header.name), header)
      
      let sectionData = readSection(peFile.file, header)
      peFile.sections.add(sectionData)

    return true
  except:
    return false

# Add these functions to read all parts of a PE file into the PE_File struct

proc readPEFile*(fileStream: File): PE_File =
  var peFile: PE_File
  peFile.file = fileStream
  if not readDOSHeaderIntoPEFile(peFile):
    return invalidPEFile()
  
  peFile.is64bit = (peFile.coffHeader.machine == 0x8664)
  
  if not readCOFFHeaderIntoPEFile(peFile):
    return invalidPEFile()

  if not readOptionalHeaderIntoPEFile(peFile):
    return invalidPEFile()

  if not readSectionsIntoPEFile(peFile):
    return invalidPEFile()

  return peFile

