extends Node

# Synthesized arcade SFX bank.
# All sounds are generated at runtime with AudioStreamGenerator, so no audio
# assets are needed. Call Sfx.play("tick") from anywhere.
#
# The old CharRoller ticks were silent because frames were pushed into the
# generator buffer but play() was never called: pushing fills the buffer,
# play() starts consuming it.

const MIX_RATE: int = 22050

# Each sound is a list of [frequency, duration] tones played back to back.
var sounds: Dictionary = {
	"tick": [[1320.0, 0.04]],
	"select": [[990.0, 0.05]],
	"confirm": [[660.0, 0.06], [990.0, 0.09]],
	"cancel": [[220.0, 0.12]],
	"countdown": [[880.0, 0.05]],
	"turn_warning": [[660.0, 0.06]],
	"timeout": [[880.0, 0.12], [440.0, 0.22]],
	"denied": [[160.0, 0.18]],
	"fail": [[392.0, 0.12], [262.0, 0.28]],
	"turn_over": [[880.0, 0.14], [660.0, 0.14], [440.0, 0.14], [220.0, 0.35]],
	"bonus": [[440.0, 0.06], [660.0, 0.06], [880.0, 0.12]]
}

var players: Dictionary = {}

func _ready():
	for name in sounds:
		players[name] = _make_player()

func _make_player():
	var generator: AudioStreamGenerator = AudioStreamGenerator.new()
	generator.mix_rate = MIX_RATE
	generator.buffer_length = 0.5
	var player: AudioStreamPlayer = AudioStreamPlayer.new()
	player.stream = generator
	add_child(player)
	return player

func play(name):
	if not sounds.has(name):
		return
	var player: AudioStreamPlayer = players[name]
	if not player:
		return
	var playback = player.get_stream_playback()
	if not playback or not playback.has_method("push_frame"):
		return
	player.stop()
	for tone in sounds[name]:
		var freq: float = tone[0]
		var dur: float = tone[1]
		var frames: int = int(MIX_RATE * dur)
		for i in range(frames):
			var t: float = float(i) / MIX_RATE
			var v: float = -0.18
			if int(t * freq * 2) % 2 == 0:
				v = 0.18
			var envelope: float = 1.0 - float(i) / frames
			playback.push_frame(Vector2(v * envelope, v * envelope))
	player.play()
