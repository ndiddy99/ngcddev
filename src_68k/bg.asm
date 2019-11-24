;background display routines
SCREEN_COLS equ 20
LEFT_FLAG equ 1
RIGHT_FLAG equ 2

;loads background into 32x16 block
;a0: pointer to map data
;d0: which sprite # to load the bg at
bgLoad:
	move.w #1,LSPC_INCR
	asl.w #6,d0 ;d0 *= 64
	; add.w #SCB1,d0 ;scb0's address is 0 so this is unnecessary
	moveq #31,d1 ;#cols - 1
.copyRow:
	move.w d0,LSPC_ADDR
	moveq #15,d2 ;#rows - 1
	.copyCol:
		move.w (a0)+,LSPC_DATA ;tile
		move.w (a0)+,LSPC_DATA ;palette
		dbra d2,.copyCol
	add.w #64,d0
	dbra d1,.copyRow
	
	;no shrink
	move.w #SCB2+1,LSPC_ADDR
	moveq #31,d1
.copyShrink:
	move.w #$0FFF,LSPC_DATA ;no shrink
	dbra d1,.copyShrink
	
	;y pos = 0
	move.w #SCB3+1,LSPC_ADDR
	move.w #(496<<7)|16,LSPC_DATA ;496=0 y pos on neo geo, sprite is 16 tiles high
	moveq #30,d1
.copySticky:
	move.w #$40,LSPC_DATA
	dbra d1,.copySticky
	
	;x pos = 0
	move.w #SCB4+1,LSPC_ADDR
	move.w #0,LSPC_DATA
	
	rts
	
;updates bg from variables (called in vblank)
bgUpdate:
	move.w #SCB3+1,LSPC_ADDR
	move.w #(496<<7)|16,LSPC_DATA
	move.w #SCB4+1,LSPC_ADDR
	move.w bg1_xPos,d0
	neg.w d0 ;transform from "distance from start of map" to "distance leftmost sprite has gone
	asl.w #7,d0 ;offscreen"
	move.w d0,LSPC_DATA
	
	moveq #0,d0 ;clear all of d0
	move.w bg1_xPos,d0
	lsr.w #4,d0
	cmp.w bg1_copiedCol,d0
	beq .noTileBoundary
	blo .scrollingR
	.scrollingL: ;scroling left so copy more columns to the right
		move.w d0,bg1_copiedCol
		add.w #SCREEN_COLS+1,d0 ;get first offscreen column
		move.w d0,d1
		and.w #31,d1
		add.w #1,d1 ;we start from sprite 1, not sprite 0
		lea map,a0
		jmp copyCol ;not jsr because of tail-call
	.scrollingR: ;scrolling right so copy more columns to the left
		move.w d0,bg1_copiedCol
		sub #1,d0 ;get first offscreen column
		move.w d0,d1
		and.w #31,d1
		add.w #1,d1 ;we start from sprite 1, not sprite 0
		lea map,a0
		jmp copyCol ;not jsr because of tail-call	
.noTileBoundary:
	rts
	
;sets background position
;d0- bg x position
bgSet:
	cmp.w bg1_xPos,d0
	blo .scrollingL
	bhi .scrollingR
	clr.w bg1_direction ;not scrolling either way
	bra .doneTests
.scrollingL:
	move.w #LEFT_FLAG,bg1_direction
	bra .doneTests
.scrollingR:
	move.w #RIGHT_FLAG,bg1_direction
.doneTests:
	move.w d0,bg1_xPos
	rts

;d0: column number to copy from map (long)
;d1: sprite to copy it to (word)
;a0: map pointer
copyCol:
	move.w #1,LSPC_INCR
	asl.w #6,d1
	move.w d1,LSPC_ADDR
	asl.l #6,d0 ;each column is 16 tiles, 2 words per tile, 2 bytes per word
	add.l d0,a0
	moveq #15,d0 ;num tiles - 1
.copyLoop:
	move.w (a0)+,LSPC_DATA
	move.w (a0)+,LSPC_DATA
	dbra d0,.copyLoop
	rts
	
	