extends Area2D

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.is_in_group("Player"):
		GameManager.last_checkpoint_pos = body.global_position
		GameManager.has_checkpoint = true
		
		# NEW: Tell the GameManager that the parent of this checkpoint (e.g., Room5) is the current room
		var room_node = get_parent()
		if room_node is Node2D and room_node.has_method("reset_room"):
			GameManager.current_room = room_node
		
		if has_node("AnimatedSprite2D"):
			$AnimatedSprite2D.play("checkpoint")
