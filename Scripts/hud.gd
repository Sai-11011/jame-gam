extends Control

@onready var score := $MarginContainer/HBoxContainer/Score
@onready var timer := $MarginContainer/HBoxContainer/Timer
@export var pause : Control

func _process(_delta: float) -> void:
	timer.text = "Timer : "+PlayerData.get_formatted_time()
	score.text = "Favor : "+ str(PlayerData.score)


func _on_button_pressed() -> void:
	if pause != null :
		get_tree().paused = true
		pause.show()
