
;load a sprite's tiles linearly into vram
;d0 - sprite to start with
;d1 - tile # to start with
;d2 - sprite width
;d3 - sprite height
;d4 - sprite attributes
spriteLoad:
	move.w #1,LSPC_INCR
	asl.w #6,d0 ;sprites are 64 words apart
	; add.w #SCB1,d0 ;initial offset (scb1 is 0)
	move.w d2,d5 ;loop counter:#rows
	sub.w #1,d5;make work with dbra
.copyRow:
	move.w d1,d6 ;tile num to d5
	move.w d0,LSPC_ADDR
	move.w d3,d7 ;loop counter:#cols
	sub.w #1,d7
	.copyCol:
		move.w d6,LSPC_DATA
		move.w d4,LSPC_DATA
		add.w d2,d6 ;move to next row in the sprite
		dbra d7,.copyCol
	add.w #64,d0 ;each sprite is 64 words
	add.w #1,d1 ;move to next column
	dbra d5,.copyRow
	rts
	