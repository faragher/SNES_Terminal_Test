; Update Triptych
TestTrip:
	.a16
	rep #$20 ; A 16-bit
; Compute Character Buffer pos from X/Y
; -- 40 characters per Y
	lda CURSORY
	jsr ACCMul40
	sta SCRATCH
; -- 1 character per X
	lda CURSORX
	clc
	adc SCRATCH
	sta BUFFERMEMORYINDEX

; Compute Tilemap address from X/Y
; -- 32 tiles per Y
	lda CURSORY
	jsr ACCMul32
	sta SCRATCH
; -- 3 tiles per Triptych
	lda CURSORX
	lsr ; /2
	lsr ; /4
	sta TRIPTYCHOFINTEREST
	clc
	adc SCRATCH
; -- Four bytes per tile
	asl ; x2
	asl ; x4
	sta BACKGROUNDMEMORYINDEX

; Set VRAM Address
; -- Set address to tilemap address above
	clc
	adc #VRAM_BG1
	sta VMADD
	
; Update Triptych X
; -- Load Glyph A Index
	lda BUFFERMEMORYINDEX ; Base ASCII code - 4 bytes per glyph means X4 required for offset
	asl ; x2
	asl ; x4 
	sta GLYPHAINDEX
	
; -- Load Glyph B Index
	lda BUFFERMEMORYINDEX ; As above
	inc ; This may be a 65c816 only command.
	asl ; x2
	asl ; x4
	sta GLYPHBINDEX
	
;; -- Load Glyph A
;; -- Align Glyph A
;; -- Load Glyph B
;; -- Align Glyph B
; -- Superimpose / OR glyphs
; -- Get Color Information (NYI)
; -- Render Bitplane A & B 
	jsr Render2BPPX ;
; -- Render Bttplane C & D
	jsr Render2BPPX ;

; Update Triptych Y

; Update Triptych Z

	.a8
	sep #$20 ; A 16-bit
	rts
	
	
; Render 2bpp Bitplane, index High / Low
Render2BPPX:
	pha
	phx
	phy
	.a8
	rep #$20 ; A 8-bit
	;-
	stz SCRATCHCHAR ; Loop counter for glyph rendering
	ldx GLYPHAINDEX ; load indices
	ldy GLYPHBINDEX
	@LoadLoop:
	lda SCREENBUFFER,x ; Load Glpyh A - Line SCRATCHCHAR
	sta GLYPHA
	lda SCREENBUFFER,y ; Load Glpyh B - Line SCRATCHCHAR
	lsr ; Six bit right shift
	lsr ;
	lsr ;
	lsr ;
	lsr ;
	lsr ; End right shift
	ora GLYPHA ; Composite scanline for glyphs
	stz VMDATAL ; Pallete index is false, skip
	sta VMDATAH ; Pallete index is true, send scanline
	inx ;
	iny ; Next Scanline
	lda SCRATCHCHAR ; Load our index position
	adc #1 ; Increment Index
	sta SCRATCHCHAR; Store new index
	cmp #8 ; Are we done with eight bytes of character?
	bne @LoadLoop ; Not yet
	;-
	.a16
	sep #$20 ; A 16-bit
	ply
	plx
	pla
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
; GLYPHAINDEX = $240 
; GLYPHBINDEX = $242
; SCRATCHGLYPH = $24b