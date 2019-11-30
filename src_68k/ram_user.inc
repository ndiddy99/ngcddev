; USER RAM (begins at $100000)
USER_RAM equ $100000

; hblank and vblank flags
flag_VBlank equ USER_RAM ; (byte) vblank flag
frame_count equ flag_VBlank+2 ;(word) incremented every frame

spr_xPos equ frame_count+2 ;(word) sprite x position
spr_yPos equ spr_xPos+2 ;(word) sprite y position
spr_xShrink equ spr_yPos+2;(byte) sprite x shrink
spr_yShrink equ spr_xShrink+1;(byte)sprite y shrink

;bg.asm
bg1_xPos equ spr_yShrink+1 ;(word)
bg1_yPos equ bg1_xPos+2 ;word
bg1_direction equ bg1_yPos+2 ;word
bg1_copiedCol equ bg1_direction+2 ;word

;player.asm
player_xPos equ bg1_copiedCol+2 ;long
player_yPos equ player_xPos+4 ;long
player_xSpeed equ player_yPos+4 ;long
player_ySpeed equ player_xSpeed+4 ;long