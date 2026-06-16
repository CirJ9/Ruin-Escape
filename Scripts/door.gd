extends StaticBody2D

# Expose a dropdown in the editor to easily change door types
@export_enum("door-1", "door-2", "door-3", "door-4") var door_direction: String = "door-1"

# Set this in the Inspector! (e.g., 2 plates, 3 plates...)
@export var required_plates: int = 1 

@onready var animated_sprite = $AnimatedSprite2D
@onready var col_1 = $CollisionDoor1
@onready var col_2 = $CollisionDoor2
@onready var col_3 = $CollisionDoor3
@onready var col_4 = $CollisionDoor4

var active_collision
var active_plates_count: int = 0 

func _ready():
	animated_sprite.animation = door_direction
	animated_sprite.frame = 0 
	
	# Turn off all physical walls initially
	col_1.disabled = true
	col_2.disabled = true
	col_3.disabled = true
	col_4.disabled = true
	
	# Determine which wall to use based on the Inspector dropdown
	if door_direction == "door-1": active_collision = col_1
	elif door_direction == "door-2": active_collision = col_2
	elif door_direction == "door-3": active_collision = col_3
	elif door_direction == "door-4": active_collision = col_4
		
	# Turn on only the correct wall
	if active_collision:
		active_collision.disabled = false

# The plate will call this when pressed
func _on_plate_pressed():
	active_plates_count += 1
	check_door_state()

# The plate will call this when released
func _on_plate_released():
	active_plates_count -= 1
	check_door_state()

func check_door_state():
	# If we have enough plates pressed, open!
	if active_plates_count >= required_plates:
		open()
	# Otherwise, if we drop below the requirement, close it
	else:
		close()

func open():
	if active_collision:
		active_collision.set_deferred("disabled", true)
	animated_sprite.frame = 1

func close():
	if active_collision:
		active_collision.set_deferred("disabled", false)
	animated_sprite.frame = 0
