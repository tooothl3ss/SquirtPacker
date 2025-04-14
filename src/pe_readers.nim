# pe_readers.nim
# This module contains procedures for reading and modifying different parts of a PE file.

import os, streams, strutils, tables
import pe_types, dos_stub, utils, pe_header_updater

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

# Reads the COFF file header from the file stream at the given offset
proc readImageDataDirectories*(fileStream: File, offset: int): ImageDataDirectories =
  var dataDirectories: ImageDataDirectories
  fileStream.setFilePos(offset)
  discard fileStream.readBuffer(addr dataDirectories, sizeof(dataDirectories))
  return dataDirectories

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
  #echo dataAddress
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

proc readImageDataDirectoriesIntoPEFile*(peFile: var PE_File): bool =
  try:
    if peFile.is64bit:
      peFile.dataDirectories = readImageDataDirectories(peFile.file, peFile.dosHeader.e_lfanew + 4 + sizeof(peFile.coffHeader) + sizeof(peFile.optional64Header))
    else:
      peFile.dataDirectories = readImageDataDirectories(peFile.file, peFile.dosHeader.e_lfanew + 4 + sizeof(peFile.coffHeader) + sizeof(peFile.optional32Header))
    return true
  except:
    return false

proc readOptionalHeaderIntoPEFile*(peFile: var PE_File): bool =
  
  try:
    if peFile.is64bit:
      #echo "[!] - is64? - ", peFile.is64bit
      peFile.optional64Header = read64OptionalHeader(peFile.file, peFile.dosHeader)
    else:
      peFile.optional32Header = read32OptionalHeader(peFile.file, peFile.dosHeader)
    
    return true
  except:
    return false

proc readSectionsIntoPEFile*(peFile: var PE_File): bool =
  try:
    let sectionStartOffset = peFile.dosHeader.e_lfanew + 24 + int(peFile.coffHeader.sizeOfOptionalHeader)
    for i in 0..<int(peFile.coffHeader.numberOfSections):
      let offset = sectionStartOffset + i * sizeof(ImageSectionHeader)
      let header = readSectionHeader(peFile.file, offset)
      peFile.sectionHeaders.add(header)
      #echo "Numbers of sections ", peFile.coffHeader.numberOfSections
      let sectionData = readSection(peFile.file, header)
      peFile.sections.add(sectionData)
    return true
  except:
    return false

# Add these functions to read all parts of a PE file into the PE_File struct

proc readPEFile*(fileStream: File): PE_File =
  var peFile: PE_File
  peFile.file = fileStream
  discard readDOSHeaderIntoPEFile(peFile)
  discard readCOFFHeaderIntoPEFile(peFile)
  peFile.is64bit = (peFile.coffHeader.machine == 0x8664)
  discard readOptionalHeaderIntoPEFile(peFile)
  discard readSectionsIntoPEFile(peFile)
  discard readImageDataDirectoriesIntoPEFile(peFile)
  return peFile