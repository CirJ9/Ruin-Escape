extends Control

@onready var final_time_label: Label = $VBoxContainer/FinalTimeLabel

func _ready() -> void:
	final_time_label.text = "Final Time: " + GameManager.get_formatted_time()

func _on_replay_button_pressed() -> void:
	GameManager.start_new_game()
	get_tree().change_scene_to_file("res://main.tscn")
