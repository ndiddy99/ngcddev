; USER RAM (begins at $100000)
USER_RAM equ $100000

; hblank and vblank flags
flag_VBlank equ USER_RAM ; (byte) vblank flag
frame_count equ flag_VBlank+1 ;(byte) incremented every frame