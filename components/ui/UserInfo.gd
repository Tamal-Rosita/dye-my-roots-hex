extends Control

signal entered(name)

func _on_LineEdit_text_entered(new_text):
	# Save user name
	var name = new_text
	emit_signal("entered", name)
