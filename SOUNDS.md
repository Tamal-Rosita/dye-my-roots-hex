# Sound & Audio Audit

Every sound in the game, where it comes from (procedural vs. audio file), and
where it is triggered. Target: all sound *effects* are procedural (generated
at runtime by `Sfx`) except the win jingle, which intentionally uses the
arcade cash-register/money files. Audio files remain for music, voice, and the
win jingle.

## Procedural SFX — `components/ui/Sfx.gd` (autoload)

All generated at runtime with `AudioStreamGenerator` (square-wave tones, no
assets). Call `Sfx.play("<name>")`.

| Sound          | Tones (Hz)                 | Trigger                                                                |
| -------------- | -------------------------- | ---------------------------------------------------------------------- |
| `tick`         | 1320                       | CharRoller value change (`CharRoller._step`)                           |
| `select`       | 990                        | CharRoller column move, MainMenu navigation/hover, wake from attract   |
| `confirm`      | 660 -> 990                 | CharRoller accept, MainMenu option activation, SoundLibrary play       |
| `cancel`       | 220                        | CharRoller cancel, any-button "back" on HighScores/Credits/SoundLibrary|
| `countdown`    | 880                        | Dye color timer: one beep per second of the 3-2-1 countdown            |
| `turn_warning` | 660                        | Session clock: one beep per second in its last 5 s                     |
| `timeout`      | 880 -> 440                 | Dye color timer expiry (auto-submit round)                             |
| `denied`       | 160                        | Player invalid-guess feedback (replaces `wrong.mp3`)                   |
| `fail`         | 392 -> 262                 | Round lost (`OneInfiniteMechanic.failed`, replaces `Timeout.wav`)      |
| `turn_over`    | 880-660-440-220            | Game-over overlay shown (`GameOver`)                                   |
| `bonus`        | 440-660-880                | Session time bonus granted (`OneInfiniteMechanic._grant_time_bonus`)   |

## File-based tracks (assets, with embedded metadata)

Metadata was embedded with `tools/tag_sounds.py` (ID3v2 for MP3, LIST/INFO
for WAV) and can be edited further in Audacity
(File > Edit Metadata Tags). Tracks are playable in-game via the
**Sound Test** entry of the main menu (`components/ui/SoundLibrary.*`), which
also shows each track's metadata.

| Asset                                        | Title / Artist            | Used for                          |
| -------------------------------------------- | ------------------------- | --------------------------------- |
| `sounds/566952__code_box__funky-groove.wav`  | Funky Groove / code_box   | Main scene BGM (`Main.tscn`)      |
| `sounds/201159__kiddpark__cash-register.mp3` | Cash Register / kiddpark  | Round won — cash (`WinSFXPlayer`) |
| `sounds/91920__...cashierreceiptservo.wav`   | Cashier Receipt Servo / filipe-chagas | Round won — money (`WinSFXPlayer`) |
| `sounds/483598__raclure__wrong.mp3`          | Wrong / raclure           | Unused (replaced by 'denied')     |
| `sounds/Timeout.wav`                         | Timeout / Unknown         | Unused (replaced by 'fail')       |
| `addons/ACVoicebox/Sounds/*.wav` (a-z, th, sh…) | —                      | Voice: Ms Kelly dialogue (TTS)    |

## Sound Test (dev tool)

`MainMenu` option "Sound Test" opens a library listing all 11 procedural SFX
and the 5 file tracks above. UP/DOWN navigates, A/ENTER plays the highlighted
entry, B/CANCEL returns to the menu, and the bottom line shows the metadata of
the selected track. (Godot 3.5 has no built-in inspector/FileSystem audio
preview — see godotengine/godot-proposals#6110 — so this in-game browser is
the equivalent tool.)

## Unused leftovers

`sounds/483598__raclure__wrong.mp3` and `sounds/Timeout.wav` are no longer
referenced by any scene (kept for reference; deletable).
