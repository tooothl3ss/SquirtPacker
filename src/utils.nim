import os, strformat, streams
import times, random, pe_types

# Call randomize() once to initialize the default random number generator.
# If this is not called, the same results will occur every time these
# examples are run.
randomize()
## Returns a hex dump of the file contents.
## Seeks to the given offset in the file, reads 'count' bytes,
## and returns a formatted string with hex and ASCII values.
proc hexDump*(file: File, offset: int, count: int): string =
  if file == nil:
    return "Error: file pointer is nil."
  
  # Use the global seek procedure from streams
  file.setFilePos(offset)
  var buffer = newSeq[byte](count)
  let bytesRead = file.readBuffer(addr buffer, count)
  if bytesRead <= 0:
    return "No bytes read from file."
  
  var result = ""
  let chunkSize = 16  # number of bytes per line

  for i in 0..<bytesRead:
    # Start a new line every chunkSize bytes with the address.
    if i mod chunkSize == 0:
      result.add &"{offset + i:08X}: "
      
    # Append the hex representation of the current byte.
    #result.add &"{buffer[i]:02X} "

    # When the line is complete or it's the last byte, append ASCII representation.
    if (i mod chunkSize == chunkSize - 1) or (i == bytesRead - 1):
      let lineStart = i - (i mod chunkSize)
      let lineCount = i - lineStart + 1
      # Pad the hex part if the last line is incomplete.
      if lineCount < chunkSize:
        for _ in lineCount..<chunkSize:
          result.add "   "
      result.add " |"
      # Append ASCII characters: printable characters remain, non-printable replaced with a dot.
      #[for j in lineStart ..< (lineStart + min(chunkSize, bytesRead - lineStart)):
        let ch = buffer[j]
        if ch >= 32 and ch <= 126:
          result.add $char(ch)
        else:
          result.add "."
      result.add "|\n"
      ]#
  return result


proc garbageGenerator*(size: int): seq[byte] =
  # Get the current date and time (DateTime type)
  var currentTime = int(cpuTime())
  echo currentTime
  # Initialize the random generator using the Unix time as seed
  var r = initRand(currentTime)
  # Create a sequence of bytes with the specified size
  var arr: seq[byte] = newSeq[byte](size)
  # Convert the message to a sequence of bytes.
  var msgBytes: seq[byte] = @[]
  var message = "-^=Uwu=^-"
  for ch in message:
    msgBytes.add(byte(ch))
  # Fill the array with random bytes (0..255)
  for x in 0..<size:
    arr[x] = byte(r.rand(256))
  return arr


proc readString*(str: openarray[char]): string =
    var result = ""
    for x in str:
        if x != '\x00':
            result.add(x)
    return result

# Example usage:
#[var f = open("example.exe", fmRead)
if f == nil:
  echo "Failed to open file."
else:
  echo hexDump(f, 0, 256)
  close(f)
]#