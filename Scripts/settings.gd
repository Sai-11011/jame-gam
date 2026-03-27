extends Control

@onready var master_slider := $VBoxContainer/VBoxContainer/MasterVolume/HSlider
@onready var music_slider := $VBoxContainer/VBoxContainer/MusicVolume/HSlider
@onready var sfx_slider := $VBoxContainer/VBoxContainer/SFXVolume/HSlider

@onready var start_scene := load(Global.SCENES.start)


func _ready() -> void:
	# 1. Set the sliders to whatever volume was saved
	master_slider.value = PlayerData.master_volume
	music_slider.value = PlayerData.music_volume
	sfx_slider.value = PlayerData.sfx_volume
	
	# 2. Connect the slider signals to trigger the functions below
	master_slider.value_changed.connect(_on_master_changed)
	music_slider.value_changed.connect(_on_music_changed)
	sfx_slider.value_changed.connect(_on_sfx_changed)

# --- SLIDER FUNCTIONS ---
func _on_master_changed(value: float) -> void:
	PlayerData.master_volume = value
	PlayerData.apply_audio("Master", value)
	PlayerData.save_game()

func _on_music_changed(value: float) -> void:
	PlayerData.music_volume = value
	PlayerData.apply_audio("Music", value)
	PlayerData.save_game()

func _on_sfx_changed(value: float) -> void:
	PlayerData.sfx_volume = value
	PlayerData.apply_audio("SFX", value)
	PlayerData.save_game()

# --- NAVIGATION ---
func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_packed(start_scene)
