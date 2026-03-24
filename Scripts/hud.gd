extends Control

@onready var score := $MarginContainer/HBoxContainer/Score
@onready var timer := $MarginContainer/HBoxContainer/Timer

func _process(_delta: float) -> void:
	timer.text = "Timer : "+PlayerData.get_formatted_time()
	score.text = "Score : "+ str(PlayerData.score)
