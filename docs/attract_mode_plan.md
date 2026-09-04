# Attract Mode — Implementation Plan (comparison)

Goal: an arcade "attract mode" that cycles — gameplay demo → high scores →
title/menu → back to gameplay demo — and wakes to the main menu on any input.

## Option A — AI live-playback (recommended)

Run the *actual* game loop with a scripted "AI" player, then switch views in a
circular sequence.

- **AI controller** (`AttractController.gd`): every demo round, pick a target,
  drive the existing `HexRoller` (scroll columns, set values, confirm) so the
  dye is submitted — using the exact same Player/Dye flow as a human. To look
  believable, the AI aims *near* the target with a little jitter, sometimes
  "missing" on purpose.
- **Sequencer**: `gameplay demo (≈8 s)` → `high scores (≈5 s, reuse the existing
  Leaderboard/AttractMode)` → `title menu (≈5 s, show the real MainMenu)` →
  loop. Any `ui_*` press wakes to the menu (already implemented in Landing).

**Effort**: moderate — one new controller + one small sequencer state machine,
reusing existing scenes/components. ~200–300 lines total, no new assets.

**Godot 3.5 support**: fully native — just nodes/scripts/timers. Works headless
and on the Raspberry Pi/FRT target (no codecs involved).

**Pros**: real-time, always matches the current build (colors/UI stay in sync
after future changes); deterministic; no media assets; trivially tunable
durations; the AI and wake-to-menu share the game's real input flow.

**Cons**: the AI must be tuned so it doesn't look dumb; slightly more code than
a video.

## Option B — Hardcoded gameplay video

Record gameplay to a file and play it with a `VideoPlayer` node.

- Record/encode an `.ogv` (Theora) clip, ship it, and stream it in the attract
  overlay.

**Effort**: content-heavy (recording/editing/encoding) but little code.

**Godot 3.5 support**: **risky on this project.** `VideoPlayer` requires the
Theora module, which is *not* guaranteed in 3.5 builds — and the game's export
preset is the FRT arm64 template (Raspberry Pi), where Theora/GLES2 video
playback is effectively unsupported. Desktop would need a custom Theora-enabled
build.

**Pros**: pixel-exact footage of a real session.

**Cons**: large binary; codec/module availability risk on the actual target;
static footage drifts out of sync with future art/UI changes; no interactivity;
production pipeline overhead.

## Recommendation

Implement **Option A (AI live-playback)** in three phases, and skip the video
for now because of the Pi/FRT codec risk:

1. **Phase 1 — AI demo segment**: `AttractController` drives a real round.
2. **Phase 2 — circular sequencer**: demo → high scores → menu → repeat
   (reuses `Leaderboard`, `MainMenu`, and the existing attract overlay).
3. **Phase 3 — polish**: wake-to-menu on any button (already scaffolded),
   loop timings, and a subtle "demo" watermark.

The current attract overlay already provides the "high scores" segment, so only
the AI segment is genuinely new work.
