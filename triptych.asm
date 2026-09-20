;---
; Get Triptych from CursorXY State
; In: None, All RAM
; Out: ACC - Triptych X pos (0-9)
;---
GetTrypticFromCursor:
	lda CURSORX ; Load Cursor X Position
	lsr ; / 2
	lsr ; / 4
	sta TRIPTYCHOFINTEREST
	
	rts

;---
; Get screenbuffer RAM location from X/Y Index
; In: None, all RAM locations
; Out: X - RAM location
;---
GetScreenbufferMemoryPosition:
	pha
	lda CURSORY
	jsr ACCMul40
	clc
	adc CURSORX
	tax
	pla
	rts
	


;---
; Update Triptych
;  in: None
; out: None
; mod: ACC, processor state (like carry)
;---

UpdateTriptych:
	rts

TwoBPPUploadX:
	lda #0
	sta SCRATCHCHAR ; Loop counter
	@TTLoop:
	lda NESfont,x ; Load first glyph. We're not worried about triptychs at this time - no offset
	sta GLYPHA
	lda NESfont,y ; load second glyph
	lsr
	lsr
	lsr
	lsr
	lsr
	lsr	; Six bit right shift
	; Composite Scanlines
  ora GLYPHA ; We should have the composite glyph scan line right now.
	; Upload scanlines in VRAM
	sta VMDATAL ; This is where color data matters
	@HighColor:
	sta VMDATAH
	@EndColor:
	inx
	iny
	lda SCRATCHCHAR ; Our current loop count
	clc
	adc #1
	sta SCRATCHCHAR
	cmp #$8
	bne @TTLoop
	rts
	
TwoBPPUploadY:
	lda #0
	sta SCRATCHCHAR ; Loop counter
	@TTLoop:
	lda NESfont,x ; Load first glyph. We're not worried about triptychs at this time - no offset
	asl
	asl
	sta GLYPHA
	lda NESfont,y ; load second glyph
	lsr
	lsr
	lsr
	lsr	; Four bit right shift
	; Composite Scanlines
  ora GLYPHA ; We should have the composite glyph scan line right now.
	; Upload scanlines in VRAM
	sta VMDATAL ; This is where color data matters
	@HighColor:
	sta VMDATAH
	@EndColor:
	inx
	iny
	lda SCRATCHCHAR ; Our current loop count
	clc
	adc #1
	sta SCRATCHCHAR
	cmp #$8
	bne @TTLoop
	rts
	
TwoBPPUploadZ:
	lda #0
	sta SCRATCHCHAR ; Loop counter
	@TTLoop:
	lda NESfont,x ; Load first glyph. We're not worried about triptychs at this time - no offset
	asl
	asl
	asl
	asl
	sta GLYPHA
	lda NESfont,y ; load second glyph
	lsr
	lsr; Two bit right shift
	; Composite Scanlines
  ora GLYPHA ; We should have the composite glyph scan line right now.
	; Upload scanlines in VRAM
	sta VMDATAL ; This is where color data matters
	@HighColor:
	sta VMDATAH
	@EndColor:
	inx
	iny
	lda SCRATCHCHAR ; Our current loop count
	clc
	adc #1
	sta SCRATCHCHAR
	cmp #$8
	bne @TTLoop
	rts
	
ACCMul8:
	asl ; x2
	asl ; x4
	asl ; x8 because of 8 byte characters
	rts

ACCMul32:
	asl ; x2
	asl ; x4
	asl ; x8
	asl ; x16
	asl ; x32
	rts

ACCMul40:
	pha
	asl ; x2
	asl ; x4
	asl ; x8
	asl ; x16
	asl ; x32
	sta SCRATCH
	pla
	asl ; x2
	asl ; x4
	clc
	adc SCRATCH
	rts

TTestTT:
  ; Panel X
	rep #$20
	.a16
	; Set VRAM Position
	ldx #VRAM_CHARSET ; Get CHARSET memory location
  stx VMADDL ; Tell PPU to set that location as active
	; ASCII Char to NESfont Position
	lda TRIPTYCHOFINTEREST ; X Position of Triptych
	and #$00ff ; Because we're loading 16 bits on an 8 bit memory location
	asl ; x 2
	asl ; x 4
	sta SCRATCH ; Store X Pos of leftmost memory location
	lda CURSORY ; 
	jsr ACCMul40 ; 40 x Y pos for memory location
	clc ;
	adc SCRATCH ; 40*Y+4*Triptych index
	;; adc #SCREENBUFFER ; Add Screenbuffer base address
	sta BUFFERMEMORYINDEX ; Save memory Offset
	tax ; More running around for indexed mode since I can't indirect
	lda SCREENBUFFER,X ; Load Char from location
	;lda BUFFERMEMORYINDEX ; Load char from location
	and #$00ff ; Yup, 16 to 8 bit again
	;;lda #$41 ; Force an 'A' glyph for testing- Be careful of 16 bit ACC when active
	jsr ACCMul8 ; x8 for 8 byte characters
	tax ; Transfer address to X register
	;;lda #$42 ; Force a 'B' glyph for testing
	ldy BUFFERMEMORYINDEX;
	iny ; BUFFERMEMORYINDEX + 1
	lda SCREENBUFFER,Y;
	and #$00ff
	jsr ACCMul8 ; x8 for 8 byte characters
	tay ; Second glyph to Y
	; Get Color Info
	; Skipping . . .
	sep #$20
	.a8
	phx
	phy
	jsr TwoBPPUploadX
	ply
	plx
	jsr TwoBPPUploadX
	; Panel Y
		rep #$20
	.a16
	; Set VRAM Position
	;ldx #VRAM_CHARSET ; Get CHARSET memory location
  ;stx VMADDL ; Tell PPU to set that location as active
	; ASCII Char to NESfont Position
	ldx BUFFERMEMORYINDEX
	inx
	lda SCREENBUFFER,X
	and #$00ff
	;;lda #$42 ; Force an 'A' glyph for testing- Be careful of 16 bit ACC when active
	jsr ACCMul8 ; x8 for 8 byte characters
	tax ; Transfer address to X register
	ldy BUFFERMEMORYINDEX
	iny
	iny
	lda SCREENBUFFER,Y;
	and #$00ff
	;;lda #$43 ; Force a 'B' glyph for testing
	jsr ACCMul8 ; x8 for 8 byte characters
	tay ; Second glyph to Y
	; Get Color Info
	; Skipping . . .
	sep #$20
	.a8
	phx
	phy
	jsr TwoBPPUploadY
	ply
	plx
	jsr TwoBPPUploadY
	; Panel Z
		rep #$20
	.a16
	; Set VRAM Position
	;ldx #VRAM_CHARSET ; Get CHARSET memory location
  ;stx VMADDL ; Tell PPU to set that location as active
	; ASCII Char to NESfont Position
	ldx BUFFERMEMORYINDEX
	inx
	inx
	lda SCREENBUFFER,X
	and #$00ff
	;;lda #$42 ; Force an 'A' glyph for testing- Be careful of 16 bit ACC when active
	jsr ACCMul8 ; x8 for 8 byte characters
	tax ; Transfer address to X register
	ldy BUFFERMEMORYINDEX
	iny
	iny
	iny
	lda SCREENBUFFER,Y;
	and #$00ff
	jsr ACCMul8 ; x8 for 8 byte characters
	tay ; Second glyph to Y
	; Get Color Info
	; Skipping . . .
	sep #$20
	.a8
	phx
	phy
	jsr TwoBPPUploadZ
	ply
	plx
	jsr TwoBPPUploadZ
	rts

	
	
	
	
; Reference
; CURSORX = $203 ; Screenbuffer Index X
; CURSORY = $204 ; Screenbuffer Index Y
; TRIPTYCHOFINTEREST = $218 ; 16 bit
; GLYPHOFINTEREST = $21A ; 
; BUFFERMEMORYINDEX = $21B ; 16 bit
; BACKGROUNDMEMORYINDEX = $21D ; 16 bit