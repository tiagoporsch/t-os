org 0x7C00
bits 16
boot:
	; Setup stack
	xor ax, ax
	mov ss, ax
	mov sp, 0x7000

	; Set up registers
	xor ax, ax
	mov ds, ax
	mov es, ax

	; Load kernel
	mov ah, 0x42
	mov dl, 0x80
	mov si, dap
	int 0x13

	; Set up paging
	; zero out a 16KiB buffer at 0x1000
	mov edi, 0x1000
	mov ecx, 0x1000
	xor eax, eax
	cld
	rep stosd

	mov edi, 0x1000
	; build P4
	lea eax, [es:di + 0x1000]
	or eax, 0x3
	mov [es:di], eax

	; build P3
	lea eax, [es:di + 0x2000]
	or eax, 0x3
	mov [es:di + 0x1000], eax

	; build P2
	lea eax, [es:di + 0x3000]
	or eax, 0x3
	mov [es:di + 0x2000], eax

	; build P1s
	lea di, [di + 0x3000]
	mov eax, 0x3
.loop:
	mov [es:di], eax
	add eax, 0x1000
	add di, 8
	cmp eax, 0x200000	; 2 MiB
	jb .loop

	; Disable IRQs
	mov al, 0xFF
	out 0xA1, al
	out 0x21, al

	; Enter long mode
	; set PAE, PGE, OSFXSR and OSXMMEXCPT bits
	mov eax, 0b11010100000
	mov cr4, eax

	; point CR3 at the P4
	mov edx, 0x1000
	mov cr3, edx

	; set the LME bit
	mov ecx, 0xC0000080
	rdmsr
	or eax, 0x100
	wrmsr

	; activate long mode
	; clear EM and set MP bits
	mov ebx, cr0
	and ebx, ~(1 << 3)
	or ebx, 0x80000011
	mov cr0, ebx

	; Load the GDT
	lgdt [gdt.descriptor]

	; Long mode jump
	jmp gdt.code:main64


; Global descriptor table
align 8
gdt:
	dq 0x0000000000000000
.code: equ $ - gdt
	dq 0x00209A0000000000
.data: equ $ - gdt
	dq 0x0000920000000000
.descriptor:
	dw $ - gdt - 1
	dd gdt

; Data address packet
dap:
.size		db 0x10
.unused		db 0x00
.sectors	dw 0x10
.offset		dw 0x0
.segment	dw 0x7E0
.lba		dq 0x1

; 64 bits
bits 64
main64:
	; Set up registers
	mov ax, gdt.data
	mov ds, ax
	mov es, ax
	mov fs, ax
	mov gs, ax
	mov ss, ax

	jmp buffer

; Padding
times 510 - ($ - $$) db 0
dw 0xaa55

; Buffer
buffer:
