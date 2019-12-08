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
