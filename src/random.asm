// Extracted from the PET original: shared.s
// Syntax translated to Kick Assembler; logic unchanged.

rand1:

	lda RAND_SEED_1
	asl
	bcc !+
	eor #$cf
!:
	sta RAND_SEED_1
	rts

rand2:

	lda RAND_SEED_2
	asl
	bcc !+
	eor #$d7
!:
	sta RAND_SEED_2
	rts

rand8:

	jsr rand1
	jsr rand2
	adc RAND_SEED_1
	rts
