; PET/CBM EDIT ROM - Extended ROM Code
; ================
; This code goes in the upper half of the 4K EDIT ROMS
; NOTE: The code from $E800-E8FF is not visible - fill with copyright or comments
;
;*=e800
;*********************************************************************************************************
;** Hidden I/O Area used for Copyright and version info text
;*********************************************************************************************************

!source "copyright-4v4e.asm"
!fill $e900-*,$ff 				; 169 bytes 

;*=e900

;*********************************************************************************************************
;** Start of Extended Code Area [E900]
;*********************************************************************************************************

!IF CRUNCH=0 {
           !byte $16,$44,$20,$20,$07,$01	;??????????
}

;*********************************************************************************************************
;** Jump Table for Extended Functions [E609]
;*********************************************************************************************************
; (Does anything use this table? - not called from EDITROM itself!)

!IF CRUNCH=0 {
           JMP CHROUT_WITH_DIACRITICS
           JMP IS_DIACRITIC_CHAR
           JMP Screen_Input_Ext
           JMP Check_Diacritic
           JMP IS_SPECIAL_KEY
           JMP IS_VOCAL
           JMP PET_TO_ASCII			;not called? not in EDITROM.ASM
           JMP SCAN_KEYBOARD

           !fill $e924-*,$aa			; 6 bytes
}

;*********************************************************************************************************
;** Extended Routines [E929-EC4A]
;*********************************************************************************************************

!source "extkeyscan.asm"			;[$E924] New Keyboard Scanner
!source "extprinting.asm"			;[$EA27] Enhanced printing
!source "extcrtc.asm"				;[$EBC2] New CRTC programming subs
!source "extclock.asm"				;[$EC0E] New Jiffy Clock routines
!source "exttabs.asm"				;[$EC4B] Tab Stops

;*********************************************************************************************************
;** Filler [EC55-EE84]
;*********************************************************************************************************

!IF CRUNCH=0 {	!fill $ee85-*,$ff }		; 560 bytes!!!!!!!!!!!!!!!!!!!!!!!!!!!

;*********************************************************************************************************
;** Extended Keyboard Scanning Tables [EE85]
;*********************************************************************************************************

!source "extkeytables.asm"

;*********************************************************************************************************
;** Keyboard Tables [EF5F]
;*********************************************************************************************************

!if KEYBOARD = 0 {!source "kbdx-n.asm" }
!if KEYBOARD = 1 {!source "kbdx-b.asm" }
!if KEYBOARD = 2 {!source "kbdx-din.asm" }
!if KEYBOARD = 3 {!source "kbdx-c64.asm" }
