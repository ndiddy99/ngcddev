;returns the tile at that location in d0
;d0- x pos (word)
;d1- y pos (word)
;a0- map address
collision_tileAt:
	;x position: this is the same as dividing by 16 (tiles)
	;and multiplying by 64 (number of bytes in one tile column)
	and.l #$FFF0,d0 ;long so the upper half of d0 is also cleared
	lsl.w #2,d0 ;pixels to 16x16 tiles
	;y position: this is the same as dividing by 16 (tiles)
	;and multiplying by 4 (number of bytes in one tile def)
	and.l #$FFFF,d1 ;clear upper half of d1
	lsr.w #4,d1
	lsl.w #2,d1
	add.w d1,d0
	move.w (a0,d0),d0
	rts

;returns collision bitmask in d0
;d0- x pos (word)
;d1- y pos (word)
;d2- width (word)
;d3- height (word)
;a0- map address
COLLISION_LEFT equ 1
COLLISION_RIGHT equ 2
COLLISION_UP equ 4
COLLISION_DOWN equ 8
COLLISION_TOPLEFT equ 16
COLLISION_TOPRIGHT equ 32
COLLISION_BOTLEFT equ 64
COLLISION_BOTRIGHT equ 128
collision_check:
	and.l #$ffff,d0 ;delete top half of regs
	and.l #$ffff,d1
	and.l #$ffff,d2
	and.l #$ffff,d3
	moveq #0,d4 ;clear regs
	moveq #0,d5
	moveq #0,d6
	moveq #0,d7 ;clear d7 (temp storage for collision bitmask)
	;top left: x = sprite x, y = sprite y
	move.w d0,d4 ;copy values 
	move.w d1,d5
	and.w #$fff0,d4 ;same as x >> 4 * 64
	lsl.w #2,d4
	
	lsr.w #4,d5 ;same as (y/16)*4
	lsl.w #2,d5
	add.l d5,d4
	move.w (a0,d4),d6
	beq .noTopLeft
		or.w #COLLISION_TOPLEFT,d7
	.noTopLeft:
	;top right: x = sprite x + (width - 1), y = sprite y
	move.w d0,d4 ;copy x pos- reuse y pos from last check
	add.w d2,d4
	sub.w #1,d4 ;x + width - 1
	and.w #$fff0,d4
	lsl.w #2,d4
	
	add.l d5,d4
	move.w (a0,d4),d6
	beq .noTopRight
		or.w #COLLISION_TOPRIGHT,d7
	.noTopRight:
	;bottom left: x = sprite x, y = sprite y + (height-1)
	move.w d0,d4 ;copy values
	move.w d1,d5
	add.w d3,d5
	sub.w #1,d5
	
	and.w #$fff0,d4
	lsl.w #2,d4
	
	lsr.w #4,d5
	lsl.w #2,d5
	add.l d5,d4
	move.w (a0,d4),d6
	beq .noBotLeft
		or.w #COLLISION_BOTLEFT,d7
	.noBotLeft:
	;bottom right: x = sprite x + (width-1), y = sprite y + (height-1)
	move.w d0,d4
	add.w d2,d4
	sub.w #1,d4 ;reuse y pos from last time
	and.w #$fff0,d4
	lsl.w #2,d4

	add.l d5,d4
	move.w (a0,d4),d6
	beq .noBotRight
		or.w #COLLISION_BOTRIGHT,d7
	.noBotRight:
	
	;left collision: top or bottom left
	move.w d7,d0
	and.w #(COLLISION_TOPLEFT|COLLISION_BOTLEFT),d0
	beq .noLeft
		or.w #COLLISION_LEFT,d7
	.noLeft:
	;right collision: top or bottom right
	move.w d7,d0
	and.w #(COLLISION_TOPRIGHT|COLLISION_BOTRIGHT),d0
	beq .noRight
		or.w #COLLISION_RIGHT,d7
	.noRight:	
	;top collision: top left or top right
	move.w d7,d0
	and.w #(COLLISION_TOPLEFT|COLLISION_TOPRIGHT),d0
	beq .noUp
		or.w #COLLISION_UP,d7
	.noUp:	
	;bottom collision: bottom left or bottom right
	move.w d7,d0
	and.w #(COLLISION_BOTLEFT|COLLISION_BOTRIGHT),d0
	beq .noDown
		or.w #COLLISION_DOWN,d7
	.noDown:
	
	move.w d7,d0
	rts
	
