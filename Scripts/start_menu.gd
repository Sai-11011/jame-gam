extends Control

@onready var main_scene := load(Global.SCENES.main) 
@onready var settings := load(Global.SCENES.settings)
@onready var achievement := load(Global.SCENES.achievement)
@onready var credits := $Credits
@onready var credit_text := $Credits/RichTextLabel
@onready var info := $Info
var credits_tween: Tween

var info_text := """
[center][font_size=24][pulse freq=0.5 color=#ffffff80][color=#ffd700][b]The Fountain of Wishes[/b][/color][/pulse][/font_size]

An endless shower of magic coins is filling the basin. 
Your goal is simple: [b]Survive as long as you can.[/b]

Click the falling coins to shatter them, claim their [color=#ffd700]Favor[/color], and keep the [color=#40e0d0]water level[/color] from overflowing. 

Spend your Favor in the [color=#ffb6c1]Wish Shop[/color] to unleash powerful lifelines when the chaos becomes too much. 

[font_size=16] [/font_size]

[wave amp=20.0 freq=3.0 connected=1][color=#b0c4de]How long can you endure the cascade?[/color][/wave][/center]
"""

func _ready() -> void:
	credit_text.text = """[center]

[font_size=12] [/font_size]

[color=#ffd700][font_size=16][b]PROGRAMMER & DESIGNER[/b][/font_size][/color]
[font_size=26]Sai[/font_size]

[font_size=8] [/font_size]

[color=#ffd700][font_size=16][b]NARRATIVE DESIGN[/b][/font_size][/color]
[font_size=26]Keem Holt (SteezyGlock)[/font_size]

[font_size=8] [/font_size]

[color=#ffd700][font_size=16][b]MUSIC & SFX[/b][/font_size][/color]
[font_size=26]RichoMaya[/font_size]

[font_size=8] [/font_size]

[color=#ffd700][font_size=16][b]ARTIST[/b][/font_size][/color]
[font_size=26]Olga Vener (Avvakira)[/font_size]

[font_size=8] [/font_size]

[color=#ffd700][font_size=16][b]TESTER[/b][/font_size][/color]
[font_size=26]Clover Lamporuge[/font_size]

[font_size=16] [/font_size]

[wave amp=20.0 freq=3.0 connected=1][color=#8b949e][font_size=20][b]Created for Jame Gam #57 [/b][/font_size][/color][/wave][/center]"""

# --- NAVIGATION ---
func _on_button_pressed() -> void:
	AudioManager.play_button_click()
	get_tree().change_scene_to_packed(main_scene)

func _on_settings_button_pressed() -> void:
	AudioManager.play_button_click()
	get_tree().change_scene_to_packed(settings)

# --- THE SCROLL ANIMATION ---
func _on_credits_button_pressed() -> void:
	AudioManager.play_button_click()
	credits.show()
	
	# 1. Reset the text position to start just below the bottom of the screen
	var screen_height = get_viewport_rect().size.y
	credit_text.position.y = screen_height
	
	# 2. Kill any old tweens just in case they clicked it rapidly
	if credits_tween and credits_tween.is_valid():
		credits_tween.kill()
		
	# 3. Create the slow, cinematic scroll
	credits_tween = create_tween()
	
	# Calculate the target (move it entirely off the top of the screen)
	var target_y = -credit_text.size.y 
	
	# Tween it over 15 seconds (Change this number to make it faster or slower!)
	credits_tween.tween_property(credit_text, "position:y", target_y, 15.0)
	
	# 4. Automatically close the menu when the text finishes scrolling naturally
	credits_tween.finished.connect(_close_credits)


# --- THE ANY-KEY SKIP LOGIC ---
func _input(event: InputEvent) -> void:
	# Only listen for skips if the credits are actually on screen
	if credits.visible:
		var is_key = event is InputEventKey and event.pressed
		var is_click = event is InputEventMouseButton and event.pressed
		var is_touch = event is InputEventScreenTouch and event.pressed
		
		# If they hit a keyboard key, clicked the mouse, or tapped the screen...
		if is_key or is_click or is_touch:
			get_viewport().set_input_as_handled() # Stop the click from hitting buttons underneath
			_close_credits()


# --- CLEANUP ---
func _close_credits() -> void:
	if credits.visible:
		credits.hide()
		
		# Stop the animation dead in its tracks if they skipped it
		if credits_tween and credits_tween.is_valid():
			credits_tween.kill()


func _on_back_button_pressed() -> void:
	AudioManager.play_button_click()
	info.hide()


func _on_intro_button_pressed() -> void:
	AudioManager.play_button_click()
	info.show()

func _on_achievements_button_pressed() -> void:
	get_tree().change_scene_to_packed(achievement)
