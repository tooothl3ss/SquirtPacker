# pe_readers.nim
# This module contains procedures for reading and modifying different parts of a PE (Portable Executable) file.

import os, streams, strutils, tables
import pe_types, dos_stub, utils, pe_header_updater

# Reads the DOS header from the given file stream and returns an ImageDosHeader structure.
proc readDosHeader*(fileStream: File): ImageDosHeader =
  var dosHeader: ImageDosHeader
  discard fileStream.readBuffer(addr dosHeader, sizeof(dosHeader))
  return dosHeader

# Reads the COFF file header from the file stream at the specified offset and returns a COFFFileHeader structure.
proc readCOFFHeader*(fileStream: File, offset: int): COFFFileHeader =
  var coffHeader: COFFFileHeader
  fileStream.setFilePos(offset)
  discard fileStream.readBuffer(addr coffHeader, sizeof(coffHeader))
  return coffHeader

# Reads the ImageDataDirectories structure from the file stream at the specified offset and returns an ImageDataDirectories structure.
proc readImageDataDirectories*(fileStream: File, offset: int): ImageDataDirectories =
  var dataDirs: ImageDataDirectories
  fileStream.setFilePos(offset)
  discard fileStream.readBuffer(addr dataDirs, sizeof(dataDirs))
  return dataDirs

# Reads the 32-bit optional header (PE32) from the file stream using the DOS header to locate the PE header.
proc read32OptionalHeader*(fileStream: File, dosHeader: ImageDosHeader): PE32_OptionalHeader =
  var optHeader: PE32_OptionalHeader
  # The PE header starts at the offset specified in e_lfanew; skip the 4-byte signature and COFF header (20 bytes) -> 24 bytes total.
  fileStream.setFilePos(dosHeader.e_lfanew + 24)
  discard fileStream.readBuffer(addr optHeader, sizeof(optHeader))
  return optHeader

# Reads the 64-bit optional header (PE32+) from the file stream using the DOS header to locate the PE header.
proc read64OptionalHeader*(fileStream: File, dosHeader: ImageDosHeader): PE64_OptionalHeader =
  var optHeader: PE64_OptionalHeader
  # The PE header starts at the offset specified in e_lfanew; skip the PE signature and COFF header (24 bytes total).
  fileStream.setFilePos(dosHeader.e_lfanew + 24)
  discard fileStream.readBuffer(addr optHeader, sizeof(optHeader))
  return optHeader

# Reads a section header from the file stream at the given offset and returns an ImageSectionHeader structure.
proc readSectionHeader*(fileStream: File, offset: int): ImageSectionHeader =
  var sectionHeader: ImageSectionHeader
  fileStream.setFilePos(offset)
  discard fileStream.readBuffer(addr sectionHeader, sizeof(sectionHeader))
  return sectionHeader

# Reads a section's raw data from the file stream based on the provided section header.
proc readSection*(fileStream: File, header: ImageSectionHeader): seq[byte] =
  var sectionSize = int(header.sizeOfRawData)
  var dataAddress = int(header.pointerToRawData)
  var sectionData: seq[byte] = newSeq[byte](sectionSize)
  fileStream.setFilePos(dataAddress)
  discard fileStream.readBuffer(addr sectionData[0], sectionSize)
  return sectionData

# Reads the DOS header into the provided PE_File structure.
# Returns true if the header was successfully read; otherwise, false.
proc readDOSHeaderIntoPEFile*(peFile: var PE_File): bool =
  try:
    peFile.dosHeader = readDosHeader(peFile.file)
    return true
  except:
    return false

# Reads the COFF header into the provided PE_File structure.
# The COFF header is located immediately after the PE signature (4 bytes) at e_lfanew.
proc readCOFFHeaderIntoPEFile*(peFile: var PE_File): bool =
  try:
    peFile.coffHeader = readCOFFHeader(peFile.file, peFile.dosHeader.e_lfanew + 4)
    return true
  except:
    return false

# Reads the ImageDataDirectories into the provided PE_File structure.
# Determines the correct offset based on whether the file is 32-bit or 64-bit.
proc readImageDataDirectoriesIntoPEFile*(peFile: var PE_File): bool =
  try:
    var headerSize: int
    if peFile.is64bit:
      headerSize = sizeof(peFile.coffHeader) + sizeof(peFile.optional64Header)
    else:
      headerSize = sizeof(peFile.coffHeader) + sizeof(peFile.optional32Header)
    peFile.dataDirectories = readImageDataDirectories(peFile.file, peFile.dosHeader.e_lfanew + 4 + headerSize)
    return true
  except:
    return false

# Reads the appropriate optional header (PE32 for 32-bit or PE32+ for 64-bit) into the provided PE_File structure.
proc readOptionalHeaderIntoPEFile*(peFile: var PE_File): bool =
  try:
    if peFile.is64bit:
      # Read the 64-bit optional header (PE32+).
      peFile.optional64Header = read64OptionalHeader(peFile.file, peFile.dosHeader)
    else:
      # Read the 32-bit optional header (PE32).
      peFile.optional32Header = read32OptionalHeader(peFile.file, peFile.dosHeader)
    return true
  except:
    return false

# Reads all section headers and their corresponding data into the provided PE_File structure.
proc readSectionsIntoPEFile*(peFile: var PE_File): bool =
  try:
    # Calculate the starting offset for section headers.
    let sectionHeadersOffset = peFile.dosHeader.e_lfanew + 24 + int(peFile.coffHeader.sizeOfOptionalHeader)
    for i in 0..<int(peFile.coffHeader.numberOfSections):
      let offset = sectionHeadersOffset + i * sizeof(ImageSectionHeader)
      let header = readSectionHeader(peFile.file, offset)
      peFile.sectionHeaders.add(header)
      let sectionData = readSection(peFile.file, header)
      peFile.sections.add(sectionData)
    return true
  except:
    return false

# Reads a complete PE file from the given file stream and returns the populated PE_File structure.
proc readPEFile*(fileStream: File): PE_File =
  var peFile: PE_File
  peFile.file = fileStream
  discard readDOSHeaderIntoPEFile(peFile)
  discard readCOFFHeaderIntoPEFile(peFile)
  # Determine if the file is 64-bit based on the machine type in the COFF header (0x8664 means AMD64).
  peFile.is64bit = (peFile.coffHeader.machine == 0x8664)
  discard readOptionalHeaderIntoPEFile(peFile)
  discard readSectionsIntoPEFile(peFile)
  discard readImageDataDirectoriesIntoPEFile(peFile)
  return peFile
