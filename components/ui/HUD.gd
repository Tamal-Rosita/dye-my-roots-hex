extends Control

func _ready():
	$Gains.text = "$0"
	$Time.text = "TIME --"
	
func set_money(amount):
	$Gains.text = "$%s" % amount

func set_time(remaining):
	$Time.text = "TIME %d" % int(ceil(remaining))

func _on_OneInfiniteMechanic_completed(gains):
	set_money(gains)

func _on_OneInfiniteMechanic_turn_time_changed(remaining):
	set_time(remaining)
