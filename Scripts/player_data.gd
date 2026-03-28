extends Node

var score := 0
var time := 0
var best_time:= 0

@onready var timer := $Timer

var master_volume: float = 1.0
var music_volume: float = 1.0
var sfx_volume: float = 1.0

const SAVE_PATH = "user://fountain_save.cfg"

func _ready() -> void:
	load_game()

func load_game() -> void:
	var config = ConfigFile.new()
	var err = config.load(SAVE_PATH)
	
	if config.load(SAVE_PATH) == OK:
		master_volume = config.get_value("Audio", "master", 1.0)
		music_volume = config.get_value("Audio", "music", 1.0)
		sfx_volume = config.get_value("Audio", "sfx", 1.0)
		
	# Apply the loaded volumes to the audio buses
	apply_audio("Master", master_volume)
	apply_audio("Music", music_volume)
	apply_audio("SFX", sfx_volume)

func apply_audio(bus_name: String, vol: float) -> void:
	var bus_idx = AudioServer.get_bus_index(bus_name)
	if bus_idx != -1: # Ensure the bus actually exists before setting it
		AudioServer.set_bus_volume_db(bus_idx, linear_to_db(vol))

func save_game() -> void:
	var config = ConfigFile.new()
	config.set_value("Stats", "best_time", best_time)
	config.set_value("Audio", "master", master_volume)
	config.set_value("Audio", "music", music_volume)
	config.set_value("Audio", "sfx", sfx_volume)
	config.save(SAVE_PATH)

func _on_timer_timeout() -> void:
	time += 1

func get_formatted_time(a := "") -> String:
	if a=="best":
		var minutes: int = best_time / 60
		var seconds: int = best_time % 60
		return "%d:%02d" % [minutes, seconds]
	else:
		var minutes: int = time / 60
		var seconds: int = time % 60
		return "%d:%02d" % [minutes, seconds]

func reset_stats() -> void:
	score = 0
	time = 0
	timer.start()
