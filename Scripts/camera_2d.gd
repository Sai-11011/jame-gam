extends Camera2D

# How quickly the shaking stops (higher number = faster stop)
@export var decay: float = 0.8 
# The maximum pixels the camera can move in any direction
@export var max_offset: Vector2 = Vector2(15.0, 15.0) 

# Trauma goes from 0.0 (no shake) to 1.0 (maximum shake)
var trauma: float = 0.0 

func _ready() -> void:
	# Add the camera to a group so we can easily find it from any other script
	add_to_group("Camera")

func _process(delta: float) -> void:
	if trauma > 0:
		# Drain the trauma away over time
		trauma = max(trauma - decay * delta, 0.0)
		shake()
	else:
		# Snap the camera perfectly back to center when there is no trauma
		offset = Vector2.ZERO

# Call this function from OTHER scripts when you want the screen to shake!
func add_trauma(amount: float) -> void:
	# Keep trauma capped at 1.0 so the screen never flies away entirely
	trauma = min(trauma + amount, 1.0)

func shake() -> void:
	# Squaring the trauma makes the shake feel punchy at the start and smooth at the end
	var shake_intensity = pow(trauma, 2)
	
	# Apply a random X and Y offset based on the current intensity
	offset.x = max_offset.x * shake_intensity * randf_range(-1.0, 1.0)
	offset.y = max_offset.y * shake_intensity * randf_range(-1.0, 1.0)
