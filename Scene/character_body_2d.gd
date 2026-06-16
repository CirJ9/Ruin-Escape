extends CharacterBody2D

# A heavy, slow speed for pushing
const PUSH_SPEED = 50.0 
const FRICTION = 400.0 # How fast the barrel stops sliding when let go

var target_velocity = Vector2.ZERO

func push(push_direction: Vector2):
	# Register the push, but let _physics_process handle the actual movement
	target_velocity = push_direction * PUSH_SPEED

func _physics_process(delta):
	velocity = target_velocity
	move_and_slide()
	
	# Apply friction: smoothly decelerate to a stop if the player isn't pushing this frame
	target_velocity = target_velocity.move_toward(Vector2.ZERO, FRICTION * delta)
