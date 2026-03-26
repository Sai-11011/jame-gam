extends Node

@onready var click_container = $CoinClick
@onready var drop_container = $CoinDrop
@onready var click = $CoinClick/Click1

# This runs automatically when the game starts to randomize the seed
func _ready() -> void:
	randomize()

func play_coin_click() -> void:
	# Get all the AudioStreamPlayers inside the CoinClick node
	var click_sounds = click_container.get_children()
	
	if click_sounds.size() > 0:
		# Godot 4's pick_random() is perfect here
		var random_sound = click_sounds.pick_random()
		
		# BONUS JUICE: Slightly alter the pitch every single time
		# This makes your 7 sounds feel like 70 sounds!
		random_sound.pitch_scale = randf_range(0.85, 1.15)
		
		random_sound.play()

func play_button_click() -> void:
	click.play()

func play_coin_drop() -> void:
	# Get all the AudioStreamPlayers inside the CoinDrop node
	var drop_sounds = drop_container.get_children()
	
	if drop_sounds.size() > 0:
		var random_sound = drop_sounds.pick_random()
		
		# Drops usually sound better with slightly less pitch variance than clicks
		random_sound.pitch_scale = randf_range(0.9, 1.1) 
		
		random_sound.play()
