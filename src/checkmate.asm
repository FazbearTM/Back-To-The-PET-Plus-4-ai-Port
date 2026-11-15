// Converted from the PET original: e_checkmate.s
// Syntax translated to Kick Assembler; effect logic unchanged.

e_checkmate:

	lda #9
	sta cm_sprite_x
	lda #13
	sta cm_sprite_y
	lda #9
	sta cm_sprite_w
	lda #11
	sta cm_sprite_h

	lda #<(cm_scene+13*40+9)
	sta Z_DST+0
	lda #>(cm_scene+13*40+9)
	sta Z_DST+1

	jsr cm_put_sprite_mem

	jsr wait_marker

	jsr checkmate_zoom

	jsr wait_marker

	jsr checkmate_scroll

	jsr wait_marker

	jsr checkmate_my_move

	jsr wait_marker

	jsr checkmate_anim_move

	jsr wait_marker

	jmp checkmate_outro //jsr:rts



checkmate_zoom:

	lda #0
	sta cm_frame

checkmate_zoom__zoom_loop:

	//prepare line buffers

	lda cm_frame
	asl
	asl
	tax
	lda cm_zoom_data+0,x
	sta cm_size
	lda cm_zoom_data+1,x
	sta cm_color
	lda cm_zoom_data+2,x
	sta cm_xoff
	lda cm_zoom_data+3,x
	sta cm_yoff

	ldx #0
	ldy cm_color

checkmate_zoom__loop1:

	tya
	sta cm_buf_normal,x
	eor #$80
	sta cm_buf_invert,x

	inc cm_xoff
	lda cm_xoff
	cmp cm_size
	bcc !+
	lda #0
	sta cm_xoff
	tya
	eor #$80
	tay
!:
	inx
	cpx #40
	bne checkmate_zoom__loop1

	//display grid frame

	jsr wait_frame
	jsr wait_frame
	jsr wait_frame
	jsr wait_frame

	lda #<SCREEN
	sta Z_DST+0
	lda #>SCREEN
	sta Z_DST+1

	ldx #24
	lda #0
	sta cm_color

checkmate_zoom__draw:

	ldy #0
	lda cm_color
	beq checkmate_zoom__draw_normal
	jmp	checkmate_zoom__draw_invert

checkmate_zoom__draw_normal:

	.for (var I=0; I<40; I++) {
	lda cm_buf_normal+I
	sta (Z_DST),y
	iny
	}

	jmp checkmate_zoom__next

checkmate_zoom__draw_invert:

	.for (var I=0; I<40; I++) {
	lda cm_buf_invert+I
	sta (Z_DST),y
	iny
	}

checkmate_zoom__next:


	inc cm_yoff
	lda cm_yoff
	cmp cm_size
	bcc !+
	lda #0
	sta cm_yoff
	lda cm_color
	eor #1
	sta cm_color
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
	jmp checkmate_zoom__draw
!:


	inc cm_frame
	lda cm_frame
	cmp #12
	bcs !+
	jmp checkmate_zoom__zoom_loop
!:

	rts



checkmate_scroll:

	lda #<(cm_scene+25*40)
	sta Z_TEMP+0
	lda #>(cm_scene+25*40)
	sta Z_TEMP+1

	lda #26
	sta Z_CNT

checkmate_scroll__loop:

	jsr wait_frame

	lda #<(SCREEN+23*40)
	sta Z_DST+0
	lda #>(SCREEN+23*40)
	sta Z_DST+1
	lda #<(SCREEN+22*40)
	sta Z_SRC+0
	lda #>(SCREEN+22*40)
	sta Z_SRC+1

	ldx #23

checkmate_scroll__scroll1:

	ldy #0

	.for (var _r0=0; _r0<40; _r0++) {
	lda (Z_SRC),y
	sta (Z_DST),y
	iny
	}

	lda Z_SRC+0
	sec
	sbc #40
	sta Z_SRC+0
	bcs !+
	dec Z_SRC+1
!:

	lda Z_DST+0
	sec
	sbc	#40
	sta Z_DST+0
	bcs !+
	dec Z_DST+1
!:

	dex
	beq !+
	jmp checkmate_scroll__scroll1
!:


	ldy #0

	.for (var I=0; I<40; I++) {
	lda (Z_TEMP),y
	sta SCREEN+I
	iny
	}

	lda Z_TEMP+0
	sec
	sbc #40
	sta Z_TEMP+0
	bcs !+
	dec Z_TEMP+1
!:


	dec Z_CNT
	beq !+
	jmp checkmate_scroll__loop
!:

	rts



checkmate_my_move:

	//clear room for the scroll

	ldx #39

checkmate_my_move__clear:

	jsr wait_frame

	ldy #4
!:
	lda #$20
	sta SCREEN+10*40,x
	sta SCREEN+11*40,x
	sta SCREEN+12*40,x
	sta SCREEN+13*40,x
	sta SCREEN+14*40,x
	dex
	dey
	bne !-

	txa
	bpl checkmate_my_move__clear


	//scroll in

	lda #0
	sta Z_CNT

checkmate_my_move__scroll_in:

	jsr wait_frame

	jsr cm_scroll_text

	ldx Z_CNT
	lda cm_my_move+0*40,x
	sta SCREEN+11*40+38
	lda cm_my_move+1*40,x
	sta SCREEN+12*40+38
	lda cm_my_move+2*40,x
	sta SCREEN+13*40+38
	inx
	lda cm_my_move+0*40,x
	sta SCREEN+11*40+39
	lda cm_my_move+1*40,x
	sta SCREEN+12*40+39
	lda cm_my_move+2*40,x
	sta SCREEN+13*40+39

	inc Z_CNT
	inc Z_CNT
	lda Z_CNT
	cmp #40
	bne checkmate_my_move__scroll_in


	//scroll out

	jsr wait_marker

	lda #0
	sta Z_CNT

checkmate_my_move__scroll_out:

	jsr wait_frame

	jsr cm_scroll_text

	lda #$20
	sta SCREEN+11*40+38
	sta SCREEN+12*40+38
	sta SCREEN+13*40+38
	sta SCREEN+11*40+39
	sta SCREEN+12*40+39
	sta SCREEN+13*40+39

	inc Z_CNT
	inc Z_CNT
	lda Z_CNT
	cmp #40
	bne checkmate_my_move__scroll_out


	//restore

	ldx #39

checkmate_my_move__restore:

	jsr wait_frame

	ldy #4
!:
	lda SCREEN+0*40,x
	sta SCREEN+10*40,x
	sta SCREEN+11*40,x
	lda SCREEN+23*40,x
	sta SCREEN+12*40,x
	sta SCREEN+13*40,x
	sta SCREEN+14*40,x
	dex
	dey
	bne !-

	txa
	bpl checkmate_my_move__restore

	rts



checkmate_anim_move:

	//clean the back for the pawn

	lda #<(cm_scene+12*40+7)
	sta Z_DST+0
	lda #>(cm_scene+12*40+7)
	sta Z_DST+1

	ldx #13

checkmate_anim_move__fill1:

	lda #$a0
	ldy #0

checkmate_anim_move__fill2:

	sta (Z_DST),y
	iny
	cpy #13
	bne checkmate_anim_move__fill2

	lda Z_DST+0
	clc
	adc #40
	sta Z_DST+0
	bcc !+
	inc Z_DST+1
!:
	dex
	bne checkmate_anim_move__fill1


	lda #12
	sta cm_sprite_cnt

checkmate_anim_move__move:

	jsr wait_frame
	jsr wait_frame

	jsr cm_put_sprite_transp

	inc cm_sprite_x
	dec cm_sprite_y

	dec cm_sprite_cnt

	bne checkmate_anim_move__move

	lda #8
	sta cm_sprite_cnt

checkmate_anim_move__blink:

	ldx #2
	jsr wait_frames
	jsr cm_put_sprite_transp
	ldx #2
	jsr wait_frames
	jsr cm_put_sprite

	dec cm_sprite_cnt
	bne checkmate_anim_move__blink

	ldx #4
	jsr wait_frames

	inc cm_sprite_x
	dec cm_sprite_y
	jsr cm_put_sprite

	rts



checkmate_outro:

	//prepare reverse table to get brightness id from char code

	ldx #0
!:
	lda cm_fade_fill,x
	tay
	txa
	sta cm_block_to_id,y
	inx
	cmp #16
	bne !-


	//prepare random table

	ldx #0
!:
	jsr rand8
	and #$30
	sta cm_rand_buf,x
	inx
	bne !-

	ldx #0
!:
	lda cm_rand_buf,x
	sta cm_rand_buf+256,x
	sta cm_rand_buf+512,x
	inx
	cpx #40
	bne !-


	lda #0
	sta Z_CNT
	sta Z_TEMP+1

checkmate_outro__loop1:

	jsr wait_frame
	jsr wait_frame

	lda #<SCREEN
	sta Z_DST+0
	lda #>SCREEN
	sta Z_DST+1

	lda #24
	sta Z_TEMP

	lda #(>cm_rand_buf)+1
	sta Z_SRC+1
	jsr rand8
	and #63
	sta Z_SRC+0

checkmate_outro__loop2:

	ldy Z_TEMP+1
	iny
	cpy #5
	bcc !+
	ldy #0
!:
	sty Z_TEMP+1

	.for (var I=0; I<8; I++) {

	lda (Z_DST),y
	tax
	lda cm_block_to_id,x
	clc
	adc (Z_SRC),y
	tax
	lda cm_fade_table,x
	sta (Z_DST),y
	tya
	clc
	adc #5
	tay

	}

	lda Z_SRC+0
	clc
	adc #111
	sta Z_SRC+0

	lda Z_DST+0
	clc
	adc #40
	sta Z_DST+0
	bcc !+
	inc Z_DST+1
!:
	dec Z_TEMP
	beq !+
	jmp checkmate_outro__loop2
!:

	inc Z_CNT
	lda Z_CNT
	cmp #64
	beq !+
	jmp checkmate_outro__loop1
!:

	rts



cm_scroll_text:

	lda #<(SCREEN+11*40+2)
	sta Z_SRC+0
	lda #>(SCREEN+11*40+2)
	sta Z_SRC+1
	lda #<(SCREEN+11*40+0)
	sta Z_DST+0
	lda #>(SCREEN+11*40+0)
	sta Z_DST+1

	ldx #3

cm_scroll_text__loop1:

	ldy #0

cm_scroll_text__loop2:

	lda (Z_SRC),y
	sta (Z_DST),y
	iny
	cpy #38
	bne cm_scroll_text__loop2

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
	bne cm_scroll_text__loop1

	rts



.label Z_BACK = Z_TEMP+4
.label Z_MASK = Z_TEMP+6

cm_put_sprite_transp:

	ldx cm_sprite_y
	lda scr40_table_l,x
	clc
	adc cm_sprite_x
	sta Z_DST+0
	lda scr40_table_h,x
	adc #0
	sta Z_DST+1

	lda Z_DST+0
	sec
	sbc #<SCREEN
	sta Z_BACK+0
	lda Z_DST+1
	sbc #>SCREEN
	sta Z_BACK+1

	lda Z_BACK+0
	clc
	adc #<cm_scene
	sta Z_BACK+0
	lda Z_BACK+1
	adc #>cm_scene
	sta Z_BACK+1

	lda #<cm_pawn_sprite
	sta Z_SRC+0
	lda #>cm_pawn_sprite
	sta Z_SRC+1

	lda #<cm_pawn_mask
	sta Z_MASK+0
	lda #>cm_pawn_mask
	sta Z_MASK+1

	lda cm_sprite_h
	sta Z_CNT

cm_put_sprite_transp__loop1:

	ldy #0

cm_put_sprite_transp__loop2:

	lda (Z_MASK),y
	cmp #$20
	beq cm_put_sprite_transp__copy

	lda (Z_BACK),y
	cmp #$a0
	beq cm_put_sprite_transp__copy

	sta (Z_DST),y
	jmp cm_put_sprite_transp__next

cm_put_sprite_transp__copy:

	lda (Z_SRC),y
	sta (Z_DST),y

cm_put_sprite_transp__next:

	iny
	cpy cm_sprite_w
	bne cm_put_sprite_transp__loop2

	lda Z_SRC+0
	clc
	adc cm_sprite_w
	sta Z_SRC+0
	bcc !+
	inc Z_SRC+1
!:
	lda Z_MASK+0
	clc
	adc cm_sprite_w
	sta Z_MASK+0
	bcc !+
	inc Z_MASK+1
!:
	lda Z_DST+0
	clc
	adc #40
	sta Z_DST+0
	bcc !+
	inc Z_DST+1
!:
	lda Z_BACK+0
	clc
	adc #40
	sta Z_BACK+0
	bcc !+
	inc Z_BACK+1
!:

	dec Z_CNT
	bne cm_put_sprite_transp__loop1

	rts



cm_put_sprite:

	ldx cm_sprite_y
	lda scr40_table_l,x
	clc
	adc cm_sprite_x
	sta Z_DST+0
	lda scr40_table_h,x
	adc #0
	sta Z_DST+1

cm_put_sprite_mem:

	lda #<cm_pawn_sprite
	sta Z_SRC+0
	lda #>cm_pawn_sprite
	sta Z_SRC+1

	lda cm_sprite_h
	sta Z_CNT

cm_put_sprite_mem__loop1:

	ldy #0

cm_put_sprite_mem__loop2:

	lda (Z_SRC),y
	sta (Z_DST),y

cm_put_sprite_mem__next:

	iny
	cpy cm_sprite_w
	bne cm_put_sprite_mem__loop2

	lda Z_SRC+0
	clc
	adc cm_sprite_w
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

	dec Z_CNT
	bne cm_put_sprite_mem__loop1

	rts



cm_scene:

	.import binary "res/checkmate.bin"

//grid size, initial color, initial offset X,Y

cm_zoom_data:

	.byte 2,$20,0,0
	.byte 3,$a0,1,0
	.byte 4,$20,0,0
	.byte 5,$a0,0,3
	.byte 6,$20,4,0
	.byte 7,$a0,1,2
	.byte 8,$a0,4,4
	.byte 9,$a0,7,6
	.byte 10,$20,0,8
	.byte 11,$20,2,10
	.byte 12,$a0,4,0
	.byte 13,$a0,6,1

cm_my_move:

	.byte $20,$20,$20,$20,$20,$20,$55,$72,$6e,$6e,$70,$20,$20,$55,$72,$72,$55,$49,$6e,$70,$70,$6e,$20,$20,$55,$49,$72,$49,$72,$6e,$72,$6e,$72,$49,$20,$20,$20,$20,$20,$20
	.byte $20,$20,$20,$20,$20,$20,$5d,$5d,$5d,$4a,$73,$20,$20,$5d,$5d,$5d,$5d,$5d,$5d,$5d,$6b,$20,$20,$20,$5d,$20,$6b,$49,$6b,$20,$6b,$20,$6b,$4b,$20,$20,$20,$20,$20,$20
	.byte $20,$20,$20,$20,$20,$20,$7d,$71,$6d,$4a,$4b,$20,$20,$7d,$71,$6d,$4a,$4b,$4a,$7d,$6d,$7d,$6e,$20,$4a,$4b,$7d,$6d,$6d,$7d,$6d,$7d,$71,$20,$20,$20,$20,$20,$20,$20

cm_pawn_sprite:

	.byte $a0,$a0,$a0,$a0,$a0,$a0,$a0,$a0,$a0
	.byte $a0,$a0,$a0,$a0,$a0,$a0,$a0,$a0,$a0
	.byte $a0,$a0,$a0,$7e,$62,$7c,$a0,$a0,$a0
	.byte $a0,$a0,$61,$ff,$20,$7f,$e1,$a0,$a0
	.byte $a0,$61,$62,$fc,$20,$fe,$62,$e1,$a0
	.byte $a0,$61,$7f,$7b,$20,$6c,$ff,$e1,$a0
	.byte $a0,$a0,$62,$e1,$20,$61,$62,$a0,$a0
	.byte $a0,$ec,$e2,$ff,$20,$7f,$e2,$fb,$a0
	.byte $a0,$6c,$e2,$20,$20,$20,$e2,$7b,$a0
	.byte $a0,$7c,$e2,$e2,$e2,$e2,$e2,$7e,$a0
	.byte $a0,$a0,$a0,$a0,$a0,$a0,$a0,$a0,$a0

cm_pawn_mask:

	.byte $a0,$a0,$a0,$a0,$a0,$a0,$a0,$a0,$a0
	.byte $a0,$a0,$a0,$a0,$a0,$a0,$a0,$a0,$a0
	.byte $a0,$a0,$a0,$a0,$20,$a0,$a0,$a0,$a0
	.byte $a0,$a0,$a0,$20,$20,$20,$a0,$a0,$a0
	.byte $a0,$a0,$20,$20,$20,$20,$20,$a0,$a0
	.byte $a0,$a0,$20,$20,$20,$20,$20,$a0,$a0
	.byte $a0,$a0,$a0,$20,$20,$20,$a0,$a0,$a0
	.byte $a0,$a0,$a0,$20,$20,$20,$a0,$a0,$a0
	.byte $a0,$20,$20,$20,$20,$20,$20,$20,$a0
	.byte $a0,$20,$20,$20,$20,$20,$20,$20,$a0
	.byte $a0,$a0,$a0,$a0,$a0,$a0,$a0,$a0,$a0



	//from full fill to empty

cm_fade_fill:

	.byte $a0,$fe,$fc,$fb,$ec,$7f,$ff,$61,$e1,$62,$e2,$7e,$7c,$7b,$6c,$20

	//replace with one of four values from a corresponding column

cm_fade_table:

	.byte $fe,$62,$62,$e2,$e2,$7e,$7c,$7e,$7c,$7b,$7e,$20,$20,$20,$20,$20
	.byte $fc,$ff,$7f,$7f,$ff,$7e,$7c,$7e,$7c,$7b,$7e,$20,$20,$20,$20,$20
	.byte $fb,$e1,$61,$e1,$61,$6c,$7b,$7b,$6c,$6c,$7c,$20,$20,$20,$20,$20
	.byte $ec,$ff,$7f,$7f,$ff,$6c,$7b,$7b,$6c,$6c,$7c,$20,$20,$20,$20,$20





cm_frame:		.byte 0
cm_size:		.byte 0
cm_color:		.byte 0
cm_xoff:		.byte 0
cm_yoff:		.byte 0
cm_sprite_x:	.byte 0
cm_sprite_y:	.byte 0
cm_sprite_w:	.byte 0
cm_sprite_h:	.byte 0
cm_sprite_cnt:	.byte 0

cm_buf_normal:	.fill 40,0
cm_buf_invert:	.fill 40,0
// M115: runtime scratch buffers must not live under the live PET charset at $7c00.
// The M100 colour-selector growth shifted cm_rand_buf so its +512 copy landed
// at $7c8d and overwrote glyph data during the Chess fade. Keep these work
// buffers in explicit scratch RAM instead of letting source growth move them.
.label cm_rand_buf=$0500
.label cm_block_to_id=$a100
