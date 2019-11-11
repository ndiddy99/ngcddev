
;load a sprite's tiles linearly into vram
;d0 - sprite to start with
;d1 - tile # to start with
;d2 - sprite width
;d3 - sprite height
spriteLoad:
	move.w #1,LSPC_INCR
	asl.w #6,d0 ;sprites are 64 words apart
	; add.w #SCB1,d0 ;initial offset (scb1 is 0)
	move.w d2,d4 ;loop counter:#rows
	sub.w #1,d4 ;make work with dbra
.copyRow:
	move.w d1,d5 ;tile num to d5
	move.w d0,LSPC_ADDR
	move.w d3,d6 ;loop counter:#cols
	sub.w #1,d6
	.copyCol:
		move.w d5,LSPC_DATA
		move.w #$100,LSPC_DATA
		add.w d2,d5 ;move to next row in the sprite
		dbra d6,.copyCol
	add.w #64,d0 ;each sprite is 64 words
	add.w #1,d1 ;move to next column
	dbra d4,.copyRow
	rts
	