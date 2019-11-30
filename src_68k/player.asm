playerInit:
	move.l #$00500000,player_xPos
	move.l #$00500000,player_yPos
playerSet:	
	move.w #SCB1+(33*64),LSPC_ADDR
	move.w #1,LSPC_INCR
	move.w #100,LSPC_DATA
	move.w #$200,LSPC_DATA
	move.w #103,LSPC_DATA
	move.w #$200,LSPC_DATA
	
	;set up shrink data in SCB2
	move.w #SCB2+33,LSPC_ADDR
	move.w #$0FFF,LSPC_DATA
	
	;set up y position data in SCB3
	move.w #SCB3+33,LSPC_ADDR
	move.w player_yPos,d0
	move.w #496,d1
	sub.w d0,d1
	asl.w #7,d1
	or.w #7,d1 ;sprite is 7 tiles high
	move.w d1,LSPC_DATA
	
	; sprite 1's x position in SCB4
	move.w #SCB4+33,LSPC_ADDR
	move.w player_xPos,d0
	asl.w #7,d0
	move.w d0,LSPC_DATA ;x pos
	rts

PLAYER_ACCEL equ $8000
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
		btst.b #JOY_LEFT,d1
		beq .NoLeft
			sub.l #PLAYER_ACCEL,player_xSpeed
		.NoLeft:
		btst.b #JOY_RIGHT,d1
		beq .NoRight
			add.l #PLAYER_ACCEL,player_xSpeed
		.NoRight:
.doneTests:
	move.l player_xPos,d0
	add.l player_xSpeed,d0
	move.l d0,player_xPos
	rts
	