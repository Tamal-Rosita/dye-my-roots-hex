extends Node

func _ready():
	$DialogueSystem.next_phase()

func _on_TutorialDialog_on_ended():
	$OneInfiniteMechanic.start_turn()
	$HUD.set_can_exit(true)

func _on_HUD_exit_requested():
	$OneInfiniteMechanic.quit_to_title()

func _on_OneInfiniteMechanic_reaction(likeness):
	$DialogueSystem.show_reaction(likeness)

