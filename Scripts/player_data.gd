extends Node

var score := 0
var time := 0
@onready var timer := $Timer

func _on_timer_timeout() -> void:
	time += 1

func get_formatted_time() -> String:
	var minutes: int = time / 60
	var seconds: int = time % 60
	return "%d:%02d" % [minutes, seconds]

func reset_stats() -> void:
	score = 0
	time = 0
	timer.start()
