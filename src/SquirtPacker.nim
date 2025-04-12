# Update main function to use the new PE_File reading functions
import os, streams, strutils, tables
import pe_types, dos_stub, pe_readers, utils, pe_header_updater


proc main() =
  if paramCount() != 1:
    echo "Usage: SquirtPacker <input_file>"
    quit(1)

  let filename = paramStr(1)
  if not fileExists(filename):
    echo "File not found: ", filename
    quit(1)

  var fileStream = open(filename, fmReadWriteExisting)
  defer:
    fileStream.close()

  let peFile = readPEFile(fileStream)
  if peFile == invalidPEFile():
    echo "Failed to read PE file"
    quit(1)

  # Print summary info
  echo "=== PE File Information ==="
  echo "DOS Header:"
  echo peFile.dosHeader

  echo "\nCOFF Header:"
  echo peFile.coffHeader

  echo "\nOptional Header:", peFile.optionalHeader.kind


  echo "\nSections:"
  for i, section in pairs(peFile.sectionHeaders):
    echo "Section ", i+1, ": ", readString(section.name)
    #echo hexDump(sectionData[section.pointerToRawData..section.pointerToRawData + section.sizeOfRawData])

when isMainModule:
  main()
