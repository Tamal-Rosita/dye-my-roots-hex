extends Node

export(Array, AudioStream) var streams
# Audio bus every created player plays on (e.g. "SFX").
export(String) var bus_name: String = "Master"
var players = []

func _ready():
	for stm in streams:
		var player = AudioStreamPlayer.new()
		player.bus = bus_name
		players.append(player)
		add_child(player)

func play_all ():
	for i in range(len(streams)):
		var player = players[i]
		var stream = streams[i]
		player.stream = stream
		player.play()
