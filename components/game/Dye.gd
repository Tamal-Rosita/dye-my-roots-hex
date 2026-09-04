extends Sprite

signal completed(likeness)
signal timeout

export var wait_time: float = 25
export(Color) var roots_color = Color.whitesmoke
export(Texture) var curly
export(Texture) var dread
export(Texture) var straight

var target
var target_html
var timer: Timer = Timer.new()
var max_distance
var max_value
var submitted: bool = false
# Last 3 seconds of the color timer show a 3-2-1 countdown with a beep.
export var countdown_seconds: int = 3
var last_countdown: int = -1

func _ready():
	max_distance = color_distance_rgb(Color.white, Color.black)
	max_value = $ProgressBar.max_value
	timer.connect("timeout", self, "on_timeout")
	timer.wait_time = wait_time
	timer.one_shot = true
	add_child(timer)
	visible = false
	
func _process(_delta):
	update_clock(wait_time - timer.time_left)
	_update_countdown()
	
func reset():
	randomize()
	submitted = false
	last_countdown = -1
	set_hair_style()
	set_hair_color()
	update_clock(0)
	timer.start()
	visible = true
	$Result.visible = false
		
func stop():
	timer.stop()
	
func submit(color):
	if submitted:
		return
	submitted = true
	timer.stop()
	self_modulate = color
	var distance = color_distance_rgb(target, color)
	# Map the distance onto its true range [0, max_distance] -> [100, 0] so a
	# guess is never crushed to 0% likeness just for being farther than 1.0.
	var likeness = stepify(clamp(range_lerp(distance, 0.0, max_distance, 100.0, 0.0), 0.0, 100.0), 0.1)
	print("Color likeness: %s" % likeness)
	$Result.visible = true
	$Result.bbcode_text = "%s%%" % likeness
	emit_signal("completed", likeness)
	
func set_hair_color():
	var r = rand_range(0.21, 0.92)
	var g = rand_range(0.21, 0.92)
	var b = rand_range(0.21, 0.92)
	target = Color(r, g, b)
	target_html = target.to_html(false)
	self_modulate = roots_color
	$Cloud/Target.self_modulate = target
	
func set_hair_style():
	var style
	match randi() % 3:
		0:	
			style = curly
		1:
			style = dread
		2:
			style = straight
	texture = style
	$Cloud/Target.texture = style

func update_clock(elapsed):
	var progress = elapsed / wait_time * max_value
	$ProgressBar.value = max_value - progress

# Shows "3", "2", "1" during the last seconds of the color timer, beeping once
# per second so the player knows time is almost up.
func _update_countdown():
	if not visible or submitted:
		$Countdown.visible = false
		last_countdown = -1
		return
	var remaining: float = timer.time_left
	if remaining <= 0.0 or remaining > countdown_seconds:
		$Countdown.visible = false
		last_countdown = -1
		return
	var digit: int = int(ceil(remaining))
	$Countdown.visible = true
	$Countdown.text = str(digit)
	if digit != last_countdown:
		last_countdown = digit
		Sfx.play("countdown")

func color_distance_rgb(color_a, color_b):
	var r = color_a.r - color_b.r
	var g = color_a.g - color_b.g
	var b = color_a.b - color_b.b
	return sqrt(r*r + g*g + b*b)

# Color timer expired: request an auto-submit instead of failing the round.
func on_timeout():
	Sfx.play("timeout")
	emit_signal("timeout")
