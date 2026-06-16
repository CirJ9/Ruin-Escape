extends Control

func _on_play_button_pressed() -> void:
	# Reset global values and turn on the clock
	GameManager.start_new_game()
	
	# Change to main gameplay scene
	get_tree().change_scene_to_file("res://main.tscn")
