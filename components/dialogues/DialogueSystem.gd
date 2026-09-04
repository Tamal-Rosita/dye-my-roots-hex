extends Control

signal on_ended

export var declaration: String = "/root/MissKellyDeclaration"

var dialog
var ended: bool = false
var index: int = 0
var finished: bool = false
var is_typing
# Hold-cancel skip: filling the ring for this long ends the sequence.
export var skip_hold_time: float = 1.0
var skip_hold: float = 0.0

onready var voicebox: ACVoiceBox = $ACVoicebox

func _ready():
	voicebox.connect("characters_sounded", self, "_on_voicebox_characters_sounded")
	voicebox.connect("finished_phrase", self, "_on_voicebox_finished_phrase")
	dialog = get_dialog()
	assert(dialog, "Dialog not found")
	$HoldSkip.set_label("HOLD\nTO SKIP")
	clear()
	
func _process(delta):
	if ended: return
	$Indicator.visible = finished
	if Input.is_action_just_pressed("ui_accept"):
		if finished:
			next_phase()
		else:
			voicebox.stop()
	# Hold CANCEL to skip the whole sequence (releasing resets the hold).
	if Input.is_action_pressed("ui_cancel"):
		skip_hold += delta
		$HoldSkip.visible = true
		$HoldSkip.set_progress(skip_hold / skip_hold_time)
		if skip_hold >= skip_hold_time:
			end()
	else:
		if skip_hold > 0.0:
			skip_hold = 0.0
			$HoldSkip.visible = false
			$HoldSkip.set_progress(0.0)
		
func end():
	if ended:
		return
	ended = true
	_stop_voice()
	$HoldSkip.visible = false
	emit_signal("on_ended")
	clear()

# Silences the voicebox completely: clears the remaining letters AND stops the
# currently playing one (a bare stop() used to leave the queue speaking).
func _stop_voice():
	voicebox.stop()
	var playback = voicebox.get_stream_playback()
	if playback and playback.has_method("stop"):
		playback.stop()
	voicebox.stream = null
	
func clear():
	$Phrase/Name.bbcode_text = ""
	$Phrase/Text.bbcode_text = ""
	$Phrase/Text.visible_characters = 0
	$Background/PortraitTexture.clear()
	
func next_phase() -> void:
	if index >= len(dialog):
		end()
		return
		
	finished = false
	var phrase = dialog[index]
	var name_bbcode: String = "[color=%s][b] %s [/b][/color]" % [phrase["NameColor"], phrase["Name"]]
	$Phrase/Name.bbcode_text = name_bbcode
	$Phrase/Text.bbcode_text = phrase["Text"].replace("{name}", _player_name())
	voicebox.base_pitch = phrase["Pitch"]

	# Call PortraitTexture function with character and emotion as parameters
	$Background/PortraitTexture.set_emotion(declaration, phrase["Emotion"])
	
	$Phrase/Text.visible_characters = 0
	voicebox.play_string($Phrase/Text.text)
	
func get_dialog() -> Array:
	var array = get_node(declaration).dialogues
	if typeof(array) == TYPE_ARRAY:
		return array
	else:
		return []

func _player_name() -> String:
	var name: String = SaveSystem.get_player_name()
	if name == "":
		return "sweetheart"
	return name

func _on_voicebox_characters_sounded(characters: String):
	var count: int = len(characters)
	$Phrase/Text.visible_characters += count

func _on_voicebox_finished_phrase():
	$Phrase/Text.visible_characters = len($Phrase/Text.text)
	finished = true
	index += 1
