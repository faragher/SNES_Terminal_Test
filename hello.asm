; Minimal example of using ca65 to build SNES ROM.

.p816   ; 65816 processor
.i16    ; X/Y are 16 bits
.a8     ; A is 8 bits

.include "snes.inc"
.include "charmap.inc"

.segment "HEADER"    ; +$7FE0 in file
.byte "CA65 EXAMPLE" ; ROM name

.segment "ROMINFO"   ; +$7FD5 in file
.byte $31            ; HiROM, fast-capable
.byte 0              ; no battery RAM
.byte $07            ; 128K ROM
.byte 0,0,0,0
.word $AAAA,$5555    ; dummy checksum and complement

.segment "CODE"
   jmp start


.include "triptych.asm"
VRAM_CHARSET   = $0000 ; must be at $1000 boundary
VRAM_BG1       = $1000 ; must be at $0400 boundary
VRAM_BG2       = $1400 ; must be at $0400 boundary
VRAM_BG3       = $1800 ; must be at $0400 boundary
VRAM_BG4       = $1C00 ; must be at $0400 boundary
START_X        = 0
START_Y        = 0
START_TM_ADDR  = VRAM_BG1 + 32*START_Y + START_X

hello_str: .asciiz "Hello, World!"

 ;--- Test Attributes
INTCOUNTER = $200 ; Counts Interrups for time-based activities
SCREENINDEXY = $201 ; Screen Index in Rows (0-32) * 8 Pixels per Row
THIRTYFRAME = $202 ; Counts 30 frames for things like cursor flash
CURSORX = $203 ; Screenbuffer Index X
CURSORY = $204 ; Screenbuffer Index Y
STREAMBUFFERREADw = $205 ; Probably unused
STREAMBUFFERWRITEw = $207 ; Probably Unused
SCREENBUFFER = $300 ; $300 - $E39 - 1440 bytes  -- Maybe 960 w/ 480 for 4bpp color data
SCRATCH = $209 ; Word Swapspace
SCREENBUFFERINDEX = $211
SCRATCHCHAR = $213 ; Byte Swapspace
SCRATCHSCANLINE = $214 ; I forgot what this was swap for
GLYPHA = $215 ; Swap for Glyph A in triptych
GLYPHB = $216 ; You know what, we may need four or zero, we'll see
XINDEXBUFFER = $217 ; I need to document this stuff when I make it

TRIPTYCHOFINTEREST = $218 ; 16 bit
GLYPHOFINTEREST = $21A ; 
BUFFERMEMORYINDEX = $21B ; 16 bit
BACKGROUNDMEMORYINDEX = $21D ; 16 bit




 ;--- 

start:
   clc             ; native mode
   xce
   rep #$10        ; X/Y 16-bit
   sep #$20        ; A 8-bit

   ; Clear registers
   ldx #$33
	 jsr ClearVRAM
	 
	 lda #39				; Initialize text at bottom of screen - fixes off by one
	 sta SCREENINDEXY 
	 sta $210E ; BG1 Vertical Position
	lda #30
	sta THIRTYFRAME
	stz STREAMBUFFERWRITEw ; Zero out buffer indices
	stz STREAMBUFFERWRITEw+1
	stz STREAMBUFFERREADw
	stz STREAMBUFFERREADw+1


@loop:
   stz INIDISP,x
   stz NMITIMEN,x
   dex
   bpl @loop

   lda #128
   sta INIDISP ; undo the accidental stz to 2100h due to BPL actually being a branch on nonnegative
	jsr ClearScreenBuffer
@LoadPalette: ; Load EGA Palette
  stz CGADD ; start with color 0 (background)
  stz CGDATA ; Black and transparent
  stz CGDATA
	lda #$00  ; Blue
	sta CGDATA
	lda #$15
	sta CGDATA
	lda #$02   ; Green
	sta CGDATA
	lda #$a0
	sta CGDATA
	lda #$02   ; Cyan
	sta CGDATA
	lda #$b5
	sta CGDATA
	lda #$54  ; Red
	sta CGDATA
	lda #$00
	sta CGDATA
	lda #$54  ; Magenta
	sta CGDATA
	lda #$15
	sta CGDATA
	lda #$55  ; Yellow/Brown
	sta CGDATA
	lda #$55
	sta CGDATA
	lda #$56  ; Light Gray
	sta CGDATA
	lda #$b5
	sta CGDATA
	lda #$29  ; Dark Gray
	sta CGDATA
	lda #$4a
	sta CGDATA
	lda #$29  ; Bright Blue
	sta CGDATA
	lda #$5f
	sta CGDATA
	lda #$2b  ; Bright Green
	sta CGDATA
	lda #$ea
	sta CGDATA
	lda #$2b  ; Bright Cyan
	sta CGDATA
	lda #$ff
	sta CGDATA
	lda #$7d  ; Bright Red
	sta CGDATA
	lda #$4a
	sta CGDATA
	lda #$7d  ; Bright Magenta
	sta CGDATA
	lda #$5f
	sta CGDATA
	lda #$7f  ; Bright Yellow
	sta CGDATA
	lda #$ea
	sta CGDATA
	lda #$7f  ; Bright White
	sta CGDATA
	lda #$ff
	sta CGDATA


   ; Setup Graphics Mode 1, 8x8 tiles all layers
	 lda #$01
   sta BGMODE
	 lda #>VRAM_BG1
   sta BG1SC ; BG1 at VRAM_BG1, only single 32x32 map (4-way mirror)
   lda #((>VRAM_CHARSET >> 4) | (>VRAM_CHARSET & $F0))
   sta BG12NBA ; BG 1 and 2 both use char tiles

   ; Load character set into VRAM
   lda #$80
   sta VMAIN   ; VRAM stride of 1 word
   ldx #VRAM_CHARSET
   stx VMADDL
   ldx #0
@charset_loop:
   ;lda NESfont,x
	 ; Convert to 4bpp
	 ;sta VMDATAL ; color index low bit = 0
   ;sta VMDATAH ; color index high bit set -> neutral red (2)
	 jsr Register2bpp
	 jsr Register2bpp
   inx
	 inx
	 inx
	 inx
	 inx
	 inx
	 inx
	 inx
   cpx #(128*8)
   bne @charset_loop
	 ldx #VRAM_CHARSET+$3C00
	 stx VMADDL
	 ldx #$1b
	 jsr Register2bpp
	 jsr Register2bpp
	 

   ; Place string tiles in background
	 rep #$20
	 .a16
	 lda #0
	 ;asl ; x2
	 ;asl ; x4
	 ;asl ; x8
	 ;asl ; x16
	 ;asl ; x32
	 ;adc #0
	 adc #VRAM_BG1
   ;ldx #START_TM_ADDR
	 tax
	 sep #$20
	 .a8
   stx VMADDL
   ldx #0
@string_loop:
   lda hello_str,x
   beq @enable_display
   sta VMDATAL
   lda #$20 ; priority 1
   sta VMDATAH
   inx
   bra @string_loop
	 @enable_display:
	 ldx #$0;
	 ldy #$0;
	 jsr MoveBGPointer ; Move that pointer!
	 jsr BufferLinkBG ; Link the BG to the tileset
	 lda #$21
	 sta VMDATAL
	 lda #$20
	 sta VMDATAH

	jsr FillScreenBuffer
	lda #$0
	sta TRIPTYCHOFINTEREST
	jsr TTestTT
	;jsr TestTTB
	;jsr TestTTC
;@enable_display:
   ; Show BG1
   lda #$01
   sta TM
   ; Maximum screen brightness
   lda #$0F
   sta INIDISP
	 


   ; enable NMI for Vertical Blank
   lda #$80
   sta NMITIMEN
	 


game_loop:
   wai ; Pause until next interrupt complete (i.e. V-blank processing is done)
   ; Do something
   jmp game_loop


nmi:
   rep #$10        ; X/Y 16-bit
   sep #$20        ; A 8-bit
   phd
   pha
   phx
   phy
	 lda THIRTYFRAME
	 bne SkipThirty ; Break if not equal Zero - Do 1/2 Hz activities
	 jsr IncScreenY
	 lda #30
	 SkipThirty: 
	 dec
	 sta THIRTYFRAME
	 ; Position Screen
	 lda #$fe ; Load Screen Position 0-255
	 sta $210E ; BG1 Vertical Position
	 ;lda SCREENINDEXY ; Load Screen Position 0-255
	 ;sta $210E ; BG1 Vertical Position
	   ; Do stuff that needs to be done during V-Blank
	lda THIRTYFRAME
	;adc #48
	;jsr PutC
   lda RDNMI ; reset NMI flag
   ply
   plx
   pla
   pld
return_int:
   rti


;--
; Test Triptych
;
;
;--
TestTriptych:
	ldx #2
	ldy #12
	jsr MoveBufferPointer
	;jsr MoveTilePointer
	phx
	ldx SCREENBUFFERINDEX
	lda SCREENBUFFER,X ; Our screenbuffer character location
	lda #$41 ; Just . . . just load an A.
	; Okay, so we need to point to the tile memory space, plus the actual display tile. And we need to do other stuff. This is too complicated for this. We need to drop back to docs.
	jsr PushTile
	
	plx
	rts
	
TestTT:
	rep #$20
	.a16
	; Set VRAM Position
	ldx #VRAM_CHARSET ; Get CHARSET memory location
  stx VMADDL ; Tell PPU to set that location as active
	; ASCII Char to NESfont Position
	lda #$41 ; Force an 'A' glyph for testing- Be careful of 16 bit ACC when active
	asl ; x2
	asl ; x4
	asl ; x8 because of 8 byte characters
	tax ; Transfer address to X register
	lda #$42 ; Force a 'B' glyph for testing
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

TestTTB:
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
	
TestTTC:
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

;-- 
; TileMapSingleChar
;
;
;--	
PushTile: 
	pha
	phy
	phx
	ldy #$0
	@PushTileLoop:
	sta VMDATAL ; For some color ; We're pusing the wrong thing to the wrong place.
  sta VMDATAH ; (%0011 or 1100?)
  inx
	iny
	cpy #$08
	bne @PushTileLoop
	@PushTileLoopA:
	stz VMDATAL
	stz VMDATAH
  inx
	iny
	cpy #$08
	bne @PushTileLoopA
	plx
	ply
	pla
	rts


;--
; Link Buffer to BG
;
;
;--
BufferLinkBG:
	phx
	pha
	phy
	rep #$20 ; A 16-bit
	.a16 ; Assembler directive A 16-bit
	lda #2324 ; Cancel ASCII tile because any tile $1-$1f is basically unused 
	;ldy #$23 ; Priority 1 - +3 for tile 960
	ldy #$0;
	ldx #0
	@TopLine:
		sta VMDATAL
		inx
		cpx #32
		bne @TopLine
	@BufLink_loop:
	ldx #0
	lda #2324 ; Cancel ASCII tile because any tile $1-$1f is basically unused 
	sta VMDATAL ; Border
	lda #$202a
	@MainLine:
	tya
	sta SCRATCH
	asl SCRATCH ; x2
	asl SCRATCH ; x4
	asl SCRATCH ; x8
	asl SCRATCH ; x16
	asl SCRATCH ; x32
	lda SCRATCH
	clc
	sty SCRATCH
	sbc SCRATCH
	sbc SCRATCH ; x30
	stx SCRATCH
	adc SCRATCH
	sta VMDATAL
	inx
	cpx #30
	bne @MainLine
	lda #2324 ; border
	sta VMDATAL ; border
	iny
	cpy #24
	bne @BufLink_loop
	ldx #0
		@BottomLine:
		sta VMDATAL
		inx
		cpx #32
		bne @BottomLine
	;; Bottom Empty Buffer
	lda #$2325 ; Another character
	ldx $0
	@EmptyLine:
		sta VMDATAL
		inx
		cpx #128
		bne @EmptyLine
	sep #$20 ; A 8-bit
	.a8
  inx
	cpx #768-32

	ply
	pla
	plx
	rts
	
;--
; Put Character in Screen Buffer
; in: ACC
;
;--
PutCharBuffer:
	phx
	ldx SCREENBUFFERINDEX
	sta SCREENBUFFER,X
	inx
	stx SCREENBUFFERINDEX
	plx
	rts
	
;--
; Fill Screen Buffer
; in 
;
;--

FillScreenBuffer:
	pha
	phx
	phy
	ldx #0
	ldy #0
	jsr MoveBufferPointer
	lda #$3F
	@FSBloop:
	jsr PutCharBuffer
	inx
	cpx #768
	bne @FSBloop
	ply
	plx
	pla
	rts

;--
; Move Buffer Pointer
; In: X,Y
; Modifies: 
;--
MoveBufferPointer:
	pha
	phx
	rep #$20 ; A 16-bit
	.a16 ; Assembler directive A 16-bit
	tya ; Transfer X to A
	asl ; x2
	asl ; x4
	asl ; x8
	sta SCRATCH
	asl ; x16
	asl ; x32
	adc SCRATCH ; x40 40*Y position
	sta SCRATCH
	txa
	adc SCRATCH; 40*Y+X
	sta SCREENBUFFERINDEX ; Stores Index
		sep #$20 ; A 8-bit
	.a8 ; Assembler Directive
	plx
	pla
	rts
	


;--
; Move BG Pointer
; In: X,Y (pos X,Y)
; Out: None
; Modifies: We'll find out!
;--

MoveBGPointer:
	pha ; Push states to stack
	phy
	phx
	rep #$20 ; A 16-bit
	.a16 ; Assembler directive A 16-bit
	tya ; load Y-Pos
	asl ; x2
	asl ; x4
	asl ; x8
	asl ; x16
	asl ; x32 - We're at 32, but VRAM is words, not bytes
	tay ; Transfer A to Y
	txa ; Load X-Pos
	;asl ; Bytes to Words
	sta SCRATCH ; Store X-Delta in scratchpad
	tya ; Transfer Y-Delta to A
	clc ; Clear Carry
	adc SCRATCH ; Add scratchpad (X-Delta) to Y-Delta for total Delta
	adc #VRAM_BG1 ; Add to base address to generate final address
	sta VMADD ; Push 16-bit address to VRAM pointer
	sep #$20 ; A 8-bit
	.a8 ; Assembler Directive
	plx ; Pull states from stack
	ply
	pla
	rts ; Return
	
	;--
; Move Tile Pointer
; In: X,Y (pos X,Y)
; Out: None
; Modifies: We'll find out!
;--

MoveTilePointer:
	pha ; Push states to stack
	phy
	phx
	rep #$20 ; A 16-bit
	.a16 ; Assembler directive A 16-bit

	sep #$20 ; A 8-bit
	.a8 ; Assembler Directive
	plx ; Pull states from stack
	ply
	pla
	rts ; Return

;--
; Register2bpp - Pushes a 2bpp 8x8 tile to VRAM
; In: X - Current Offset
; Out: VRAM
; Modifies: Flags? Registers maintained
;--
Register2bpp:
	pha
	phy
	phx
	ldy #$0
	@R2bppLoop:
	lda NESfont,x
	sta VMDATAL
  sta VMDATAH
  inx
	iny
	cpy #$08
	bne @R2bppLoop
	plx
	ply
	pla
	rts

;---
;
;---
IncScreenY:
	pha
	lda SCREENINDEXY ; Load Screen Position 0-255
	adc #$08 ; Index by one row
	;sta $210E ; BG1 Vertical Position
	sta SCREENINDEXY ; store new position
	pla
	rts

;---
; PutC -- Puts character into stream
; Currently only stream 1 (std)
; In: A for ASCII character to add to stream
; Out: None (other architectures differ)
; Modifies: None
;---

;PutC:
;	phx
;	jsr IncScreenBuffer
;	sta STREAMBUFFER,x
;	plx
;	rts
	
;IncScreenBuffer:
;	ldx STREAMBUFFERWRITEw
;	inx
;	cpx #1024
;	bne NotEndOfBuffer
;	ldx #0
;	NotEndOfBuffer:
;	stx STREAMBUFFERWRITEw
;	rts
	
	

;----------------------------------------------------------------------------
; ClearVRAM -- Sets every byte of VRAM to zero
; from bazz's VRAM tutorial
; In: None
; Out: None
; Modifies: flags
;----------------------------------------------------------------------------
ClearVRAM:
   pha
   phx
   php

   REP #$30		; mem/A = 8 bit, X/Y = 16 bit
   SEP #$20

   LDA #$80
   STA $2115         ;Set VRAM port to word access
   LDX #$1809
   STX $4300         ;Set DMA mode to fixed source, WORD to $2118/9
   LDX #$0000
   STX $2116         ;Set VRAM port address to $0000
   STX $0000         ;Set $00:0000 to $0000 (assumes scratchpad ram)
   STX $4302         ;Set source address to $xx:0000
   LDA #$00
   STA $4304         ;Set source bank to $00
   LDX #$FFFF
   STX $4305         ;Set transfer size to 64k-1 bytes
   LDA #$01
   STA $420B         ;Initiate transfer

   STZ $2119         ;clear the last byte of the VRAM

   plp
   plx
   pla
   RTS


;--
; ClearScreenBuffer
; Clobbers everything, I guess
;--
ClearScreenBuffer:
	rep #$20 ; A 16-bit
	.a16 ; Assembler directive A 16-bit
	lda #0
	ldx #0
	CSBLoop:
	sta SCREENBUFFER,x
	inx
	cpx #1024
	bne CSBLoop
	sep #$20 ; A 16-bit
	.a8 ; Assembler directive A 8-bit
	rts



.include "charset.asm"

TriLookup:
.byte 0
.byte 3
.byte 6
.byte 9
.byte 12
.byte 15
.byte 18
.byte 21
.byte 24
.byte 27

.segment "VECTORS"
.word 0, 0        ;Native mode vectors
.word .loword(return_int)  ;COP
.word .loword(return_int)  ;BRK
.word .loword(return_int)  ;ABORT
.word .loword(nmi)         ;NMI
.word .loword(start)       ;RST
.word .loword(return_int)  ;IRQ

.word 0, 0        ;Emulation mode vectors
.word .loword(return_int)  ;COP
.word 0
.word .loword(return_int)  ;ABORT
.word .loword(nmi)         ;NMI
.word .loword(start)       ;RST
.word .loword(return_int)  ;IRQ