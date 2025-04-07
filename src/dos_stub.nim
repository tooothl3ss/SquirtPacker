# dos_stub.nim
import os, utils

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
  arr = garbageGenerator(sectionSize)
  fileStream.setFilePos(startA)
  discard fileStream.writeBuffer(addr arr[0], sectionSize)