extends Node2D

@onready var coin_scene: PackedScene = load(Global.SCENES.coin)
@onready var sparkle_scene: PackedScene = load(Global.SCENES.sparkle)
@onready var splash_scene: PackedScene = load(Global.SCENES.splash)
@onready var spawn_timer: Timer = $Timers/SpawnTimer
@onready var water_sprite: AnimatedSprite2D = $Fountain/Water
@onready var coin_container: Node = $CoinContainer
@onready var effects_container: Node = $EffectsContainer
@onready var game_over_scene: Control = $CanvasLayer/GameOver 
@onready var pause_menu: Control = $CanvasLayer/PauseMenu
@onready var percent_label : Label = $CanvasLayer/Hud/FillLabel
@onready var laser_line := $Fountain/Line
@onready var wish := $CanvasLayer/Wish

var danger_tween: Tween
var water_tween: Tween
var floor_y_position: float = 360.0
var total_water_displacement: float = 0.0 
# The starting state of the water (Empty)
var water_start_scale_y: float = 0.85
var water_start_pos_y: float = 510.0
var survived_danger: bool = false

# The maximum state of the water (Game Over)
var water_max_scale_y: float = 1.3
var water_max_pos_y: float = 455.0

# --- DIFFICULTY SETTINGS ---
var base_spawn_time: float = 1.0 # The starting speed (1 coin per second)
var min_spawn_time: float = 0.25 # The absolute fastest it can get (4 coins per second)
var speedup_factor: float = 0.015 # How much time to shave off the timer every second

# You might need to adjust this number through testing!
var max_displacement_allowed: float = 100.0

func _ready() -> void:
	Global.is_game_over = false
	get_tree().paused = false
	PlayerData.reset_stats()

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().paused = true
		pause_menu.show()

func _on_spawn_timer_timeout() -> void:
	spawn_coin()

func spawn_coin() -> void:
	if not coin_scene:
		return
	
	var new_coin = coin_scene.instantiate()
	var roll = randf()
	var random_key = "normal"
	
	# --- 1. COIN PROGRESSION LOGIC ---
	var current_time = PlayerData.time
	
	if current_time < 15:
		# PHASE 1 (0-15 seconds): 100% Bronze
		random_key = "normal"
		
	elif current_time < 35:
		# PHASE 2 (15-35 seconds): Introduce Silver (Bouncy)
		if roll < 0.85:
			random_key = "normal"
		else:
			random_key = "bouncy" # 15% chance for Silver
			
	else:
		# PHASE 3 (35+ seconds): Introduce Gold (Heavy)
		if roll < 0.70:
			random_key = "normal"
		elif roll < 0.90:
			random_key = "bouncy"
		else:
			random_key = "heavy" # 15% chance for Gold
			
	# --- 2. SPAWN THE COIN ---
	var selected_coin_data = Global.COIN_TYPES[random_key]
	new_coin.setup(selected_coin_data)
	
	var toss_side = randi() % 2
	if toss_side == 0:
		# Spawn at Y = -100 (Off the top of the screen)
		new_coin.position = Vector2(0, -10)
		# Throw them HARD right, with a slight upward arc for hang time
		new_coin.linear_velocity = Vector2(randf_range(450.0, 750.0), randf_range(-150.0, 50.0))
	else:
		# Spawn at Y = -100 (Off the top of the screen)
		new_coin.position = Vector2(1280, -10)
		# Throw them HARD left, with a slight upward arc for hang time
		new_coin.linear_velocity = Vector2(randf_range(-450.0, -750.0), randf_range(-150.0, 50.0))

	new_coin.clicked.connect(_on_coin_clicked)
	coin_container.add_child(new_coin)
	
	# --- 3. DIFFICULTY SCALING LOGIC ---
	var new_wait_time = base_spawn_time
	
	# Only start speeding up the drops AFTER 35 seconds
	if current_time > 35:
		# Calculate how many seconds have passed SINCE the 35-second mark
		var active_speedup_time = current_time - 35
		new_wait_time = base_spawn_time - (active_speedup_time * speedup_factor)
	
	# Use max() to ensure the timer never goes below your minimum limit!
	spawn_timer.wait_time = max(new_wait_time, min_spawn_time)

func _on_coin_clicked(clicked_coin: RigidBody2D) -> void:
	# 1. Play the click sound!
	AudioManager.play_coin_click()
	
	# 2. Spawn the Sparkles!
	if sparkle_scene:
		var new_sparkle = sparkle_scene.instantiate()
		new_sparkle.global_position = clicked_coin.global_position
		effects_container.add_child(new_sparkle)
		
	# 3. Add the specific coin's score! (Bronze +1, Silver +3, Gold +5)
	PlayerData.score += clicked_coin.score
	# Achievement Checks
	if PlayerData.score > 0:
		PlayerData.unlock_achievement("first_catch", "First Catch")
	if PlayerData.score >= 25:
		PlayerData.unlock_achievement("getting_hang", "Getting the Hang")
	if PlayerData.score >= 100:
		PlayerData.unlock_achievement("in_zone", "In the Zone")
	# 4. Wake up the pile so gravity takes over
	get_tree().call_group("Coins", "wake_up")
	
	# --- 5. WISH SYSTEM LOGIC ---
	if Global.active_wish == "bomb":
		Global.active_wish = "" # Reset the wish so it only happens once!
		
		# Find all coins and pop the ones close to the click
		var all_coins = get_tree().get_nodes_in_group("Coins")
		for coin in all_coins:
			# If the coin is within 180 pixels of the clicked coin, blow it up!
			if coin.global_position.distance_to(clicked_coin.global_position) < 180.0:
				if is_instance_valid(coin) and coin != clicked_coin:
					coin.pop() # This triggers a glorious chain of sparkles and scores!
					
	elif Global.active_wish == "chain":
		Global.active_wish = "" # Reset the wish
		
		var all_coins = get_tree().get_nodes_in_group("Coins")
		all_coins.shuffle() # Mix up the array to get random targets
		
		# Pop up to 4 random coins currently on screen
		var pops_left = 4
		for coin in all_coins:
			if pops_left > 0 and is_instance_valid(coin) and coin != clicked_coin:
				coin.pop()
				pops_left -= 1

func update_water_level() -> void:
	var fill_percent = clamp(total_water_displacement / max_displacement_allowed, 0.0, 1.0)
	
	# --- 1. UPDATE PERCENTAGE LABEL ---
	if percent_label:
		# Multiplies 0.50 by 100 to display "50%"
		percent_label.text = "Water Level: %d%%" % (fill_percent * 100)
		
	# --- 2. DANGER PULSE INDICATOR ---
	if fill_percent >= 0.85: 
		# If it's 85% full and not already animating, start the pulse
		survived_danger = true
		if not danger_tween or not danger_tween.is_valid():
			laser_line.modulate = Color(1, 0, 0, 1) # Tint the laser line red
			danger_tween = create_tween().set_loops().set_trans(Tween.TRANS_SINE) # Loops infinitely
			# Pulse from White to Red
			danger_tween.tween_property(laser_line, "modulate", Color(1, 0, 0, 1), 0.2)
			# Pulse from Red back to White
			danger_tween.tween_property(laser_line, "modulate", Color(1, 1, 1, 1), 0.2)
	else:
		# If water drops below 85%, kill the animation and reset the line
		if danger_tween and danger_tween.is_valid():
			danger_tween.kill()
		laser_line.scale.y = 1.0
		laser_line.modulate = Color(1, 1, 1, 1) # Reset to normal color
		
		if fill_percent < 0.60 and survived_danger:
			survived_danger = false
			PlayerData.unlock_achievement("close_call", "Close Call!")

	# --- 3. EXISTING WATER MATH ---
	var target_scale_y = lerp(water_start_scale_y, water_max_scale_y, fill_percent)
	var target_pos_y = lerp(water_start_pos_y, water_max_pos_y, fill_percent)
	
	if water_tween and water_tween.is_valid():
		water_tween.kill()
		
	water_tween = create_tween()
	water_tween.set_trans(Tween.TRANS_SINE)
	water_tween.set_ease(Tween.EASE_OUT)
	water_tween.set_parallel(true)
	
	water_tween.tween_property(water_sprite, "scale:y", target_scale_y, 0.3)
	water_tween.tween_property(water_sprite, "position:y", target_pos_y, 0.3)
	
	if fill_percent >= 1.0:
		print("GAME OVER! The fountain overflowed!")
		if PlayerData.time > PlayerData.best_time:
			PlayerData.best_time = PlayerData.time
			PlayerData.save_game() 
			print("New High Score Saved!")
		Global.is_game_over = true
		get_tree().call_group("Camera", "add_trauma", 0.8)
		get_tree().paused = true
		game_over_scene.set_final_stats() 
		spawn_timer.stop()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Coins") and not Global.is_game_over:
		AudioManager.play_coin_drop()
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
	if body.is_in_group("Coins") and not Global.is_game_over:
		
		total_water_displacement -= body.water_increase
		update_water_level()

# --- WISH SYSTEM LOGIC ---

# The Pause Menu calls this when "Breathing Room" is purchased
func freeze_time() -> void:
	spawn_timer.stop() # Stop the coins falling!
	
	# Wait exactly 5 seconds using a quick built-in timer
	await get_tree().create_timer(6.0,false).timeout 
	
	# Resume the chaos!
	if not Global.is_game_over:
		spawn_timer.start()
