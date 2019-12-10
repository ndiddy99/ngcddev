playerInit:
	;init player variables
	move.l #$00000000,player_xPos
	move.l #$00000000,player_yPos
	clr.l player_xSpeed
	clr.l player_ySpeed
	clr.w player_animTimer
	clr.w player_tileIndex
	;set up initial tilemap
	move.w #SCB1+(33*64),LSPC_ADDR
	move.w #1,LSPC_INCR
	move.w #100,LSPC_DATA
	move.w #$200,LSPC_DATA
	move.w #103,LSPC_DATA
	move.w #$200,LSPC_DATA
playerSet:
	;set up shrink data in SCB2
	move.w #SCB2+33,LSPC_ADDR
	move.w #$0FFF,LSPC_DATA
	
	;set up y position data in SCB3
	move.w #SCB3+33,LSPC_ADDR
	move.w player_yPos,d0
	move.w #496,d1
	sub.w d0,d1
	asl.w #7,d1
	or.w #2,d1 ;sprite is 2 tiles high
	move.w d1,LSPC_DATA
	
	; sprite 1's x position in SCB4
	move.w #SCB4+33,LSPC_ADDR
	move.w player_xPos,d0
	asl.w #7,d0
	move.w d0,LSPC_DATA ;x pos
	rts

PLAYER_ACCEL equ $8000
GRAVITY equ $6000
PLAYER_MAX_SPEED equ $48000
HORIZ_FLIP equ $1
PlayerTiles:
	dc.w 101,100,102,100,$FFFF
playerMove:
	move.b BIOS_P1CURRENT,d0
	move.b d0,d1
	and.b #$c,d0 ;are either left/right being pressed?
	bne .testDirs ;if yes, do normal acceleration stuff
		move.l player_xSpeed,d0
		beq .doneTests
		and.l #$80000000,d0
		beq .subSpeed
		.addSpeed:
			add.l #PLAYER_ACCEL,player_xSpeed
			bra .doneTests
		.subSpeed:
			sub.l #PLAYER_ACCEL,player_xSpeed
			bra .doneTests
	.testDirs:
		move.l player_xSpeed,d0
		btst.b #JOY_LEFT,d1
		beq .NoLeft
			sub.l #PLAYER_ACCEL,player_xSpeed
			cmp.l #-PLAYER_MAX_SPEED,d0
			bpl .dontClampLSpeed
				move.l #-PLAYER_MAX_SPEED,player_xSpeed
			.dontClampLSpeed:
			;mirror sprite so he's facing left
			move.w #SCB1+(33*64)+1,LSPC_ADDR
			clr.w LSPC_INCR
			move.w LSPC_DATA,d0
			or.w #HORIZ_FLIP,d0
			move.w d0,LSPC_DATA
			move.w #SCB1+(33*64)+3,LSPC_ADDR
			move.w LSPC_DATA,d0
			or.w #HORIZ_FLIP,d0
			move.w d0,LSPC_DATA
			
		.NoLeft:
		btst.b #JOY_RIGHT,d1
		beq .NoRight
			add.l #PLAYER_ACCEL,player_xSpeed
			cmp.l #PLAYER_MAX_SPEED,d0
			bmi .dontClampRSpeed
				move.l #PLAYER_MAX_SPEED,player_xSpeed
			.dontClampRSpeed:
			;unmirror sprite just in case :)
			move.w #SCB1+(33*64)+1,LSPC_ADDR
			clr.w LSPC_INCR
			move.w LSPC_DATA,d0
			and.w #~HORIZ_FLIP,d0
			move.w d0,LSPC_DATA	
			move.w #SCB1+(33*64)+3,LSPC_ADDR
			move.w LSPC_DATA,d0
			and.w #~HORIZ_FLIP,d0
			move.w d0,LSPC_DATA			
		.NoRight:
.doneTests:
	move.l player_xPos,d0
	add.l player_xSpeed,d0
	move.l d0,player_xPos
	
	btst.b #JOY_UP,d1
	beq .NoUp
		sub.l #$30000,player_yPos
	.NoUp:
	
	btst.b #JOY_DOWN,d1
	beq .NoDown
		add.l #$30000,player_yPos
	.NoDown:
	
	; move.l player_ySpeed,d0
	; add.l #GRAVITY,d0
	; move.l d0,player_ySpeed
	; add.l d0,player_yPos

	;animate player based on movement
	move.w player_xSpeed,d0
	bne .normalAnimate
		move.w #2,player_tileIndex
		bra .writeTile
	.normalAnimate:
		move.w player_animTimer,d0
		add.w #1,d0
		cmp.w #7,d0
		beq .animPlayer
			move.w d0,player_animTimer
			bra .dontAnim
		.animPlayer:
			clr.w player_animTimer
		.writeTile:
			move.w player_tileIndex,d0
			lea PlayerTiles,a0
			move.w (a0,d0),d1
			cmp.w #$FFFF,d1
			bne .notEndList
				move.w #0,d0
				move.w (a0),d1
		.notEndList:
			add.w #2,d0 ;next word
			move.w d0,player_tileIndex
			;correct tile is now in d1
			move.w #SCB1+(33*64),LSPC_ADDR
			move.w #2,LSPC_INCR
			move.w d1,LSPC_DATA
			add.w #3,d1
			move.w d1,LSPC_DATA
	.dontAnim:
	rts
	