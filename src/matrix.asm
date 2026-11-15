// Converted from the PET original: e_matrix.s
// Syntax translated to Kick Assembler; effect logic unchanged.

.const MAX_ELEMENTS = 40
.const MAT_DURATION_1 = 3*60-15
.const MAT_DURATION_2 = 6*60

.label MAT_SCAN_Y = Z_LOOP




e_matrix:

	ldx #0*23
	jsr e_matrix_print

	lda #<MAT_DURATION_1
	ldx #>MAT_DURATION_1
	jsr e_matrix_fall

	ldx #1*23
	jsr e_matrix_print

	lda #<MAT_DURATION_1
	ldx #>MAT_DURATION_1
	jsr e_matrix_fall

	ldx #2*23
	jsr e_matrix_print

	lda #<MAT_DURATION_2
	ldx #>MAT_DURATION_2
	jmp e_matrix_fall //jsr:rts


e_matrix_print:

	txa
	pha

	lda #<(SCREEN+12*40+5)
	sta Z_DST+0
	lda #>(SCREEN+12*40+5)
	sta Z_DST+1

	ldy #0

e_matrix_print__first_blink:

	lda #0
	sta Z_CNT

e_matrix_print__blink1:

	jsr wait_frame

	ldx #$20
	lda Z_CNT
	and #8
	bne !+
	ldx #$a0
!:
	txa
	sta (Z_DST),y

	inc Z_CNT
	lda Z_CNT
	cmp #32
	bne e_matrix_print__blink1


	pla
	tax

e_matrix_print__loop:

	lda #$a0
	sta (Z_DST),y

	jsr wait_frame

	lda e_matrix_text,x
	beq e_matrix_print__done

	sta (Z_DST),y
	iny
	inx
	jmp e_matrix_print__loop

e_matrix_print__done:

e_matrix_print__second_blink:

	lda #0
	sta Z_CNT

e_matrix_print__blink2:

	jsr wait_frame

	ldx #$20
	lda Z_CNT
	and #8
	bne !+
	ldx #$a0
!:
	txa
	sta (Z_DST),y

	inc Z_CNT
	jsr check_marker
	bne !+
	jmp e_matrix_print__blink2
!:
	lda #$20
	sta (Z_DST),y

	rts



e_matrix_new_item:

	jsr rand8
	and #3
	bne !+
	clc
	adc #2
!:
	clc
	adc #1
	sta MAT_DY,y
	jsr rand8
	and #$1f
	ora #$80
	sta MAT_CH,y

	rts



e_matrix_fall:

	sta MAT_TIME+0
	stx MAT_TIME+1

	lda #1
	sta MAT_SPAWN

	//initializing arrays

	ldy #0

e_matrix_fall__init1:

	jsr rand8
	and #31
	clc
	adc #25
	asl
	asl
	sta MAT_Y,y

	jsr e_matrix_new_item

	iny
	cpy #MAX_ELEMENTS
	bne e_matrix_fall__init1

	ldx #0

e_matrix_fall__init2:

	jsr rand8
	and #7
	adc #15
	eor #$ff
	sta MAT_RAND1,x

	jsr rand8
	and #7
	adc #31
	eor #$ff
	sta MAT_RAND2,x

	inx
	bne e_matrix_fall__init2

	lda #0
	sta MAT_FRAME_M3

e_matrix_fall__loop:

	jsr wait_frame

	jsr rand8
	sta Z_RAND

	lda #0
	sta MAT_COLUMN_M3

	ldy #MAX_ELEMENTS-1

e_matrix_fall__upd:

	lda MAT_Y,y
	clc
	adc MAT_DY,y
	sta MAT_Y,y
	bcc e_matrix_fall__next1

	ldx MAT_SPAWN
	beq e_matrix_fall__hide
	pha
	jsr e_matrix_new_item
	pla
	jmp e_matrix_fall__next1

e_matrix_fall__hide:

	sta MAT_DY,y
	lda #30<<2
	sta MAT_Y,y

e_matrix_fall__next1:

	cmp #25*4
	bcc e_matrix_fall__visible

	lda #24
	sta MAT_SCAN_Y
	lda scr40_table_l+25
	sta Z_DST+0
	lda scr40_table_h+25
	sta Z_DST+1

	jmp e_matrix_fall__fade

e_matrix_fall__visible:

	lsr
	lsr
	tax

	lda scr40_table_l,x
	sta Z_DST+0
	lda scr40_table_h,x
	sta Z_DST+1

	lda MAT_CH,y
	sta (Z_DST),y

	dex
	stx MAT_SCAN_Y

e_matrix_fall__fade:

	lda MAT_COLUMN_M3
	cmp MAT_FRAME_M3
	beq !+
	jmp e_matrix_fall__next
!:

	tya
	and #1
	beq e_matrix_fall__fade_even
	jmp e_matrix_fall__fade_odd

e_matrix_fall__fade_even:

	lda #6
	sta Z_CNT

e_matrix_fall__fade_even_loop:

	ldx MAT_SCAN_Y
	bmi e_matrix_fall__next

	lda Z_DST+0
	sec
	sbc #40
	sta Z_DST+0
	bcs !+
	dec Z_DST+1
!:

	lda (Z_DST),y

	bpl !+
	and #$7f
	bne e_matrix_fall__fade_even_write

!:
	cmp #$20
	bne !+

	dec Z_CNT
	bmi e_matrix_fall__next

!:
	tax
	lda chr_to_density,x

	ldx Z_RAND
	inc Z_RAND
	adc MAT_RAND1,x

	bcs !+
	lda #0
!:
	tax
	lda density_to_chr,x

e_matrix_fall__fade_even_write:

	sta (Z_DST),y

	dec MAT_SCAN_Y

	jmp e_matrix_fall__fade_even_loop


e_matrix_fall__fade_odd:

	lda #3
	sta Z_CNT

e_matrix_fall__fade_odd_loop:

	ldx MAT_SCAN_Y
	bmi e_matrix_fall__next

	lda Z_DST+0
	sec
	sbc #40
	sta Z_DST+0
	bcs !+
	dec Z_DST+1
!:

	lda (Z_DST),y

	bpl !+
	and #$7f
	bne e_matrix_fall__fade_odd_write

!:
	cmp #$20
	bne !+

	dec Z_CNT
	bmi e_matrix_fall__next

!:
	tax
	lda chr_to_density,x

	ldx Z_RAND
	inc Z_RAND
	adc MAT_RAND2,x

	bcs !+
	lda #0
!:
	tax
	lda density_to_chr,x

e_matrix_fall__fade_odd_write:

	sta (Z_DST),y

	dec MAT_SCAN_Y

	jmp e_matrix_fall__fade_odd_loop



e_matrix_fall__next:

	lda MAT_COLUMN_M3
	clc
	adc #1
	cmp #3
	bcc !+
	lda #0
!:
	sta MAT_COLUMN_M3

	dey
	bmi !+
	jmp e_matrix_fall__upd
!:

	lda MAT_FRAME_M3
	clc
	adc #1
	cmp #3
	bcc !+
	lda #0
!:
	sta MAT_FRAME_M3

	//jsr GETIN

	lda MAT_TIME+1
	bne !+
	lda MAT_TIME+0
	cmp #25*4
	bcs !+
	lda #0
	sta MAT_SPAWN
!:

	lda MAT_TIME+0
	sec
	sbc #1
	sta MAT_TIME+0
	bcs !+
	dec MAT_TIME+1
!:
	ora MAT_TIME+1
	beq !+
	jmp e_matrix_fall__loop
!:

	rts



//23 chars per text line

e_matrix_text:

	.byte $13,$08,$09,$12,$15,$38,$02,$09,$14,$20,$10,$12,$05,$13,$05,$0e,$14,$13,$20,$00,$20,$20,$00
	.byte $01,$20,$10,$12,$0f,$10,$05,$12,$20,$04,$05,$0d,$0f,$20,$00,$20,$20,$20,$20,$20,$20,$20,$00
	.byte $13,$10,$05,$03,$09,$01,$0c,$20,$06,$0f,$12,$20,$03,$01,$06,$05,$20,$32,$57,$32,$32,$20,$00


MAT_Y:			.fill MAX_ELEMENTS,0
MAT_DY:			.fill MAX_ELEMENTS,0
MAT_CH:			.fill MAX_ELEMENTS,0
MAT_RAND1:		.fill 256,0
MAT_RAND2:		.fill 256,0
MAT_FRAME_M3:	.byte 0
MAT_COLUMN_M3:	.byte 0
MAT_SPAWN:		.byte 0
MAT_TIME:		.word 0
