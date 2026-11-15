// Converted from the PET original: e_timeline.s
// Syntax translated to Kick Assembler; effect logic unchanged.

.const TM_EOF = $00
.const TM_POS_ABS = $01
.const TM_POS_REL = $02
.const TM_POS_UP = $03
.const TM_POS_DOWN = $04
.const TM_POS_LEFT = $05
.const TM_POS_RIGHT = $06
.const TM_POINT = $07
.const TM_TEXT = $09
.const TM_DELAY = $10
.const TM_BLINK = $11

.label TM_SCROLL_UP = $0a
.label TM_SCROLL_DOWN = $0b
.label TM_SCROLL_LEFT = $0c
.label TM_SCROLL_RIGHT = $0d
.label TM_POS_STORE = $0e
.label TM_POS_RESTORE = $0f




e_timeline:

	lda #<timeline_seq
	sta tm_src_ptr+0
	lda #>timeline_seq
	sta tm_src_ptr+1

e_timeline__loop:

	jsr tm_fetch_byte
	sta tm_tag

	cmp #TM_EOF
	bne !+
	jmp e_timeline__done
!:

	cmp #TM_POS_ABS
	bne !+

e_timeline__pos_abs:

	jsr tm_fetch_byte
	sta tm_put_x
	jsr tm_fetch_byte
	sta tm_put_y
	jmp e_timeline__loop

!:
	cmp #TM_POS_REL
	bne !+

e_timeline__pos_rel:

	jsr tm_fetch_byte
	clc
	adc tm_put_x
	sta tm_put_x
	jsr tm_fetch_byte
	clc
	adc tm_put_y
	sta tm_put_y
	jmp e_timeline__loop

!:
	cmp #TM_POS_STORE
	bne !+

e_timeline__pos_store:

	lda tm_put_x
	sta tm_put_xr
	lda tm_put_y
	sta tm_put_yr
	jmp e_timeline__loop

!:
	cmp #TM_POS_RESTORE
	bne !+

e_timeline__pos_restore:

	lda tm_put_xr
	sta tm_put_x
	lda tm_put_yr
	sta tm_put_y
	jmp e_timeline__loop

!:
	cmp #TM_DELAY
	bne !+

	jsr tm_fetch_byte
	tax
e_timeline__delay:
	jsr wait_frame
	dex
	bne e_timeline__delay
	jmp e_timeline__loop

!:
	cmp #TM_SCROLL_UP
	bne !+

	jsr tm_fetch_byte
	tax
e_timeline__scroll_up:
	jsr wait_frame
	jsr tm_scroll_up
	dex
	bne e_timeline__scroll_up
	jmp e_timeline__loop

!:
	cmp #TM_SCROLL_DOWN
	bne !+

	jsr tm_fetch_byte
	tax
e_timeline__scroll_down:
	jsr wait_frame
	jsr tm_scroll_down
	dex
	bne e_timeline__scroll_down
	jmp e_timeline__loop

!:
	cmp #TM_SCROLL_LEFT
	bne !+

	jsr tm_fetch_byte
	tax
e_timeline__scroll_left:
	jsr wait_frame
	jsr tm_scroll_left
	dex
	bne e_timeline__scroll_left
	jmp e_timeline__loop

!:
	cmp #TM_SCROLL_RIGHT
	bne !+

	jsr tm_fetch_byte
	tax
e_timeline__scroll_right:
	jsr wait_frame
	jsr tm_scroll_right
	dex
	bne e_timeline__scroll_right
	jmp e_timeline__loop

!:
	cmp #TM_POINT
	bne !+

e_timeline__point:

	jsr tm_xy_to_dst

	jsr wait_frame

	ldy #0
	lda #$51
	sta (Z_DST),y

	jsr wait_frame
	jsr wait_frame

	lda #$a0
	sta (Z_DST),y

	sta tm_point_flag
	inc tm_put_x
	inc tm_put_x

!:
	cmp #TM_POS_UP
	bne !+

e_timeline__pos_up:

	lda #0
	sta tm_put_dx
	lda #<-1
	sta tm_put_dy
	jsr tm_fetch_byte
	tax
	lda #$5d
	jsr tm_put_line
	jmp e_timeline__loop

!:
	cmp #TM_POS_DOWN
	bne !+

e_timeline__pos_down:

	lda #0
	sta tm_put_dx
	lda #1
	sta tm_put_dy
	jsr tm_fetch_byte
	tax
	lda #$5d
	jsr tm_put_line
	jmp e_timeline__loop

!:
	cmp #TM_POS_LEFT
	bne !+

e_timeline__pos_left:

	lda #<-1
	sta tm_put_dx
	lda #0
	sta tm_put_dy
	jsr tm_fetch_byte
	tax
	lda #$40
	jsr tm_put_line
	jmp e_timeline__loop

!:
	cmp #TM_POS_RIGHT
	bne !+

e_timeline__pos_right:

	lda #1
	sta tm_put_dx
	lda #0
	sta tm_put_dy
	jsr tm_fetch_byte
	tax
	lda #$40
	jsr tm_put_line
	jmp e_timeline__loop

!:
	cmp #TM_TEXT
	bne !+

e_timeline__text:

	jsr tm_xy_to_dst
	lda Z_DST+0
	sta tm_text_adr+0
	lda Z_DST+1
	sta tm_text_adr+1
	lda #0
	sta tm_text_len

e_timeline__text_loop:

	jsr wait_frame

	jsr tm_fetch_byte
	ora #0
	beq !+

	jsr tm_xy_to_dst
	ldy #0
	sta (Z_DST),y

	inc tm_put_x
	inc tm_text_len
	jmp e_timeline__text_loop

!:
	cmp #TM_BLINK
	bne !+

e_timeline__blink:

	jsr tm_fetch_byte
	jsr tm_blink

!:
	jmp e_timeline__loop

e_timeline__done:

	rts



tm_fetch_byte:

	lda tm_src_ptr+0
	sta Z_SRC+0
	lda tm_src_ptr+1
	sta Z_SRC+1

	ldy #0
	lda (Z_SRC),y

	inc tm_src_ptr+0
	bne !+
	inc tm_src_ptr+1
!:
	rts



tm_xy_to_dst:

	pha

	ldy tm_put_y
	lda scr40_table_h,y
	sta Z_DST+1
	lda scr40_table_l,y
	clc
	adc tm_put_x
	sta Z_DST+0
	bcc !+
	inc Z_DST+1
!:
	pla

	rts



tm_put_line:

	sta tm_tile_first
	sta tm_tile_next

	lda tm_point_flag
	bne tm_put_line__loop

	lda tm_tag
	cmp tm_prev_dir
	beq tm_put_line__loop

	sec
	sbc	#TM_POS_UP
	asl
	asl
	sta Z_TEMP
	lda tm_prev_dir
	sec
	sbc #TM_POS_UP
	ora Z_TEMP
	tay
	lda tm_tile_corners,y
	sta tm_tile_first

tm_put_line__loop:

	jsr wait_frame

	jsr tm_xy_to_dst
	ldy #0
	lda tm_tile_first
	sta (Z_DST),y

	lda tm_tile_next
	sta tm_tile_first

	lda tm_put_x
	clc
	adc tm_put_dx
	sta tm_put_x

	lda tm_put_y
	clc
	adc tm_put_dy
	sta tm_put_y

	dex
	bne tm_put_line__loop

	lda tm_tag
	sta tm_prev_dir

	lda #0
	sta tm_point_flag

	rts



tm_blink:

	sta Z_CNT

tm_blink__blink_loop_1:

	ldx #4
!:
	jsr wait_frame
	dex
	bne !-

	lda tm_text_adr+0
	sta Z_SRC+0
	lda tm_text_adr+1
	sta Z_SRC+1

	ldx tm_text_len
	ldy #0

tm_blink__blink_loop_2:

	lda (Z_SRC),y
	pha
	lda tm_blink_buf,y
	sta (Z_SRC),y
	pla
	sta tm_blink_buf,y
	iny
	dex
	bne tm_blink__blink_loop_2

	dec Z_CNT
	bne tm_blink__blink_loop_1

	rts



tm_scroll_up:

	txa
	pha

	lda #<(SCREEN+0*40)
	sta Z_DST+0
	lda #>(SCREEN+0*40)
	sta Z_DST+1
	lda #<(SCREEN+1*40)
	sta Z_SRC+0
	lda #>(SCREEN+1*40)
	sta Z_SRC+1

	ldx #24

tm_scroll_up__loop1:

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
	jmp tm_scroll_up__loop1
!:

	ldy #0
	lda #$20

tm_scroll_up__loop3:

	sta SCREEN+24*40,y
	iny
	cpy #40
	bne tm_scroll_up__loop3

	pla
	tax

	rts



tm_scroll_down:

	txa
	pha

	lda #<(SCREEN+24*40)
	sta Z_DST+0
	lda #>(SCREEN+24*40)
	sta Z_DST+1
	lda #<(SCREEN+23*40)
	sta Z_SRC+0
	lda #>(SCREEN+23*40)
	sta Z_SRC+1

	ldx #24

tm_scroll_down__loop1:

	ldy #0

	.for (var _r1=0; _r1<40; _r1++) {
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
	sbc #40
	sta Z_DST+0
	bcs !+
	dec Z_DST+1
!:

	dex
	beq !+
	jmp tm_scroll_down__loop1
!:

	ldy #0
	lda #$20

tm_scroll_down__loop3:

	sta SCREEN,y
	iny
	cpy #40
	bne tm_scroll_down__loop3

	pla
	tax

	rts



tm_scroll_left:

	txa
	pha

	lda #<(SCREEN+0)
	sta Z_DST+0
	lda #>(SCREEN+0)
	sta Z_DST+1
	lda #<(SCREEN+1)
	sta Z_SRC+0
	lda #>(SCREEN+1)
	sta Z_SRC+1

	ldx #25

tm_scroll_left__loop1:

	ldy #0

	.for (var _r2=0; _r2<39; _r2++) {
	lda (Z_SRC),y
	sta (Z_DST),y
	iny
	}

	lda #$20
	sta (Z_DST),y

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
	jmp tm_scroll_left__loop1
!:
	pla
	tax

	rts



tm_scroll_right:

	txa
	pha

	lda #<(SCREEN+0)
	sta Z_DST+0
	lda #>(SCREEN+0)
	sta Z_DST+1
	lda #<(SCREEN-1)
	sta Z_SRC+0
	lda #>(SCREEN-1)
	sta Z_SRC+1

	ldx #25

tm_scroll_right__loop1:

	ldy #39

	.for (var _r3=0; _r3<39; _r3++) {
	lda (Z_SRC),y
	sta (Z_DST),y
	dey
	}

	lda #$20
	sta (Z_DST),y

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
	jmp tm_scroll_right__loop1
!:

	pla
	tax

	rts



tm_tile_corners:

	.byte $5d,$5d,$6d,$7d
	.byte $5d,$5d,$70,$6e
	.byte $6e,$7d,$40,$40
	.byte $70,$6d,$40,$40


timeline_seq:

	.byte TM_POS_ABS,10,0
	.byte TM_POS_DOWN,10
	.byte TM_DELAY,25
	.byte TM_POS_RIGHT,5
	.byte TM_POINT
	.byte TM_DELAY,25
	.byte TM_TEXT,$31,$39,$39,$35,$20,$17,$09,$0e,$04,$0f,$17,$13,$27,$39,$35,0 //windows 95
	.byte TM_POS_REL,1,0
	.byte TM_POS_RIGHT,5
	.byte TM_POS_DOWN,5
	.byte TM_POS_LEFT,6
	.byte TM_POS_REL,<-23,0
	.byte TM_POS_STORE
	.byte TM_POINT
	.byte TM_DELAY,25
	.byte TM_TEXT,$31,$39,$39,$34,$20,$13,$0f,$0e,$19,$20,$10,$0c,$01,$19,$13,$14,$01,$14,$09,$0f,$0e,0 //playstation
	.byte TM_SCROLL_UP,5
	.byte TM_POS_RESTORE
	.byte TM_POS_REL,0,<-4
	.byte TM_POS_DOWN,5
	.byte TM_POINT
	.byte TM_DELAY,25
	.byte TM_TEXT,$31,$39,$39,$33,$20,$09,$0e,$14,$05,$0c,$20,$10,$05,$0e,$14,$09,$15,$0d,0 //pentium
	.byte TM_POS_REL,1,0
	.byte TM_POS_RIGHT,10
	.byte TM_DELAY,25
	.byte TM_SCROLL_LEFT,30
	.byte TM_POS_REL,<-30,0
	.byte TM_POS_STORE
	.byte TM_POINT
	.byte TM_DELAY,25
	.byte TM_TEXT,$31,$39,$39,$32,$20,$07,$12,$01,$16,$09,$13,$20,$15,$0c,$14,$12,$01,$13,$0f,$15,$0e,$04,0 //gravis
	.byte TM_POS_RESTORE
	.byte TM_POS_REL,0,1
	.byte TM_POS_DOWN,4
	.byte TM_POS_RIGHT,5
	.byte TM_POS_STORE
	.byte TM_POINT
	.byte TM_DELAY,25
	.byte TM_TEXT,$01,$0d,$09,$07,$01,$20,$01,$07,$01,0 //amiga aga
	.byte TM_SCROLL_UP,15
	.byte TM_POS_RESTORE
	.byte TM_POS_REL,0,<-14
	.byte TM_POS_DOWN,5
	.byte TM_POS_STORE
	.byte TM_POINT
	.byte TM_DELAY,10
	.byte TM_TEXT,$31,$39,$39,$31,$20,$03,$04,$14,$16,0 //cdtv
	.byte TM_POS_RESTORE
	.byte TM_POS_REL,0,1
	.byte TM_POS_DOWN,5
	.byte TM_POS_RIGHT,5
	.byte TM_POINT
	.byte TM_DELAY,10
	.byte TM_TEXT,$16,$09,$12,$14,$15,$01,$0c,$09,$14,$19,0 //virtuality
	.byte TM_POS_REL,1,0
	.byte TM_DELAY,10
	.byte TM_SCROLL_LEFT,34
	.byte TM_POS_REL,<-33,0
	.byte TM_POS_RIGHT,10
	.byte TM_POINT
	.byte TM_DELAY,10
	.byte TM_TEXT,$31,$39,$39,$30,$20,$13,$15,$10,$05,$12,$20,$0e,$09,$0e,$14,$05,$0e,$04,$0f,0 //snes
	.byte TM_POS_REL,1,0
	.byte TM_DELAY,10
	.byte TM_SCROLL_UP,15
	.byte TM_POS_REL,0,<-15
	.byte TM_POS_RIGHT,3
	.byte TM_POS_DOWN,5
	.byte TM_POS_LEFT,7
	.byte TM_POS_REL,<-18,0
	.byte TM_POS_STORE
	.byte TM_POINT
	.byte TM_DELAY,10
	.byte TM_TEXT,$31,$39,$38,$39,$20,$09,$0e,$14,$05,$0c,$20,$38,$30,$34,$38,$36,0 //intel 486
	.byte TM_DELAY,10
	.byte TM_POS_RESTORE
	.byte TM_POS_REL,0,1
	.byte TM_POS_DOWN,4
	.byte TM_POS_RIGHT,5
	.byte TM_POS_STORE
	.byte TM_POINT
	.byte TM_DELAY,10
	.byte TM_TEXT,$07,$01,$0d,$05,$20,$02,$0f,$19,0 //game boy
	.byte TM_POS_RESTORE
	.byte TM_POS_REL,0,1
	.byte TM_POS_DOWN,4
	.byte TM_POS_STORE
	.byte TM_POINT
	.byte TM_TEXT,$13,$0f,$15,$0e,$04,$20,$02,$0c,$01,$13,$14,$05,$12,0 //sound blaster
	.byte TM_SCROLL_UP,10
	.byte TM_POS_RESTORE
	.byte TM_POS_REL,0,<-9
	.byte TM_POS_DOWN,3
	.byte TM_POS_LEFT,10
	.byte TM_POS_DOWN,3
	.byte TM_POS_STORE
	.byte TM_POINT
	.byte TM_TEXT,$31,$39,$38,$38,$20,$13,$05,$07,$01,$20,$07,$05,$0e,$05,$13,$09,$13,0 //sega
	.byte TM_POS_RESTORE
	.byte TM_POS_REL,0,1
	.byte TM_POS_DOWN,4
	.byte TM_POS_STORE
	.byte TM_POINT
	.byte TM_TEXT, $31, $39, $38, $37, $20, $16, $07, $01, 0 //vga
	.byte TM_SCROLL_UP,15
	.byte TM_POS_RESTORE
	.byte TM_POS_REL,0,<-14
	.byte TM_POS_DOWN,4
	.byte TM_POS_RIGHT,5
	.byte TM_POS_STORE
	.byte TM_POINT
	.byte TM_TEXT, $09, $02, $0d, $20, $10, $13, $2f, $32, 0 //ps/2
	.byte TM_POS_RESTORE
	.byte TM_POS_REL,0,1
	.byte TM_POS_DOWN,4
	.byte TM_POS_STORE
	.byte TM_POINT
	.byte TM_TEXT, $01, $04, $0c, $09, $02, 0 //adlib
	.byte TM_POS_RESTORE
	.byte TM_SCROLL_RIGHT,22
	.byte TM_POS_REL,21,0
	.byte TM_POS_LEFT,23
	.byte TM_POS_DOWN,4
	.byte TM_POS_STORE
	.byte TM_POINT
	.byte TM_TEXT, $31, $39, $38, $36, $20, $04, $05, $13, $0b, $10, $12, $0f, $20, $33, $38, $36, 0 //deskpro 386
	.byte TM_POS_RESTORE
	.byte TM_SCROLL_UP,15
	.byte TM_POS_REL,0,<-14
	.byte TM_POS_DOWN,4
	.byte TM_POS_RIGHT,5
	.byte TM_POINT
	.byte TM_TEXT, $1a, $18, $20, $13, $10, $05, $03, $14, $12, $15, $0d, $20, $31, $32, $38, $0b, 0 //spectrum 128k
	.byte TM_POS_REL,1,0
	.byte TM_POS_RIGHT,3
	.byte TM_POS_DOWN,5
	.byte TM_POS_LEFT,10
	.byte TM_POS_REL,<-17,0
	.byte TM_POS_STORE
	.byte TM_POINT
	.byte TM_TEXT, $31, $39, $38, $35, $20, $01, $0d, $09, $07, $01, $20, $31, $30, $30, $30, 0 //amiga 1000
	.byte TM_POS_RESTORE
	.byte TM_POS_REL,0,1
	.byte TM_POS_DOWN,4
	.byte TM_POS_RIGHT,5
	.byte TM_POS_STORE
	.byte TM_POINT
	.byte TM_TEXT, $01, $14, $01, $12, $09, $20, $13, $14, 0 //atari st
	.byte TM_POS_RESTORE
	.byte TM_POS_REL,0,1
	.byte TM_POS_DOWN,4
	.byte TM_SCROLL_LEFT,10
	.byte TM_POS_REL,<-10,0
	.byte TM_POS_RIGHT,10
	.byte TM_POS_STORE
	.byte TM_POINT
	.byte TM_TEXT, $31, $39, $38, $34, $20, $01, $0d, $13, $14, $12, $01, $04, $20, $03, $10, $03, 0 //amstrad cpc
	.byte TM_SCROLL_UP,22
	.byte TM_POS_RESTORE
	.byte TM_POS_REL,0,<-21
	.byte TM_POS_DOWN,4
	.byte TM_POS_RIGHT,5
	.byte TM_POS_STORE
	.byte TM_POINT
	.byte TM_TEXT, $0d, $01, $03, $09, $0e, $14, $0f, $13, $08, 0 //macintosh
	.byte TM_POS_RESTORE
	.byte TM_POS_REL,0,1
	.byte TM_POS_DOWN,2
	.byte TM_POS_LEFT,5
	.byte TM_POS_DOWN,2
	.byte TM_POS_STORE
	.byte TM_POINT
	.byte TM_TEXT, $31, $39, $38, $33, $20, $0d, $13, $18, 0 //msx
	.byte TM_POS_RESTORE
	.byte TM_POS_REL,0,1
	.byte TM_POS_DOWN,4
	.byte TM_POS_RIGHT,5
	.byte TM_POS_STORE
	.byte TM_POINT
	.byte TM_TEXT, $06, $01, $0d, $09, $03, $0f, $0d, 0 //famicom
	.byte TM_SCROLL_UP,10
	.byte TM_POS_RESTORE
	.byte TM_POS_REL,0,<-9
	.byte TM_POS_DOWN,3
	.byte TM_POS_REL,<-10,1
	.byte TM_POS_STORE
	.byte TM_POINT
	.byte TM_TEXT, $31, $39, $38, $32, $20, $03, $0f, $0d, $0d, $0f, $04, $0f, $12, $05, $20, $36, $34, 0 //c64
	.byte TM_SCROLL_UP,5
	.byte TM_POS_RESTORE
	.byte TM_POS_REL,0,<-4
	.byte TM_POS_DOWN,4
	.byte TM_POS_RIGHT,5
	.byte TM_POS_STORE
	.byte TM_POINT
	.byte TM_TEXT, $1a, $18, $20, $13, $10, $05, $03, $14, $12, $15, $0d, 0 //spectrum
	.byte TM_SCROLL_UP,5
	.byte TM_POS_RESTORE
	.byte TM_POS_REL,0,<-4
	.byte TM_POS_DOWN,3
	.byte TM_POS_REL,<-5,1
	.byte TM_POINT
	.byte TM_TEXT, $31, $39, $38, $31, $20, $13, $09, $0e, $03, $0c, $01, $09, $12, $20, $1a, $18, $38, $31, 0 //zx81
	.byte TM_POS_REL,1,0
	.byte TM_POS_RIGHT,3
	.byte TM_POS_DOWN,5
	.byte TM_POS_LEFT,6
	.byte TM_POS_REL,<-13,0
	.byte TM_POS_STORE
	.byte TM_POINT
	.byte TM_TEXT, $09, $02, $0d, $20, $10, $03, $20, $35, $31, $35, $30, 0 //ibm pc
	.byte TM_POS_RESTORE
	.byte TM_POS_STORE
	.byte TM_POS_REL,0,1
	.byte TM_POS_DOWN,3
	.byte TM_SCROLL_UP,5
	.byte TM_POS_RESTORE
	.byte TM_POS_REL,<-5,0
	.byte TM_POS_STORE
	.byte TM_POINT
	.byte TM_TEXT, $31, $39, $38, $30, $20, $03, $0f, $0d, $0d, $0f, $04, $0f, $12, $05, $20, $16, $09, $03, $2d, $32, $30,0 //vic-20
	.byte TM_POS_RESTORE
	.byte TM_POS_REL,0,1
	.byte TM_POS_STORE
	.byte TM_POS_DOWN,7
	.byte TM_SCROLL_UP,19
	.byte TM_POS_RESTORE
	.byte TM_POS_REL,0,<-18
	.byte TM_POS_DOWN,12
	.byte TM_POINT
	.byte TM_TEXT, $17, $05, $20, $0e, $05, $05, $04, $20, $14, $0f, $20, $07, $0f, $20, $04, $05, $05, $10, $05, $12, $2e, $2e, $2e, 0 //deeper
	.byte TM_BLINK,16
	.byte TM_SCROLL_UP,15
	.byte TM_EOF

tm_prev_dir:	.byte TM_POS_DOWN
tm_blink_buf:	.fill 40,$20
tm_src_ptr:		.word 0
tm_put_x:		.byte 0
tm_put_y:		.byte 0
tm_put_xr:		.byte 0
tm_put_yr:		.byte 0
tm_put_dx:		.byte 0
tm_put_dy:		.byte 0
tm_put_cnt:		.byte 0
tm_delay:		.byte 0
tm_tile_first:	.byte 0
tm_tile_next:	.byte 0
tm_tag:			.byte 0
tm_point_flag:	.byte 0
tm_text_adr:	.word 0
tm_text_len:	.byte 0
