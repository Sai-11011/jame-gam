extends Control

@onready var score := $MarginContainer/HBoxContainer/Score
@onready var timer := $MarginContainer/HBoxContainer/Timer
@onready var wish_menu := $"../Wish"
@export var pause : Control
var last_score: int = 0

func _ready() -> void:
	# Crucial: Set the pivot to the center so it scales outward uniformly, not from the top-left corner
	score.pivot_offset = score.size / 2

func _process(_delta: float) -> void:
	timer.text = "Timer : "+PlayerData.get_formatted_time()
	if PlayerData.score > last_score:
		last_score = PlayerData.score
		score.text = "Favor : "+ str(PlayerData.score)
		var tween = create_tween()
		# Scale up slightly using a bouncy transition
		tween.tween_property(score, "scale", Vector2(1.4, 1.4), 0.1).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		# Scale back down to normal
		tween.tween_property(score, "scale", Vector2.ONE, 0.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	else:
		score.text = "Favor : "+ str(PlayerData.score)

func _on_button_pressed() -> void:
	AudioManager.play_button_click()
	if pause != null :
		get_tree().paused = true
		pause.show()


func _on_wish_button_pressed() -> void:
	AudioManager.play_button_click()
	get_tree().paused = true
	wish_menu.show() # Show the shop!
