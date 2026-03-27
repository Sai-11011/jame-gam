extends Control

@onready var main_scene := load(Global.SCENES.main) 
@onready var settings := load(Global.SCENES.settings)
@onready var credits := $Credits

func _on_button_pressed() -> void:
	AudioManager.play_button_click()
	get_tree().change_scene_to_packed(main_scene)

func _on_settings_button_pressed() -> void:
	AudioManager.play_button_click()
	get_tree().change_scene_to_packed(settings)



func _on_credits_button_pressed() -> void:
	credits.show()
