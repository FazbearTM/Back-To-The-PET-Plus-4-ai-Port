// M207 integrated Noise: D14 literal PET graphics + selector colour + TED noise sound
// ~7s visual run, 16-phase deconstruction, then 1s "Loading . . ." two-blink transition.
.const ATTR=$9800
.const SCREEN=$9c00
.const SELECTED_COLOUR=$04fe
.const NOISE_BUF=$a000
.const NOISE_FRAMES_PER_STEP=30
.const TOTAL_FRAMES=420 //       // D14 renderer runs near 50Hz on NTSC: ~7 seconds

*=$d000
    jmp start

start:
    cld
    lda #0
    sta $ff11

    // Freeze the proven D9/D14 physical display path.
    lda $ff06
    and #%10000000
    ora #%00010000
    sta $ff06
    lda $ff07
    and #%01000000
    ora #%00001000
    sta $ff07
    lda #$98
    sta $ff14
    lda $ff12
    and #$fb
    sta $ff12
    lda $ff13
    and #$03
    ora #$7c
    sta $ff13
    lda #0
    sta $ff15
    sta $ff19

    // Colour picker mailbox contains the actual TED attribute ($54/$55/$58).
    lda SELECTED_COLOUR
    ldx #0
!attr:
    sta ATTR,x
    sta ATTR+$100,x
    sta ATTR+$200,x
    cpx #$e8
    bcs !atail+
    sta ATTR+$300,x
!atail:
    inx
    bne !attr-

    lda #0
    tax
!clear_buf:
    sta NOISE_BUF,x
    inx
    bne !clear_buf-
    lda pdr_frame
    sta last_frame
    lda #139
    sta rand_seed_1
    lda #0
    sta rand_seed_2
    lda #128
    sta noise_ptr
    lda #0
    sta noise_step
    sta noise_frame
    sta noise_snd_ptr
    sta total_lo
    sta total_hi
    sta phase_next_hi
    lda #26
    sta phase_next_lo

scene_loop:
    lda #0
    sta noise_frame
frame_loop:
    ldx noise_ptr
    ldy #12
fill_noise:
    jsr rand8
    and #15
    adc noise_step          // original carry behaviour retained
    sta NOISE_BUF,x
    inx
    dey
    bne fill_noise
    stx noise_ptr

    jsr rand8
    sta temp
    ldy #0
show_column:
    .for (var J=0; J<5; J++) {
        .for (var I=0; I<8; I++) {
            ldx temp
            inc temp
            lda NOISE_BUF,x
            clc
            adc noise_pic+((J*8+I)*25),y
            tax
            lda noise_tiles,x
            sta SCREEN+((J*8+I)*25),y
        }
    }
    iny
    cpy #25
    beq !show_done+
    jmp show_column
!show_done:

    // Sound is derived from current visual state only: it never consumes rand8,
    // so D14's now-proven graphics sequence stays untouched.
    jsr ted_noise_update

    lda pdr_frame
    tax
    sec
    sbc last_frame
    stx last_frame
    clc
    adc total_lo
    sta total_lo
    bcc !nohi+
    inc total_hi
!nohi:
    lda total_hi
    cmp #>TOTAL_FRAMES
    bcc !continue+
    bne noise_finished
    lda total_lo
    cmp #<TOTAL_FRAMES
    bcs noise_finished
!continue:
    lda total_hi
    cmp phase_next_hi
    bcc !keep+
    bne !advance+
    lda total_lo
    cmp phase_next_lo
    bcc !keep+
!advance:
    lda noise_step
    clc
    adc #16
    sta noise_step
    inc noise_snd_ptr
    lda phase_next_lo
    clc
    adc #26
    sta phase_next_lo
    bcc !keep+
    inc phase_next_hi
!keep:
    jmp frame_loop

noise_finished:
    lda #0
    sta $ff11
    rts

// TED channel 2 hardware noise. Original 16-phase mask supplies the envelope;
// visual state supplies the rapidly changing value/frequency without advancing RNG.
ted_noise_update:
    lda noise_snd_ptr
    and #15
    tax
    lda noise_sound_mask,x
    sta snd_mask
    lda temp
    eor noise_step
    eor NOISE_BUF,x
    and snd_mask
    sta snd_value
    and #$0f
    ora #$40
    sta $ff11
    lda snd_value
    eor #$a5
    sta $ff0f
    lda snd_value
    lsr
    lsr
    lsr
    lsr
    and #$03
    sta $ff10
    rts

rand1:
    lda rand_seed_1
    asl
    bcc !+
    eor #$cf
!:
    sta rand_seed_1
    rts
rand2:
    lda rand_seed_2
    asl
    bcc !+
    eor #$d7
!:
    sta rand_seed_2
    rts
rand8:
    jsr rand1
    jsr rand2
    adc rand_seed_1
    rts

rand_seed_1: .byte 0
rand_seed_2: .byte 0
noise_ptr: .byte 0
noise_step: .byte 0
noise_frame: .byte 0
noise_snd_ptr: .byte 0
temp: .byte 0
total_lo: .byte 0
total_hi: .byte 0
snd_mask: .byte 0
snd_value: .byte 0
last_frame: .byte 0
phase_next_lo: .byte 0
phase_next_hi: .byte 0

noise_sound_mask:
.byte %00000001,%00010001,%01001001,%01010101
.byte %01110101,%01110111,%01111101,%11110101
.byte %11110101,%01111101,%01110111,%01110101
.byte %01010101,%01001001,%00010001,%00000001

noise_tiles:
.byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$6c,$7b,$7c,$7e,$7f,$ff
.byte $20,$6c,$7b,$7c,$7e,$7f,$ff,$20,$20,$20,$6c,$7b,$7c,$7e,$7f,$ff
.byte $20,$6c,$7b,$7c,$7e,$7f,$ff,$61,$e1,$62,$e2,$20,$61,$e1,$62,$e2
.byte $20,$6c,$7b,$7c,$7e,$7f,$ff,$61,$e1,$62,$e2,$ec,$fb,$fc,$fe,$e0
.byte $20,$61,$e1,$62,$e2,$e0,$e0,$61,$e1,$62,$e2,$ec,$fb,$fc,$fe,$e0
.byte $ec,$fb,$fc,$fe,$e0,$ec,$fb,$fc,$fe,$e0,$ec,$fb,$fc,$fe,$e0,$e0
.byte $20,$61,$e1,$62,$e2,$e0,$e0,$61,$e1,$62,$e2,$ec,$fb,$fc,$fe,$e0
.byte $20,$6c,$7b,$7c,$7e,$7f,$ff,$61,$e1,$62,$e2,$ec,$fb,$fc,$fe,$e0
.byte $20,$6c,$7b,$7c,$7e,$7f,$ff,$61,$e1,$62,$e2,$20,$61,$e1,$62,$e2
.byte $20,$6c,$7b,$7c,$7e,$7f,$ff,$20,$20,$20,$6c,$7b,$7c,$7e,$7f,$ff
.byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$6c,$7b,$7c,$7e,$7f,$ff
.byte $20,$20,$20,$20,$20,$20,$20,$20,$20,$20,$6c,$7b,$7c,$7e,$7f,$ff
.byte $20,$6c,$7b,$7c,$7e,$7f,$ff,$20,$20,$20,$6c,$7b,$7c,$7e,$7f,$ff
.byte $20,$6c,$7b,$7c,$7e,$7f,$ff,$61,$e1,$62,$e2,$20,$61,$e1,$62,$e2
.byte $20,$6c,$7b,$7c,$7e,$7f,$ff,$61,$e1,$62,$e2,$20,$61,$e1,$62,$e2
.byte $20,$6c,$7b,$7c,$7e,$7f,$ff,$20,$20,$20,$6c,$7b,$7c,$7e,$7f,$ff

noise_pic:
.import binary "noise_pic_m189.bin"

.label pdr_frame=$274d // generated by build script
