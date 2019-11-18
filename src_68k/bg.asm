;background display routines

;loads background into 32x14 block
;a0: pointer to map data
;d0: which sprite # to load the bg at
bgLoad:
	move.w #1,LSPC_INCR
	asl.w #6,d0 ;d0 *= 64
	; add.w #SCB1,d0 ;scb0's address is 0 so this is unnecessary
	moveq #31,d1 ;#cols - 1
.copyRow:
	move.w d0,LSPC_ADDR
	moveq #13,d2 ;#rows - 1
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
	move.w #(496<<7)|14,LSPC_DATA ;496=0 y pos on neo geo, sprite is 14 tiles high
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
	; move.w bg1_yPos,d1
	; move.w #496,d0
	; sub.w d1,d0
	; asl.w #7,d0
	; or.w #14,d0
	move.w #(496<<7)|14,LSPC_DATA
	move.w d0,LSPC_DATA
	move.w #SCB4+1,LSPC_ADDR
	move.w bg1_xPos,d0
	asl.w #7,d0
	move.w d0,LSPC_DATA
	rts

	