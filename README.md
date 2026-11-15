# Back-To-The-PET-Plus-4-ai-Port
The ever popular Back To The PET Demo has finally been Ported to the Commodore Plus/4 for NTSC and Pal systems, made in Kick Assembler

A Commodore Plus/4 port of Shiru's Back to the PET demo, with separate NTSC and PAL builds. The Plus/4 port is by FazbearTM a.k.a Me! and Chatgpt + Chatgpt Codex, drawing on the original PET
demo and Macc's C64 port. I also improved the Demo a little bit with it by adding the ability to play the Demo theoretically forever as long as you continue to press a key at the menu, also I added a few more colours to pick from to give this Port it's own identity. Purple is the Default, Green is the original, Orange I added for fun.

The Plus/4 has it's own limitations, the music was one for example, The TED chip doesn't have as low of frequencies as the other 8-Bit Commodore Computers have, so the Timeline scene had it's music shifted up 1 frequency. It's recognizable now. The Maze scene has the other Music issue, I couldn't get an arrangement for it to work so I left it with a note missing. as it better represents it. Graphics had no issue with it at all.

This release has been verified to run great on the VICE Plus/4 Emulator by a Human, Me!
At this time, I'm unable to test on a Real Plus/4 until mine is repaired but will be repaired shortly.
I will be uploading this to Plus/4 World for all users to enjoy

## Controls and Requirements

A standard 64 KB Commodore Plus/4, or a correctly configured Plus/4 emulator.
Choose the PRG matching the machine's video standard.

At the introduction, Pick your Colour:
    1  Purple (default)
    2  Green (original PET look)
    3  Amber / orange
    Any other key starts the demo.

After the demo returns to the introduction, choose a colour or start again.
The program intentionally stays in the demo/menu loop; it does not exit to
BASIC at the end.

### Files and Size

BackToThePET_Plus4_NTSC.prg     28,564 bytes

BackToThePET_Plus4_PAL.prg      28,713 bytes

Both ordinary, uncompressed build images are 60,247 bytes. Executable
compression reduces their disk-file sizes by approximately 52.6% (NTSC)
and 52.4% (PAL). It does not reduce the required 64 KB machine RAM.
The Noise overlay itself is 671 bytes compressed with ZX02, compared with
984 bytes for the inherited LZSS payload.

### NTSC / PAL NOTES

The NTSC build retains the established NTSC scene and music clock.
The PAL runtime uses TED timer 1 to generate evenly spaced music/graphics
clock ticks at approximately 60 Hz on a 50 Hz display. It does not double
music updates on selected raster frames. Timer reload is 14779, clocked at
886723.5 Hz. Its TED music frequency-divider tables are adjusted for PAL.

The inherited cycle-timed speech routine is retained. PAL's CPU clock makes
that speech approximately 0.9% slower; it has not been resampled or rewritten.
Heavy drawing can still limit presentation rate. These builds do not promise
identical individual raster frames on the two video standards.

Real-hardware playback and a listening check of the revised PAL timing are
still needed. No claim is made that the large user-supplied video recording
was inspected: it exceeded the environment's 32 MiB attachment-transfer limit.

## References

Original demo / Shiru:
https://shiru.untergrund.net/
https://www.pouet.net/prod.php?which=92595

C64 reference source:
https://github.com/AbelVincze/Backtothepet-c64-ai-port
Reference checkout: 98098761b8f87ca33c0de0e5e9445d39d75c278c
