# dos_stub.nim
import os

# Reads a DOSStub 
proc readDosStub*(fileStream: File, startA: int, endA: int): seq[byte] =
  var sectionSize = endA - startA
  var arr: seq[byte] = newSeq[byte](sectionSize)
  fileStream.setFilePos(startA)
  discard fileStream.readBuffer(addr arr[0], sectionSize)
  return arr

# Rewrite a DOSStub 
proc rewriteDosStub*(fileStream: File, startA: int, endA: int) =
  var sectionSize = endA - startA
  var arr: seq[byte] = newSeq[byte](sectionSize)
  for x in 0..<sectionSize:
    arr[x] = 0x90
  fileStream.setFilePos(startA)
  discard fileStream.writeBuffer(addr arr[0], sectionSize)