extends Control

func _ready():
	$Gains.text = "$0"
	
func set_money(amount):
	$Gains.text ="$%s" % amount

func _on_OneInfiniteMechanic_completed(gains):
	set_money(gains)
