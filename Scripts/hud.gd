extends CanvasLayer

@onready var time_label: Label = $TimerLabel

func _process(_delta: float) -> void:
	# Continuously update the clock with the GameManager's tracked time
	if GameManager.timer_running:
		time_label.text = GameManager.get_formatted_time()
