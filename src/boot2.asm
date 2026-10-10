org 0x7E00
bits 16

start:
	xor ax, ax
	mov ds, ax
	mov es, ax

	mov ax, 0x1000
	mov es, ax ;# segment
	xor bx, bx ;# offset 

	mov dl, 0x00 ;# floppy
	mov ch, 0x00 ;# cylinder 0
	mov cl, 0x03 ;# sector 2
	mov dh, 0x00 ;# head 0
	call read_sector

    xor ax, ax 
    mov es, ax

	cli            ; disable interrupts
	lgdt [GDT_Pointer]    ; load GDT register with start address of Global Descriptor Table
	mov eax, cr0 
	or eax, 1       ; set PE (Protection Enable) bit in CR0 (Control Register 0)
	mov cr0, eax

	; Perform far jump to selector 08h (offset into GDT, pointing at a 32bit PM code segment descriptor) 
	; to load CS with proper PM32 descriptor)
	jmp 08h:PModeMain

read_sector:
	mov ah, 0x02
	mov al, 0x01
	int 0x13
	jc fail
	ret

fail:
    xor ax, ax 
    mov es, ax
	mov si, error_msg
	call print_string
	ret
	jmp done

print_string:
	lodsb
	cmp al, 0
	je done
	
	mov ah, 0x0e
	int 0x10
	jmp print_string

done:
	ret


[bits 32]
PModeMain:
	mov	ax, 0x10		; set data segments to data selector (0x10)
	mov	ds, ax
	mov	ss, ax
	mov	es, ax

	jmp 0x10000


align 4
GDT_Table:
	; This is the beginning of the GDT. Because of this, its offset is 0.
	
	; null descriptor 
		dd 0 				; null descriptor--just fill 8 bytes with zero
		dd 0 
	
	; Notice that each descriptor is exactally 8 bytes in size. THIS IS IMPORTANT.
	; Because of this, the code descriptor has offset 0x8.
	
	; code descriptor:			; code descriptor. Right after null descriptor
		dw 0FFFFh 			; limit low
		dw 0 				; base low
		db 0 				; base middle
		db 10011010b 			; access
		db 11001111b 			; granularity
		db 0 				; base high
	
	; Because each descriptor is 8 bytes in size, the Data descritpor is at offset 0x10 from
	; the beginning of the GDT, or 16 (decimal) bytes from start.
	
	; data descriptor:			; data descriptor
		dw 0FFFFh 			; limit low (Same as code)
		dw 0 				; base low
		db 0 				; base middle
		db 10010010b 			; access
		db 11001111b 			; granularity
		db 0				; base high

GDT_End:

GDT_Pointer:
	dw GDT_End - GDT_Table - 1 
	dd GDT_Table

error_msg: db "Disk Read Error 2", 0

