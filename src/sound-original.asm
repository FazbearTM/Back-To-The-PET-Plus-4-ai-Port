// ---------------------------------------------------------------------------
// Music player -- ported from the PET's petplayp.s
//
// The PET drove sound by clocking the VIA's shift register out of CB2.  None
// of that survives here, but everything above it does: this player still walks
// the original packed pm2 data, counts frame delays, raises the markers that
// scenes sync to, and keeps PP_WAVE/PP_PITCH current for e_greets' waveform
// display.  Only the two routines that actually touched hardware are stubbed.
//
// The data is unchanged PET music data, so scene timing matches the original
// beat for beat.  pp_set_wave and pp_set_pitch live in sid.asm, which turns
// what the PET asked of its shift register into what SID needs to hear.
// ---------------------------------------------------------------------------

//---------------------------------------------------------------------------
// Start the player.  A is the PET's charset selector, meaningless here.
//---------------------------------------------------------------------------

petplay_init:

        jmp petplay_stop                //jsr:rts

//---------------------------------------------------------------------------
// Silence the player for good; the last scenes make their own noise.
//---------------------------------------------------------------------------

petplay_done:

        jmp petplay_stop                //jsr:rts

petplay_get_pitch:

        lda PP_PITCH+0
        ldx PP_PITCH+1
        rts

petplay_get_wave:

        lda PP_WAVE
        rts

//---------------------------------------------------------------------------
// Everything below is the PET player unchanged.
//---------------------------------------------------------------------------

pp_update:

	lda PP_ACTIVE
	bne !+
	rts
!:

	lda PP_WAIT
	beq pp_update_read
	dec PP_WAIT
	beq pp_update_read
	rts

pp_update_read:

	lda PP_MUSIC_PTR+0
	sta PP_ISRC+0
	lda PP_MUSIC_PTR+1
	sta PP_ISRC+1

	ldy #0
	lda (PP_ISRC),y
	cmp #$fe
	bcc pp_update_frame
	beq pp_update_marker

pp_update_eof:

	sty PP_ACTIVE
	sty PP_WAVE
	jmp pp_update_done

pp_update_marker:

	// M83 PDR v3.1: physical-time audio can cross more than one marker
	// before a graphics-heavy scene consumes them. Queue markers instead
	// of overwriting the original one-bit latch.
	inc PP_MARKER
	inc PP_MUSIC_PTR+0
	bne pp_update_read
	inc PP_MUSIC_PTR+1
	jmp pp_update_read

pp_update_frame:

//The PET build selected the 4-byte delay/wave/pitch table format
//(PP_PM2); the 2-byte alternative was compiled out and is dropped here.
	sta PP_ISRC+0
	sty PP_ISRC+1
	asl
	rol PP_ISRC+1
	clc
	adc PP_ISRC+0
	bcc !+
	inc PP_ISRC+1
!:

	clc
	adc PP_TABLE_PTR+0
	sta PP_ISRC+0
	lda PP_ISRC+1
	adc PP_TABLE_PTR+1
	sta PP_ISRC+1

	lda (PP_ISRC),y
	iny
	sta PP_WAIT
	lda (PP_ISRC),y
	iny
	tax
	and #$0f
	sta PP_PITCH+1
	txa
	and #$f0
	sta PP_WAVE
	lda (PP_ISRC),y
	sta PP_PITCH+0

	inc PP_MUSIC_PTR+0
	bne !+
	inc PP_MUSIC_PTR+1
!:


pp_update_done:

	lda PP_WAVE
	jsr pp_set_wave
	ldx PP_PITCH+0
	ldy PP_PITCH+1
	jmp pp_set_pitch //jsr:rts


petplay_start:

	pha
	jsr petplay_stop
	pla

	sta PP_SRC+0
	stx PP_SRC+1

	ldy #0
	clc
	adc	(PP_SRC),y
	sta PP_TABLE_PTR+0
	iny
	txa
	adc (PP_SRC),y
	sta PP_TABLE_PTR+1

	lda PP_SRC+0
	clc
	adc #2
	bcc !+
	inc PP_SRC+1
!:
	sta PP_MUSIC_PTR+0
	lda PP_SRC+1
	sta PP_MUSIC_PTR+1

	lda #1
	sta PP_ACTIVE

	rts



//-------------------------------------------------------------------------
// stop playing a song
//-------------------------------------------------------------------------

petplay_stop:

	lda #0
	sta PP_ACTIVE
	sta PP_WAIT
	sta PP_MARKER
	sta PP_WAVE
	sta PP_PITCH+0
	sta PP_PITCH+1

	jmp pp_set_wave //jsr:rts



//-------------------------------------------------------------------------


petplay_is_marker:

	lda PP_MARKER
	beq !+
	dec PP_MARKER
	lda #1
!:
	rts



PP_MUSIC_PTR:		.word 0
PP_TABLE_PTR:		.word 0
PP_WAIT:			.byte 0
PP_MARKER:			.byte 0
PP_WAVE:			.byte 0
PP_PITCH:			.word 0
PP_ACTIVE:			.byte 0
