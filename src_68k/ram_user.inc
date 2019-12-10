; USER RAM (begins at $100000)
USER_RAM equ $100000

; hblank and vblank flags
flag_VBlank equ USER_RAM ; (byte) vblank flag
frame_count equ flag_VBlank+2 ;(word) incremented every frame
curr_tile equ frame_count+2 ;(word) current tile player's on

;bg.asm
bg1_xPos equ curr_tile+2 ;(word)
bg1_yPos equ bg1_xPos+2 ;word
bg1_direction equ bg1_yPos+2 ;word
bg1_copiedCol equ bg1_direction+2 ;word

;player.asm
player_xPos equ bg1_copiedCol+2 ;long
player_yPos equ player_xPos+4 ;long
player_xSpeed equ player_yPos+4 ;long
player_ySpeed equ player_xSpeed+4 ;long
player_animTimer equ player_ySpeed+4 ;word
player_tileIndex equ player_animTimer+2 ;word, current location in tile array
player_collision equ player_tileIndex+2 ;word, player collision bitmask