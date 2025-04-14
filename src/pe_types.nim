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

  DataDirectory* {.packed.} = object
    rva*: uint32    # 4 байта (DWORD)
    size*: uint32   # 4 байта (DWORD)

  ImageDataDirectories* {.packed.} = object
    export_dir*: DataDirectory       # 0. Export Directory
    import_dir*: DataDirectory       # 1. Import Directory
    resource_dir*: DataDirectory     # 2. Resource Directory
    exception_dir*: DataDirectory    # 3. Exception Directory
    security_dir*: DataDirectory     # 4. Security Directory
    basereloc_dir*: DataDirectory    # 5. Base Relocation Table
    debug_dir*: DataDirectory        # 6. Debug Directory
    architecture_dir*: DataDirectory # 7. Architecture Specific Data
    global_ptr*: DataDirectory       # 8. RVA of GP
    tls_dir*: DataDirectory          # 9. TLS Directory
    load_config_dir*: DataDirectory  # 10. Load Configuration Directory
    bound_import_dir*: DataDirectory # 11. Bound Import Directory
    iat_dir*: DataDirectory          # 12. Import Address Table
    delay_import_dir*: DataDirectory # 13. Delay Load Import Descriptors
    com_descriptor*: DataDirectory   # 14. COM Runtime descriptor
    reserved_dir*: DataDirectory     # 15. Reserved

  PE_File* = object
    file*: File
    is64bit*: bool
    dosHeader*: ImageDosHeader
    coffHeader*: COFFFileHeader
    optional32Header*: PE32_OptionalHeader
    optional64Header*: PE64_OptionalHeader
    dataDirectories*: ImageDataDirectories
    sectionHeaders*: seq[ImageSectionHeader]
    sections*: seq[seq[byte]]