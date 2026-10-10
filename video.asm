LoadPalettes: ; Hardcoded for two palettes. EGA and Background
  stz CGADD ; start with color 0 (background)
	ldx #0 ; Set Index to zero
	@Loop:
	lda palette,x
	sta CGDATA
	inx
	cpx #64 ; 2x pal 16x colors 2x bytes
	bne @Loop
	rts 