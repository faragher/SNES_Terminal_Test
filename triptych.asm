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

;UpdateTriptych:
;	rts

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
	
ACCMul30:
	sta MATHSCRATCH
	asl ; x2
	asl ; x4
	asl ; x8
	asl ; x16
	asl ; x32
	clc
	sec
	sbc MATHSCRATCH
	sec
	sbc MATHSCRATCH
	rts

ACCMul40:
	pha
	asl ; x2
	asl ; x4
	asl ; x8
	asl ; x16
	asl ; x32
	sta MATHSCRATCH
	pla
	asl ; x2
	asl ; x4
	asl ; x8
	clc
	adc MATHSCRATCH
	rts
	
ACCMul3:
	phx
	php
	tax
	acc8
	lda TriLookup,X ; Lookup Mul by 3 (range 0-30 out) - No error handling!
	;and #$00ff
	plp
	plx
	rts

	
	
	
	
; Reference - for Notepad++ autocomplete, addresses outdated
; CURSORX = $203 ; Screenbuffer Index X
; CURSORY = $204 ; Screenbuffer Index Y
; TRIPTYCHOFINTEREST = $218 ; 16 bit
; GLYPHOFINTEREST = $21A ; 
; BUFFERMEMORYINDEX = $21B ; 16 bit
; BACKGROUNDMEMORYINDEX = $21D ; 16 bit
; BACKGROUNDMEMORYINDEX = $21D ; 16 bit
; SCREENINDEXSCRATCH = $21F ; 16 Bit