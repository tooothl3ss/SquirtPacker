# pe_readers.nim
# This module contains procedures for reading and modifying different parts of a PE file.

import os, streams, strutils
import pe_types

# Reads the DOS header from the file stream
proc readDosHeader*(pefile: PE_File) {.raises: [IOError, ValueError].} =
  var dosHeader: ImageDosHeader
  discard fileStream.readBuffer(addr dosHeader, sizeof(dosHeader))
  return dosHeader

# Reads the image file header from the file stream at the given offset
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
