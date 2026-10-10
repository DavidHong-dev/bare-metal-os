# bare-metal-os

A hobby x86 operating system written completely from scratch: no frameworks, no existing bootloader (no GRUB), no libraries.

> **Status: work in progress.** This is not a full OS yet. Right now it's a custom two-stage bootloader that boots into 32-bit protected mode and runs a small kernel written in assembly and C.

## What it does today

- **Stage 1 bootloader** (`boot1.asm`): a 512-byte boot sector loaded by the BIOS. Its job is to load stage 2.
- **Stage 2 bootloader** (`boot2.asm`): switches the CPU from 16-bit real mode into 32-bit protected mode and loads the kernel.
- **Kernel** (`kernel.asm` + `kernel.c`): an assembly entry point hands control to C code, which prints text (such as "Hello, World!") to the screen.
- **Linker script** (`linker.ld`): links the assembly and C parts into one flat binary and lays out the kernel's memory, so the C code gets its own region of memory.

## Boot flow

```
BIOS
  -> Stage 1 (512-byte boot sector)
    -> Stage 2 (enters protected mode, loads kernel)
      -> kernel.asm (entry point)
        -> kernel.c (prints text to the screen)
```

## Disk layout

The build produces a 1440 KB floppy disk image (`build/disk.img`):

| Sector | Contents            |
|--------|---------------------|
| 0      | Stage 1 (`boot1`)   |
| 1      | Stage 2 (`boot2`)   |
| 2+     | Kernel (`kernel`)   |

## Project structure

```
bare-metal-os/
├── src/
│   ├── boot1.asm     # Stage 1 bootloader
│   ├── boot2.asm     # Stage 2 bootloader (protected mode)
│   ├── kernel.asm    # Kernel entry point, jumps into C
│   └── kernel.c      # Kernel code in C
├── linker.ld         # Linker script
├── Makefile
└── README.md
```

Build output goes into `bin/` and `build/`, which are not tracked by Git.

## Requirements

- `nasm`
- `gcc` with 32-bit support (on Debian/Ubuntu: `sudo apt install gcc-multilib`)
- `ld` (from binutils)
- `make`
- `qemu-system-x86_64`

On Debian/Ubuntu:

```bash
sudo apt install nasm gcc gcc-multilib binutils make qemu-system-x86
```

## Building and running

```bash
make          # build everything into build/disk.img
make run      # build and boot in QEMU
make clean    # delete bin/ and build/
```

## Notes

- Stage 2 sits in a single 512-byte sector, so it has to stay under 512 bytes unless the disk layout changes.
- The number of sectors stage 2 reads for the kernel must be at least as large as `bin/kernel.bin`. If the kernel grows and boot starts failing, check this first.
- The kernel is compiled freestanding (`-ffreestanding`, no standard library).

## Roadmap

- [ ] Interrupts (IDT) and exception handling
- [ ] Keyboard driver
- [ ] Better screen output (scrolling, colors, `printf`-style formatting)
- [ ] Memory management
- [ ] Load a larger kernel (multi-sector / more flexible loading)

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.
