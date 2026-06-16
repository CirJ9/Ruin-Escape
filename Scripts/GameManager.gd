extends Node

# --- Checkpoint & Room System ---
var last_checkpoint_pos: Vector2 = Vector2.ZERO
var has_checkpoint: bool = false
var current_room: Node2D = null

# --- Timer System ---
var game_time: float = 0.0
var timer_running: bool = false

func _process(delta: float) -> void:
	# Only accumulate time if the game is active
	if timer_running:
		game_time += delta

# Formats raw seconds into a readable MM:SS:MS string
func get_formatted_time() -> String:
	var minutes: int = int(game_time) / 60
	var seconds: int = int(game_time) % 60
	# Grab the fractional part and convert to 2-digit milliseconds
	var milliseconds: int = int((game_time - int(game_time)) * 100)
	
	return "%02d:%02d:%02d" % [minutes, seconds, milliseconds]

# Call this whenever a fresh run starts
func start_new_game():
	last_checkpoint_pos = Vector2.ZERO
	has_checkpoint = false
	current_room = null
	game_time = 0.0
	timer_running = true
