extends Node2D

# Dictionary to store the original positions of objects
var initial_positions = {}

func _ready():
	# Loop through all children of this room when the game starts
	for child in get_children():
		# If the child is a barrel (make sure they are in the "Pushable" group!)
		if child.is_in_group("Pushable"):
			initial_positions[child] = child.global_position

func reset_room():
	# Move every saved object back to its starting position
	for object in initial_positions:
		if is_instance_valid(object):
			object.global_position = initial_positions[object]
			
			# Optional: If your barrels have velocity/movement variables, 
			# you might want to call a reset function on them here.
			# Example: if object.has_method("stop_moving"): object.stop_moving()
