extends Control

@onready var start := load(Global.SCENES.start)
@onready var timer_label := $MarginContainer/VBoxContainer/HBoxContainer/Time
@onready var score_label := $MarginContainer/VBoxContainer/HBoxContainer/Score

func set_final_stats()-> void:
	PlayerData.timer.stop()
	timer_label.text = "Time : " + PlayerData.get_formatted_time()
	score_label.text = "Score : " + str(PlayerData.score)
	show()

func _on_restart_button_pressed() -> void:
	get_tree().reload_current_scene()

func _on_menu_button_pressed() -> void:
	get_tree().change_scene_to_packed(start)
