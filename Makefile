ASM = nasm
CC  = gcc
LD  = ld
RUN = qemu-system-x86_64

SRCDIR   = src
BINDIR   = bin
BUILDDIR = build

BOOT1  = $(BINDIR)/boot1.bin
BOOT2  = $(BINDIR)/boot2.bin
KERNEL = $(BINDIR)/kernel.bin
DISK   = $(BUILDDIR)/disk.img

CFLAGS = -m32 -std=gnu99 -ffreestanding -fno-pic -fno-stack-protector -O2 -c

.PHONY: all run clean

all: $(DISK)

$(BINDIR) $(BUILDDIR):
	mkdir -p $@

$(BOOT1): $(SRCDIR)/boot1.asm | $(BINDIR)
	$(ASM) -f bin $< -o $@

$(BOOT2): $(SRCDIR)/boot2.asm | $(BINDIR)
	$(ASM) -f bin $< -o $@

$(KERNEL): $(SRCDIR)/kernel.asm $(SRCDIR)/kernel.c linker.ld | $(BINDIR)
	$(ASM) -f elf32 $(SRCDIR)/kernel.asm -o $(BINDIR)/kasm.o
	$(CC) $(CFLAGS) $(SRCDIR)/kernel.c -o $(BINDIR)/kc.o
	$(LD) -m elf_i386 -T linker.ld -o $@ $(BINDIR)/kasm.o $(BINDIR)/kc.o --oformat binary

$(DISK): $(BOOT1) $(BOOT2) $(KERNEL) | $(BUILDDIR)
	dd if=/dev/zero of=$@ bs=1k count=1440 status=none
	dd if=$(BOOT1)  of=$@ bs=512 count=1 conv=notrunc status=none
	dd if=$(BOOT2)  of=$@ bs=512 seek=1 conv=notrunc status=none
	dd if=$(KERNEL) of=$@ bs=512 seek=2 conv=notrunc status=none

run: $(DISK)
	$(RUN) -fda $(DISK)

clean:
	rm -rf $(BINDIR) $(BUILDDIR)