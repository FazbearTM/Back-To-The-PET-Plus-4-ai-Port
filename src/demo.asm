// M276 Noise handoff diagnostic - based on M273 checkpoint
// Back to the PET - Plus/4 M230 - M190 integration with Noise packed source moved out of live TED attribute RAM
// M110: M107 recovery baseline; Maze note 3 muted; TED-attribute Checkmate fade.
// No PM2/messages/markers: visual falling-stream checkpoint only.

*=$1001
.byte $0b,$10,$0a,$00,$9e,$38,$31,$39,$32,$00,$00,$00

.const ATTR=$0800
.const TED_SCREEN=$0c00
.const SCREEN=$9c00
.const PETCHAR=$7c00
.const PDR_SHADOW=$0400

// M83 PDR v3.1: IRQ-driven physical NTSC clock.
// PM2 advances only from the raster IRQ; graphics maintains its own logical frame.

.const Z_DST=$56
.const Z_LOOP=$58
.const Z_CNT=$59
.const Z_RAND=$5a

// M77 replay-safe packed bank in the unused BASIC-to-code gap.
*=$1100
m77_morph_zx02: .import binary "overlay_morph_m77.zx02"
m77_music6_zx02: .import binary "music_6.pm2.zx02"

*=$2000

m48_intro:
 sei
 cld
 lda #0
 sta $ff3f
 sta $ff11
 sta $ff0a
 lda $ff09
 sta $ff09
 // M100: every return to the intro resets selection to purple.
 lda #$54
 sta demo_colour
 // Explicit M18 physical screen mapping before intro.
 lda $ff06
 and #%10000000
 ora #%00000000       // display off until menu/font initialization completes
 sta $ff06
 lda $ff07
 and #%01000000
 ora #%00001000
 sta $ff07
 lda #$08
 sta $ff14
 // M56: apply proven M24 cleanup to the intro itself.
 lda $ff0a
 and #$fb
 sta $ff0a
 lda #$20
 ldx #0
m56_intro_phys_clear:
 sta TED_SCREEN,x
 sta TED_SCREEN+$100,x
 sta TED_SCREEN+$200,x
 sta TED_SCREEN+$300,x
 inx
 bne m56_intro_phys_clear
 lda #0
 ldx #0
m56_intro_attr_clear:
 sta ATTR,x
 sta ATTR+$100,x
 sta ATTR+$200,x
 sta ATTR+$300,x
 inx
 bne m56_intro_attr_clear
 lda $ff12
 ora #$04              // TED fetches characters from ROM, CPU stays all-RAM
 sta $ff12
 lda #$d4              // menu font at $D400, not the PET font at $7C00
 sta $ff13
 lda demo_colour
 sta $ff15
 lda #0
 sta $ff19
 jsr m48_clear
 lda $ff06
 ora #$10
 sta $ff06
 lda #<m48_text
 sta $f7
 lda #>m48_text
 sta $f8
 lda #<(TED_SCREEN+40)
 sta $f9
 lda #>(TED_SCREEN+40)
 sta $fa
 lda #0
 sta m48_col
m48_type:
 ldy #0
 lda ($f7),y
 inc $f7
 bne !+
 inc $f8
!:
 cmp #$ff
 beq m48_page
 cmp #$fe
 beq m48_nl
 ldy m48_col
 sta ($f9),y
 inc m48_col
 jsr m48_frame
 jmp m48_type
m48_nl:
 clc
 lda $f9
 adc #40
 sta $f9
 bcc !+
 inc $fa
!:
 lda #0
 sta m48_col
 jmp m48_type
m48_page:
 // Keep the original picker semantics, but absorb delayed
 // LOAD/RUN keyboard-buffer residue once when the picker first appears.
 sei
m48_release:
 jsr menu_key
 bne m48_release
 // Ten video frames (~0.2 s NTSC) of one-time debounce/flush.  GETIN is
 // deliberately discarded here; after this window every new key is real input.
 ldx #10
m212_flush_input:
 jsr m48_frame
 jsr menu_key
 dex
 bne m212_flush_input
m48_press:
 jsr menu_key
 beq m48_wait_frame
 cmp #$31            // 1 = Purple
 beq m100_pick_purple
 cmp #$32            // 2 = Green (original PET look)
 beq m100_pick_green
 cmp #$33            // 3 = Amber/Orange
 beq m100_pick_amber
 jmp m48_got         // M212: any other deliberate key starts the demo
m48_wait_frame:
 jsr m48_frame
 jmp m48_press

m100_pick_purple:
 lda #$54
 bne m100_colour_selected
m100_pick_green:
 lda #$55
 bne m100_colour_selected
m100_pick_amber:
 lda #$58
m100_colour_selected:
 sta demo_colour
 sta $ff15           // immediate visible feedback on intro
m100_wait_release:
 jsr menu_key
 bne m100_wait_release
 jmp m48_press       // M209 behavior: selection returns to normal key polling

m48_got:
 jsr menu_key
 bne m48_got
 sei
 // Transition to black background; selected colour becomes the demo foreground.
 lda #0
 sta $ff15
 jsr m48_purple
 jsr m48_scroll
 jmp m55_after_intro

m48_frame:
 lda $ff1d
 sta m48_prev
!:
 lda $ff1d
 cmp m48_prev
 bcc !+
 sta m48_prev
 jmp !-
!:
 rts
m48_clear:
 lda #$20
 ldx #0
!:
 sta TED_SCREEN,x
 sta TED_SCREEN+$100,x
 sta TED_SCREEN+$200,x
 cpx #$e8
 bcs !+
 sta TED_SCREEN+$300,x
!:
 inx
 bne !--
 lda #0
 ldx #0
!:
 sta ATTR,x
 sta ATTR+$100,x
 sta ATTR+$200,x
 cpx #$e8
 bcs !+
 sta ATTR+$300,x
!:
 inx
 bne !--
 rts
m48_purple:
 lda demo_colour
 ldx #0
!:
 sta ATTR,x
 sta ATTR+$100,x
 sta ATTR+$200,x
 cpx #$e8
 bcs !+
 sta ATTR+$300,x
!:
 inx
 bne !--
 rts
m48_scroll:
 lda #0
 sta m53_step
m53_outer:
 ldy #1
 lda m53_step
 cmp #5
 bcs m53_delay
 ldy #8
m53_delay:
 jsr m48_frame
 dey
 bne m53_delay

 lda #<TED_SCREEN
 sta $fb
 lda #>TED_SCREEN
 sta $fc
 lda #<(TED_SCREEN+40)
 sta $fd
 lda #>(TED_SCREEN+40)
 sta $fe
 lda #24
 sta m53_rows
m53_row:
 ldy #0
m53_col:
 lda ($fd),y
 sta ($fb),y
 iny
 cpy #40
 bne m53_col
 clc
 lda $fd
 adc #40
 sta $fd
 bcc !+
 inc $fe
!:
 clc
 lda $fb
 adc #40
 sta $fb
 bcc !+
 inc $fc
!:
 dec m53_rows
 bne m53_row
 lda #$20
 ldy #0
m53_clear_last:
 sta TED_SCREEN+24*40,y
 iny
 cpy #40
 bne m53_clear_last
 inc m53_step
 lda m53_step
 cmp #25
 bne m53_outer
 rts
m53_step: .byte 0
m53_rows: .byte 0
m48_col:.byte 0
m48_prev:.byte 0
// M102 first Checkmate frame: zoom_data frame 0 is a 2x2 checker grid
// ($20/$a0), so pre-rendering it makes the scene boundary seamless.
m102_prefill_checkmate:
 ldx #0
!row:
 txa
 and #2
 beq !normal+
 lda #$a0
 bne !seed+
!normal:
 lda #$20
!seed:
 sta m102_grid_seed
 txa
 pha
 lda scr40_table_l,x
 sta Z_DST
 lda scr40_table_h,x
 sta Z_DST+1
 ldy #0
!col:
 lda m102_grid_seed
 sta (Z_DST),y
 iny
 sta (Z_DST),y
 iny
 lda m102_grid_seed
 eor #$80
 sta m102_grid_seed
 cpy #40
 bne !col-
 pla
 tax
 inx
 cpx #25
 bne !row-
 rts
m102_grid_seed:.byte 0

demo_colour:.byte $54
m48_text:
.byte $2a,$2a,$2a,$20,$42,$41,$43,$4b,$20,$54,$4f,$20,$54,$48,$45,$20,$50,$45,$54,$20,$2d,$20,$50,$4c,$55,$53,$2f,$34,$20,$2a,$2a,$2a,$fe,$fe,$4f,$52,$49,$47,$49,$4e,$41,$4c,$20,$50,$45,$54,$20,$44,$45,$4d,$4f,$20,$42,$59,$20,$53,$48,$49,$52,$55,$38,$42,$49,$54,$fe,$48,$54,$54,$50,$53,$3a,$2f,$2f,$53,$48,$49,$52,$55,$2e,$55,$4e,$54,$45,$52,$47,$52,$55,$4e,$44,$2e,$4e,$45,$54,$2f,$fe,$fe,$43,$36,$34,$20,$50,$4f,$52,$54,$20,$42,$59,$20,$4d,$41,$43,$43,$3b,$20,$50,$4c,$55,$53,$2f,$34,$20,$50,$4f,$52,$54,$fe,$54,$41,$52,$47,$45,$54,$53,$20,$41,$20,$53,$54,$41,$4e,$44,$41,$52,$44,$20,$36,$34,$4b,$20,$4d,$41,$43,$48,$49,$4e,$45,$2e,$fe,$fe,$54,$48,$45,$20,$45,$46,$46,$45,$43,$54,$53,$20,$55,$53,$45,$20,$54,$48,$45,$20,$4e,$41,$54,$49,$56,$45,$20,$34,$30,$58,$32,$35,$fe,$54,$45,$44,$20,$54,$45,$58,$54,$20,$53,$43,$52,$45,$45,$4e,$20,$44,$49,$52,$45,$43,$54,$4c,$59,$2e,$fe,$fe,$43,$4f,$4d,$4d,$4f,$44,$4f,$52,$45,$20,$50,$4c,$55,$53,$2f,$34,$20,$50,$4f,$52,$54,$fe,$42,$59,$20,$46,$41,$5a,$42,$45,$41,$52,$54,$4d,$fe,$fe,$50,$52,$45,$53,$53,$20,$31,$20,$46,$4f,$52,$20,$50,$55,$52,$50,$4c,$45,$20,$28,$44,$45,$46,$41,$55,$4c,$54,$29,$2c,$fe,$32,$20,$46,$4f,$52,$20,$47,$52,$45,$45,$4e,$20,$28,$4f,$52,$49,$47,$49,$4e,$41,$4c,$29,$2c,$fe,$33,$20,$46,$4f,$52,$20,$41,$4d,$42,$45,$52,$20,$28,$4f,$52,$41,$4e,$47,$45,$29,$fe,$fe,$50,$52,$45,$53,$53,$20,$41,$4e,$59,$20,$4b,$45,$59,$fe,$ff

start:
 sei
 ldx #$ff
 txs
 jmp m48_intro
m55_after_intro:

 // M55: straight-line intro handoff completed; enter M40 runtime.
 cld
 ldx #0
 ldy #0

 // Frozen verified M18/M19/M22 TED setup.
 lda $ff06
 and #%10000000
 ora #%00000000
 sta $ff06
 lda $ff07
 and #%01000000
 ora #%00001000
 sta $ff07
 lda #$08
 sta $ff14
 lda #0
 sta $ff15
 sta $ff19

 // M24 artifact cleanup only:
 // disable TED cursor/blink display and make the unused 24 bytes at the end
 // of both 1K video pages deterministic.
 lda $ff0a
 and #$fb
 sta $ff0a

 // M61: charset source sits at $8000 to make room for the old M32 audio table.
 // Expose all RAM BEFORE copying it; live TED charset remains verified $7C00.
 lda #0
 sta $ff3f

 // M74 packed exact PET charset -> live $7C00.
 lda #<m74_charset_zx02
 ldx #>m74_charset_zx02
 jsr m74_unpack_to_7c00

 lda $ff07
 and #$7f
 sta $ff07
 lda $ff12
 and #$fb
 sta $ff12
 lda $ff13
 and #$03
 ora #$7c
 sta $ff13

 // M93: initialize the future live TED pages BEFORE selecting them.
 // This prevents TED from briefly displaying uninitialized $9C00 RAM (the
 // all-@ flash seen at M92 startup).  M91 direct-screen architecture stays.
 lda demo_colour
 ldx #0
m93_attr_preinit:
 sta $9800,x
 sta $9900,x
 sta $9a00,x
 sta $9b00,x
 inx
 bne m93_attr_preinit
 lda #$20
 ldx #0
m93_screen_preinit:
 sta $9c00,x
 sta $9d00,x
 sta $9e00,x
 sta $9f00,x
 inx
 bne m93_screen_preinit
 // $FF14=$98 maps attributes at $9800 and character matrix at $9C00.
 lda #$98
 sta $ff14

 // M49: reassert the verified M24/M26 post-intro cleanup.
 lda $ff0a
 and #$fb
 sta $ff0a
 lda #$20
 ldx #0
m49_phys_preclear:
 sta TED_SCREEN,x
 sta TED_SCREEN+$100,x
 sta TED_SCREEN+$200,x
 sta TED_SCREEN+$300,x
 inx
 bne m49_phys_preclear

 lda demo_colour
 ldx #0
col:
 sta ATTR,x
 sta ATTR+$100,x
 sta ATTR+$200,x
 sta ATTR+$300,x
 inx
 bne col

 // M21/M22-proven CPU all-RAM mapping: exposes $A000 framebuffer.
 lda #0
 sta $ff3f

 // M24: deterministic full physical 1K character page.
 lda #$20
 ldx #0
m24_phys_clear:
 sta TED_SCREEN,x
 sta TED_SCREEN+$100,x
 sta TED_SCREEN+$200,x
 sta TED_SCREEN+$300,x
 inx
 bne m24_phys_clear

 // Clear virtual PET screen and initialize PDR shadow to match it.
 lda #$20
 ldx #0
clr:
 sta SCREEN,x
 sta PDR_SHADOW,x
 sta SCREEN+$100,x
 sta PDR_SHADOW+$100,x
 sta SCREEN+$200,x
 sta PDR_SHADOW+$200,x
 cpx #$e8
 bcs clr4
 sta SCREEN+$300,x
 sta PDR_SHADOW+$300,x
clr4:
 inx
 bne clr

 lda $ff06
 ora #$10
 sta $ff06

 // Original PET random seeds.
 lda #139
 sta RAND_SEED_1
 lda #0
 sta RAND_SEED_2

 // M83 PDR v3.1: install a raster IRQ at line $F0.  The IRQ owns physical
 // music time.  Scene code/presentation never calls pp_update directly.
 jsr pdr_init

 // Original main-sequence relationship: start PM2 part 0 before Matrix.
 lda #0
 sta m36_visual_mode
 lda #<m74_music0_zx02
 ldx #>m74_music0_zx02
 jsr m74_unpack_to_b000
 lda #<$b000
 ldx #>$b000
 jsr pmdr_start_atomic

 jsr e_matrix

m31_wait_timeline_marker:
 jsr wait_frame
 jsr petplay_is_marker
 beq m31_wait_timeline_marker

 lda #1
 sta m102_pitch_profile       // Timeline-only pitch trim profile
 jsr e_timeline
 lda #0
 sta m102_pitch_profile
 jsr m61_wait_music_stop

 lda #<m74_music1_zx02
 ldx #>m74_music1_zx02
 jsr m74_unpack_to_b000
 lda #<$b000
 ldx #>$b000
 jsr pmdr_start_atomic
 jsr e_title
 jsr e_floor

 lda #<m74_music2_zx02
 ldx #>m74_music2_zx02
 jsr m74_unpack_to_b000
 lda #<$b000
 ldx #>$b000
 jsr pmdr_start_atomic
 // M111: Maze restored to the exact standard M98/M105 PMDR conversion path.
 lda #0
 sta m102_pitch_profile
 jsr e_maze
 jsr m61_wait_music_stop

 lda #<m74_music3_zx02
 ldx #>m74_music3_zx02
 jsr m74_unpack_to_b000
 lda #<$b000
 ldx #>$b000
 jsr pmdr_start_atomic
 jsr e_checkers
 // M111: restore M98 Checkers -> Checkmate execution and original
 // character-density fade verbatim. No prefill, bottom-row patch, attribute
 // fade, or post-fade display manipulation is inserted here.
 jsr e_checkmate
 jsr m61_wait_music_stop

 lda #<m74_music4_zx02
 ldx #>m74_music4_zx02
 jsr m74_unpack_to_b000
 lda #<$b000
 ldx #>$b000
 jsr pmdr_start_atomic
 // Waves packed source is permanently at $F000.
 lda #<m74_charset_zx02
 ldx #>m74_charset_zx02
 jsr m74_unpack_to_7c00
 // M104: Petflip reveals its first picture progressively. Clear the virtual
 // PET matrix before entering it so stale Checkmate/chess-piece cells cannot
 // survive around the newly revealed picture. Do not blank TED directly.
 lda #$20
 ldx #$00
!m104_petflip_clear:
 sta SCREEN+$000,x
 sta SCREEN+$100,x
 sta SCREEN+$200,x
 cpx #$e7
 bcs !m104_petflip_tail+
 sta SCREEN+$300,x
!m104_petflip_tail:
 inx
 bne !m104_petflip_clear-
 lda #<m68_petflip_zx02
 ldx #>m68_petflip_zx02
 jsr m69_run_overlay
 lda #$01
 sta m94_waves_active
 // M95: repair Waves lower-row TED attributes before its first visible frame.
 jsr m94_repair_waves_attrs
 lda #<m75_waves_zx02
 ldx #>m75_waves_zx02
 jsr m69_run_overlay
 lda #$00
 sta m94_waves_active
 // M94: Waves uses the lower compatibility rows; sanitize rows 18-24 after it
 // visible PET rows during its strip math.  With M91's live framebuffer those
 // formerly-hidden tail writes persist into later scenes.  Clean only the
 // two bottom compatibility rows AFTER Waves returns; effect math is untouched.
 jsr m93_clean_bottom_rows
 jsr m61_wait_music_stop

 // Reuse the old part-4 music window for part 5.
 lda #<m73_music5_zx02
 ldx #>m73_music5_zx02
 jsr m73_unpack_music_b000
 lda #<$b000
 ldx #>$b000
 jsr pmdr_start_atomic

 lda #<m73_greets_zx02
 ldx #>m73_greets_zx02
 jsr m73_run_overlay_e000
 jsr m61_wait_music_stop

 // M77: original Morph scene + original PM2 part 6.
 // Both packed sources live in the otherwise-unused BASIC-to-code gap,
 // so they survive all scene overlays and are also available for replay.
 lda #<m77_music6_zx02
 ldx #>m77_music6_zx02
 jsr m74_unpack_to_b000
 lda #<$b000
 ldx #>$b000
 jsr pmdr_start_atomic
 lda #<m77_morph_zx02
 ldx #>m77_morph_zx02
 jsr m69_run_overlay
 jsr m61_wait_music_stop

 // M78a: original PM2 part 7, then wait for its opening marker exactly
 // like the original main sequence before entering Bump.
 lda #<m78_music7_zx02
 ldx #>m78_music7_zx02
 jsr m74_unpack_to_b000
 lda #<$b000
 ldx #>$b000
 jsr pmdr_start_atomic
 jsr wait_marker

 // M78a: packed Bump lives permanently in the unused $C800-$CA94 hole.
 // No runtime staging and no $FCxx storage near TED I/O.
 lda #<m78_bump_zx02
 ldx #>m78_bump_zx02
 jsr m69_run_overlay
 jsr m61_wait_music_stop

 // M138: M136/M135 Voice visuals frozen; PET SOUND/MUTE use PMDR, PLAY silent.
 // Publish the selector colour in a fixed mailbox so the relocatable overlay
 // does not depend on a resident symbol address.
 lda demo_colour
 sta $04fe
 // M142: unpack the real 2063-byte voice.bin before Voice.  Speech output
 // now uses TED D/A mode with audible sources enabled and NTSC pacing.
 jsr replay_save
 lda #<m140_voice_data_zx02
 ldx #>m140_voice_data_zx02
 jsr m140_unpack_voice_7000
 lda #<m142_voice_ntsc_zx02
 ldx #>m142_voice_ntsc_zx02
 jsr m69_run_overlay

 // M213: restore the proven M153/M206 Voice endpoint exactly: do not mask
 // IRQs before the authentic deconstruction routine.
hold:
 // M153 proven Voice endpoint: authentic deconstruction while Voice state is intact.
 jsr m153_pet_deconstruct_fade

 sei
 jsr petplay_stop
 ldx #0
!stage:
 lda noise_packed,x
 sta $b000,x
 lda noise_packed+$100,x
 sta $b100,x
 inx
 bne !stage-
 ldx #0
!tail:
 lda noise_packed_tail,x
 sta $b200,x
 inx
 cpx #noise_tail_size
 bne !tail-
 lda #<$b000
 ldx #>$b000
 sta comp_data
 stx comp_data+1
 lda #<$d000
 sta out_adr
 lda #>$d000
 sta out_adr+1
 jsr full_decomp
 jsr pdr_init
 jsr $d000
 jsr m153_pet_deconstruct_fade
 sei
 jsr replay_restore
 jmp start

m93_clean_bottom_rows:
 // M94: clear all seven lower compatibility rows after Waves.
 lda #$20
 .for (var R=18; R<25; R++) {
   ldx #0
!:
   sta SCREEN+R*40,x
   inx
   cpx #40
   bne !-
 }
 lda demo_colour
 .for (var R=18; R<25; R++) {
   ldx #0
!:
   sta $9800+R*40,x
   inx
   cpx #40
   bne !-
 }
 rts

// M94 Waves-only live attribute repair.  The original effect still writes its
// character data directly; this only restores TED attributes for lower rows.
m94_waves_active: .byte 0
m94_repair_waves_attrs:
 lda demo_colour
 .for (var R=18; R<25; R++) {
   ldx #0
!:
   sta $9800+R*40,x
   inx
   cpx #40
   bne !-
 }
 rts

// M85 PMDR v2: PM2 stream startup is an atomic transaction.
// The raster IRQ is the sole pp_update owner, so it must never observe
// petplay_start halfway through pointer/table/state initialization.
pmdr_start_atomic:
 sei
 jsr petplay_start
 cli
 rts

m69_run_overlay:
 sta comp_data
 stx comp_data+1
 lda #<$d000
 sta out_adr
 lda #>$d000
 sta out_adr+1
 jsr full_decomp
 jsr $d000
 rts

m73_run_overlay_e000:
 sta comp_data
 stx comp_data+1
 lda #<$e000
 sta out_adr
 lda #>$e000
 sta out_adr+1
 jsr full_decomp
 jsr $e000
 rts

m140_unpack_voice_7000:
 sta comp_data
 stx comp_data+1
 lda #<$7000
 sta out_adr
 lda #>$7000
 sta out_adr+1
 jsr full_decomp
 rts

m74_unpack_to_7c00:
 sta comp_data
 stx comp_data+1
 lda #<$7c00
 sta out_adr
 lda #>$7c00
 sta out_adr+1
 jsr full_decomp
 rts
m74_unpack_to_b000:
 // The IRQ may fire while we decompress.  Stop the old stream first so it
 // can never walk a half-replaced $B000 music image.
 pha
 txa
 pha
 jsr petplay_stop
 pla
 tax
 pla
 sta comp_data
 stx comp_data+1
 lda #<$b000
 sta out_adr
 lda #>$b000
 sta out_adr+1
 jsr full_decomp
 rts

m73_unpack_music_b000:
 jmp m74_unpack_to_b000

// ---------------------------------------------------------------------------
// PET Dynamic Runtime v3
// NTSC: one raster IRQ per frame. PAL: evenly spaced 60 Hz TED timer-1 IRQs.
// Graphics waits for a new tick; no frame backlog crosses a scene boundary.
// Presentation: at most once per physical frame, with the M79 dirty shadow.
// ---------------------------------------------------------------------------
pdr_phys_frame:    .byte 0
pdr_graph_frame:   .byte 0
pdr_present_frame: .byte $ff

pdr_init:
 sei
 lda #0
 sta $ff0a
 sta pdr_phys_frame
 sta pdr_graph_frame
 lda #$ff
 sta pdr_present_frame
 lda #<pdr_irq
 sta $fffe
 lda #>pdr_irq
 sta $ffff
 .if (PAL) {
 // TED timer 1 decrements at the PAL single clock (886723.5 Hz).
 // Reload 14779 gives 59.9989 Hz without double-updating any notes.
 lda #<14779
 sta $ff00
 lda #>14779
 sta $ff01
 lda $ff09
 sta $ff09
 lda #$08
 sta $ff0a
 } else {
 lda #$f0
 sta $ff0b
 lda $ff09
 sta $ff09
 lda #$02
 sta $ff0a
 }
 cli
 rts

pdr_irq:
 pha
 txa
 pha
 tya
 pha
 .if (PAL) { lda #$08 } else { lda #$02 }
 sta $ff09
 inc pdr_phys_frame
 inc m68_api_frame_cnt
 jsr pp_update           // sole PM2 clock: one update per physical frame
 pla
 tay
 pla
 tax
 pla
 rti

// Compatibility service used by Waves/Bump/marker polling.  PM2 no longer
// needs cooperative polling: the raster IRQ owns it.
m72_music_poll:
 rts

// Original scenes call wait_frame once per logical PET frame.
// Always wait for a fresh tick so later scenes cannot consume earlier debt.
wait_frame:
 pha
 txa
 pha
 tya
 pha
 // M91: graphics remain one logical PET frame per physical NTSC frame,
 // but SCREEN=$9C00 is now TED's live character matrix. No copy/scan.
 // Wait for a new clock tick. Do not carry a backlog across scenes.
 lda pdr_phys_frame
m91_wf_wait:
 cmp pdr_phys_frame
 beq m91_wf_wait
 inc pdr_graph_frame
 pla
 tay
 pla
 tax
 pla
 rts

// Direct-present callers (notably Waves) need no compatibility copy now.
// Their writes to SCREEN are already visible to TED.
m90_present_sync:
pet_present:
 lda pdr_phys_frame
 sta pdr_present_frame
 lda m94_waves_active
 beq !done+
 jsr m94_repair_waves_attrs
!done:
 rts

// Not used by this M23 entry path; supplied only so the original matrix.asm
// remains unedited and can resolve its e_matrix_print references.
check_marker:
 // M82: PM2 advances from the raster IRQ even inside tight marker loops.
 jmp petplay_is_marker

m61_wait_music_stop:
 jsr wait_frame
 lda PP_ACTIVE
 bne m61_wait_music_stop
 rts

wait_frames:
 cpx #0
 beq !+
!loop:
 jsr wait_frame
 dex
 bne !loop-
!:
 rts

wait_marker:
 jsr wait_frame
 jsr petplay_is_marker
 beq wait_marker
 rts

m36_visual_mode: .byte 0
m36_marker_lo: .byte 0

// Original 40-column PET row table, now pointing at virtual PET SCREEN=$A000.
// Entry 25 is intentionally present: original fade logic uses it off-screen.
scr40_table_l:
.fill 26, <(SCREEN+i*40)
scr40_table_h:
.fill 26, >(SCREEN+i*40)

RAND_SEED_1: .byte 139
RAND_SEED_2: .byte 0


// Original PET PM2 player configuration.
.const Z_SRC=$54
.const Z_LEN=$5b
.const Z_TEMP=$5d


.const PP_SRC=$65
.const PP_ISRC=$67

// M61: exact M32 rough TED backend (the VIC-20-like sounding version).
pp_set_wave:
 beq pp_wave_off
 lda $ff11
 and #$e0
 ora #$18              // voice 1 on, volume 8
 sta $ff11
 rts
pp_wave_off:
 lda $ff11
 and #$e0
 sta $ff11
 rts

// M87 PMDR v3: complete mathematical PET->TED conversion for the TED
// representable range.  The PET timer period is the pitch itself; this table
// is generated from the documented C64/PET frequency conversion and NTSC TED
// divisor formula.  No octave folding and no part-0-derived vocabulary.
// X/Y = original 12-bit PET timer pitch.
pp_set_pitch:
 stx m87_pitch_lo
 sty m87_pitch_hi
 // M104 scene-local PMDR lift. Timeline and Maze use the same established
 // PET->TED conversion as the rest of the demo, but their original PET timer
 // periods are halved before conversion. Halving the timer period raises the
 // complete scene by one octave while preserving every interval, and brings
 // the lowest notes above TED's practical bass floor.
 lda m102_pitch_profile
 cmp #1
 bne !profile_done+
 txa
 sec
 sbc #$01
 tax
 tya
 sbc #$00
 tay
 tya
 lsr
 tay
 txa
 ror
 tax
 stx m87_pitch_lo
 sty m87_pitch_hi
!profile_done:
 // M110 Maze note 3 only: silence it. Notes 1,2,4,5 use the exact
 // normal M98/M105 conversion below; no noise, clamp, or octave substitute.
 lda m102_pitch_profile
 cmp #2
 bne !m110_normal_note+
 inc m109_maze_note_index
 lda m109_maze_note_index
 cmp #3
 bne !m110_wrap+
 lda $ff11
 and #$e0              // disable tone/noise sources; preserve upper control bits
 sta $ff11
 rts
!m110_wrap:
 cmp #6
 bcc !m110_normal_note+
 lda #1
 sta m109_maze_note_index
!m110_normal_note:
 lda $ff11
 and #$8f
 ora #$10              // voice 1 tone, current volume
 sta $ff11
 ldx m87_pitch_lo
 ldy m87_pitch_hi
 // M88 PMDR v4: preserve every directly representable PET fundamental.
 // For only the first octave below TED's floor ($023b-$0475), use the
 // PET waveform's second harmonic instead of silence.  Deeper bass stays
 // muted: no repeated/global octave folding.
 cpy #$02
 bcc m87_pitch_lookup
 bne m88_try_second_harmonic
 cpx #$3b
 bcc m87_pitch_lookup
m88_try_second_harmonic:
 // M97: restore the exact M89/M88 Maze low-note behavior.
 // PET periods $023b-$0475 use the exact second harmonic; deeper bass mutes.
 cpy #$04
 bcc m89_second_harmonic
 bne m87_pitch_mute
 cpx #$76
 bcs m87_pitch_mute
m89_second_harmonic:
 // Divide the 12-bit PET timer period by two, matching M89's pitch path.
 txa
 sec
 sbc #$01
 tax
 tya
 sbc #$00
 tay
 tya
 lsr
 tay
 txa
 ror
 tax
 stx m87_pitch_lo
 sty m87_pitch_hi
 jmp m87_pitch_lookup
m87_pitch_lookup:
 // Three direct 256-entry pages avoid a linear search in the NTSC IRQ.
 lda m87_pitch_hi
 beq m87_page0
 cmp #$01
 beq m87_page1
 ldx m87_pitch_lo
 lda m87_ted_lo2,x
 sta $ff0e
 lda m87_ted_hi2,x
 jmp m87_pitch_store_hi
m87_page1:
 ldx m87_pitch_lo
 lda m87_ted_lo1,x
 sta $ff0e
 lda m87_ted_hi1,x
 jmp m87_pitch_store_hi
m87_page0:
 ldx m87_pitch_lo
 lda m87_ted_lo0,x
 sta $ff0e
 lda m87_ted_hi0,x
m87_pitch_store_hi:
 pha
 lda $ff12
 and #$fc
 sta m87_ff12_tmp
 pla
 ora m87_ff12_tmp
 sta $ff12
 rts
m87_pitch_mute:
 lda #$00
 sta $ff11
 rts

m102_pitch_profile: .byte 0
m109_maze_note_index: .byte 0
m87_pitch_lo: .byte 0
m87_pitch_hi: .byte 0
m87_ff12_tmp: .byte 0
m87_tables:
.label m87_ted_lo0=m87_tables+0
.label m87_ted_hi0=m87_tables+256
.label m87_ted_lo1=m87_tables+512
.label m87_ted_hi1=m87_tables+768
.label m87_ted_lo2=m87_tables+1024
.label m87_ted_hi2=m87_tables+1280
.if (PAL) {
table_lo0: .byte $fb,$fa,$f8,$f6,$f4,$f2,$f1,$ef,$ed,$eb,$ea,$e8,$e6,$e4,$e2,$e1,$df,$dd,$db,$d9,$d8,$d6,$d4,$d2,$d0,$cf,$cd,$cb,$ca,$c9,$c7,$c5,$c3,$c1,$c0,$be,$bc,$ba,$b8,$b7,$b5,$b3,$b1,$af,$ae,$ac,$aa,$a8,$a7,$a5,$a3,$a1,$9f,$9e,$9c,$9a,$98,$96,$95,$93,$91,$8f,$8d,$8c,$8a,$88,$86,$85,$83,$81,$7f,$7d,$7c,$7a,$78,$76,$74,$73,$71,$6f,$6d,$6b,$6a,$68,$66,$64,$63,$61,$5f,$5d,$5c,$5b,$59,$57,$55,$53,$52,$50,$4e,$4c,$4a,$49,$47,$45,$43,$41,$40,$3e,$3c,$3a,$39,$37,$35,$33,$31,$30,$2e,$2c,$2a,$28,$27,$25,$23,$21,$1f,$1e,$1c,$1a,$18,$17,$15,$13,$11,$0f,$0e,$0c,$0a,$08,$06,$05,$03,$01,$ff,$fd,$fc,$fa,$f8,$f6,$f5,$f3,$f1,$f0,$ee,$ed,$eb,$e9,$e7,$e5,$e4,$e2,$e0,$de,$dc,$db,$d9,$d7,$d5,$d4,$d2,$d0,$ce,$cc,$cb,$c9,$c7,$c5,$c3,$c2,$c0,$be,$bc,$ba,$b9,$b7,$b5,$b3,$b2,$b0,$ae,$ac,$aa,$a9,$a7,$a5,$a3,$a1,$a0,$9e,$9c,$9a,$98,$97,$95,$93,$91,$90,$8e,$8c,$8a,$88,$87,$85,$84,$82,$80,$7f,$7d,$7b,$79,$77,$76,$74,$72,$70,$6f,$6d,$6b,$69,$67,$66,$64,$62,$60,$5e,$5d,$5b,$59,$57,$55,$54,$52,$50,$4e,$4d,$4b,$49,$47,$45,$44,$42,$40,$3e,$3c,$3b,$39,$37
table_hi0: .byte $03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$03,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02
table_lo1: .byte $37,$35,$33,$32,$30,$2e,$2c,$2b,$29,$27,$25,$23,$22,$20,$1e,$1c,$1a,$19,$17,$16,$14,$12,$11,$0f,$0d,$0b,$09,$08,$06,$04,$02,$01,$ff,$fd,$fb,$f9,$f8,$f6,$f4,$f2,$f0,$ef,$ed,$eb,$e9,$e7,$e6,$e4,$e2,$e0,$df,$dd,$db,$d9,$d7,$d6,$d4,$d2,$d0,$ce,$cd,$cb,$c9,$c7,$c5,$c4,$c2,$c0,$be,$bd,$bb,$b9,$b7,$b5,$b4,$b2,$b0,$ae,$ac,$ab,$aa,$a8,$a6,$a4,$a3,$a1,$9f,$9d,$9c,$9a,$98,$96,$94,$93,$91,$8f,$8d,$8b,$8a,$88,$86,$84,$82,$81,$7f,$7d,$7b,$7a,$78,$76,$74,$72,$71,$6f,$6d,$6b,$69,$68,$66,$64,$62,$60,$5f,$5d,$5b,$59,$58,$56,$54,$52,$50,$4f,$4d,$4b,$49,$47,$46,$44,$42,$40,$3e,$3e,$3c,$3a,$38,$37,$35,$33,$31,$2f,$2e,$2c,$2a,$28,$26,$25,$23,$21,$1f,$1d,$1c,$1a,$18,$16,$15,$13,$11,$0f,$0d,$0c,$0a,$08,$06,$04,$03,$01,$ff,$fd,$fb,$fa,$f8,$f6,$f4,$f3,$f1,$ef,$ed,$eb,$ea,$e8,$e6,$e4,$e2,$e1,$df,$dd,$db,$d9,$d8,$d6,$d4,$d2,$d1,$d0,$ce,$cc,$ca,$c9,$c7,$c5,$c3,$c1,$c0,$be,$bc,$ba,$b8,$b7,$b5,$b3,$b1,$af,$ae,$ac,$aa,$a8,$a7,$a5,$a3,$a1,$9f,$9e,$9c,$9a,$98,$96,$95,$93,$91,$8f,$8d,$8c,$8a,$88,$86,$85,$83,$81,$7f,$7d,$7c,$7a,$78,$76,$74,$73
table_hi1: .byte $02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$02,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$01,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
table_lo2: .byte $71,$6f,$6d,$6b,$6a,$68,$66,$65,$64,$62,$60,$5e,$5c,$5b,$59,$57,$55,$53,$52,$50,$4e,$4c,$4a,$49,$47,$45,$43,$42,$40,$3e,$3c,$3a,$39,$37,$35,$33,$31,$30,$2e,$2c,$2a,$28,$27,$25,$23,$21,$20,$1e,$1c,$1a,$18,$17,$15,$13,$11,$0f,$0e,$0c,$0a,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
table_hi2: .byte $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
} else {
table_lo0: .byte $fb, $fa, $f8, $f6, $f4, $f2, $f1, $ef, $ed, $eb, $ea, $e8, $e6, $e4, $e2, $e1, $df, $dd, $db, $d9, $d8, $d6, $d4, $d2, $d0, $cf, $cd, $cb, $c9, $c8, $c6, $c4, $c2, $c0, $bf, $bd, $bb, $b9, $b7, $b6, $b4, $b2, $b0, $ae, $ad, $ab, $a9, $a7, $a6, $a4, $a2, $a0, $9e, $9d, $9b, $99, $97, $95, $94, $92, $90, $8e, $8c, $8b, $89, $87, $85, $84, $82, $80, $7e, $7c, $7b, $79, $77, $75, $73, $72, $70, $6e, $6c, $6a, $69, $67, $65, $63, $62, $60, $5e, $5c, $5a, $59, $57, $55, $53, $51, $50, $4e, $4c, $4a, $48, $47, $45, $43, $41, $3f, $3e, $3c, $3a, $38, $37, $35, $33, $31, $2f, $2e, $2c, $2a, $28, $26, $25, $23, $21, $1f, $1d, $1c, $1a, $18, $16, $15, $13, $11, $0f, $0d, $0c, $0a, $08, $06, $04, $03, $01, $ff, $fd, $fb, $fa, $f8, $f6, $f4, $f3, $f1, $ef, $ed, $eb, $ea, $e8, $e6, $e4, $e2, $e1, $df, $dd, $db, $d9, $d8, $d6, $d4, $d2, $d1, $cf, $cd, $cb, $c9, $c8, $c6, $c4, $c2, $c0, $bf, $bd, $bb, $b9, $b7, $b6, $b4, $b2, $b0, $af, $ad, $ab, $a9, $a7, $a6, $a4, $a2, $a0, $9e, $9d, $9b, $99, $97, $95, $94, $92, $90, $8e, $8d, $8b, $89, $87, $85, $84, $82, $80, $7e, $7c, $7b, $79, $77, $75, $73, $72, $70, $6e, $6c, $6b, $69, $67, $65, $63, $62, $60, $5e, $5c, $5a, $59, $57, $55, $53, $51, $50, $4e, $4c, $4a, $49, $47, $45, $43, $41, $40, $3e, $3c, $3a, $38, $37, $35, $33
table_hi0: .byte $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $03, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02
table_lo1: .byte $33, $31, $2f, $2e, $2c, $2a, $28, $27, $25, $23, $21, $1f, $1e, $1c, $1a, $18, $16, $15, $13, $11, $0f, $0d, $0c, $0a, $08, $06, $04, $03, $01, $ff, $fd, $fc, $fa, $f8, $f6, $f4, $f3, $f1, $ef, $ed, $eb, $ea, $e8, $e6, $e4, $e2, $e1, $df, $dd, $db, $da, $d8, $d6, $d4, $d2, $d1, $cf, $cd, $cb, $c9, $c8, $c6, $c4, $c2, $c0, $bf, $bd, $bb, $b9, $b8, $b6, $b4, $b2, $b0, $af, $ad, $ab, $a9, $a7, $a6, $a4, $a2, $a0, $9e, $9d, $9b, $99, $97, $96, $94, $92, $90, $8e, $8d, $8b, $89, $87, $85, $84, $82, $80, $7e, $7c, $7b, $79, $77, $75, $74, $72, $70, $6e, $6c, $6b, $69, $67, $65, $63, $62, $60, $5e, $5c, $5a, $59, $57, $55, $53, $52, $50, $4e, $4c, $4a, $49, $47, $45, $43, $41, $40, $3e, $3c, $3a, $38, $37, $35, $33, $31, $30, $2e, $2c, $2a, $28, $27, $25, $23, $21, $1f, $1e, $1c, $1a, $18, $16, $15, $13, $11, $0f, $0e, $0c, $0a, $08, $06, $05, $03, $01, $ff, $fd, $fc, $fa, $f8, $f6, $f4, $f3, $f1, $ef, $ed, $ec, $ea, $e8, $e6, $e4, $e3, $e1, $df, $dd, $db, $da, $d8, $d6, $d4, $d2, $d1, $cf, $cd, $cb, $c9, $c8, $c6, $c4, $c2, $c1, $bf, $bd, $bb, $b9, $b8, $b6, $b4, $b2, $b0, $af, $ad, $ab, $a9, $a7, $a6, $a4, $a2, $a0, $9f, $9d, $9b, $99, $97, $96, $94, $92, $90, $8e, $8d, $8b, $89, $87, $85, $84, $82, $80, $7e, $7d, $7b, $79, $77, $75, $74, $72, $70, $6e, $6c, $6b
table_hi1: .byte $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $02, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $01, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
table_lo2: .byte $69, $67, $65, $63, $62, $60, $5e, $5c, $5b, $59, $57, $55, $53, $52, $50, $4e, $4c, $4a, $49, $47, $45, $43, $41, $40, $3e, $3c, $3a, $39, $37, $35, $33, $31, $30, $2e, $2c, $2a, $28, $27, $25, $23, $21, $1f, $1e, $1c, $1a, $18, $17, $15, $13, $11, $0f, $0e, $0c, $0a, $08, $06, $05, $03, $01, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
table_hi2: .byte $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00



}

.import source "sound-original.asm"

.import source "random.asm"
.import source "tables.asm"
.import source "matrix.asm"
.import source "timeline.asm"
.import source "title.asm"
.import source "floor.asm"
.import source "maze.asm"
.import source "checkers.asm"
.import source "checkmate.asm"

// M153: authentic PET shared e_fade appended AFTER all Chess/Checkmate code.
// Pre-Voice scene addresses therefore remain exactly M149/M115.
.const M153_RAND_TABLE=$0500
m153_pet_deconstruct_fade:
 lda #0
 sta $ff11
 jsr m153_fade_init
 lda #64
 sta m153_fade_cnt
!loop:
 jsr wait_frame
 jsr m153_fade_frame
 dec m153_fade_cnt
 bne !loop-
 rts
m153_fade_init:
 ldx #0
!fill:
 jsr rand8
 and #7
 clc
 adc #4
 sta M153_RAND_TABLE,x
 inx
 bne !fill-
 rts
m153_fade_frame:
 lda #0
 sta m153_fade_row
!row:
 ldx m153_fade_row
 lda scr40_table_l,x
 sta Z_DST
 lda scr40_table_h,x
 sta Z_DST+1
 ldy #0
!col:
 lda (Z_DST),y
 tax
 lda chr_to_density,x
 beq !skip+
 sec
 sbc M153_RAND_TABLE,y
 bcs !nonneg+
 lda #0
!nonneg:
 tax
 lda density_to_chr,x
 sta (Z_DST),y
!skip:
 iny
 cpy #40
 bne !col-
 inc m153_fade_row
 lda m153_fade_row
 cmp #25
 bne !row-
 rts

m153_fade_cnt: .byte 0
m153_fade_row: .byte 0

.assert "Resident code must stay below charset", * <= $7c00, true

// M221: keep unreachable postfade hold removed so main code stays below $7C00.

*=$a400
.import source "zx02.asm"

*=$9180
m68_api_wait_frame:   jmp wait_frame
m68_api_check_marker: jmp check_marker
m68_api_rand8:        jmp rand8
m68_api_frame_cnt:    .byte 0
m71_api_present:      jmp m90_present_sync
m72_api_music_poll:   jmp m72_music_poll
m73_api_get_pitch:    jmp petplay_get_pitch
m73_api_get_wave:     jmp petplay_get_wave
// M138 Voice-only ABI: established PMDR low-level PET wave/timer conversion.
m138_api_set_wave:     jmp pp_set_wave
m138_api_set_pitch:    jmp pp_set_pitch

// M140 permanent packed Voice sample. $7000 is post-Chess scratch by Voice time.
*=$9200
m140_voice_data_zx02: .import binary "voice_data_m140.zx02"

// Packed core bank below the stable overlay ABI.
*=$8000
m74_charset_zx02: .import binary "pet_charset_1k.zx02"
m74_music0_zx02:  .import binary "music_0.pm2.zx02"
m74_music1_zx02:  .import binary "music_1.pm2.zx02"
m74_music2_zx02:  .import binary "music_2.pm2.zx02"
m74_music3_zx02:  .import binary "music_3.pm2.zx02"
m74_music4_zx02:  .import binary "music_4.pm2.zx02"

// $A000-$A3E7 is framebuffer, $A400 is decompressor. This packed bank
// begins safely after the small decompressor and ends below $B000.
*=$a600
m73_greets_zx02: .import binary "overlay_greets_m76.zx02"
m73_music5_zx02: .import binary "music_5.pm2.zx02"
m78_music7_zx02: .import binary "music_7.pm2.zx02"

*=$b600
m68_petflip_zx02: .import binary "overlay_petflip_m68.zx02"

// M78a permanent Bump packed source in the unused gap after Petflip.
*=$c800
m78_bump_zx02: .import binary "overlay_bump_m79.zx02"
m142_voice_ntsc_zx02: .import binary "overlay_m144_voice_ntsc_return.zx02"

// Immutable Waves source: all scene overlays end below $F000.
*=$f000
m75_waves_zx02: .import binary "overlay_waves_m72.zx02"

*=$9652
noise_packed_tail: .import binary "noise_part2.bin"
.label noise_tail_size=*-noise_packed_tail
.assert "Noise tail fits", * <= $9800, true

// Immutable Noise payload, no longer stored in the music destination $B000.
*=$8f27
noise_packed: .import binary "noise_part1.bin"
.assert "Noise packed payload must fit below attributes", * <= $9180, true

*=$1f20
replay_save:
 ldx #0
!loop:
 .for (var P=0; P<9; P++) {
 lda $7000+P*$100,x
 sta $e000+P*$100,x
 }
 inx
 bne !loop-
 rts
replay_restore:
 ldx #0
!loop:
 .for (var P=0; P<9; P++) {
 lda $e000+P*$100,x
 sta $7000+P*$100,x
 }
 inx
 bne !loop-
 rts
.assert "Replay helpers must fit", * <= $2000, true

*=$100d
// A=0 no key, ASCII 1/2/3 for colour keys, space for other keys.
// X/Y preserved. Disable joystick selection while sampling keyboard matrix.
menu_key:
 txa
 pha
 lda #$7f
 sta $fd30
 lda #$ff
 sta $ff08
 lda $ff08
 and #1
 beq !one+
 lda $ff08
 and #8
 beq !two+
 lda #$fd
 sta $fd30
 lda #$ff
 sta $ff08
 lda $ff08
 and #1
 beq !three+
 lda #0
 sta $fd30
 lda #$ff
 sta $ff08
 lda $ff08
 cmp #$ff
 beq !none+
 lda #$20
 bne !done+
!one: lda #$31
 bne !done+
!two: lda #$32
 bne !done+
!three: lda #$33
 bne !done+
!none: lda #0
!done:
 sta menu_result
 lda #$ff
 sta $fd30
 pla
 tax
 lda menu_result
 rts
menu_result: .byte 0
.assert "Keyboard helper must fit", * <= $1100, true
