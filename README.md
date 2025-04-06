# SquirtPacker

This project is a simple example of parsing and modifying Portable Executable (PE) files using Nim.

## Project Structure

The project is organized into several files:
- **dos_stub.nim**: Module for handling DOS stub operations.
- **pe_types.nim**: Contains type definitions for PE file headers.
- **pe_readers.nim**: Implements functions to read  PE file sections.
- **pe_writer.nim**: Implements functions to modify PE file sections.
- **utils.nim**: Сommon helpers
- **main.nim**: The main entry point that ties everything together.

## Getting Started

To build and run the project:
```
nim c -r main.nim
```

## License

This project is licensed under the MIT License.