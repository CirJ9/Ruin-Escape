extends Area2D

@export var target_door: StaticBody2D

signal plate_pressed
signal plate_released

var objects_on_plate = 0
var is_active = false

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	if target_door:
		# CHANGED: Connect to the door's new counting functions instead of open/close
		plate_pressed.connect(target_door._on_plate_pressed)
		plate_released.connect(target_door._on_plate_released)

func _on_body_entered(body):
	if body.is_in_group("Player") or body.is_in_group("Pushable"):
		objects_on_plate += 1
		check_state()

func _on_body_exited(body):
	if body.is_in_group("Player") or body.is_in_group("Pushable"):
		objects_on_plate -= 1
		if objects_on_plate < 0:
			objects_on_plate = 0
		check_state()

func check_state():
	if objects_on_plate > 0 and not is_active:
		is_active = true
		$AnimatedSprite2D.frame = 1 
		plate_pressed.emit() 
		
	elif objects_on_plate <= 0 and is_active:
		is_active = false
		$AnimatedSprite2D.frame = 0 
		plate_released.emit()
