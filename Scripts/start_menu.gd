extends Control

@onready var main_scene := load(Global.SCENES.main) 

func _on_button_pressed() -> void:
	AudioManager.play_button_click()
	get_tree().change_scene_to_packed(main_scene)


func _on_button_3_pressed() -> void:
	AudioManager.play_button_click()
	
