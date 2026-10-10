ASM = nasm
ASMFLAGS = -f bin
BOOT1_TARGET = boot1.bin
BOOT2_TARGET = boot2.bin
KERNEL_TARGET = kernel.bin
DISK = disk.img
RUN = qemu-system-x86_64
SRCDIR = src
BUILDDIR = build
BINDIR = bin
# SRC = $(SRCDIR)/boot.asm

#all: $(BOOT1_TARGET) $(BOOT2_TARGET)
all: $(DISK)

$(DISK): $(BOOT1_TARGET) $(BOOT2_TARGET) $(KERNEL_TARGET)
	dd if=/dev/zero of=$(BUILDDIR)/disk.img bs=1k count=1440 status=none conv=notrunc
	dd if=$(BINDIR)/$(BOOT1_TARGET) of=$(BUILDDIR)/disk.img bs=512 count=1 conv=notrunc
	dd if=$(BINDIR)/$(BOOT2_TARGET) of=$(BUILDDIR)/disk.img bs=512 seek=1 conv=notrunc
	dd if=$(BINDIR)/$(KERNEL_TARGET) of=$(BUILDDIR)/disk.img bs=512 seek=2 conv=notrunc

$(BOOT1_TARGET): $(SRCDIR)/boot1.asm
	$(ASM) $(ASMFLAGS) $(SRCDIR)/boot1.asm -o $(BINDIR)/$(BOOT1_TARGET)

$(BOOT2_TARGET): $(SRCDIR)/boot2.asm
	$(ASM) $(ASMFLAGS) $(SRCDIR)/boot2.asm -o $(BINDIR)/$(BOOT2_TARGET)

$(KERNEL_TARGET): $(SRCDIR)/kernel.asm $(SRCDIR)/kernel.c
	$(ASM) -f elf32 $(SRCDIR)/kernel.asm -o $(BINDIR)/kasm.o
	gcc -m32 -c $(SRCDIR)/kernel.c -o $(BINDIR)/kc.o -std=gnu99 -ffreestanding -fno-pic -O2
	ld -m elf_i386 -T linker.ld -o $(BINDIR)/kernel.bin $(BINDIR)/kasm.o $(BINDIR)/kc.o --oformat binary


run: $(DISK)
	$(RUN) -fda $(BUILDDIR)/$(DISK)

clean:
	rm -f $(BINDIR)/$(BOOT1_TARGET) $(BINDIR)/$(BOOT2_TARGET) $(BINDIR)/$(KERNEL_TARGET) $(BINDIR)/kasm.o $(BINDIR)/kc.o $(BUILDDIR)/$(DISK)