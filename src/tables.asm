// Character density tables: the mapping between PETSCII glyphs and how
// many pixels they light up.  Effects fade and dither through these.

// Extracted from the PET original: shared.s
// Syntax translated to Kick Assembler; logic unchanged.

//index=pixel density (least to most), value=character
//there are two characters with zero pixels, $20 and $60
//the tables are set to have $20 as even more empty than $60

density_to_chr:
	.byte $20,$60,$3a,$2c,$27,$3b,$2e,$55,$21,$4a,$49,$2f,$2d,$22,$1c,$70
	.byte $4b,$29,$28,$6e,$6d,$67,$65,$64,$63,$5d,$59,$54,$52,$4e,$4d,$48
	.byte $47,$46,$45,$44,$43,$42,$40,$7d,$2b,$72,$6b,$3f,$1f,$1e,$14,$09
	.byte $73,$71,$3d,$19,$0c,$0a,$5e,$37,$31,$1d,$1b,$03,$25,$18,$16,$0f
	.byte $7a,$5b,$50,$4f,$4c,$34,$0b,$06,$7e,$7c,$7b,$77,$74,$6f,$6c,$6a
	.byte $68,$5c,$57,$56,$3e,$3c,$15,$11,$33,$26,$24,$10,$07,$58,$39,$36
	.byte $35,$32,$1a,$13,$0e,$08,$04,$01,$2a,$38,$17,$12,$0d,$05,$00,$30
	.byte $23,$02,$79,$78,$76,$75,$5a,$e9,$df,$d3,$41,$ff,$e6,$e2,$e1,$d1
	.byte $7f,$66,$62,$61,$51,$c1,$53,$69,$5f,$da,$f9,$f8,$f6,$f5,$b0,$a3
	.byte $82,$b8,$97,$92,$8d,$85,$80,$aa,$d8,$b9,$b6,$b5,$b2,$9a,$93,$8e
	.byte $88,$84,$81,$b3,$a6,$a4,$90,$87,$fe,$fc,$fb,$f7,$f4,$ef,$ec,$ea
	.byte $e8,$dc,$d7,$d6,$be,$bc,$95,$91,$fa,$db,$d0,$cf,$cc,$b4,$8b,$86
	.byte $a5,$98,$96,$8f,$de,$b7,$b1,$9d,$9b,$83,$f3,$f1,$bd,$99,$8c,$8a
	.byte $f2,$eb,$bf,$9f,$9e,$94,$89,$fd,$ab,$ee,$ed,$e7,$e5,$e4,$e3,$dd
	.byte $d9,$d4,$d2,$ce,$cd,$c8,$c7,$c6,$c5,$c4,$c3,$c2,$c0,$f0,$cb,$a9
	.byte $a8,$ca,$c9,$af,$ad,$a2,$9c,$d5,$a1,$bb,$ae,$ac,$a7,$ba,$e0,$a0

//index=chr code, value=pixel density

chr_to_density:
	.byte $6e,$67,$71,$3b,$66,$6d,$47,$5c,$65,$2f,$35,$46,$34,$6c,$64,$3f
	.byte $5b,$57,$6b,$63,$2e,$56,$3e,$6a,$3d,$33,$62,$3a,$0e,$39,$2d,$2c
	.byte $00,$08,$0d,$70,$5a,$3c,$59,$04,$12,$11,$68,$28,$03,$0c,$06,$0b
	.byte $6f,$38,$61,$58,$45,$60,$5f,$37,$69,$5e,$02,$05,$55,$32,$54,$2b
	.byte $26,$7a,$25,$24,$23,$22,$21,$20,$1f,$0a,$09,$10,$44,$1e,$1d,$43
	.byte $42,$84,$1c,$86,$1b,$07,$53,$52,$5d,$1a,$76,$41,$51,$19,$36,$88
	.byte $01,$83,$82,$18,$17,$16,$81,$15,$50,$87,$4f,$2a,$4e,$14,$13,$4d
	.byte $0f,$31,$29,$30,$4c,$75,$74,$4b,$73,$72,$40,$4a,$49,$27,$48,$80
	.byte $96,$a2,$90,$c9,$a1,$95,$bf,$a7,$a0,$d6,$cf,$be,$ce,$94,$9f,$c3
	.byte $a6,$b7,$93,$9e,$d5,$b6,$c2,$92,$c1,$cd,$9d,$c8,$f6,$c7,$d4,$d3
	.byte $ff,$f8,$f5,$8f,$a5,$c0,$a4,$fc,$f0,$ef,$97,$d8,$fb,$f4,$fa,$f3
	.byte $8e,$c6,$9c,$a3,$bd,$9b,$9a,$c5,$91,$99,$fd,$f9,$b5,$cc,$b4,$d2
	.byte $ec,$85,$eb,$ea,$e9,$e8,$e7,$e6,$e5,$f2,$f1,$ee,$bc,$e4,$e3,$bb
	.byte $ba,$7f,$e2,$79,$e1,$f7,$b3,$b2,$98,$e0,$89,$b9,$b1,$df,$c4,$78
	.byte $fe,$7e,$7d,$de,$dd,$dc,$7c,$db,$b0,$77,$af,$d1,$ae,$da,$d9,$ad
	.byte $ed,$cb,$d0,$ca,$ac,$8d,$8c,$ab,$8b,$8a,$b8,$aa,$a9,$d7,$a8,$7b
