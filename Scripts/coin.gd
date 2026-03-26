extends RigidBody2D

@onready var sprite = $AnimatedSprite2D
@onready var spin_collision = $CollisionSpin
@onready var flat_collision = $CollisionFlat

signal clicked(coin_node) 

var has_slammed: bool = false # Locks the shake so it only happens ONCE
var previous_velocity: Vector2 = Vector2.ZERO # Remembers how fast it was falling
var water_increase: float = 0.0
var coin_material: String = "" 
var is_settled: bool = false 
var score : int 
var my_coin_data: Dictionary

func setup(coin_data: Dictionary) -> void:
	my_coin_data = coin_data
	
	mass = coin_data["weight"]
	score = coin_data["score"]
	var phys_mat = PhysicsMaterial.new()
	phys_mat.bounce = coin_data["bounce"]
	phys_mat.friction = coin_data["friction"]
	physics_material_override = phys_mat
	
	water_increase = coin_data["water_increase"]
	coin_material = coin_data["type"] 
	

func _ready() -> void:
	if randf() > 0.5:
		spin_collision.set_deferred("disabled", false)
		flat_collision.set_deferred("disabled", true)
	else:
		spin_collision.set_deferred("disabled", true)
		flat_collision.set_deferred("disabled", false)
		
	# Start the spinning animation
	sprite.play("spin_" + coin_material) 

func _physics_process(_delta: float) -> void:
	if coin_material == "gold" and not has_slammed:
		# If it was falling fast downwards, but suddenly lost its speed (hit a surface!)
		if previous_velocity.y > 100.0 and linear_velocity.y < 20.0:
			get_tree().call_group("Camera", "add_trauma", 0.4)
			has_slammed = true # Lock it forever so it never shakes on pop!
			
	# Always save current speed for the next frame's math
	previous_velocity = linear_velocity

	# --- EXISTING ANIMATION LOGIC ---
	if is_settled:
		return
		
	if linear_velocity.length() < 10.0:
		is_settled = true
		sprite.stop()
		
		# Check which collision shape is active to know how it landed
		if not spin_collision.disabled:
			sprite.play("idle_round_" + coin_material)
		else:
			sprite.play("idle_flat_" + coin_material)

func wake_up() -> void:
	sleeping = false
	is_settled = false 

func _on_click_area_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	# 1. Check if it's a left mouse click (for PC)
	var is_mouse_click = event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed
	
	# 2. Check if it's a direct physical screen tap (for Mobile)
	var is_screen_touch = event is InputEventScreenTouch and event.pressed
	
	# 3. If EITHER of those things happen, pop the coin!
	if is_mouse_click or is_screen_touch:
		get_viewport().set_input_as_handled()
		pop()

func pop() -> void:
	emit_signal("clicked", self) 
	get_tree().call_group("Coins", "wake_up")
	queue_free()
