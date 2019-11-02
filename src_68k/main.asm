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

	include "print.asm" ;print routines
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
	; palette RAM updates. However, this demo doesn't use either...yet.

	; SNK also wants you to call SYSTEM_IO every 1/60th of a second. (probably 1/50th on PAL)
	; This is pretty important, otherwise the RAM locations for input variables
	; don't get updated (unless you do it yourself), among other things.
	jsr SYSTEM_IO
	

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

	jsr DrawHello_Routine ; draw "Hello World" string with a routine
	
Loop:
	add.w #$10,frame_count	
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

;******************************************************************************;
; == The Hello World example-specific code begins here. == ;
;******************************************************************************;

;==============================================================================;
; Writing Hello World on the Fix Layer with a routine
;==============================================================================;
; str_HelloWorld
; $FF-terminated hello world string, for use with fix_PrintString.
					 ;012345678901234567890
str_HelloWorld: dc.b "Hi, I'm a Neo-Geo CD!",$FF

; Note that even-length strings will need to be aligned properly, in order to
; prevent address errors.
str_HelloWorld2: dc.b "Hello World!",$FF,$00 ; unused, presented as example only

;------------------------------------------------------------------------------;
; DrawHello_Routine
; Uses the fix_PrintString to print the "Hello World" string to the screen.

DrawHello_Routine:
	moveq #$6,d0
	moveq #$10,d1 ;
	moveq #$03,d2 ; Palette 0, Page 3
	; (moveq is used to clear out any garbage from the top bits, since it will be shifted later.)
	lea str_HelloWorld,a0 ; load pointer to string into a0
	jsr fix_PrintString ; jump to the print string subroutine
	rts
