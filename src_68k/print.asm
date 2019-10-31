FIX_ADDR equ $7022 ;top/left of FIX area screen
LO_NYBBLE_MASK equ $0F
HI_NYBBLE_MASK equ $F0
ASCII_BASE equ $30 ;what to add to numbers from 0-9 to get equivalent ascii value
ASCII_A_BASE equ $37 ;what to add to numbers from a-f

; fix_PrintString
; Prints a string on the Fix layer.

; (Params)
; d0 - [word] Fix layer X position
; d1 - [word] Fix layer y position
; d2 - [byte] Palette number and page number
; a0 - [long] Pointer to string to write

fix_PrintString:
	move.w #$20,LSPC_INCR ; set LSPC increment to $20/32 (horizontal writing)
	asl.w #$5,d0 ;x position on FIX layer increments by $20
	add.w d1,d0 ;y position on FIX layer increments by 1
	add.w #FIX_ADDR,d0 ;calculate offset from start of FIX
	move.w d0,LSPC_ADDR ; set up LSPC address from param in d0
	moveq #0,d0 ; clear d0 so we can use it in the loop without issue.
	asl.w #8,d2 ; move byte from param in d2 to upper half of word

.fix_PrintString_Loop:
	move.b (a0)+,d0 ; get character from string and increment pointer position
	cmpi.b #$FF,d0 ; check if this character is $FF (the terminator)
	beq.s .fix_PrintString_End ; if so, we're done with the string; exit the routine.

	; normal execution:
	or.w d2,d0 ; OR with the palette and page number
	move.w d0,LSPC_DATA ; write tile to fix layer
	bra.s .fix_PrintString_Loop ; loop back for another character

.fix_PrintString_End:
	rts

; fix_PrintHexByte
; Prints a byte on the Fix layer.

; (Params)
; d0 - [word] Fix layer X position
; d1 - [word] Fix layer y position
; d2 - [byte] Palette number and page number
; a0 - [long] Pointer to byte to print

fix_PrintHexByte:
	move.w #$20,LSPC_INCR ; set LSPC increment to $20/32 (horizontal writing)
	asl.w #$5,d0 ;x position on FIX layer increments by $20
	add.w d1,d0 ;y position on FIX layer increments by 1
	add.w #FIX_ADDR,d0 ;calculate offset from start of FIX
	move.w d0,LSPC_ADDR ; set up LSPC address from param in d0
	asl.w #8,d2 ; move byte from param in d2 to upper half of word
	moveq #$0,d0 ;clear d0
	move.b (a0),d1 ;load byte to print from ram
	;print high nybble
	move.b d1,d0
	lsr.b #$4,d0 ;isolate high nybble
	cmp.b #$A,d0
	bcs .9orLess
		add.b #ASCII_A_BASE,d0
		jmp .doneAdd
	.9orLess:
		add.b #ASCII_BASE,d0
	.doneAdd:
	or.w d2,d0
	move.w d0,LSPC_DATA
	;print low nybble
	HiNybble: ;label to allow local labels to work
	move.b d1,d0
	and.b #LO_NYBBLE_MASK,d0 ;isolate low nybble
	cmp.b #$A,d0 
	bcs .9orLess
		add.b #ASCII_A_BASE,d0
		jmp .doneAdd
	.9orLess:
		add.b #ASCII_BASE,d0
	.doneAdd:
	or.w d2,d0 ; OR with the palette and page number
	move.w d0,LSPC_DATA ; write tile to fix layer
	rts