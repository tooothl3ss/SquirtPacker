# pe_types.nim
# This module defines the data structures for parsing PE (Portable Executable) files.

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

  PE32_OptionalHeader* {.packed.} = object
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

  COFFFileHeader* {.packed.} = object
    machine*: uint16
    numberOfSections*: uint16
    timeDateStamp*: uint32
    pointerToSymbolTable*: uint32
    numberOfSymbols*: uint32
    sizeOfOptionalHeader*: uint16
    characteristics*: uint16

  PE64_OptionalHeader* {.packed.} = object
    # Standard fields
    magic*: uint16 
    majorLinkerVersion*: uint8  
    minorLinkerVersion*: uint8  
    sizeOfCode*: uint32 
    sizeOfInitializedData*: uint32 
    sizeOfUninitializedData*: uint32 
    addressOfEntryPoint*: uint32 
    baseOfCode*: uint32 
    # Windows-specific fields (64-bit)
    imageBase*: uint64 
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
    subsystem*: uint16 
    dllCharacteristics*: uint16 
    sizeOfStackReserve*: uint64 
    sizeOfStackCommit*: uint64 
    sizeOfHeapReserve*: uint64 
    sizeOfHeapCommit*: uint64 
    loaderFlags*: uint32 
    numberOfRvaAndSizes*: uint32 

  OptionalHeaderKind = enum ohk32, ohk64
  OptionalHeader = object
    case kind: OptionalHeaderKind
    of ohk32: header32: PE32_OptionalHeader
    of ohk64: header64: PE64_OptionalHeader


  PE_File* = object
    file*: File
    is64bit*: bool
    dosHeader*: ImageDosHeader
    coffHeader*: COFFFileHeader
    optionalHeader*: OptionalHeader
    sectionHeaders*: seq[ImageSectionHeader]
    sections*: seq[seq[byte]]