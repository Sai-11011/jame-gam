extends Node2D

@onready var coin_scene: PackedScene = load(Global.SCENES.coin)
@onready var sparkle_scene: PackedScene = load(Global.SCENES.sparkle)
@onready var splash_scene: PackedScene = load(Global.SCENES.splash)
@onready var spawn_timer: Timer = $Timers/SpawnTimer
@onready var water_rect: ColorRect = $FountainPlaceholders/CanvasGroup/WaterIncrease

var water_tween: Tween
var score: int = 0 
var floor_y_position: float = 360.0
var total_water_displacement: float = 0.0 

func _ready() -> void:
	Global.is_game_over = false

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
	add_child(new_coin)

func _on_coin_clicked(clicked_coin: RigidBody2D) -> void:
	# 1. Spawn the Sparkle Juice!
	if sparkle_scene:
		var new_sparkle = sparkle_scene.instantiate()
		new_sparkle.global_position = clicked_coin.global_position
		add_child(new_sparkle)
		
	# 2. Existing score and water math...
	score += 1
	total_water_displacement -= clicked_coin.water_increase
	update_water_level()
	print("Coin collected! Score: ", score)
	
	get_tree().call_group("Coins", "wake_up")

func update_water_level() -> void:
	var target_height = total_water_displacement # how much the water height should be 
	var target_y_pos = floor_y_position - target_height # from the current height 
	
	# 2. Stop the old animation if a new coin hits the water before it finishes
	if water_tween and water_tween.is_valid():
		water_tween.kill()
		
	# 3. Create a fresh Tween
	water_tween = create_tween()
	
	# 4. Make the animation smooth like liquid (Sine curve eases in and out)
	water_tween.set_trans(Tween.TRANS_SINE)
	water_tween.set_ease(Tween.EASE_OUT)
	
	# 5. Tell the Tween to animate BOTH size and position at the same time
	water_tween.set_parallel(true)
	
	# 6. Run the animations! (The "0.3" is how many seconds it takes to rise)
	water_tween.tween_property(water_rect, "size:y", target_height, 0.3)
	water_tween.tween_property(water_rect, "position:y", target_y_pos, 0.3)
	
	# 7. Check for Game Over using the TARGET position, not the animated position
	if target_y_pos <= 250.0:
		print("GAME OVER! The fountain overflowed!")
		Global.is_game_over = true
		spawn_timer.stop()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Coins") and not Global.is_game_over:
		# 1. Spawn the Splash Juice!
		if splash_scene:
			var new_splash = splash_scene.instantiate()
			# Spawn it at the coin's X, but lock the Y to the top of the water
			new_splash.global_position = Vector2(body.global_position.x, water_rect.position.y)
			add_child(new_splash)
			
		# 2. Existing water math...
		total_water_displacement += body.water_increase
		update_water_level()

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("Coins"):
		total_water_displacement -= body.water_increase
		update_water_level()
