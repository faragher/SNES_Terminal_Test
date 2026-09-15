;---
; Get Triptych from CursorXY State
;
;
;---
GetTrypticFromCursor:
	lda CURSORX ; Load Cursor X Position
	lsr ; / 2
	lsr ; / 4
	sta TRIPTYCHOFINTEREST
	
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

TTestTT:
  ; Panel X
	rep #$20
	.a16
	; Set VRAM Position
	ldx #VRAM_CHARSET ; Get CHARSET memory location
  stx VMADDL ; Tell PPU to set that location as active
	; ASCII Char to NESfont Position
	lda #$41 ; Force an 'A' glyph for testing- Be careful of 16 bit ACC when active
	jsr ACCMul8 ; x8 for 8 byte characters
	tax ; Transfer address to X register
	lda #$42 ; Force a 'B' glyph for testing
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
	lda #$42 ; Force an 'A' glyph for testing- Be careful of 16 bit ACC when active
	jsr ACCMul8 ; x8 for 8 byte characters
	tax ; Transfer address to X register
	lda #$43 ; Force a 'B' glyph for testing
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
	lda #$43 ; Force an 'A' glyph for testing- Be careful of 16 bit ACC when active
	jsr ACCMul8 ; x8 for 8 byte characters
	tax ; Transfer address to X register
	lda #$44 ; Force a 'B' glyph for testing
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

TTestTTB:
	rep #$20
	.a16
	; Set VRAM Position

	; ASCII Char to NESfont Position
	lda #$42 ; Force an 'B' glyph for testing- Be careful of 16 bit ACC when active
	asl ; x2
	asl ; x4
	asl ; x8 because of 8 byte characters
	tax ; Transfer address to X register
	lda #$43 ; Force a 'C' glyph for testing
	asl
	asl
	asl
	tay ; Second glyph to Y
	; Get Color Info
	; Skipping . . .
	sep #$20
	.a8
	
	lda #0
	sta SCRATCHCHAR ; Loop counter
	phx
	phy
	@TTLoop:
	lda NESfont,x ; Load first glyph. We're not worried about triptychs at this time - no offset
	asl
	asl
	sta GLYPHA
	lda NESfont,y ; load second glyph
	lsr
	lsr
	lsr
	lsr	; four bit right shift
	; Composite Scanlines
  ora GLYPHA ; We should have the composite glyph scan line right now.
	; Upload scanlines in VRAM
	sta VMDATAL ; This is where color data matters
	sta VMDATAH
	inx
	iny
	lda SCRATCHCHAR ; Our current loop count
	clc
	adc #1
	sta SCRATCHCHAR
	cmp #$8
	bne @TTLoop
	
	ply
	plx
	lda #0
	sta SCRATCHCHAR ; Loop counter

	@TTLoopA:
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
	sta VMDATAH
	inx
	iny
	lda SCRATCHCHAR ; Our current loop count
	clc
	adc #1
	sta SCRATCHCHAR
	cmp #$8
	bne @TTLoopA
	rts
	
TTestTTC:
	rep #$20
	.a16
	; Set VRAM Position

	; ASCII Char to NESfont Position
	lda #$43 ; Force an 'A' glyph for testing- Be careful of 16 bit ACC when active
	asl ; x2
	asl ; x4
	asl ; x8 because of 8 byte characters
	tax ; Transfer address to X register
	lda #$44 ; Force a 'B' glyph for testing
	asl
	asl
	asl ; Bytes
	tay ; Second glyph to Y
	; Get Color Info
	; Skipping . . .
	sep #$20
	.a8
	
	lda #0
	sta SCRATCHCHAR ; Loop counter
	phx
	phy
	@TTLoop:
	lda NESfont,x ; Load first glyph. We're not worried about triptychs at this time - no offset
	asl
	asl
	asl
	asl
	sta GLYPHA
	lda NESfont,y ; load second glyph
	lsr
	lsr	; Two bit right shift
	; Composite Scanlines
  ora GLYPHA ; We should have the composite glyph scan line right now.
	; Upload scanlines in VRAM
	sta VMDATAL ; This is where color data matters
	sta VMDATAH
	inx
	iny
	lda SCRATCHCHAR ; Our current loop count
	clc
	adc #1
	sta SCRATCHCHAR
	cmp #$8
	bne @TTLoop
	
	ply
	plx
	lda #0
	sta SCRATCHCHAR ; Loop counter

	@TTLoopA:
	lda NESfont,x ; Load first glyph. We're not worried about triptychs at this time - no offset
	asl
	asl
	asl
	asl
	sta GLYPHA
	lda NESfont,y ; load second glyph
	lsr
	lsr	; Two bit right shift
	; Composite Scanlines
  ora GLYPHA ; We should have the composite glyph scan line right now.
	; Upload scanlines in VRAM
	sta VMDATAL ; This is where color data matters
	sta VMDATAH
	inx
	iny
	lda SCRATCHCHAR ; Our current loop count
	clc
	adc #1
	sta SCRATCHCHAR
	cmp #$8
	bne @TTLoopA
	rts	
	
	
	
	
; Reference
; CURSORX = $203 ; Screenbuffer Index X
; CURSORY = $204 ; Screenbuffer Index Y
; TRIPTYCHOFINTEREST = $218 ; 16 bit
; GLYPHOFINTEREST = $21A ; 
; BUFFERMEMORYINDEX = $21B ; 16 bit
; BACKGROUNDMEMORYINDEX = $21D ; 16 bit