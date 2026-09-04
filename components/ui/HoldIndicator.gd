extends Control

# Circular hold-to-confirm indicator: a ring that fills clockwise while a
# button is held. Used for "hold to exit" (gameplay) and "hold to skip"
# (intro dialogue). Call set_progress(0..1) each frame while holding.

export(Color) var track_color: Color = Color(1, 1, 1, 0.14)
export(Color) var fill_color: Color = Color(0.886, 0.702, 0.835)
export(float) var ring_width: float = 9.0

var progress: float = 0.0

func set_progress(value: float):
	progress = clamp(value, 0.0, 1.0)
	update()

func set_label(text: String):
	$Label.text = text

func _draw():
	if rect_size.x <= 1.0 or rect_size.y <= 1.0:
		return
	var center: Vector2 = rect_size * 0.5
	var radius: float = min(rect_size.x, rect_size.y) * 0.5 - ring_width * 0.5 - 2.0
	if radius <= 1.0:
		return
	draw_arc(center, radius, 0.0, TAU, 48, track_color, ring_width, true)
	if progress > 0.005:
		var end_angle: float = -PI / 2.0 + TAU * progress
		draw_arc(center, radius, -PI / 2.0, end_angle, 48, fill_color, ring_width, true)
