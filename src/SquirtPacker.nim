# main.nim
# This module demonstrates how to use the new PE_File reading functions and prints out a formatted summary of the PE file.

import os, streams, strutils, tables, std/strformat
import pe_types, dos_stub, pe_readers, utils, pe_header_updater

proc main() =
  # Check command-line arguments.
  if paramCount() != 1:
    echo "Usage: SquirtPacker <input_file>"
    quit(1)

  var p = newParser:
  option("-f", "--file", help="Path to file")
  

  let filename = paramStr(1)
  if not fileExists(filename):
    echo "File not found: ", filename
    quit(1)

  # Open the file stream in read-write mode; ensure it's closed when done.
  var fileStream = open(filename, fmReadWriteExisting)
  defer:
    fileStream.close()

  # Read the complete PE file structure using the reader procedures.
  var peFile = readPEFile(fileStream)

  # Print a formatted summary of the PE file.
  printHeader("PE File Information")

  echo "\n[DOS Header]"
  echo peFile.dosHeader
  printSeparator()

  echo "\n[COFF Header]"
  echo peFile.coffHeader
  printSeparator()

  echo "\n[Optional Header]"
  if peFile.is64bit:
    echo "Architecture: 64-bit (PE32+)"
    echo peFile.optional64Header
  else:
    echo "Architecture: 32-bit (PE32)"
    echo peFile.optional32Header
  printSeparator()

  echo "\n[Data Directories]"
  echo peFile.dataDirectories
  printSeparator()

  echo "\n[Section Headers]"
  # Iterate over section headers with index for better clarity.
  for idx, header in peFile.sectionHeaders.pairs:
    echo fmt"[Section {idx}]: {header}"
  printSeparator()

  echo "\n[Raw Section Data]"
  # Print summary information for raw section data lengths.
  for idx, sectionData in peFile.sections.pairs:
    echo fmt"Section {idx}: Length = {len(sectionData)} bytes"
  printSeparator()

when isMainModule:
  main()
