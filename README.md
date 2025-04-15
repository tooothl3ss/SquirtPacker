# SquirtPacker

This project is a simple example of parsing and modifying Portable Executable (PE) files using Nim.

## Project Structure
```
SquirtPacker/
├── src/
│   ├── dos_stub.nim            # Module for reading and rewriting the DOS stub.
│   ├── pe_types.nim            # Contains type definitions for PE file headers.
│   ├── pe_readers.nim          # Implements functions to read PE file headers and sections.
│   ├── pe_writer.nim           # Implements functions to modify PE file sections. (TBD)
│   ├── pe_header_updater.nim   # Implements functions to update PE file headers. (TBD)
│   ├── pe_analyzer.nim         # Implements analysis of PE file properties (e.g., architecture, security flags). (TBD)
│   ├── utils.nim               # Provides common helper functions.
│   ├── stuber.nim              # Stub generator for PE files. (TBD)
│   └── SquirtPacker.nim        # The main entry point that ties everything together.
├── LICENSE                     # Project LICENSE.
└── README.md                   # Project overview and documentation.
```
SquirtPacker is organized into several modules, each handling a distinct part of PE file processing:

- **dos_stub.nim**: Manages reading and rewriting the DOS stub section of PE files.
- **pe_types.nim**: Contains detailed type definitions that mirror the PE file header structures.
- **pe_readers.nim**: Implements functions for reading various headers and sections from a PE file.
- **pe_writer.nim**: Responsible for modifying and writing PE file sections. *(Work in Progress)*
- **pe_header_updater.nim**: Focuses on updating the PE file headers independently from the section writers. *(Work in Progress)*
- **pe_analyzer.nim**: Provides analysis of PE file properties, currently identifying architecture, with plans to add additional security checks. *(Work in Progress)*
- **utils.nim**: Contains common utility functions (e.g., logging, formatting) that support the main modules.
- **stuber.nim**: Generates stub necessary for unpacking PE files. *(Work in Progress)*
- **SquirtPacker.nim**: Acts as the main entry point, coordinating operations across all modules.

## Getting Started

To build and run the project:
```
nim c -r SquirtPacker.nim calc.exe
```

## License

This project is licensed under the MIT License.
