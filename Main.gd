extends Node

func _ready():
	$DialogueSystem.next_phase()

func _on_TutorialDialog_on_ended():
	$OneInfiniteMechanic.start_turn()
