// Converted from the PET original: e_title.s
// Syntax translated to Kick Assembler; effect logic unchanged.

e_title:

	jsr rand8

	lda #5
	jsr title_set_rand
	jsr title_state_012

	lda #3
	jsr title_set_rand
	jsr title_state_345

	jsr title_state_6
	jsr title_state_78
	jmp title_state_9



title_set_rand:

	sta Z_TEMP
	ldx #0
!:
	jsr rand8
	and #7
	cmp Z_TEMP
	bcc !+
	lda #0
!:
	sta tl_rand_table,x
	inx
	bne !--

	rts



title_down_src_dst:

	lda Z_DST+0
	clc
	adc #40
	sta Z_DST+0
	bcc !+
	inc Z_DST+1
!:

title_down_src:

	lda Z_SRC+0
	clc
	adc #40
	sta Z_SRC+0
	bcc !+
	inc Z_SRC+1
!:

	rts



title_scroll_left:

	lda tl_scroll_w
	bne !+
	rts
!:

	ldx tl_scroll_y
	lda scr40_table_l,x
	clc
	adc tl_scroll_x
	sta Z_SRC+0
	sta Z_DST+0
	lda scr40_table_h,x
	adc #0
	sta Z_SRC+1
	sta Z_DST+1

	inc Z_SRC+0
	bne !+
	inc Z_SRC+1
!:

	lda tl_scroll_h
	sta tl_scroll_hcnt

title_scroll_left__loop1:

	ldx tl_scroll_w
	ldy #0

title_scroll_left__loop2a:

	cpx #11
	bcc title_scroll_left__loop2

	.for (var _r0=0; _r0<10; _r0++) {
	lda (Z_SRC),y
	sta (Z_DST),y
	iny
	dex
	}
	jmp title_scroll_left__loop2a

title_scroll_left__loop2:

	lda (Z_SRC),y
	sta (Z_DST),y
	iny
	dex
	bne title_scroll_left__loop2

	jsr title_down_src_dst

	dec tl_scroll_hcnt
	bne title_scroll_left__loop1

	rts



title_scroll_right:

	lda tl_scroll_w
	bne !+
	rts
!:

	ldx tl_scroll_y
	lda scr40_table_l,x
	clc
	adc tl_scroll_x
	sta Z_SRC+0
	sta Z_DST+0
	lda scr40_table_h,x
	adc #0
	sta Z_SRC+1
	sta Z_DST+1

	lda Z_SRC+0
	bne !+
	dec Z_SRC+1
!:
	dec Z_SRC+0

	lda tl_scroll_h
	sta tl_scroll_hcnt

title_scroll_right__loop1:

	ldx tl_scroll_w
	ldy tl_scroll_w

title_scroll_right__loop2a:

	cpx #11
	bcc title_scroll_right__loop2

	.for (var _r1=0; _r1<10; _r1++) {
	dey
	lda (Z_SRC),y
	sta (Z_DST),y
	dex
	}
	jmp title_scroll_right__loop2a

title_scroll_right__loop2:

	dey
	lda (Z_SRC),y
	sta (Z_DST),y
	dex
	bne title_scroll_right__loop2

	jsr title_down_src_dst

	dec tl_scroll_hcnt
	bne title_scroll_right__loop1

	rts



title_fade_area:

	lda tl_fade_w
	bne !+
	rts
!:

	jsr rand8
	sta tl_rand_ptr

	ldx tl_fade_y
	lda scr40_table_l,x
	sta Z_SRC+0
	lda scr40_table_h,x
	sta Z_SRC+1

	lda tl_fade_h
	sta tl_fade_hcnt

title_fade_area__loop1:

	ldy tl_fade_x

	lda tl_fade_w
	sta Z_CNT

title_fade_area__loop2:

	lda (Z_SRC),y
	cmp #$20
	beq title_fade_area__skip
	tax
	lda chr_to_density,x
	and #63
	inc tl_rand_ptr
	ldx tl_rand_ptr
	sbc tl_rand_table,x
	bcs !+
	lda #0
!:
	tax
	lda density_to_chr,x

	sta (Z_SRC),y

title_fade_area__skip:

	iny
	dec Z_CNT
	bne title_fade_area__loop2

	jsr title_down_src

	dec tl_fade_hcnt
	bne title_fade_area__loop1

	rts



title_border_draw:

	lda tl_border_cnt
	and #7
	asl
	tax
	lda tl_border_anim_frames+0,x
	sta Z_SRC+0
	lda tl_border_anim_frames+1,x
	sta Z_SRC+1

	ldy tl_border_off

	.for (var I=0; I<40; I++) {
	lda (Z_SRC),y
	iny
	sta SCREEN+0*40+I
	}


	lda tl_border_cnt
	and #7
	eor #7
	asl
	tax
	lda tl_border_anim_frames+0,x
	sta Z_SRC+0
	lda tl_border_anim_frames+1,x
	sta Z_SRC+1

	lda #124-40
	sec
	sbc tl_border_off
	tay

	.for (var I=0; I<40; I++) {
	lda (Z_SRC),y
	iny
	sta SCREEN+24*40+I
	}

	rts



title_pet_draw:

	lda #<(tl_screen+12*40+11)
	sta Z_SRC+0
	lda #>(tl_screen+12*40+11)
	sta Z_SRC+1
	lda #<(SCREEN+12*40+11)
	sta Z_DST+0
	lda #>(SCREEN+12*40+11)
	sta Z_DST+1

	lda #<tl_petrand
	sta Z_TEMP+0
	lda #>tl_petrand
	sta Z_TEMP+1

	lda #12
	sta Z_CNT

title_pet_draw__loop1:

	ldy #0
	sec

//@loop2:

	.for (var _r2=0; _r2<29; _r2++) {

	lda (Z_TEMP),y
	beq !++
	sbc #1
	sta (Z_TEMP),y
	tax
	lda tl_petgrad,x
	bne !+
	lda (Z_SRC),y
!:
	sta (Z_DST),y
!:
	iny

	}

	jsr title_down_src_dst

	lda Z_TEMP+0
	clc
	adc #29
	sta Z_TEMP+0
	bcc !+
	inc Z_TEMP+1
!:

	dec Z_CNT
	beq !+
	jmp title_pet_draw__loop1
!:

	rts



title_state_012:

//state 0

	lda #0
	sta tl_state_cnt

title_state_012__loop1:

	jsr wait_frame

	lda #0
	sta tl_scroll_x
	lda #1
	sta tl_scroll_y
	lda #39
	sta tl_scroll_w
	lda #11
	sta tl_scroll_h

	jsr title_scroll_left

	lda #<(tl_screen+1*40)
	sta Z_SRC+0
	lda #>(tl_screen+1*40)
	sta Z_SRC+1

	lda #<(SCREEN+1*40+39)
	sta Z_DST+0
	lda #>(SCREEN+1*40+39)
	sta Z_DST+1

	ldx #11

title_state_012__column:

	ldy tl_state_cnt
	lda (Z_SRC),y
	ldy #0
	sta (Z_DST),y

	jsr title_down_src_dst

	dex
	bne title_state_012__column

	inc tl_state_cnt
	lda tl_state_cnt
	cmp #40
	bne title_state_012__loop1

//state 1

	lda #0
	sta tl_state_cnt
	lda #39
	sta tl_scroll_w
	lda #1
	sta tl_fade_w

title_state_012__loop2:

	jsr wait_frame

	lda #0
	sta tl_scroll_x
	lda #1
	sta tl_scroll_y
	lda #11
	sta tl_scroll_h

	jsr title_scroll_left

	lda #40
	sec
	sbc tl_fade_w
	sta tl_fade_x
	lda #4
	sta tl_fade_y
	lda #5
	sta tl_fade_h

	jsr title_fade_area

	inc tl_fade_w
	dec tl_scroll_w
	lda tl_scroll_w
	bpl title_state_012__loop2

//state 2

	lda #0
	sta tl_fade_x
	lda #40
	sta tl_fade_w

	lda #64
	sta tl_state_cnt

title_state_012__loop3:

	jsr wait_frame

	jsr title_fade_area

	dec tl_state_cnt
	bne title_state_012__loop3

	rts



title_state_345:

//state 3

	lda #10
	sta tl_state_cnt

title_state_345__loop1:

	jsr wait_frame

	lda #1
	sta tl_scroll_x
	lda #14
	sta tl_scroll_y
	lda #39
	sta tl_scroll_w
	lda #8
	sta tl_scroll_h

	jsr title_scroll_right

	lda #<(tl_screen+14*40)
	sta Z_SRC+0
	lda #>(tl_screen+14*40)
	sta Z_SRC+1

	lda #<(SCREEN+14*40)
	sta Z_DST+0
	lda #>(SCREEN+14*40)
	sta Z_DST+1

	ldx #11
	lda tl_state_cnt
	sta Z_TEMP
title_state_345__column:

	ldy Z_TEMP
	lda (Z_SRC),y
	ldy #0
	sta (Z_DST),y

	jsr title_down_src_dst

	dex
	bne title_state_345__column

	dec tl_state_cnt
	bpl title_state_345__loop1

//state 4

	lda #0
	sta tl_state_cnt
	lda #1
	sta tl_fade_w

title_state_345__loop2:

	jsr wait_frame

	lda tl_state_cnt
	clc
	adc #1
	sta tl_scroll_x
	lda #14
	sta tl_scroll_y
	lda #39
	sec
	sbc tl_state_cnt
	sta tl_scroll_w
	lda #8
	sta tl_scroll_h

	jsr title_scroll_right

	lda #0
	sta tl_fade_x
	lda #17
	sta tl_fade_y
	lda #2
	sta tl_fade_h

	jsr title_fade_area

	inc tl_fade_w
	lda tl_fade_w
	cmp #40
	bne title_state_345__loop2

//state 5

	lda #48
	sta tl_state_cnt

title_state_345__loop3:

	jsr wait_frame
	jsr title_fade_area

	dec tl_state_cnt
	bne title_state_345__loop3

	rts



title_state_6:

	lda #0
	sta tl_state_cnt

title_state_6__loop:

	jsr wait_frame

	lda #1
	sta tl_scroll_x
	sta tl_scroll_y
	lda #39
	sta tl_scroll_w
	lda #11
	sta tl_scroll_h

	jsr title_scroll_right

	lda #0
	sta tl_scroll_x
	lda #14
	sta tl_scroll_y
	lda #39
	sta tl_scroll_w
	lda #8
	sta tl_scroll_h

	jsr title_scroll_left


	lda #<(tl_screen+1*40)
	sta Z_SRC+0
	lda #>(tl_screen+1*40)
	sta Z_SRC+1

	lda #<(SCREEN+1*40)
	sta Z_DST+0
	lda #>(SCREEN+1*40)
	sta Z_DST+1

	ldx #11
	lda #39
	sec
	sbc tl_state_cnt
	sta Z_TEMP

title_state_6__column1:

	ldy Z_TEMP
	lda (Z_SRC),y
	ldy #0
	sta (Z_DST),y

	jsr title_down_src_dst

	dex
	bne title_state_6__column1


	lda #<(tl_screen+14*40)
	sta Z_SRC+0
	lda #>(tl_screen+14*40)
	sta Z_SRC+1

	lda #<(SCREEN+14*40+39)
	sta Z_DST+0
	lda #>(SCREEN+14*40+39)
	sta Z_DST+1

	ldx #8

	lda tl_state_cnt
	cmp #11
	bcs title_state_6__column2b

	lda tl_state_cnt
	sta Z_TEMP
title_state_6__column2a:

	ldy Z_TEMP
	lda (Z_SRC),y
	ldy #0
	sta (Z_DST),y

	jsr title_down_src_dst

	dex
	bne title_state_6__column2a

	jmp title_state_6__next

title_state_6__column2b:

	ldy #0
	lda #$20
	sta (Z_DST),y

	jsr title_down_src_dst

	dex
	bne title_state_6__column2b

title_state_6__next:

	inc tl_state_cnt
	lda tl_state_cnt
	cmp #40
	bcs !+
	jmp title_state_6__loop
!:

	rts



title_state_78:

	lda #0
	sta tl_border_cnt
	sta tl_border_off


	lda #<(tl_petrand+12*29-29)
	sta Z_DST+0
	lda #>(tl_petrand+12*29-29)
	sta Z_DST+1

	ldx #12

title_state_78__setpetrand1:

	ldy #0
	lda #29
	sta Z_TEMP

title_state_78__setpetrand2:

	jsr rand8
	and #31
	sta Z_TEMP
	lda #224
	sec
	sbc Z_TEMP

	sta (Z_DST),y

	iny
	cpy #29
	bne title_state_78__setpetrand2

	lda Z_DST+0
	sec
	sbc #29
	sta Z_DST+0
	bcs !+
	dec Z_DST+1
!:

	dex
	bne title_state_78__setpetrand1


title_state_78__loop1:

	jsr wait_frame

	jsr title_border_draw
	jsr title_pet_draw

	lda tl_border_cnt
	clc
	adc #3
	sta tl_border_cnt
	cmp #8
	bcc !+
	sbc #8
	sta tl_border_cnt
	lda tl_border_off
	clc
	adc #2
	sta tl_border_off
	cmp #42
	bcs title_state_78__next
!:

	jmp title_state_78__loop1


title_state_78__next:

title_state_78__loop2:

	jsr wait_frame

	jsr title_border_draw
	jsr title_pet_draw

	inc tl_border_cnt
	lda tl_border_cnt
	and #7
	bne !+
	lda tl_border_off
	clc
	adc #2
	sta tl_border_off
	cmp #124-40
	bcs title_state_78__done
!:

	jmp title_state_78__loop2

title_state_78__done:

	rts



title_state_9:

	lda #14
	sta Z_CNT

title_state_9__loop:

	jsr wait_frame


	lda #<(SCREEN+1*40)
	sta Z_SRC+0
	lda #>(SCREEN+1*40)
	sta Z_SRC+1
	lda #<(SCREEN+0*40)
	sta Z_DST+0
	lda #>(SCREEN+0*40)
	sta Z_DST+1

	ldx #12

title_state_9__up:

	jsr title_copy_40b
	jsr title_down_src_dst

	dex
	beq !+
	jmp title_state_9__up
!:



	ldx #0
	lda #$20

title_state_9__clear:

	sta SCREEN+11*40,x
	inx
	cpx #40*2
	bne title_state_9__clear


	lda #<(SCREEN+23*40)
	sta Z_SRC+0
	lda #>(SCREEN+23*40)
	sta Z_SRC+1
	lda #<(SCREEN+24*40)
	sta Z_DST+0
	lda #>(SCREEN+24*40)
	sta Z_DST+1

	ldx #12

title_state_9__down:

	jsr title_copy_40b

	lda Z_SRC+0
	sec
	sbc #40
	sta Z_SRC+0
	bcs !+
	dec Z_SRC+1
!:
	lda Z_DST+0
	sec
	sbc #40
	sta Z_DST+0
	bcs !+
	dec Z_DST+1
!:

	dex
	beq !+
	jmp title_state_9__down
!:



	dec Z_CNT
	beq !+
	jmp title_state_9__loop
!:

	rts



title_copy_40b:

	ldy #0

	.for (var _r3=0; _r3<40; _r3++) {
	lda (Z_SRC),y
	sta (Z_DST),y
	iny
	}

	rts



//124*8 bytes

tl_border_anim:

	.byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20
	.byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20
	.byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$e0,$20,$e0,$20,$e0,$20
	.byte $e0,$20,$e0,$20,$e0,$20,$e0,$20,$e0,$20,$e0,$20,$e0,$20,$e0,$20
	.byte $e0,$20,$e0,$20,$e0,$20,$e0,$20,$e0,$20,$e0,$20,$e0,$20,$e0,$20
	.byte $e0,$20,$e0,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20
	.byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20
	.byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20
	.byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20
	.byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20
	.byte $20,$20,$20,$20,$20,$6a,$ea,$6a,$ea,$6a,$ea,$6a,$ea,$6a,$ea,$6a
	.byte $ea,$6a,$ea,$6a,$ea,$6a,$ea,$6a,$ea,$6a,$ea,$6a,$ea,$6a,$ea,$6a
	.byte $ea,$6a,$ea,$6a,$ea,$6a,$ea,$6a,$ea,$6a,$ea,$6a,$ea,$6a,$ea,$20
	.byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20
	.byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20
	.byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20
	.byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20
	.byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20
	.byte $20,$e1,$61,$e1,$61,$e1,$61,$e1,$61,$e1,$61,$e1,$61,$e1,$61,$e1
	.byte $61,$e1,$61,$e1,$61,$e1,$61,$e1,$61,$e1,$61,$e1,$61,$e1,$61,$e1
	.byte $61,$e1,$61,$e1,$61,$e1,$61,$e1,$61,$e1,$61,$20,$20,$20,$20,$20
	.byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20
	.byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20
	.byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20
	.byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20
	.byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$f4,$74,$f4
	.byte $74,$f4,$74,$f4,$74,$f4,$74,$f4,$74,$f4,$74,$f4,$74,$f4,$74,$f4
	.byte $74,$f4,$74,$f4,$74,$f4,$74,$f4,$74,$f4,$74,$f4,$74,$f4,$74,$f4
	.byte $74,$f4,$74,$f4,$74,$f4,$74,$20,$20,$20,$20,$20,$20,$20,$20,$20
	.byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20
	.byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20
	.byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20
	.byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20
	.byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$e0,$20,$e0,$20,$e0,$20,$e0
	.byte $20,$e0,$20,$e0,$20,$e0,$20,$e0,$20,$e0,$20,$e0,$20,$e0,$20,$e0
	.byte $20,$e0,$20,$e0,$20,$e0,$20,$e0,$20,$e0,$20,$e0,$20,$e0,$20,$e0
	.byte $20,$e0,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20
	.byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20
	.byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20
	.byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20
	.byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20
	.byte $20,$20,$20,$20,$6a,$ea,$6a,$ea,$6a,$ea,$6a,$ea,$6a,$ea,$6a,$ea
	.byte $6a,$ea,$6a,$ea,$6a,$ea,$6a,$ea,$6a,$ea,$6a,$ea,$6a,$ea,$6a,$ea
	.byte $6a,$ea,$6a,$ea,$6a,$ea,$6a,$ea,$6a,$ea,$6a,$ea,$6a,$ea,$20,$20
	.byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20
	.byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20
	.byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20
	.byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20
	.byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20
	.byte $e1,$61,$e1,$61,$e1,$61,$e1,$61,$e1,$61,$e1,$61,$e1,$61,$e1,$61
	.byte $e1,$61,$e1,$61,$e1,$61,$e1,$61,$e1,$61,$e1,$61,$e1,$61,$e1,$61
	.byte $e1,$61,$e1,$61,$e1,$61,$e1,$61,$e1,$61,$20,$20,$20,$20,$20,$20
	.byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20
	.byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20
	.byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20
	.byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20
	.byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$f4,$74,$f4,$74
	.byte $f4,$74,$f4,$74,$f4,$74,$f4,$74,$f4,$74,$f4,$74,$f4,$74,$f4,$74
	.byte $f4,$74,$f4,$74,$f4,$74,$f4,$74,$f4,$74,$f4,$74,$f4,$74,$f4,$74
	.byte $f4,$74,$f4,$74,$f4,$74,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20
	.byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20
	.byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20

tl_border_anim_frames:

	.word tl_border_anim+0*124
	.word tl_border_anim+1*124
	.word tl_border_anim+2*124
	.word tl_border_anim+3*124
	.word tl_border_anim+4*124
	.word tl_border_anim+5*124
	.word tl_border_anim+6*124
	.word tl_border_anim+7*124

tl_petgrad:

	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$20,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$20,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$20,$00,$00,$00,$00,$00,$00,$00,$00,$00,$20
	.byte $00,$00,$20,$00,$00,$00,$20,$00,$00,$20,$00,$00,$00,$00,$20,$00
	.byte $00,$00,$20,$00,$00,$20,$20,$00,$00,$00,$20,$00,$20,$00,$00,$20
	.byte $00,$20,$00,$20,$00,$20,$00,$20,$00,$20,$00,$20,$00,$20,$00,$20
	.byte $00,$20,$20,$00,$20,$00,$20,$00,$20,$20,$00,$20,$00,$20,$20,$00
	.byte $20,$20,$00,$20,$20,$00,$20,$20,$20,$20,$20,$00,$20,$20,$20,$20
	.byte $00,$20,$20,$20,$00,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20
	.byte $00,$20,$00,$20,$20,$00,$20,$20,$20,$20,$20,$20,$20,$00,$20,$20
	.byte $20,$00,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$00,$20,$20,$20
	.byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$00,$20
	.byte $20,$20,$20,$20,$20,$00,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20
	.byte $20,$20,$00,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20
	.byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20
	.byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$20

tl_screen:
	.import binary "res/title.bin"

tl_scroll_x:	.byte 0
tl_scroll_y:	.byte 0
tl_scroll_w:	.byte 0
tl_scroll_h:	.byte 0
tl_scroll_hcnt:	.byte 0

tl_fade_x:		.byte 0
tl_fade_y:		.byte 0
tl_fade_w:		.byte 0
tl_fade_h:		.byte 0
tl_fade_hcnt:	.byte 0

tl_border_cnt:	.byte 0
tl_border_off:	.byte 0

tl_state_cnt:	.byte 0
tl_rand_ptr:	.byte 0

tl_rand_table:
tl_petrand:		.fill 12*29,0
