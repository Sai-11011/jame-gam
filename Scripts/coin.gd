extends RigidBody2D

@onready var sprite = $AnimatedSprite2D
@onready var spin_collision = $CollisionSpin
@onready var flat_collision = $CollisionFlat

signal clicked(coin_node) 

var water_increase: float = 0.0
var coin_material: String = "" 
var is_settled: bool = false 

var my_coin_data: Dictionary

func setup(coin_data: Dictionary) -> void:
	my_coin_data = coin_data
	
	mass = coin_data["weight"]
	
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
	if is_settled:
		return
		
	if linear_velocity.length() < 10.0:
		is_settled = true
		sprite.stop()
		
		# Check which collision shape is active to know how it landed
		if not spin_collision.disabled:
			sprite.play("idle_" + "round_" + coin_material)
		else:
			sprite.play("idle_" + "flat_" + coin_material)

func wake_up() -> void:
	sleeping = false
	is_settled = false 

func _input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		emit_signal("clicked", self) 
		get_tree().call_group("Coins", "wake_up")
		queue_free()
