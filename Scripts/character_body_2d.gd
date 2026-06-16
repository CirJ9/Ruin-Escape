extends CharacterBody2D

const WALK_SPEED = 100.0
const RUN_SPEED = 220.0
const ROLL_SPEED = 300.0
const PUSH_SPEED = 50.0 # Match the barrel's speed so we don't stutter against it

var current_state = "idle"
var facing_direction = "down" 
var is_touching_wall = false
var is_doing_action = false 

var last_iso_direction = Vector2(0, 1) 

# A buffer timer to prevent animation jitter when pushing
var push_grace_timer: float = 0.0

func _ready():
	$AnimatedSprite2D.animation_finished.connect(_on_animation_finished)
	update_collision_shape()
	
	# NEW: Teleport to the checkpoint if we have one saved globally!
	if GameManager.has_checkpoint:
		global_position = GameManager.last_checkpoint_pos

func _physics_process(delta: float) -> void:
	var prev_state = current_state
	var prev_dir = facing_direction
	
	# Tick down the push grace timer
	if push_grace_timer > 0:
		push_grace_timer -= delta
	
	if not is_doing_action:
		handle_actions()
		
	if not is_doing_action:
		handle_movement()
	else:
		move_and_slide()
		
	handle_collisions()
	
	update_animation()
	
	if prev_state != current_state or prev_dir != facing_direction:
		update_collision_shape()

func handle_movement():
	var input_dir = Input.get_vector("left", "right", "up", "down")
	var current_speed = WALK_SPEED
	
	if input_dir != Vector2.ZERO:
		# If the push timer is active, lock our speed to the pushing speed
		if push_grace_timer > 0.0:
			current_speed = PUSH_SPEED
		elif Input.is_action_pressed("sprint"):
			current_state = "run"
			current_speed = RUN_SPEED
		else:
			current_state = "walk"
			
		var iso_dir = cartesian_to_isometric(input_dir).normalized()
		velocity = iso_dir * current_speed
		
		last_iso_direction = iso_dir 
		update_facing_direction(iso_dir) 
	else:
		current_state = "idle"
		velocity = Vector2.ZERO

	move_and_slide()

func handle_actions():
	if Input.is_action_just_pressed("restart"):
		# 1. Reset the room the player is in
		if GameManager.current_room:
			GameManager.current_room.reset_room()
			
		if GameManager.has_checkpoint:
			call_deferred("_teleport_to_checkpoint")
		
	elif Input.is_action_just_pressed("roll"): 
		start_action("roll")
	elif Input.is_action_just_pressed("jump"): 
		if Input.is_action_pressed("sprint") and current_state == "run":
			start_action("running-jump") 
		else:
			start_action("jump")

func start_action(action_name: String):
	var anim_name = action_name + "-" + facing_direction
	
	if not $AnimatedSprite2D.sprite_frames.has_animation(anim_name):
		return 
		
	is_doing_action = true
	current_state = action_name
	
	if action_name == "roll":
		velocity = last_iso_direction * ROLL_SPEED
	elif action_name == "jump":
		velocity = Vector2.ZERO 
	elif action_name == "running-jump":
		pass 

func _on_animation_finished():
	if is_doing_action:
		is_doing_action = false
		current_state = "idle"

func update_facing_direction(dir: Vector2):
	var x = 0
	if dir.x > 0.1: x = 1
	elif dir.x < -0.1: x = -1
	
	var y = 0
	if dir.y > 0.1: y = 1
	elif dir.y < -0.1: y = -1
	
	if x == 1 and y == 0: facing_direction = "right"
	elif x == -1 and y == 0: facing_direction = "left"
	elif x == 0 and y == 1: facing_direction = "down"
	elif x == 0 and y == -1: facing_direction = "up"
	elif x == 1 and y == 1: facing_direction = "down-right"
	elif x == -1 and y == 1: facing_direction = "down-left"
	elif x == 1 and y == -1: facing_direction = "up-right"
	elif x == -1 and y == -1: facing_direction = "up-left"

func cartesian_to_isometric(cartesian: Vector2) -> Vector2:
	return Vector2(cartesian.x - cartesian.y, (cartesian.x + cartesian.y) / 2.0)

func handle_collisions():
	var pushed_something = false
	
	if get_slide_collision_count() > 0:
		for i in get_slide_collision_count(): 
			var collision = get_slide_collision(i)
			var collider = collision.get_collider()
			
			if collider.is_in_group("SolidObstacle"): 
				if not is_touching_wall:
					is_touching_wall = true
					
			elif collider.is_in_group("Pushable"):
				if collider.has_method("push"):
					collider.push(last_iso_direction)
					pushed_something = true
	else:
		is_touching_wall = false
		
	# If we hit a block, set the grace timer
	if pushed_something:
		push_grace_timer = 0.15 # 150ms of sticky pushing
		
	# Overwrite the state if the grace timer is active, rather than relying on exact frame contact
	if push_grace_timer > 0.0 and current_state in ["walk", "run"]:
		current_state = "push"

func update_animation():
	var anim_name = current_state + "-" + facing_direction
	
	# Check if the animation is actually changing so we don't accidentally restart it
	if $AnimatedSprite2D.animation != anim_name or not $AnimatedSprite2D.is_playing():
		if $AnimatedSprite2D.sprite_frames.has_animation(anim_name):
			$AnimatedSprite2D.play(anim_name)
		else:
			$AnimatedSprite2D.play("idle-" + facing_direction)

func update_collision_shape():
	var target_name = ""
	var shared_states = ["idle", "walk", "run", "jump", "running-jump"]
	
	# Override: If we are pushing, just use the walk collision shape
	var state_for_collision = current_state
	if state_for_collision == "push":
		state_for_collision = "walk"
	
	if state_for_collision in shared_states:
		target_name = "collision-" + state_for_collision
		if not has_node(target_name):
			target_name = "collision-idle"
	else:
		target_name = "collision-" + state_for_collision + "-" + facing_direction
		
	for child in get_children():
		if child.name.begins_with("collision-") and "disabled" in child:
			if child.name == target_name:
				child.set_deferred("disabled", false)
			else:
				child.set_deferred("disabled", true)

func _teleport_to_checkpoint():
	global_position = GameManager.last_checkpoint_pos
