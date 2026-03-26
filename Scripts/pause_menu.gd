extends Control

@onready var start := load(Global.SCENES.start)

# --- UI REFERENCES based on your image ---
@onready var wish_panel := $WishPanel
@onready var desc_label := $WishPanel/VBoxContainer/HBoxContainer/PanelContainer/VBoxContainer/RichTextLabel
@onready var confirm_btn := $WishPanel/VBoxContainer/HBoxContainer/PanelContainer/VBoxContainer/ConfirmButton

var selected_wish_id: String = ""

func _ready() -> void:
	wish_panel.hide()
	confirm_btn.disabled = true
	desc_label.text = "[center]Select a wish from the left to view its details.[/center]"
	
	# Turn on BBCode so we can use colors and bold text!
	desc_label.bbcode_enabled = true 

# --- PAUSE MENU BUTTONS ---
func _on_resume_button_pressed() -> void:
	AudioManager.play_button_click()
	get_tree().paused = false
	hide()

func _on_wish_button_pressed() -> void:
	AudioManager.play_button_click()
	wish_panel.show()

func _on_restart_button_pressed() -> void:
	AudioManager.play_button_click()
	get_tree().reload_current_scene()

func _on_start_menu_button_pressed() -> void:
	AudioManager.play_button_click()
	get_tree().change_scene_to_packed(start)


# --- WISH SELECTION LOGIC ---
func select_wish(wish_id: String) -> void:
	AudioManager.play_button_click()
	selected_wish_id = wish_id
	var wish = Global.WISHES[wish_id]
	
	# Format the text nicely using BBCode
	var info = "[center][b]%s[/b][/center]\n\n" % wish.name
	info += "%s\n\n" % wish.desc
	info += "[color=gold]Cost: %d Favor[/color]" % wish.cost
	
	# Check if they can afford it
	if PlayerData.score < wish.cost:
		info += "\n[color=red](Not enough Favor!)[/color]"
		confirm_btn.disabled = true
	else:
		confirm_btn.disabled = false
		
	desc_label.text = info

# Connect your 5 Grid Buttons to these!
func _on_chain_button_pressed() -> void: select_wish("chain")
func _on_bomb_button_pressed() -> void: select_wish("bomb")
func _on_wipe_button_pressed() -> void: select_wish("wipe")
func _on_bronze_button_pressed() -> void: select_wish("bronze_banish")
func _on_freeze_button_pressed() -> void: select_wish("time_freeze")


# --- WISH CONFIRMATION & EXECUTION ---
func _on_confirm_button_pressed() -> void:
	AudioManager.play_button_click()
	var cost = Global.WISHES[selected_wish_id].cost
	
	if PlayerData.score >= cost:
		# 1. Deduct the cost
		PlayerData.score -= cost
		
		# 2. Execute INSTANT Wishes right here!
		if selected_wish_id == "wipe":
			var all_coins = get_tree().get_nodes_in_group("Coins")
			for coin in all_coins: coin.pop()
			
		elif selected_wish_id == "bronze_banish":
			var all_coins = get_tree().get_nodes_in_group("Coins")
			for coin in all_coins:
				if coin.coin_material == "bronze": 
					coin.pop()
					
		elif selected_wish_id == "time_freeze":
			# Tell the Main scene to stop the spawner
			get_tree().call_group("Main", "freeze_time") 
			
		else:
			# For Bomb and Chain, save the state so the next click in the game triggers it!
			Global.active_wish = selected_wish_id
			
		# 3. Reset the UI, hide the panel, and unpause the game!
		selected_wish_id = ""
		desc_label.text = "[center]Select a wish from the left to view its details.[/center]"
		confirm_btn.disabled = true
		wish_panel.hide()
		get_tree().paused = false
		hide()


func _on_close_button_pressed() -> void:
	wish_panel.hide()
