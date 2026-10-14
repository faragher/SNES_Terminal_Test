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
	sta BUFFERMEMORYINDEX ; We need to deal with this for Triptych purposes

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
	; sta BACKGROUNDMEMORYINDEX ; I Probably utterly incorrect

; Set VRAM Address
; -- Set address to tilemap address above
	clc
	adc #VRAM_CHARSET ; It's zero. Why do we care? Compatibility?
	sta VMADD
	
; Update Triptych X
; -- Load Glyph A Index
	ldx BUFFERMEMORYINDEX ; Where we're looking relative to the Screen Buffer
	lda SCREENBUFFER,x; Base ASCII code - 4bpp means X4 required for	offset
	and #$00ff
	sta GLYPHAINDEX
	
; -- Load Glyph B Index
	ldy BUFFERMEMORYINDEX ; As above
	iny
	lda SCREENBUFFER,y
	and #$00ff
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
	lda GLYPHBINDEX
	sta GLYPHAINDEX
	ldy BUFFERMEMORYINDEX
	iny
	iny
	lda SCREENBUFFER,y
	and #$00ff
	sta GLYPHBINDEX
	jsr Render2BPPY
	jsr Render2BPPY

; Update Triptych Z
	lda GLYPHBINDEX
	sta GLYPHAINDEX
	ldy BUFFERMEMORYINDEX
	iny
	iny
	iny
	lda SCREENBUFFER,y
	and #$00ff
	sta GLYPHBINDEX
	jsr Render2BPPZ
	jsr Render2BPPZ

	.a8
	sep #$20 ; A 16-bit
	rts
	
	
; Render 2bpp Bitplane, index High / Low
Render2BPPX:
	pha
	phx
	phy
	acc16
	;acc8
	;-
	stz SCRATCHCHAR ; Loop counter for glyph rendering
	lda GLYPHAINDEX ; load indices
	asl ;
	asl ;
	asl ;
	tax ;
	lda GLYPHBINDEX
	asl ;
	asl ;
	asl ;
	tay
	@LoadLoop:
	lda NESfont,x ; Load Glpyh A - Line SCRATCHCHAR
	and #$00ff
	sta GLYPHA
	lda NESfont,y ; Load Glpyh B - Line SCRATCHCHAR
	and #$00ff
	lsr ; Six bit right shift
	lsr ;
	lsr ;
	lsr ;
	lsr ;
	lsr ; End right shift
	ora GLYPHA ; Composite scanline for glyphs
	acc8
	stz VMDATAL ; Pallete index is false, skip
	sta VMDATAH ; Pallete index is true, send scanline
	acc16
	inx ;
	iny ; Next Scanline
	lda SCRATCHCHAR ; Load our index position
	inc ; Increment Index
	sta SCRATCHCHAR; Store new index
	cmp #8 ; Are we done with eight bytes of character?
	bne @LoadLoop ; Not yet
	;-
	;acc16
	ply
	plx
	pla
	rts
	
; Render 2bpp Bitplane, index High / Low
Render2BPPY:
	pha
	phx
	phy
	acc16
	;acc8
	;-
	stz SCRATCHCHAR ; Loop counter for glyph rendering
	lda GLYPHAINDEX ; load indices
	asl ;
	asl ;
	asl ;
	tax ;
	lda GLYPHBINDEX
	asl ;
	asl ;
	asl ;
	tay
	@LoadLoop:
	lda NESfont,x ; Load Glpyh A - Line SCRATCHCHAR
	and #$00ff
	asl
	asl
	sta GLYPHA
	lda NESfont,y ; Load Glpyh B - Line SCRATCHCHAR
	and #$00ff
	lsr ; Six bit right shift
	lsr ;
	lsr ;
	lsr ; End right shift
	ora GLYPHA ; Composite scanline for glyphs
	acc8
	sta VMDATAL ; Pallete index is false, skip
	stz VMDATAH ; Pallete index is true, send scanline
	acc16
	inx ;
	iny ; Next Scanline
	lda SCRATCHCHAR ; Load our index position
	inc ; Increment Index
	sta SCRATCHCHAR; Store new index
	cmp #8 ; Are we done with eight bytes of character?
	bne @LoadLoop ; Not yet
	;-
	;acc16
	ply
	plx
	pla
	rts
	; Render 2bpp Bitplane, index High / Low
Render2BPPZ:
	pha
	phx
	phy
	acc16
	;acc8
	;-
	stz SCRATCHCHAR ; Loop counter for glyph rendering
	lda GLYPHAINDEX ; load indices
	asl ;
	asl ;
	asl ;
	tax ;
	lda GLYPHBINDEX
	asl ;
	asl ;
	asl ;
	tay
	@LoadLoop:
	lda NESfont,x ; Load Glpyh A - Line SCRATCHCHAR
	and #$00ff
	asl
	asl
	asl
	asl
	sta GLYPHA
	lda NESfont,y ; Load Glpyh B - Line SCRATCHCHAR
	and #$00ff
	lsr ; Six bit right shift
	lsr ; End right shift
	ora GLYPHA ; Composite scanline for glyphs
	acc8
	sta VMDATAL ; Pallete index is false, skip
	sta VMDATAH ; Pallete index is true, send scanline
	acc16
	inx ;
	iny ; Next Scanline
	lda SCRATCHCHAR ; Load our index position
	inc ; Increment Index
	sta SCRATCHCHAR; Store new index
	cmp #8 ; Are we done with eight bytes of character?
	bne @LoadLoop ; Not yet
	;-
	;acc16
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