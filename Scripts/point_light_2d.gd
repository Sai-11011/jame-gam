extends PointLight2D

# We use @export so you can easily change these numbers in the Inspector 
# without having to open the script again!
@export var min_energy: float = 0.3
@export var max_energy: float = 1.1
@export var pulse_duration: float = 1.5

func _ready() -> void:
	# 1. Create a Tween and tell it to loop infinitely
	var tween = create_tween().set_loops()
	
	# 2. Make the transition smooth like breathing (Sine wave)
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)
	
	# 3. Animate the glow getting brighter...
	tween.tween_property(self, "energy", max_energy, pulse_duration)
	
	# 4. ...and then animate it dimming back down!
	tween.tween_property(self, "energy", min_energy, pulse_duration)
