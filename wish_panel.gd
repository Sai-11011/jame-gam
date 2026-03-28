extends Control

@onready var desc_label := $VBoxContainer/HBoxContainer/PanelContainer/VBoxContainer/RichTextLabel
@onready var confirm_btn := $VBoxContainer/HBoxContainer/PanelContainer/VBoxContainer/ConfirmButton
@onready var favor_label := $VBoxContainer/Label/FavorLabel

# Notice we removed the 'load' variables for the scenes!

var selected_wish_id: String = ""

func _ready() -> void:
	confirm_btn.disabled = true
	desc_label.text = "[center]Select a wish from the left to view its details.[/center]"
	
# --- NEW: UPDATE SCORE ON OPEN ---
# every time it becomes visible, not just when it loads!
func _on_visibility_changed() -> void:
	if visible:
		favor_label.text = "Favor : "+ str(PlayerData.score)
		


# --- WISH SELECTION LOGIC ---
func select_wish(wish_id: String) -> void:
	AudioManager.play_button_click()
	selected_wish_id = wish_id
	var wish = Global.WISHES[wish_id]
	
	var info = "[center][b]%s[/b][/center]\n\n" % wish.name
	info += "%s\n\n" % wish.desc
	info += "[color=gold]Cost: %d Favor[/color]" % wish.cost
	
	if PlayerData.score < wish.cost:
		info += "\n[color=red](Not enough Favor!)[/color]"
		confirm_btn.disabled = true
	else:
		confirm_btn.disabled = false
		
	desc_label.text = info

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
		PlayerData.score -= cost
		favor_label.text = "Favor : "+ str(PlayerData.score) # Update instantly!
		
		if selected_wish_id == "wipe":
			var all_coins = get_tree().get_nodes_in_group("Coins")
			for coin in all_coins: coin.pop()
			
		elif selected_wish_id == "bronze_banish":
			var all_coins = get_tree().get_nodes_in_group("Coins")
			for coin in all_coins:
				if coin.coin_material == "bronze": 
					coin.pop()
					
		elif selected_wish_id == "time_freeze":
			get_tree().call_group("Main", "freeze_time") 
			
		else:
			Global.active_wish = selected_wish_id
			
		if selected_wish_id == "time_freeze":
			selected_wish_id = ""
			desc_label.text = "[center][color=green]Time Freeze Activated![/color]\nTime will stop when you resume. Select another wish?[/center]"
			confirm_btn.disabled = true
		else:
			selected_wish_id = ""
			desc_label.text = "[center]Select a wish from the left to view its details.[/center]"
			confirm_btn.disabled = true
			
			# FIX: Just hide the menu and unpause!
			hide()
			get_tree().paused = false


func _on_close_button_pressed() -> void:	
	AudioManager.play_button_click()
	hide()
	get_tree().paused = false
