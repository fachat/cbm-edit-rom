; PET/CBM EDIT ROM - AUTOBOOT - Code from Autoboot edit rom
; ================
;
; Appears to be made by a company called "Cyberia, Inc" 2330 Lincoln Way, IOWA
;
; This ROM stuffs a "SYS59279<CR>" ($E78F) into the keyboard buffer which causes it to
; run additional code that loads the "*" file from device 8 then runs it.
; Currently it is not clear to me, why it was done this way.
; Why not stuff "<SHIFT/RUN>" ($83) into the buffer?
;
;-------------- Editor Jump Table
; Patch at $E000

		JMP AUTOBOOT_INIT		; Modified to point to new routine


;-------------- TEXT to stuff into KEYBOARD BUFFER
; Patch at $E039

AB_SYS		!text "sys59279"
		!byte $0D


;--------------- Autoboot - stuff keyboard buffer using table at $E039 (9 bytes)
; Patch at $E1EF

AUTOBOOT_INIT	JSR RESET_EDITOR		; Do Normal Init
		LDX #9				; Length of string

AB_LOOP		LDA AB_SYS,X			; Get a key from table
		STA KEYD,X 			; put it in the Keyboard Buffer
		DEX
		BPL AB_LOOP			; loop until done

		LDA #9				; Length of string
		STA CharsInBuffer		; Set characters in keyboard buffer 
		RTS

;---------------- This is the code that is executed for AUTOBOOT
; Patch at $E78F

AB_E78F
		LDA $8E        			; Jiffy clock (second byte)
		BEQ AB_E78F     		; Delay loop

		LDA #$33       			; This address ($B433) contains "*"
		STA FNADR			; Filename pointer
		LDA #$B4
		STA FNADR+1 			; Filename pointer

		LDA #1       			; Length = 1
		STA FNLEN 			; Num characters in filename
		LDA #0
		STA $78 			; Basic pointer
		LDA #8       			; Device 8	
		STA FA				; Current file device#
		LDA #1
		STA FACTPA			; Misc work area

;--------------- start of loop

AB_E7AB
		LDA #0
		STA VERCK			; Work area
		STA STATUS			; IO status
		LDA #$60	
		STA SA				; Current file secondary address
		JSR $F4A5			; Open close parameters
		JSR $F0D2			; Send talk/listen
		LDA SA				; Ccurrent file secondary address
		JSR $F143			; Send byte and clear ATN
		JSR $F1C0	     		; Input byte from IEEE
		STA STAL        		; Temp pointer
		LDA STATUS 			; IO status
		BEQ AB_E7E5			; Skip ahead
		DEC FACTPA			; Misc work area
		BPL AB_E7D0			; Skip ahead
		JMP $B3FF 			; Warm start wait for basic command

AB_E7D0
		JSR $F0D5     			; Send talk/listen
		LDA #$6F
		STA SA				; Current file secondary address
		JSR $F143			; Write timeout/device not present
		LDA #$49
		JSR $F19E			; Input byte IEEE
		JSR $F1B9			; Input byte IEEE
		JMP AB_E7AB			; Loop back

AB_E7E5
		JSR $F387			; Perform LOAD
		LDA $78				; Inside CHRGET
		BNE AB_E7F7			; Skip ahead
		LDA EAL				; Get end of program
		STA VARTAB			; Copy to start of variables
		LDA EAL + 1			; Get end of program
		STA VARTAB + 1			; Copy to start of variables
		JSR $B5E9			; Perform CLR
AB_E7F7
		JSR $B622			; Reset BASIC execution to start
		JSR $B60B			; Perform CLR
		JMP $B74A			;
