extends GPUParticles2D

func _ready() -> void:
	# Tell the particles to burst the moment this scene is spawned
	emitting = true
	# Delete this node automatically when the particles finish falling
	finished.connect(queue_free)
