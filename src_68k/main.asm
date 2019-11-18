; a simple "Hello World" program (68000 code)
; from "Neo-Geo Assembly Programming for the Absolute Beginner" by freem
; http://ajworld.net/neogeodev/beginner/
;==============================================================================;
;-- includes --;
	include "inc/neogeo.inc"   ; hardware defines
	include "inc/ram_bios.inc" ; system ROM RAM usage
	include "ram_user.inc"     ; user ram, defined in a pretty lame way. sorry.
	
;==============================================================================;
;-- 68000 header --;
	include "header_68k.inc" ; 68k vectors

;-- Neo-Geo Header --;
	include "header_cd.inc" ; Neo-Geo CD systems header

	include "tools\neoconv\map1.map" ;map data

	include "print.asm" ;print routines
	include "sprite.asm" ;sprite copy routines
	include "bg.asm" ;bg simulation routines
	
;******************************************************************************;
; == The required routines == ;
;******************************************************************************;
; These four routines are defined in the system header.
; They *require* being jmp'd to, so watch out if you're enabling optimizations.
; (This is why devpac compatibility mode is enabled in the build process, as
; it disables optimizations by default.)

;==============================================================================;
; USER
; Respond to the system ROM's request (BIOS_USER_REQUEST).
;==============================================================================;

USER:
	move.b d0,REG_DIPSW ; kick watchdog
	lea $10F300,sp ; set stack pointer to $10F300 (BIOS_WORKRAM)
	move.w #0,LSPC_MODE ; Disable auto-animation and timer interrupts, set auto-anim speed to 0 frames
	move.w #7,LSPC_IRQ_ACK ; acknowledge all IRQs

	move.w #$2000,sr ; Enable VBlank interrupt, go Supervisor

	; Handle user request
	moveq #0,d0 ; clear all bits of d0
	move.b BIOS_USER_REQUEST,d0 ; put user request value into d0
	lsl.b #2,d0 ; shift value left twice to get offset into tbl_UserRequestCommands
	lea tbl_UserRequestCommands,a0 ; load address of user commands
	movea.l (a0,d0),a0 ; get address from table and offset
	jsr (a0) ; jump to subroutine (typically ends with a jmp SYSTEM_RETURN)
	jmp SYSTEM_RETURN ; this is here just in case it doesn't...?

;------------------------------------------------------------------------------;
; tbl_UserRequestCommands
; Table that contains the addresses for each BIOS_USER_REQUEST command.

tbl_UserRequestCommands:
	dc.l User_Initialize ; Command 0 (Initialize)
	dc.l SYSTEM_RETURN ; Command 1 (Custom Eyecatch, unused)
	dc.l User_Main ; Command 2 (Demo Game/Game)
	dc.l User_Main ; Command 3 (Title Display)

;==============================================================================;
; PLAYER_START
; Called when a player presses Start with coins in the machine or if the
; attract mode timer reaches 0 (when the compulsion timer is enabled).
;==============================================================================;

PLAYER_START:
	; In this demo, we don't handle the Start button, or coins, for that matter.
	rts

;==============================================================================;
; DEMO_END
;==============================================================================;

DEMO_END:
	rts ; we're not doing anything in this routine, so just exit.

;==============================================================================;
; COIN_SOUND
; Play a sound upon coin insertion.
;==============================================================================;

COIN_SOUND:
	rts  ; we're not doing anything in this routine, so just exit.

;******************************************************************************;
; == Interrupt Routines == ;
;******************************************************************************;
; These routines are called from external sources. Since they can interrupt the
; code at any possible moment, it's important to save and restore the registers
; before performing any work.

; (of course, you can still use instructions that don't touch the registers...)
;==============================================================================;
; VBlank
; Vertical blanking interrupt. Called once per frame.

VBlank:
	btst #7,BIOS_SYSTEM_MODE ; check if the System ROM wants to run its VBlank routine.
	bne.s .VBlank_game ; if not, run our VBlank.
	jmp SYSTEM_INT1 ; jump to system ROM's VBlank routine

.VBlank_game:
	movem.l d0-d7/a0-a6,-(sp) ; save registers to the stack
	move.w #4,LSPC_IRQ_ACK ; acknowledge the VBlank interrupt
	move.b d0,REG_DIPSW ; kick the watchdog

	; [Things to perform in VBlank]
	; VBlank is where you should be doing sprite data updates (SCB writes) and
	; palette RAM updates.
	;update RAM locations for joypad inputs
	jsr SYSTEM_IO
	jsr bgUpdate
	; move.w #1,LSPC_INCR
	; move.w #SCB2+1,LSPC_ADDR
	; moveq #9,d1 ;10 sprites - 1
	; .copySCB2:
		; move.w spr_xShrink,LSPC_DATA ;copy x/y shrink data by accessing x as a word
		; dbra d1,.copySCB2
	
	; move.w #SCB3+1,LSPC_ADDR ;y pos (given to LSPC as 496-yPos)
	; move.w spr_yPos,d0
	; move.w #496,d1
	; sub.w d0,d1
	; asl.w #7,d1
	; or.w #7,d1 ;sprite is 7 tiles high
	; move.w d1,LSPC_DATA
	
	; move.w #SCB4+1,LSPC_ADDR
	; move.w spr_xPos,d0
	; asl.w #7,d0
	; move.w d0,LSPC_DATA ;x pos
	

.VBlank_end:
	move.b #0,flag_VBlank ; clear vblank flag so WaitVBlank knows to stop
	movem.l (sp)+,d0-d7/a0-a6 ; restore registers from the stack
	rte

;==============================================================================;
; IRQ2
; Horizontal blanking interrupt.

IRQ2:
	move.w #2,LSPC_IRQ_ACK ; ack. interrupt #2 (HBlank)
	move.b d0,REG_DIPSW    ; kick watchdog
	rte

;==============================================================================;
; IRQ3
; Interrupt for CD systems.

IRQ3:
	move.w #1,LSPC_IRQ_ACK ; acknowledge interrupt 3
	move.b d0,REG_DIPSW ; kick watchdog
	rte

;==============================================================================;
; WaitVBlank
; Waits for VBlank to finish via a flag.
; (Not an interrupt routine, but related to it)

WaitVBlank:
	move.b #1,flag_VBlank ; set vblank flag to 1.
.WaitVBlank_loop:
	tst.b flag_VBlank ; check if vblank flag is 0.
	bne.s .WaitVBlank_loop ; if not zero, loop until it is.
	rts

;******************************************************************************;
; == USER request routines == ;
;******************************************************************************;
; User_Initialize

User_Initialize:
	; this would be the place to initialize high scores and other such data in
	; the backup RAM area (see cart/cd header, "pointer to backup RAM block").

	; in this demo we don't do anything, so just jump to SYSTEM_RETURN.
	jmp SYSTEM_RETURN

;==============================================================================;
; User_Main

User_Main:
	; In a real Neo-Geo program, this would be handled differently, but this is
	; a demo, so it's going to be simpler than expected.

	; --perform initialization, part 1--
	; (Palette)
	; The reference color (address $400000) must be set to the darkest possible
	; color, which is $8000. (Black with the 'dark bit' set.)
	move.w #$8000,PALETTE_REFERENCE

	; Set the background color ($401FFE) to a regular black ($0000).
	move.w #0,PALETTE_BACKDROP

	; Finally, we need to set a color for the text to display. Set the first
	; palette entry in the first palette row ($40xxxx) to white ($0FFF).
	move.w #$0FFF,PALETTES+2

	; (Fix Layer)
	; The System ROM provides a command to set up the Fix layer, and it should
	; typically be called at boot.
	jsr FIX_CLEAR ; jump to the FIX_CLEAR subroutine

	; (Sprites)
	; Sprites will need to be initialized as well. The System ROM provides a
	; routine for this purpose as well.
	jsr LSP_1st ; jump to the LSP_1st subroutine
	
	move.w #80,spr_xPos ;clear variables
	move.w #80,spr_yPos
	move.b #$f,spr_xShrink ;x shrink is only 4 bits, set to no shrinking
	move.b #$ff,spr_yShrink ;y shrink is 8 bits
	
	moveq #$1,d0 ;write to palette 1
	lea WeebPalette,a0
	jsr LoadPalette
	
	;tell MESS_OUT we're busy messing with the data, so don't run.
	bset.b	#0,BIOS_MESS_BUSY
	
	; ;set up tiles in SCB1
	; moveq #1,d0 ;sprite #1
	; moveq #0,d1 ;tile #0
	; moveq #10,d2 ;sprite is 10 tiles wide
	; moveq #7,d3 ;sprite is 7 tiles tall
	; move.w #$100,d4 ;palette 1, no special attributes
	; jsr spriteLoad
	
	moveq #1,d0
	lea map1,a0
	jsr bgLoad
	
	; ;set up shrink data in SCB2
	; move.w #SCB2+2,LSPC_ADDR
	; moveq #9,d1
	; .copySCB2:
		; move.w spr_xShrink,LSPC_DATA ;copy x/y shrink data by accessing x as a word
		; dbra d1,.copySCB2
	
	; ;set up y position data in SCB3
	; move.w #SCB3+1,LSPC_ADDR
	; move.w spr_yPos,d0
	; move.w #496,d1
	; sub.w d0,d1
	; asl.w #7,d1
	; or.w #7,d1 ;sprite is 7 tiles high
	; move.w d1,LSPC_DATA
	
	; move.w #8,d0 ;sticky bits for remaining 9 sprites
	; .copySCB3:
		; move.w #$40,LSPC_DATA
		; dbra d0,.copySCB3
	
	;sprite 1's x position in SCB4
	; move.w #SCB4+1,LSPC_ADDR
	; move.w spr_xPos,d0
	; asl.w #7,d0
	; move.w d0,LSPC_DATA ;x pos
	
	bclr.b	#0,BIOS_MESS_BUSY ;tell MESS_OUT it can run again
	
	;play track 2 from the cd
	moveq #2,d0 ;play track 2 with loop
CDDALoadLoop: ;metal slug 2 waits for this part of BIOS RAM to be non-zero
	tst.b $10F6D9 ;so it might be important?
	beq CDDALoadLoop
	jsr BIOSF_CDDACMD
	
	
Loop:
	move.b BIOS_P1CURRENT,d0
	; btst.b #JOY_UP,d0
	; beq .NoUp
		; sub.w #1,bg1_yPos
	; .NoUp:
	; btst.b #JOY_DOWN,d0
	; beq .NoDown
		; add.w #1,bg1_yPos
	; .NoDown:
	btst.b #JOY_LEFT,d0
	beq .NoLeft
		add.w #1,bg1_xPos
	.NoLeft:
	btst.b #JOY_RIGHT,d0
	beq .NoRight
		sub.w #1,bg1_xPos
	.NoRight:
	; btst.b #JOY_A,d0
	; beq .NoA
		; sub.b #1,spr_xShrink
	; .NoA:
	; btst.b #JOY_B,d0
	; beq .NoB
		; add.b #1,spr_xShrink
	; .NoB:	
	; btst.b #JOY_C,d0
	; beq .NoC
		; sub.b #1,spr_yShrink
	; .NoC:	
	; btst.b #JOY_D,d0
	; beq .NoD
		; add.b #1,spr_yShrink
	; .NoD:
	
	add.w #$1,frame_count	
	moveq #$4,d0
	moveq #$4,d1
	moveq #$3,d2
	lea frame_count,a0
	jsr fix_PrintHexWord
	
	lea BIOS_P1CURRENT,a0
	moveq #$4,d0
	moveq #$5,d1
	moveq #$3,d2
	jsr fix_PrintHexByte	
	jsr WaitVBlank
	jmp Loop

str_HelloWorld: dc.b "Hi, I'm a Neo-Geo CD!",$FF

WeebPalette:
	dc.w $B423,$3744,$0855,$7A65,$A869,$3C88,$4CA9,$4CBC,$0FB9,$0FDB,$1FDC,$2FED,$0FEF,$5FFF,$6FFF,$FFFF

;copies palette into palette ram
;d0- palette number to copy to (long)
;a0- pointer to palette to copy
LoadPalette:
	asl.w #$5,d0 ;multiply d0 by $20 to get where to write in palette ram
	add.l #PALETTES,d0
	move.l d0,a1 ;address to a1
	moveq #$F,d0 ;16 colors - 1
	.LoadLoop:
		move.w (a0)+,(a1)+ ;copy stuff from wram to palette ram
		dbra d0,.LoadLoop
	rts
	
	

	
