extends Node2D

@onready var coin_scene: PackedScene = load(Global.SCENES.coin)
@onready var sparkle_scene: PackedScene = load(Global.SCENES.sparkle)
@onready var splash_scene: PackedScene = load(Global.SCENES.splash)
@onready var spawn_timer: Timer = $Timers/SpawnTimer
@onready var water_sprite: Sprite2D = $Fountain/Water
@onready var coin_container: Node = $CoinContainer
@onready var effects_container: Node = $EffectsContainer
@onready var game_over_scene: Control = $CanvasLayer/GameOver 

var water_tween: Tween
var floor_y_position: float = 360.0
var total_water_displacement: float = 0.0 
# The starting state of the water (Empty)
var water_start_scale_y: float = 0.85
var water_start_pos_y: float = 480.0

# The maximum state of the water (Game Over)
var water_max_scale_y: float = 1.3
var water_max_pos_y: float = 435.0

# How much displacement it takes to reach Game Over
# You might need to adjust this number through testing!
var max_displacement_allowed: float = 50.0

func _ready() -> void:
	Global.is_game_over = false
	get_tree().paused = false
	PlayerData.reset_stats()

func _on_spawn_timer_timeout() -> void:
	spawn_coin()

func spawn_coin() -> void:
	if not coin_scene:
		return
	
	var new_coin = coin_scene.instantiate()
	var roll = randf()
	var random_key = "normal"
	
	if roll < 0.80: 
		random_key = "normal"
	elif roll < 0.95: 
		random_key = "heavy"
	else: 
		random_key = "bouncy"
		
	var selected_coin_data = Global.COIN_TYPES[random_key]
	
	new_coin.setup(selected_coin_data)
	
	var toss_side = randi() % 2
	if toss_side == 0:
		new_coin.position = Vector2(100, 100)
		new_coin.linear_velocity = Vector2(randf_range(200.0, 450.0), randf_range(-200.0, -400.0))
	else:
		new_coin.position = Vector2(1180, 100)
		new_coin.linear_velocity = Vector2(randf_range(-200.0, -450.0), randf_range(-200.0, -400.0))

	new_coin.clicked.connect(_on_coin_clicked)
	coin_container.add_child(new_coin)

func _on_coin_clicked(clicked_coin: RigidBody2D) -> void:
	if sparkle_scene:
		var new_sparkle = sparkle_scene.instantiate()
		new_sparkle.global_position = clicked_coin.global_position
		effects_container.add_child(new_sparkle)
		
	PlayerData.score += 1
	print("Coin collected! Score: ", PlayerData.score)
	
	get_tree().call_group("Coins", "wake_up")

func update_water_level() -> void:
	# 1. Calculate how full the fountain is (from 0.0 to 1.0)
	# clamp ensures the percentage never goes below 0% or above 100%
	var fill_percent = clamp(total_water_displacement / max_displacement_allowed, 0.0, 1.0)
	print(fill_percent)
	# 2. Use lerp to find the exact target scale and position based on that percentage
	var target_scale_y = lerp(water_start_scale_y, water_max_scale_y, fill_percent)
	var target_pos_y = lerp(water_start_pos_y, water_max_pos_y, fill_percent)
	
	# 3. Stop the old animation
	if water_tween and water_tween.is_valid():
		water_tween.kill()
		
	# 4. Create a fresh Tween
	water_tween = create_tween()
	water_tween.set_trans(Tween.TRANS_SINE)
	water_tween.set_ease(Tween.EASE_OUT)
	water_tween.set_parallel(true)
	
	# 5. Tween the Sprite2D's scale and position
	water_tween.tween_property(water_sprite, "scale:y", target_scale_y, 0.3)
	water_tween.tween_property(water_sprite, "position:y", target_pos_y, 0.3)
	
	# 6. Check for Game Over! (If the percentage hits 100%)
	if fill_percent >= 1.0:
		print("GAME OVER! The fountain overflowed!")
		Global.is_game_over = true
		get_tree().paused = true
		game_over_scene.set_final_stats() 
		spawn_timer.stop()
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Coins") and not Global.is_game_over:
		# 1. Spawn the Splash Juice!
		if splash_scene:
			var new_splash = splash_scene.instantiate()
			# Simply spawn the splash exactly where the coin is when it hits the water!
			new_splash.global_position = body.global_position
			effects_container.add_child(new_splash)
			
		# 2. Existing water math...
		total_water_displacement += body.water_increase
		update_water_level()

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("Coins"):
		total_water_displacement -= body.water_increase
		update_water_level()
