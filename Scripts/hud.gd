extends Control

@onready var score := $MarginContainer/HBoxContainer/Score
@onready var timer := $MarginContainer/HBoxContainer/Timer
@onready var wish_menu := $"../Wish"
@onready var achievement_popup := $AchievementPopup
@onready var achievement_label := $AchievementPopup/Label

@onready var sparkle_scene: PackedScene = load(Global.SCENES.sparkle)
var achievement_queue: Array[String] = []
var is_showing_achievement: bool = false
var achievement_tween: Tween
@export var pause : Control
var last_score: int = 0

func _ready() -> void:
	# Crucial: Set the pivot to the center so it scales outward uniformly, not from the top-left corner
	score.pivot_offset = score.size / 2


func _process(_delta: float) -> void:
	timer.text = "Timer : "+PlayerData.get_formatted_time()
	if PlayerData.score > last_score:
		last_score = PlayerData.score
		score.text = "Favor : "+ str(PlayerData.score)
		var tween = create_tween()
		# Scale up slightly using a bouncy transition
		tween.tween_property(score, "scale", Vector2(1.4, 1.4), 0.1).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		# Scale back down to normal
		tween.tween_property(score, "scale", Vector2.ONE, 0.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	else:
		score.text = "Favor : "+ str(PlayerData.score)

func _on_button_pressed() -> void:
	AudioManager.play_button_click()
	if pause != null :
		get_tree().paused = true
		pause.show()

func _on_wish_button_pressed() -> void:
	AudioManager.play_button_click()
	get_tree().paused = true
	wish_menu.show() # Show the shop!

func show_achievement(title: String) -> void:
	# Add it to the waiting list!
	achievement_queue.append(title)
	
	# If we aren't already showing one, start the line
	if not is_showing_achievement:
		_play_next_achievement()

func _play_next_achievement() -> void:
	# If the line is empty, we are done
	if achievement_queue.is_empty():
		is_showing_achievement = false
		return
		
	is_showing_achievement = true
	var title = achievement_queue.pop_front() # Grab the first one in line
	
	achievement_label.text = "🏆 Achievement Unlocked!\n" + title
	
	# Reset position off-screen just in case
	achievement_popup.position.x = get_viewport_rect().size.x + 50
	
	achievement_tween = create_tween()
	
	var target_x = get_viewport_rect().size.x - achievement_popup.size.x - 100
	achievement_tween.tween_property(achievement_popup, "position:x", target_x, 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	
	achievement_tween.tween_callback(_play_sparkles)
	achievement_tween.tween_interval(3.0)
	
	var off_screen_x = get_viewport_rect().size.x + 50
	achievement_tween.tween_property(achievement_popup, "position:x", off_screen_x, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	
	# NEW: When this animation finishes completely, check the queue for the next one!
	achievement_tween.tween_callback(_play_next_achievement)

# --- NEW: Helper function triggered by the Tween ---
func _play_sparkles() -> void:
	if sparkle_scene:
		var new_sparkle = sparkle_scene.instantiate()
		achievement_popup.add_child(new_sparkle)
		new_sparkle.scale = Vector2(2, 2)  # Double the size
		new_sparkle.amount = 100 
		# Center the sparkles perfectly inside the UI box using local position!
		new_sparkle.position = achievement_popup.size / 2
