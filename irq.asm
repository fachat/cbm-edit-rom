; PET/CBM EDIT ROM - IRQ Handler Routines
; ================
; The IRQ does the work of updating the clock/timer, checking interrupts and calling the keyboard scanner.


IRQ_MAIN
		PHA
		TXA
		PHA
		TYA
		PHA
		TSX
		LDA STACK+4,X
		AND #16
		BEQ Be452
		JMP (CBINV)	; Vector: BRK Instr. Interrupt [D478]
Be452		JMP (CINV)	; Vector: Hardware Interrupt   [E455] Points to 'IRQ_NORMAL'

;*********************************************************************************************************
;** IRQ_NORMAL [$E455]
;*********************************************************************************************************

;************** IRQ (Called from Jump Table)
; The IRQ is fired when the CRTC chip does a VSYNC, so the timing is
; dependent on the CRTC configuration.
; Normally: $E455

IRQ_NORMAL
		!IF IRQFIX=1 {
			!IF CODEBASE=0 { JMP ADVANCE_TIMER }
			!IF CODEBASE=1 { JMP ADVANCE_TIMER }
			!IF CODEBASE=2 { JSR ADVANCE_TIMER }
		} ELSE {
			JSR UDTIME			; Update System Jiffy Clock. KERNAL routine $FFEA 			
		}

;		--------------------------------------- Blink the cursor

IRQ_NORMAL2						; ie458
		LDA Blink				; Cursor Blink enable: 0 = Flash Cursor
		BNE Be474				; skip it
		DEC BLNCT				; Timer: Countdown to Toggle Cursor
		BNE Be474				; skip it

		LDA #$14				; default cursor blink rate (20)
!if REPEATOPT = 1 {
		BIT RPTFLG				; check repeat flag
		BPL ie468				; skip if not enabled
		LDA #2					; make cursor blink immediately
}
ie468		STA BLNCT				; store to blink countdown counter
		LDY CursorCol				; Column where cursor lives
		LSR BlinkPhase				; Is it blinking?
		LDA (ScrPtr),Y				; Get character from the screen
		BCS Be470				; Yes, skip
		INC BlinkPhase				; count
		STA CursorChar				; Remember the character at cursor (to be restored when cursor moves)
Be470		EOR #$80				; Flip the reverse bit
		STA (ScrPtr),Y				; Put it back on the screen

;		--------------------------------------- Prep for keyboard scanning [$E47B]

Be474		LDY #0
		LDA PIA1_Port_A 			; Keyboard ROW select - PIA#1, Register 0
							; Upper bits: IEEE and Cassette
							; Lower bits: Keyboard ROW select
!if CODEBASE<2 {
		AND #$F0				; Mask off lower 4 bits (reset keyboard scan row)
		STA PIA1_Port_A				; Keyboard ROW select - PIA#1, Register 0				CHIP
		LDA PIA1_Port_A				; Keyboard ROW select - PIA#1, Register 0				CHIP
} 

;		--------------------------------------- Check IEEE and Cassette status

		ASL					; Shift upper bits to lower 
		ASL 
		ASL 
		BPL Be487				; Is CASSETTE#1 Sense? No, skip

		STY CAS1				; Yes, Tape Motor Interlock #1
		LDA PIA1_Cont_B				; PIA#1 Register 13 (Retrace flag and interrupt
		ORA #8					; Is CASSETTE#2 Sense?
		BNE Be490				; No, skip

Be487		LDA CAS1				; Yes, Tape Motor Interlock #1
		BNE Be493				; No, skip

		LDA PIA1_Cont_B				; PIA#1 Register 13 (Retrace flag and interrupt)
		AND #$f7				; Mask off bit 4
Be490		STA PIA1_Cont_B				; PIA#1 Register 13 (Retrace flag and interrupt)
Be493		BCC Be49e

		STY CAS2				; Tape Motor Interlock #2
		LDA VIA_Port_B				; VIA Register 0 (flags)
		ORA #16
		BNE Be4a7
Be49e		LDA CAS2				; Tape Motor Interlock #2
		BNE Be4aa
		LDA VIA_Port_B				; VIA Register 0 (flags)
		AND #$ef
Be4a7		STA VIA_Port_B				; VIA Register 0 (flags)
Be4aa		JSR SCAN_KEYBOARD			; Scan the keyboard

!IF KEYRESET=1 {  JSR CheckReboot }			; Check for soft reset ******* should this go above Be474 ?????????????????

		JMP IRQ_END				; Return from Interrupt

;