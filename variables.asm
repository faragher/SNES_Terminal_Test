; Variable Definitions


;--- Test Attributes
;INTCOUNTER = $200 ; Counts Interrups for time-based activities
SCREENINDEXY = $201 ; Screen Index in Rows (0-32) * 8 Pixels per Row
THIRTYFRAME = $202 ; Counts 30 frames for things like cursor flash
CURSORX = $223 ; Screenbuffer Index X - 16 bit
CURSORY = $225 ; Screenbuffer Index Y - 16 bit
;STREAMBUFFERREADw = $205 ; Probably unused
;STREAMBUFFERWRITEw = $207 ; Probably Unused
SCREENBUFFER = $300 ; $300 - $E39 - 1440 bytes  -- Maybe 960 w/ 480 for 4bpp color data
SCRATCH = $209 ; Word Swapspace
SCREENBUFFERINDEX = $211
SCRATCHCHAR = $213 ; Byte Swapspace
;SCRATCHSCANLINE = $214 ; I forgot what this was swap for
GLYPHA = $215 ; Swap for Glyph A in triptych
;GLYPHB = $216 ; You know what, we may need four or zero, we'll see
;XINDEXBUFFER = $217 ; I need to document this stuff when I make it

TRIPTYCHOFINTEREST = $218 ; 16 bit
;GLYPHOFINTEREST = $21A ; 
BUFFERMEMORYINDEX = $21B ; 16 bit
BACKGROUNDMEMORYINDEX = $21D ; 16 bit
SCREENINDEXSCRATCH = $21F ; 16 Bit
MATHSCRATCH = $221 ; 16 bit

; Constants 16 bit
;ONE = $230
;TWO = $232
;ZERO = $234

; Rendering Variables - 16 bit
GLYPHAINDEX = $240 
GLYPHBINDEX = $242

; Rendering Variables - 8 bit
;SCRATCHGLYPH = $24b ; Redundant with GLYPHA position

; Variable Initialization
acc8
INITRAM:
 lda #39				; Initialize text at bottom of screen - fixes off by one
; sta SCREENINDEXY 
 sta $210E ; BG1 Vertical Position
	lda #30
;	sta THIRTYFRAME
;	stz STREAMBUFFERWRITEw ; Zero out buffer indices
;	stz STREAMBUFFERWRITEw+1
;	stz STREAMBUFFERREADw
;	stz STREAMBUFFERREADw+1
	stz CURSORX
	stz CURSORY
	stz CURSORX+1
	stz CURSORY+1
;	stz SCREENINDEXSCRATCH
;	stz SCREENINDEXSCRATCH+1
	stz BUFFERMEMORYINDEX
;	stz BACKGROUNDMEMORYINDEX
	stz BUFFERMEMORYINDEX+1
;	stz BACKGROUNDMEMORYINDEX+1
;	lda #1
;	sta ONE
;	stz ONE+1
;	lda #2
;	sta TWO
;	stz TWO+1
;	stz ZERO
;	stz ZERO+1
;	stz GLYPHAINDEX
;	stz GLYPHBINDEX
;	stz GLYPHAINDEX+1
;	stz GLYPHBINDEX+1
	rts