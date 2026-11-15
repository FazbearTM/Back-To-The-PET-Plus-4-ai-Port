// Converted from the PET original: e_checkers.s
// Syntax translated to Kick Assembler; effect logic unchanged.

e_checkers:

	lda #0
	sta ch_delay_cnt

	jsr checkers_clear

	jsr checkers_intro

	jsr wait_marker

	jsr checkers_state_0
	jsr checkers_state_1
	jsr checkers_state_2
	jsr checkers_state_3
	jsr checkers_state_4
	jsr checkers_state_5
	jsr checkers_state_6

	jsr checkers_clear
	jsr checkers_wait_frame_delay
	jsr checkers_render_horz

	//jsr wait_marker
	ldx #15
!:
	jsr wait_frame
	dex
	bne !-

	rts



checkers_clear:

	ldx #0
!:
	lda #16<<3
	sta ch_offsets,x
	inx
	lda #0
	sta ch_offsets,x
	inx
	cpx #20
	bne !-

	rts



checkers_wait_frame_delay:

!:
	jsr wait_frame

	lda ch_delay_cnt
	beq !+
	dec ch_delay_cnt
	jmp !-
!:
	rts



checkers_state_0:

	lda #0
	sta ch_state_sub
	sta ch_state_cnt

checkers_state_0__loop:

	lda ch_state_sub
	and #1
	tax

checkers_state_0__calc:

	lda ch_offsets,x
	clc
	adc #1<<3
	sta ch_offsets,x
	inx
	inx
	cpx #20
	bcc checkers_state_0__calc

	jsr checkers_wait_frame_delay
	jsr checkers_render_horz

	inc ch_state_cnt
	lda ch_state_cnt
	cmp #32
	bcc checkers_state_0__loop

	lda #0
	sta ch_state_cnt
	lda #8
	sta ch_delay_cnt
	inc ch_state_sub
	lda ch_state_sub
	cmp #4
	bcc checkers_state_0__loop

	rts



checkers_state_1:

	lda #0
	sta ch_state_sub
	sta ch_state_cnt

checkers_state_1__loop:

	lda ch_state_sub
	and #1
	tax

checkers_state_1__calc:

	lda ch_offsets,x
	sec
	sbc	#1<<3
	sta ch_offsets,x
	inx
	inx
	cpx #20
	bcc checkers_state_1__calc

	jsr checkers_wait_frame_delay
	jsr checkers_render_horz

	inc ch_state_cnt
	lda ch_state_cnt
	cmp #32
	bcc checkers_state_1__loop

	lda #0
	sta ch_state_cnt
	lda #8
	sta ch_delay_cnt
	inc ch_state_sub
	lda ch_state_sub
	cmp #4
	bcc checkers_state_1__loop

	rts



checkers_state_2:

	lda #0
	sta ch_state_sub
	sta ch_state_cnt

checkers_state_2__loop:

	lda ch_state_sub
	and #3
	asl
	sta Z_TEMP

	lda #8
	sec
	sbc Z_TEMP
	tax

	lda ch_offsets-0,x
	sec
	sbc #2<<3
	sta ch_offsets-0,x
	lda ch_offsets-1,x
	sec
	sbc #2<<3
	sta ch_offsets-1,x
	lda ch_offsets-2,x
	sec
	sbc #2<<3
	sta ch_offsets-2,x

	lda #11
	clc
	adc Z_TEMP
	tax

	lda ch_offsets+0,x
	sec
	sbc #2<<3
	sta ch_offsets+0,x
	lda ch_offsets+1,x
	sec
	sbc #2<<3
	sta ch_offsets+1,x
	lda ch_offsets+2,x
	sec
	sbc #2<<3
	sta ch_offsets+2,x


	jsr checkers_wait_frame_delay
	jsr checkers_render_vert

	inc ch_state_cnt
	lda ch_state_cnt
	cmp #16
	bcc checkers_state_2__loop

	lda #0
	sta ch_state_cnt
	lda #8
	sta ch_delay_cnt
	inc ch_state_sub
	lda ch_state_sub
	cmp #4
	bcc checkers_state_2__loop

	rts



checkers_state_3:

	lda #0
	sta ch_state_sub
	sta ch_state_cnt

checkers_state_3__loop:

	lda ch_state_sub
	and #3
	asl
	sta Z_TEMP

	lda #1
	clc
	adc	Z_TEMP
	tax

	lda ch_offsets+0,x
	clc
	adc	#2<<3
	sta ch_offsets+0,x
	lda ch_offsets+1,x
	clc
	adc #2<<3
	sta ch_offsets+1,x
	lda ch_offsets+2,x
	clc
	adc #2<<3
	sta ch_offsets+2,x

	lda #18
	sec
	sbc	Z_TEMP
	tax

	lda ch_offsets-0,x
	clc
	adc #2<<3
	sta ch_offsets-0,x
	lda ch_offsets-1,x
	clc
	adc #2<<3
	sta ch_offsets-1,x
	lda ch_offsets-2,x
	clc
	adc #2<<3
	sta ch_offsets-2,x


	jsr checkers_wait_frame_delay
	jsr checkers_render_vert

	inc ch_state_cnt
	lda ch_state_cnt
	cmp #16
	bcc checkers_state_3__loop

	lda #0
	sta ch_state_cnt
	lda #8
	sta ch_delay_cnt
	inc ch_state_sub
	lda ch_state_sub
	cmp #4
	bcc checkers_state_3__loop

	rts



checkers_state_4:

	lda #0
	sta ch_state_sub
	sta ch_state_cnt

checkers_state_4__loop:

	ldx #2<<3
	lda ch_state_sub
	cmp #4
	bcc !+
	ldx #4<<3
!:
	stx ch_speed

	ldx #0
	and #3
	cmp #2
	bcs checkers_state_4__type23

checkers_state_4__type01:

!:
	lda ch_offsets,x
	sec
	sbc ch_speed
	sta ch_offsets,x
	inx
	inx
	cpx #20
	bcc !-

	jmp checkers_state_4__next

checkers_state_4__type23:

!:
	lda ch_offsets,x
	clc
	adc ch_speed
	sta ch_offsets,x
	inx
	inx
	cpx #20
	bcc !-

	jmp checkers_state_4__next

checkers_state_4__next:


	jsr checkers_wait_frame_delay

	lda ch_state_sub
	ror
	bcs !+
	jsr checkers_render_horz
	jmp !++
!:
	jsr checkers_render_vert
!:


	inc ch_state_cnt
	lda ch_state_cnt
	cmp #16
	bcs !+
	jmp checkers_state_4__loop
!:
	lda #0
	sta ch_state_cnt
	lda ch_state_sub
	cmp #4
	bcs !+
	lda #8
	sta ch_delay_cnt
!:

	inc ch_state_sub
	lda ch_state_sub
	cmp #12
	bcs !+
	jmp checkers_state_4__loop
!:

	rts



checkers_state_5:

	lda #0
	sta ch_state_cnt
	sta ch_state_sub

checkers_state_5__loop:

	lda ch_state_sub
	bne checkers_state_5__type1

checkers_state_5__type0:

	ldx #0
	ldy ch_state_cnt
!:
	lda checkers_splash,y
	clc
	adc #16<<3
	sta ch_offsets,x
	iny
	inx
	lda checkers_splash,y
	sta ch_offsets,x
	iny
	inx
	cpx #20
	bcc !-

	jmp checkers_state_5__next

checkers_state_5__type1:

	ldx #19
	ldy ch_state_cnt
!:
	lda checkers_splash,y
	sta ch_offsets,x
	iny
	dex
	lda checkers_splash,y
	clc
	adc #16<<3
	sta ch_offsets,x
	iny
	dex
	bpl !-

checkers_state_5__next:


	jsr checkers_wait_frame_delay
	jsr checkers_render_vert

	lda ch_state_cnt
	cmp #120
	bcs !+
	inc ch_state_cnt
	jmp checkers_state_5__loop
!:
	lda #0
	sta ch_state_cnt
	inc ch_state_sub
	lda ch_state_sub
	cmp #2
	bne checkers_state_5__loop

	rts



checkers_state_6:

	lda #0
	sta ch_state_cnt
	sta ch_state_sub

checkers_state_6__loop:

	lda ch_state_cnt
	ldx #0*6
	cmp #132
	bcc checkers_state_6__setspeed
	ldx #1*6
	cmp #140
	bcc checkers_state_6__setspeed
	ldx #2*6
	cmp #148
	bcc checkers_state_6__setspeed
	ldx #3*6

checkers_state_6__setspeed:


	lda ch_state_cnt
	cmp #(5*16)
	bcc !+
	lda ch_offsets+0
	clc
	adc ch_parallax_speed+0,x
	sta ch_offsets+0
	clc
	adc #16*8
	sta ch_offsets+11
!:

	lda ch_state_cnt
	cmp #(4*16)
	bcc !+
	lda ch_offsets+1
	clc
	adc ch_parallax_speed+1,x
	sta ch_offsets+1
	clc
	adc #16*8
	sta ch_offsets+10
!:

	lda ch_state_cnt
	cmp #(3*16)
	bcc !+
	lda ch_offsets+2
	clc
	adc ch_parallax_speed+2,x
	sta ch_offsets+2
	clc
	adc #16*8
	sta ch_offsets+9
!:

	lda ch_state_cnt
	cmp #(2*16)
	bcc !+
	lda ch_offsets+3
	clc
	adc ch_parallax_speed+3,x
	sta ch_offsets+3
	clc
	adc #16*8
	sta ch_offsets+8
!:

	lda ch_state_cnt
	cmp #(1*16)
	bcc !+
	lda ch_offsets+4
	clc
	adc ch_parallax_speed+4,x
	sta ch_offsets+4
	clc
	adc #16*8
	sta ch_offsets+7
!:

	lda ch_offsets+5
	clc
	adc ch_parallax_speed+5,x
	sta ch_offsets+5
	clc
	adc #16*8
	sta ch_offsets+6


	jsr checkers_wait_frame_delay
	jsr checkers_render_horz

	inc ch_state_sub
	lda ch_state_sub
	and #1
	bne !+
	jmp checkers_state_6__loop
!:
	inc ch_state_cnt
	lda ch_state_cnt
	cmp #156
	bcs !+
	jmp checkers_state_6__loop
!:

	rts



checkers_intro:

	lda #$20
	ldx #0
!:
	sta ch_buf_normal,x
	sta ch_buf_invert,x
	inx
	cpx #40
	bne !-

	ldx #0
!:
	txa
	asl
	asl
	sta ch_buf_time,x
	inx
	cpx #10
	bne !-


checkers_intro__loop:

	//prepare buffers

	.for (var I=0; I<10; I++) {
	lda ch_buf_time+I
	inc ch_buf_time+I
	sec
	sbc #10*4
	bmi !++
	cmp #16
	bcc !+
	lda #15
!:
	asl
	asl
	tax
	lda checkers_fill_anim+0,x
	sta ch_buf_normal+I*4+0
	lda checkers_fill_anim+1,x
	sta ch_buf_normal+I*4+1
	lda checkers_fill_anim+2,x
	sta ch_buf_invert+38-I*4+0
	lda checkers_fill_anim+3,x
	sta ch_buf_invert+38-I*4+1
!:
	}

	jsr wait_frame
	jsr wait_frame

	//display buffers

	lda #<SCREEN
	sta Z_DST+0
	lda #>SCREEN
	sta Z_DST+1

	ldx #0

checkers_intro__render_loop:

	ldy #0
	txa
	and #2
	bne checkers_intro__render_normal
	jmp checkers_intro__render_inv

checkers_intro__render_normal:

	.for (var I=0; I<40; I++) {
	lda ch_buf_normal+I
	sta (Z_DST),y
	iny
	}

	jmp checkers_intro__render_next

checkers_intro__render_inv:

	.for (var I=0; I<40; I++) {
	lda ch_buf_invert+I
	sta (Z_DST),y
	iny
	}

checkers_intro__render_next:

	lda Z_DST+0
	clc
	adc #40
	sta Z_DST+0
	bcc !+
	inc Z_DST+1
!:

	inx
	cpx #24
	beq !+
	jmp checkers_intro__render_loop
!:

	lda ch_buf_time+9
	cmp #9*4+10*4+16
	bcs checkers_intro__done
	jmp checkers_intro__loop

checkers_intro__done:

	rts



.label Z_DST1 = Z_DST
.label Z_DST2 = Z_SRC
.label Z_DST3 = Z_LEN
.label Z_DST4 = Z_TEMP+2
.label Z_DST5 = Z_TEMP+4
.label Z_DST6 = Z_TEMP+6

checkers_render_horz:

	lda #<SCREEN
	sta Z_DST+0
	clc
	adc #40
	sta Z_DST2+0
	lda #>SCREEN
	sta Z_DST+1
	adc #0
	sta Z_DST2+1

	lda #0
	sta Z_LOOP

checkers_render_horz__loop:

	ldx Z_LOOP
	lda ch_offsets,x
	lsr
	lsr
	lsr
	and #31
	asl
	asl
	tax

	ldy #0

	.for (var _r0=0; _r0<10; _r0++) {
	lda checkers_horz+0,x
	sta (Z_DST),y
	sta (Z_DST2),y
	iny
	lda checkers_horz+1,x
	sta (Z_DST),y
	sta (Z_DST2),y
	iny
	lda checkers_horz+2,x
	sta (Z_DST),y
	sta (Z_DST2),y
	iny
	lda checkers_horz+3,x
	sta (Z_DST),y
	sta (Z_DST2),y
	iny
	}

	lda Z_DST+0
	clc
	adc #40*2
	sta Z_DST+0
	bcc !+
	inc Z_DST+1
!:
	lda Z_DST2+0
	clc
	adc #40*2
	sta Z_DST2+0
	bcc !+
	inc Z_DST2+1
!:

	inc Z_LOOP
	lda Z_LOOP
	cmp #12
	bcs !+
	jmp checkers_render_horz__loop
!:

	rts



checkers_render_vert:

	lda #0
	sta Z_LOOP

checkers_render_vert__loop:

	lda #<(SCREEN+0*40)
	clc
	adc Z_LOOP
	sta Z_DST1+0
	lda #>(SCREEN+0*40)
	adc #0
	sta Z_DST1+1

	lda #<(SCREEN+4*40)
	clc
	adc Z_LOOP
	sta Z_DST2+0
	lda #>(SCREEN+4*40)
	adc #0
	sta Z_DST2+1

	lda #<(SCREEN+8*40)
	clc
	adc Z_LOOP
	sta Z_DST3+0
	lda #>(SCREEN+8*40)
	adc #0
	sta Z_DST3+1

	lda #<(SCREEN+12*40)
	clc
	adc Z_LOOP
	sta Z_DST4+0
	lda #>(SCREEN+12*40)
	adc #0
	sta Z_DST4+1

	lda #<(SCREEN+16*40)
	clc
	adc Z_LOOP
	sta Z_DST5+0
	lda #>(SCREEN+16*40)
	adc #0
	sta Z_DST5+1

	lda #<(SCREEN+20*40)
	clc
	adc Z_LOOP
	sta Z_DST6+0
	lda #>(SCREEN+20*40)
	adc #0
	sta Z_DST6+1

	lda Z_LOOP
	lsr
	tax
	lda ch_offsets,x
	lsr
	lsr
	lsr
	and #31
	tax

	lda checkers_vert+0*32,x
	ldy #0*40
	sta (Z_DST1),y
	sta (Z_DST2),y
	sta (Z_DST3),y
	sta (Z_DST4),y
	sta (Z_DST5),y
	sta (Z_DST6),y
	iny
	sta (Z_DST1),y
	sta (Z_DST2),y
	sta (Z_DST3),y
	sta (Z_DST4),y
	sta (Z_DST5),y
	sta (Z_DST6),y
	lda checkers_vert+1*32,x
	ldy #1*40
	sta (Z_DST1),y
	sta (Z_DST2),y
	sta (Z_DST3),y
	sta (Z_DST4),y
	sta (Z_DST5),y
	sta (Z_DST6),y
	iny
	sta (Z_DST1),y
	sta (Z_DST2),y
	sta (Z_DST3),y
	sta (Z_DST4),y
	sta (Z_DST5),y
	sta (Z_DST6),y
	lda checkers_vert+2*32,x
	ldy #2*40
	sta (Z_DST1),y
	sta (Z_DST2),y
	sta (Z_DST3),y
	sta (Z_DST4),y
	sta (Z_DST5),y
	sta (Z_DST6),y
	iny
	sta (Z_DST1),y
	sta (Z_DST2),y
	sta (Z_DST3),y
	sta (Z_DST4),y
	sta (Z_DST5),y
	sta (Z_DST6),y
	lda checkers_vert+3*32,x
	ldy #3*40
	sta (Z_DST1),y
	sta (Z_DST2),y
	sta (Z_DST3),y
	sta (Z_DST4),y
	sta (Z_DST5),y
	sta (Z_DST6),y
	iny
	sta (Z_DST1),y
	sta (Z_DST2),y
	sta (Z_DST3),y
	sta (Z_DST4),y
	sta (Z_DST5),y
	sta (Z_DST6),y

	lda Z_LOOP
	clc
	adc #2
	sta Z_LOOP
	cmp #40
	bcs !+
	jmp checkers_render_vert__loop
!:

	rts



checkers_fill_anim:

	.byte $65,$20,$20,$67
	.byte $74,$20,$20,$6a
	.byte $75,$20,$20,$76
	.byte $61,$20,$20,$e1
	.byte $f6,$20,$20,$f5
	.byte $ea,$20,$20,$f4
	.byte $e7,$20,$20,$e5
	.byte $e0,$20,$20,$e0
	.byte $e0,$65,$67,$e0
	.byte $e0,$74,$6a,$e0
	.byte $e0,$75,$76,$e0
	.byte $e0,$61,$e1,$e0
	.byte $e0,$f6,$f5,$e0
	.byte $e0,$ea,$f4,$e0
	.byte $e0,$e7,$e5,$e0
	.byte $e0,$e0,$e0,$e0

checkers_horz:

	.byte $e0,$e0,$20,$20
	.byte $e0,$e7,$20,$67
	.byte $e0,$ea,$20,$6a
	.byte $e0,$f6,$20,$76
	.byte $e0,$61,$20,$e1
	.byte $e0,$75,$20,$f5
	.byte $e0,$74,$20,$f4
	.byte $e0,$65,$20,$e5
	.byte $e0,$20,$20,$e0
	.byte $e7,$20,$67,$e0
	.byte $ea,$20,$6a,$e0
	.byte $f6,$20,$76,$e0
	.byte $61,$20,$e1,$e0
	.byte $75,$20,$f5,$e0
	.byte $74,$20,$f4,$e0
	.byte $65,$20,$e5,$e0
	.byte $20,$20,$e0,$e0
	.byte $20,$67,$e0,$e7
	.byte $20,$6a,$e0,$ea
	.byte $20,$76,$e0,$f6
	.byte $20,$e1,$e0,$61
	.byte $20,$f5,$e0,$75
	.byte $20,$f4,$e0,$74
	.byte $20,$e5,$e0,$65
	.byte $20,$e0,$e0,$20
	.byte $67,$e0,$e7,$20
	.byte $6a,$e0,$ea,$20
	.byte $76,$e0,$f6,$20
	.byte $e1,$e0,$61,$20
	.byte $f5,$e0,$75,$20
	.byte $f4,$e0,$74,$20
	.byte $e5,$e0,$65,$20

checkers_vert:

	.byte $e0,$e0,$e0,$e0,$e0,$e0,$e0,$e0,$e0,$e4,$ef,$f9,$e2,$78,$77,$63,$20,$20,$20,$20,$20,$20,$20,$20,$20,$64,$6f,$79,$62,$f8,$f7,$e3
	.byte $e0,$e4,$ef,$f9,$e2,$78,$77,$63,$20,$20,$20,$20,$20,$20,$20,$20,$20,$64,$6f,$79,$62,$f8,$f7,$e3,$e0,$e0,$e0,$e0,$e0,$e0,$e0,$e0
	.byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$64,$6f,$79,$62,$f8,$f7,$e3,$e0,$e0,$e0,$e0,$e0,$e0,$e0,$e0,$e0,$e4,$ef,$f9,$e2,$78,$77,$63
	.byte $20,$64,$6f,$79,$62,$f8,$f7,$e3,$e0,$e0,$e0,$e0,$e0,$e0,$e0,$e0,$e0,$e4,$ef,$f9,$e2,$78,$77,$63,$20,$20,$20,$20,$20,$20,$20,$20

checkers_splash:

	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$12,$25,$36,$47,$56,$64,$72,$7d,$87,$90,$97
	.byte $9c,$a0,$a2,$a2,$a1,$9e,$9a,$94,$8d,$85,$7b,$71,$66,$5a,$4e,$41
	.byte $34,$27,$19,$0c,$00,$f4,$e8,$dd,$d2,$c9,$c0,$b8,$b1,$ab,$a7,$a3
	.byte $a0,$9f,$9e,$9f,$a1,$a3,$a6,$ab,$af,$b5,$bb,$c1,$c8,$cf,$d7,$de
	.byte $e5,$ec,$f3,$fa,$00,$05,$0b,$10,$15,$18,$1c,$1f,$21,$22,$23,$23
	.byte $23,$23,$21,$20,$1e,$1c,$19,$17,$14,$11,$0f,$0c,$09,$07,$05,$03
	.byte $02,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
	.byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00

ch_parallax_speed:

	.byte 7*4,6*4,5*4,4*4,3*4,2*4
	.byte 7*3,6*3,5*3,4*3,3*3,2*3
	.byte 7*2,6*2,5*2,4*2,3*2,2*2
	.byte 7*1,6*1,5*1,4*1,3*1,2*1

ch_buf_time:	.fill 10,0
ch_buf_normal:	.fill 40,0
ch_buf_invert:	.fill 40,0
ch_offsets:		.fill 20,0

ch_cnt:			.byte 0
ch_off:			.byte 0
ch_state_cnt:	.byte 0
ch_state_sub:	.byte 0
ch_delay_cnt:	.byte 0
ch_speed:		.byte 0
