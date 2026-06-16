extends Node2D

# We will drag the saved .tscn file into this slot in the Inspector!
@export var room_scene: PackedScene 

func _ready():
	# Connect the boundary so we know when the player enters
	if has_node("RoomBoundary"):
		$RoomBoundary.body_entered.connect(_on_boundary_entered)

func _on_boundary_entered(body):
	if body.is_in_group("Player"):
		# Tell the global manager that this is the active room
		GameManager.current_room = self

func reset_room():
	if room_scene:
		# Create a brand new copy of the room from your files
		var fresh_room = room_scene.instantiate()
		
		# Add it to the main map exactly where this one is
		call_deferred("add_sibling", fresh_room)
		fresh_room.global_position = global_position
		
		# Delete this broken/stuck room
		queue_free()
