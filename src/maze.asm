// Converted from the PET original: e_maze.s
// Syntax translated to Kick Assembler; effect logic unchanged.

e_maze:

	lda #0
	sta mz_pos_x
	sta mz_pos_y
	sta mz_row_cnt
	sta mz_delay
	sta mz_scroll

	lda #1
	sta mz_dir
	lda #6
	sta mz_rows_all

	jsr maze_state_0 //1x1 normal speed

	lda #0
	sta mz_row_cnt
	lda #12
	sta mz_rows_all
	lda #2
	sta mz_dir
	sta mz_len

	jsr maze_state_12 //1x1 double and quad speed

	lda #0
	sta mz_row_cnt
	lda #12
	sta mz_rows_all
	lda #4
	sta mz_dir
	sta mz_len

	jsr maze_state_12

	lda #23
	sta mz_pos_y
	lda #0
	sta mz_pos_x
	sta mz_row_cnt
	lda #10
	sta mz_rows_all
	lda #4
	sta mz_dir
	lda #2
	sta mz_len
	lda #2
	sta mz_scroll

	jsr maze_state_3 //2x2 double speed

	lda #25-6
	sta mz_pos_y
	lda #0
	sta mz_pos_x
	sta mz_row_cnt
	sta mz_dir
	lda #4
	sta mz_rows_all
	lda #6
	sta mz_scroll

	jsr maze_state_4 //4x4 one by one

	lda #0
	sta mz_row_cnt
	lda #8
	sta mz_rows_all
	lda #2
	sta mz_delay_set
	lda #1
	sta mz_rnd_mask

	jsr maze_state_5678 //4x4 whole row

	lda #0
	sta mz_row_cnt
	lda #8
	sta mz_rows_all
	lda #2
	sta mz_delay_set
	lda #3
	sta mz_rnd_mask

	jsr maze_state_5678

	lda #0
	sta mz_row_cnt
	lda #8
	sta mz_rows_all
	lda #0
	sta mz_delay_set
	lda #7
	sta mz_rnd_mask

	jsr maze_state_5678

	lda #0
	sta mz_row_cnt
	lda #8
	sta mz_rows_all
	lda #0
	sta mz_delay_set
	lda #15
	sta mz_rnd_mask

	jsr maze_state_5678

	lda #25
	sta mz_scroll

	jmp maze_do_scroll_and_delay //jsr:rts




maze_pos_to_dst:

	ldy mz_pos_y
	lda scr40_table_l,y
	sta Z_DST+0
	lda scr40_table_h,y
	sta Z_DST+1

	rts



maze_do_scroll_and_delay:

maze_do_scroll_and_delay__delay:

	lda mz_delay
	beq !+
	jsr wait_frame
	dec mz_delay
	beq !+
	jmp maze_do_scroll_and_delay__delay
!:

maze_do_scroll_and_delay__scroll:

	lda mz_scroll
	bne !+
	rts
!:

	jsr wait_frame

	lda #<(SCREEN+1*40)
	sta Z_SRC+0
	lda #>(SCREEN+1*40)
	sta Z_SRC+1
	lda #<(SCREEN+0*40)
	sta Z_DST+0
	lda #>(SCREEN+0*40)
	sta Z_DST+1

	ldx #24

maze_do_scroll_and_delay__loop:

	ldy #0

	.for (var _r0=0; _r0<40; _r0++) {
	lda (Z_SRC),y
	sta (Z_DST),y
	iny
	}

	lda Z_SRC+0
	clc
	adc #40
	sta Z_SRC+0
	bcc !+
	inc Z_SRC+1
!:
	lda Z_DST+0
	clc
	adc #40
	sta Z_DST+0
	bcc !+
	inc Z_DST+1
!:

	dex
	beq !+
	jmp maze_do_scroll_and_delay__loop
!:

	lda #$20
	.for (var I=0; I<40; I++) {
	sta SCREEN+24*40+I
	}

	dec mz_scroll

	jmp maze_do_scroll_and_delay__scroll



maze_state_0:

maze_state_0__loop:

	jsr maze_do_scroll_and_delay

	jsr wait_frame

	jsr maze_pos_to_dst

	jsr rand8
	and #1
	clc
	adc #$4d

	ldy mz_pos_x
	sta (Z_DST),y

	lda mz_pos_x
	clc
	adc mz_dir
	sta mz_pos_x
	cmp #40
	bcc maze_state_0__loop

	lda #0
	sta mz_pos_x

	lda mz_pos_y
	cmp #24
	bcc maze_state_0__noscroll
	lda #1
	sta mz_scroll
	jmp maze_state_0__next

maze_state_0__noscroll:

	inc mz_pos_y

maze_state_0__next:

	inc mz_row_cnt
	lda mz_row_cnt
	cmp mz_rows_all
	bcc maze_state_0__loop

	rts



maze_state_12:

maze_state_12__loop:

	jsr maze_do_scroll_and_delay

	jsr wait_frame

	jsr maze_pos_to_dst

	ldy mz_pos_x
	ldx mz_len
!:
	jsr rand8
	and #1
	clc
	adc #$4d

	sta (Z_DST),y
	iny
	dex
	bne !-

	lda mz_pos_x
	clc
	adc mz_dir
	sta mz_pos_x
	bmi maze_state_12__clip_left
	cmp #40
	bcs maze_state_12__clip_right
	jmp maze_state_12__loop

maze_state_12__clip_left:

	lda #0
	sta mz_pos_x

	jmp maze_state_12__clip_common

maze_state_12__clip_right:

	lda #40
	sec
	sbc mz_dir
	sta mz_pos_x

	jmp maze_state_12__clip_common

maze_state_12__clip_common:

	lda mz_dir
	eor #$ff
	clc
	adc #1
	sta mz_dir

	lda mz_pos_y
	cmp #24
	bcc maze_state_12__noscroll
	lda #1
	sta mz_scroll
	jmp maze_state_12__next

maze_state_12__noscroll:

	inc mz_pos_y

maze_state_12__next:

	inc mz_row_cnt
	lda mz_row_cnt
	cmp mz_rows_all
	bcc maze_state_12__loop

maze_state_12__done:

	rts



maze_state_3:

maze_state_3__loop:

	jsr maze_do_scroll_and_delay

	jsr wait_frame

	jsr maze_pos_to_dst

	ldy mz_pos_x
	ldx mz_len

maze_state_3__loopdraw:

	tya
	pha

	jsr rand8
	and #1
	beq maze_state_3__type1

maze_state_3__type0:

	lda #$4d
	sta (Z_DST),y
	iny
	lda #$20
	sta (Z_DST),y
	tya
	clc
	adc #39
	tay
	lda #$20
	sta (Z_DST),y
	iny
	lda #$4d
	sta (Z_DST),y

	jmp maze_state_3__typenext

maze_state_3__type1:

	lda #$20
	sta (Z_DST),y
	iny
	lda #$4e
	sta (Z_DST),y
	tya
	clc
	adc #39
	tay
	lda #$4e
	sta (Z_DST),y
	iny
	lda #$20
	sta (Z_DST),y

maze_state_3__typenext:

	pla
	tay
	iny
	iny
	dex
	bne maze_state_3__loopdraw

	lda mz_pos_x
	clc
	adc mz_dir
	sta mz_pos_x
	bmi maze_state_3__clip_left
	cmp #40
	bcs maze_state_3__clip_right
	jmp maze_state_3__loop

maze_state_3__clip_left:

	lda #0
	sta mz_pos_x

	jmp maze_state_3__clip_common

maze_state_3__clip_right:

	lda #40
	sec
	sbc mz_dir
	sta mz_pos_x

	jmp maze_state_3__clip_common

maze_state_3__clip_common:

	lda mz_dir
	eor #$ff
	clc
	adc #1
	sta mz_dir

	lda #2
	sta mz_scroll

maze_state_3__next:

	inc mz_row_cnt
	lda mz_row_cnt
	cmp mz_rows_all
	bcs maze_state_3__done
	jmp maze_state_3__loop

maze_state_3__done:

	rts



maze_state_4:

maze_state_4__loop:

	jsr maze_do_scroll_and_delay

	jsr wait_frame

	jsr maze_pos_to_dst

	lda Z_DST+0
	clc
	adc mz_pos_x
	sta Z_DST+0
	bcc !+
	inc Z_DST+1
!:

	lda #<mz_large_tiles
	sta Z_SRC+0
	lda #>mz_large_tiles
	sta Z_SRC+1

	jsr rand8
	and #1
	beq !+
	lda Z_SRC+0
	clc
	adc #6
	sta Z_SRC+0
	bcc !+
	inc Z_SRC+1
!:

	ldx #6
	lda mz_pos_x
	cmp #36
	bcc !+
	ldx #4
!:
	stx mz_xmax

	lda mz_dir
	bne maze_state_4__type1

maze_state_4__type0:

	lda #0
	sta Z_CNT

maze_state_4__type0_1:

	ldy #0

maze_state_4__type0_2:

	lda (Z_SRC),y
	beq maze_state_4__type0_next
	tax

	cpy #0
	bne !+
	lda Z_CNT
	bne !+
	lda (Z_DST),y
	cmp #$e7
	bne !+
	ldx #$5f
!:
	txa
	sta (Z_DST),y

maze_state_4__type0_next:

	iny
	cpy mz_xmax
	bne maze_state_4__type0_2

	lda Z_SRC+0
	clc
	adc #12
	sta Z_SRC+0
	bcc !+
	inc Z_SRC+1
!:
	lda Z_DST+0
	clc
	adc #40
	sta Z_DST+0
	bcc !+
	inc Z_DST+1
!:

	inc Z_CNT
	lda Z_CNT
	cmp #6
	bne maze_state_4__type0_1

	jmp maze_state_4__next

maze_state_4__type1:

	lda #0
	sta Z_CNT

maze_state_4__type1_1:

	ldy #0

maze_state_4__type1_2:

	lda (Z_SRC),y
	beq maze_state_4__type1_next
	tax

	cpy #3+1
	bcc !+
	lda (Z_DST),y
	cmp #$20
	bne maze_state_4__type1_next
!:

	cpy #0
	bne !+
	lda Z_CNT
	bne !+
	lda (Z_DST),y
	cmp #$e7
	bne !+
	ldx #$5f
!:
	txa
	sta (Z_DST),y

maze_state_4__type1_next:

	iny
	cpy mz_xmax
	bne maze_state_4__type1_2

	lda Z_SRC+0
	clc
	adc #12
	sta Z_SRC+0
	bcc !+
	inc Z_SRC+1
!:
	lda Z_DST+0
	clc
	adc #40
	sta Z_DST+0
	bcc !+
	inc Z_DST+1
!:

	inc Z_CNT
	lda Z_CNT
	cmp #6
	bne maze_state_4__type1_1



maze_state_4__next:

	lda mz_dir
	bne maze_state_4__left

maze_state_4__right:

	lda mz_pos_x
	clc
	adc #4
	sta mz_pos_x
	cmp #40
	bcc maze_state_4__noclip

	lda #1
	sta mz_dir
	lda #36
	sta mz_pos_x
	lda #4
	sta mz_scroll
	inc mz_row_cnt

	jmp maze_state_4__noclip

maze_state_4__left:

	lda mz_pos_x
	sec
	sbc #4
	sta mz_pos_x

	bpl maze_state_4__noclip

	lda #0
	sta mz_dir
	sta mz_pos_x
	lda #4
	sta mz_scroll
	inc mz_row_cnt

maze_state_4__noclip:

	lda mz_row_cnt
	cmp mz_rows_all
	bcs maze_state_4__done

	cmp #4
	bcs !+
	lda #2
	sta mz_delay
!:
	jmp maze_state_4__loop

maze_state_4__done:

	rts



maze_state_5678:

maze_state_5678__loop:

	jsr maze_do_scroll_and_delay

	lda #0
	sta mz_pos_x

maze_state_5678__looprow:

	ldy mz_pos_y
	lda scr40_table_l,y
	clc
	adc mz_pos_x
	sta Z_DST+0
	lda scr40_table_h,y
	adc #0
	sta Z_DST+1

	jsr rand8
	and mz_rnd_mask
	cmp #2
	bcc !+
	jmp maze_state_5678__next
!:

	ldx #<mz_large_tiles
	stx Z_SRC+0
	ldx #>mz_large_tiles
	stx Z_SRC+1

	and #1
	beq !+
	lda Z_SRC+0
	clc
	adc #6
	sta Z_SRC+0
	bcc !+
	inc Z_SRC+1
!:

	lda mz_pos_x
	cmp #36
	bcs maze_state_5678__type1

maze_state_5678__type0:

	lda #0
	sta Z_CNT

maze_state_5678__type0_1:

	ldy #0

	lda (Z_SRC),y
	beq maze_state_5678__type0_next1
	tax

	cpy #0
	bne !+
	lda Z_CNT
	bne !+
	lda (Z_DST),y
	cmp #$e7
	bne !+
	ldx #$5f
!:
	txa
	sta (Z_DST),y

maze_state_5678__type0_next1:

	iny

	.for (var _r1=0; _r1<5; _r1++) {
	lda (Z_SRC),y
	beq !+
	sta (Z_DST),y
!:
	iny
	}

	lda Z_SRC+0
	clc
	adc #12
	sta Z_SRC+0
	bcc !+
	inc Z_SRC+1
!:
	lda Z_DST+0
	clc
	adc #40
	sta Z_DST+0
	bcc !+
	inc Z_DST+1
!:

	inc Z_CNT
	lda Z_CNT
	cmp #6
	bne maze_state_5678__type0_1

	jmp maze_state_5678__next



maze_state_5678__type1:

	lda #0
	sta Z_CNT

maze_state_5678__type1_1:

	ldy #0

	lda (Z_SRC),y
	beq maze_state_5678__type1_next1
	tax

	cpy #0
	bne !+
	lda Z_CNT
	bne !+
	lda (Z_DST),y
	cmp #$e7
	bne !+
	ldx #$5f
!:
	txa
	sta (Z_DST),y

maze_state_5678__type1_next1:

	iny

	.for (var _r2=0; _r2<3; _r2++) {
	lda (Z_SRC),y
	beq !+
	sta (Z_DST),y
!:
	iny
	}

	lda Z_SRC+0
	clc
	adc #12
	sta Z_SRC+0
	bcc !+
	inc Z_SRC+1
!:
	lda Z_DST+0
	clc
	adc #40
	sta Z_DST+0
	bcc !+
	inc Z_DST+1
!:

	inc Z_CNT
	lda Z_CNT
	cmp #6
	bne maze_state_5678__type1_1



maze_state_5678__next:

	lda mz_pos_x
	clc
	adc #4
	sta mz_pos_x

	cmp #40
	bcs !+
	jmp maze_state_5678__looprow
!:

	lda #4
	sta mz_scroll

	lda mz_delay_set
	sta mz_delay

	inc mz_row_cnt
	lda mz_row_cnt
	cmp mz_rows_all
	beq !+
	jmp maze_state_5678__loop
!:

	rts



mz_large_tiles:

	.byte $4d,$00,$00,$00,$00,$00,$00,$00,$00,$e9,$00,$00
	.byte $65,$4d,$00,$00,$00,$00,$00,$00,$e9,$e7,$00,$00
	.byte $4d,$65,$4d,$00,$00,$00,$00,$e9,$e7,$69,$00,$00
	.byte $00,$4d,$65,$4d,$00,$00,$e9,$e7,$69,$00,$00,$00
	.byte $00,$00,$4d,$65,$65,$00,$e7,$69,$00,$00,$00,$00
	.byte $00,$00,$00,$4d,$65,$00,$69,$00,$00,$00,$00,$00

mz_pos_x:		.byte 0
mz_pos_y:		.byte 0
mz_dir:			.byte 0
mz_len:			.byte 0
mz_row_cnt:		.byte 0
mz_rows_all:	.byte 0
mz_scroll:		.byte 0
mz_delay:		.byte 0
mz_delay_set:	.byte 0
mz_xmax:		.byte 0
mz_rnd_mask:	.byte 0
