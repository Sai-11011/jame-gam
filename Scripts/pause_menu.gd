extends Control

@onready var start := load(Global.SCENES.start)
@onready var wish_menu := $"../Wish" # Reaches out to the CanvasLayer and grabs the Wish scene

func _on_resume_button_pressed() -> void:
	AudioManager.play_button_click()
	get_tree().paused = false
	hide()

func _on_wish_button_pressed() -> void:
	AudioManager.play_button_click()
	hide() # Hide the pause menu
	wish_menu.show() # Show the shop!

func _on_restart_button_pressed() -> void:
	AudioManager.play_button_click()
	get_tree().reload_current_scene()

func _on_start_menu_button_pressed() -> void:
	AudioManager.play_button_click()
	get_tree().change_scene_to_packed(start)
