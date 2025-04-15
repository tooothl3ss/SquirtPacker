# pe_types.nim
# This module defines the data structures for parsing PE (Portable Executable) files.

type

  # IMAGE_DOS_HEADER structure
  # Contains the MS-DOS header which is present at the beginning of all PE files.
  ImageDosHeader* {.packed.} = object
    e_magic*: uint16                   # Magic number; must be 'MZ' (0x5A4D)
    e_cblp*: uint16                    # Bytes on last page of file
    e_cp*: uint16                      # Pages in file
    e_crlc*: uint16                    # Relocations count
    e_cparhdr*: uint16                 # Size of header in paragraphs
    e_minalloc*: uint16                # Minimum extra paragraphs needed
    e_maxalloc*: uint16                # Maximum extra paragraphs needed
    e_ss*: uint16                      # Initial (relative) SS value
    e_sp*: uint16                      # Initial SP value
    e_csum*: uint16                    # Checksum
    e_ip*: uint16                      # Initial IP value
    e_cs*: uint16                      # Initial (relative) CS value
    e_lfarlc*: uint16                  # File address of relocation table
    e_ovno*: uint16                    # Overlay number
    e_res*: array[4, uint16]           # Reserved words
    e_oemid*: uint16                   # OEM identifier (for e_oeminfo)
    e_oeminfo*: uint16                 # OEM information; e_oemid specific
    e_res2*: array[10, uint16]         # Reserved words
    e_lfanew*: int32                   # File address of the new exe header

  # PE32 Optional Header for 32-bit PE files
  # Contains crucial information about the layout of the executable in memory.
  PE32_OptionalHeader* {.packed.} = object
    magic*: uint16                     # Magic number; should be 0x10B for PE32
    majorLinkerVersion*: uint8         # Major linker version
    minorLinkerVersion*: uint8         # Minor linker version
    sizeOfCode*: uint32                # Size of the code (text) section
    sizeOfInitializedData*: uint32     # Size of the initialized data section
    sizeOfUninitializedData*: uint32   # Size of the uninitialized data section (BSS)
    addressOfEntryPoint*: uint32       # Entry point (in .text section)
    baseOfCode*: uint32                # Base address of the .text section
    baseOfData*: uint32                # Base address of the .data section
    imageBase*: uint32                 # Preferred address of the first byte of image when loaded in memory
    sectionAlignment*: uint32          # Alignment (in bytes) of sections when loaded into memory
    fileAlignment*: uint32             # Alignment factor (in bytes) for the raw data of sections in the file
    majorOperatingSystemVersion*: uint16  # Major version number of the required operating system
    minorOperatingSystemVersion*: uint16  # Minor version number of the required operating system
    majorImageVersion*: uint16         # Major version number of the image
    minorImageVersion*: uint16         # Minor version number of the image
    majorSubsystemVersion*: uint16     # Major version number of the subsystem
    minorSubsystemVersion*: uint16     # Minor version number of the subsystem
    win32VersionValue*: uint32         # Reserved, should be 0
    sizeOfImage*: uint32               # Size of the image, including all headers, when loaded into memory
    sizeOfHeaders*: uint32             # Combined size of all headers (MS-DOS stub, PE header, section headers)
    checkSum*: uint32                  # Checksum of the file
    subsystem*: uint16                 # Subsystem required to run this image (e.g., WINDOWS_GUI)
    dllCharacteristics*: uint16        # DLL characteristics flags
    sizeOfStackReserve*: uint32        # Size of the stack to reserve
    sizeOfStackCommit*: uint32         # Size of the stack to commit
    sizeOfHeapReserve*: uint32         # Size of the local heap space to reserve
    sizeOfHeapCommit*: uint32          # Size of the local heap space to commit
    loaderFlags*: uint32               # Loader flags (reserved, must be 0)
    numberOfRvaAndSizes*: uint32       # Number of data-directory entries

  # IMAGE_SECTION_HEADER structure
  # Describes a section within the PE file.
  ImageSectionHeader* {.packed.} = object
    name*: array[8, char]              # Section name (null-padded)
    virtualSize*: uint32               # Total size of the section when loaded into memory
    virtualAddress*: uint32            # Relative Virtual Address (RVA) of the section
    sizeOfRawData*: uint32             # Size of the section data in the file
    pointerToRawData*: uint32          # File pointer to the first page of the section
    pointerToRelocations*: uint32      # File pointer to the beginning of relocations for the section
    pointerToLinenumbers*: uint32      # File pointer to the beginning of line numbers for the section
    numberOfRelocations*: uint16       # Number of relocations for the section
    numberOfLinenumbers*: uint16       # Number of line numbers for the section
    characteristics*: uint32           # Flags describing the characteristics of the section

  # COFF File Header structure
  # Provides overall information about the file such as architecture and section count.
  COFFFileHeader* {.packed.} = object
    machine*: uint16                 # Machine type (architecture), e.g., 0x14C for x86
    numberOfSections*: uint16        # Number of sections in the PE file
    timeDateStamp*: uint32           # Time and date the file was created (timestamp)
    pointerToSymbolTable*: uint32    # File pointer to the symbol table (deprecated)
    numberOfSymbols*: uint32         # Number of symbols (deprecated)
    sizeOfOptionalHeader*: uint16    # Size of the optional header
    characteristics*: uint16         # Characteristics flags of the file

  # PE64 Optional Header for 64-bit PE files
  # Contains crucial information for 64-bit executables.
  PE64_OptionalHeader* {.packed.} = object
    # Standard fields
    magic*: uint16                   # Magic number; should be 0x20B for PE32+
    majorLinkerVersion*: uint8       # Major linker version
    minorLinkerVersion*: uint8       # Minor linker version
    sizeOfCode*: uint32              # Size of the code (text) section
    sizeOfInitializedData*: uint32   # Size of the initialized data section
    sizeOfUninitializedData*: uint32 # Size of the uninitialized data section (BSS)
    addressOfEntryPoint*: uint32     # Entry point address
    baseOfCode*: uint32              # Base address of the code section
    # Windows-specific fields (64-bit)
    imageBase*: uint64               # Preferred load address for the image
    sectionAlignment*: uint32        # Alignment (in bytes) of sections when loaded into memory
    fileAlignment*: uint32           # Alignment factor (in bytes) for raw section data in the file
    majorOperatingSystemVersion*: uint16  # Required major version of the operating system
    minorOperatingSystemVersion*: uint16  # Required minor version of the operating system
    majorImageVersion*: uint16       # Image major version
    minorImageVersion*: uint16       # Image minor version
    majorSubsystemVersion*: uint16   # Subsystem major version
    minorSubsystemVersion*: uint16   # Subsystem minor version
    win32VersionValue*: uint32       # Reserved, must be 0
    sizeOfImage*: uint32             # Total size of the image when loaded in memory
    sizeOfHeaders*: uint32           # Combined size of all headers
    checkSum*: uint32                # Checksum of the image
    subsystem*: uint16               # Subsystem required (e.g., WINDOWS_GUI)
    dllCharacteristics*: uint16      # DLL characteristics flags
    sizeOfStackReserve*: uint64      # Size of stack to reserve
    sizeOfStackCommit*: uint64       # Size of stack to commit
    sizeOfHeapReserve*: uint64       # Size of heap to reserve
    sizeOfHeapCommit*: uint64        # Size of heap to commit
    loaderFlags*: uint32             # Loader flags (reserved, must be 0)
    numberOfRvaAndSizes*: uint32     # Number of data-directory entries

  # Data Directory entry structure
  # Represents a single entry in the Data Directories array.
  DataDirectory* {.packed.} = object
    rva*: uint32    # Relative Virtual Address (4 bytes, DWORD)
    size*: uint32   # Size of the directory (4 bytes, DWORD)

  # IMAGE_DATA_DIRECTORIES structure
  # Contains an array of 16 DataDirectory entries used to locate various tables and resources.
  ImageDataDirectories* {.packed.} = object
    export_dir*: DataDirectory       # 0. Export Directory
    import_dir*: DataDirectory       # 1. Import Directory
    resource_dir*: DataDirectory     # 2. Resource Directory
    exception_dir*: DataDirectory    # 3. Exception Directory
    security_dir*: DataDirectory     # 4. Security Directory
    basereloc_dir*: DataDirectory    # 5. Base Relocation Table
    debug_dir*: DataDirectory        # 6. Debug Directory
    architecture_dir*: DataDirectory # 7. Architecture Specific Data
    global_ptr*: DataDirectory       # 8. RVA of Global Pointer (GP)
    tls_dir*: DataDirectory          # 9. TLS Directory
    load_config_dir*: DataDirectory  # 10. Load Configuration Directory
    bound_import_dir*: DataDirectory # 11. Bound Import Directory
    iat_dir*: DataDirectory          # 12. Import Address Table
    delay_import_dir*: DataDirectory # 13. Delay Load Import Descriptors
    com_descriptor*: DataDirectory   # 14. COM Runtime descriptor
    reserved_dir*: DataDirectory     # 15. Reserved (unused)

  # PE_File structure
  # Represents an entire PE file, encapsulating headers, directories, section data, and more.
  PE_File* = object
    file*: File                      # Underlying file handle
    is64bit*: bool                   # Flag indicating if the file is 64-bit (PE32+) or 32-bit
    dosHeader*: ImageDosHeader       # DOS header of the file
    coffHeader*: COFFFileHeader      # COFF file header
    optional32Header*: PE32_OptionalHeader  # Optional header for PE32 (if the file is 32-bit)
    optional64Header*: PE64_OptionalHeader  # Optional header for PE32+ (if the file is 64-bit)
    dataDirectories*: ImageDataDirectories  # Data directories structure
    sectionHeaders*: seq[ImageSectionHeader]  # Array of section headers
    sections*: seq[seq[byte]]                # Raw data for each section
