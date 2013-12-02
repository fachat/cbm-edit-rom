; PET/CBM EDIT ROM - CRTC Setup Tables - OLD
; ================   80 Column x 25 Line, 50 Hz Line, 20 kHz Horizontal (for internal monitor)
;
; These tables are used to program the CRTC chip to set the screen to the proper rows, columns, and timing 

;--------- Text Mode - 80 column, 50 Hz, 20 kHz

CRT_CONFIG_TEXT_OLD
           !byte $3a,$28,$2c,$08,$20,$09,$19,$1d
           !byte $00,$09,$00,$00,$30,$00,$00,$00
           !byte $00,$00

;--------- Graphics Mode - 80 column, 50 Hz, 20 kHz

CRT_CONFIG_GRAPHICS_OLD
           !byte $3a,$28,$2c,$08,$29,$03,$19,$22
           !byte $00,$07,$00,$00,$30,$00,$00,$00
           !byte $00,$00
