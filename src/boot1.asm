org 0x7C00
bits 16

start:
	xor ax, ax
	mov ds, ax
	mov es, ax

	mov ax, 0x0000
	mov es, ax ;# segment
	mov bx, 0x7E00 ;# offset 
	mov dl, 0x00 ;# floppy
	mov ch, 0x00 ;# cylinder 0
	mov cl, 0x02 ;# sector 2
	mov dh, 0x00 ;# head 0
	call read_sector

	mov si, 0x7E00
	call print_string
	
	jmp 0x0000:0x7E00

read_sector:
	mov ah, 0x02
	mov al, 0x01
	int 0x13
	jc fail
	ret

fail:
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

error_msg: db "Disk Read Error 1", 0

times 510 - ($-$$) db 0
dw 0xAA55

