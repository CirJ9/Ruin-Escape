extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		GameManager.timer_running = false
		
		get_tree().change_scene_to_file("res://Scene/VictoryScreen.tscn")
