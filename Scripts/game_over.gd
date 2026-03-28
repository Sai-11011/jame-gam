extends Control

@onready var start := load(Global.SCENES.start)
@onready var timer_label := $MarginContainer/VBoxContainer/HBoxContainer/Time
@onready var score_label := $MarginContainer/VBoxContainer/HBoxContainer/Score
@onready var best_time_lable := $MarginContainer/Label

func set_final_stats()-> void:
	PlayerData.timer.stop()
	timer_label.text = "Time : " + PlayerData.get_formatted_time()
	score_label.text = "Favor : " + str(PlayerData.score)
	best_time_lable.text = "Best Time : "+PlayerData.get_formatted_time("best")
	PlayerData.save_game()
	show()

func _on_restart_button_pressed() -> void:
	AudioManager.play_button_click()
	get_tree().reload_current_scene()

func _on_menu_button_pressed() -> void:
	AudioManager.play_button_click()
	get_tree().change_scene_to_packed(start)
