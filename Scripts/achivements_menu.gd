extends Control

@onready var achievement_list := $VBoxContainer/RichTextLabel
@onready var start := load(Global.SCENES.start)

# A master list of every badge in the game to check against their save file
var master_list = {
	"first_catch": {
		"title": "First Catch", 
		"desc": "Shatter your very first coin."
	},
	"getting_hang": {
		"title": "Getting the Hang", 
		"desc": "Amass 50 Favor."
	},
	"close_call": {
		"title": "Close Call!", 
		"desc": "Recover the water level after a critical danger warning."
	},
	"panic_button": {
		"title": "Panic Button", 
		"desc": "Purchase Fountain Sweep lifeline from the Wish Shop."
	},
	"in_zone": {
		"title": "In the Zone", 
		"desc": "Amass 1000 Favor."
	}
}
func _ready() -> void:
	update_display()

func update_display() -> void:
	if not achievement_list:
		return
		
	var display_text = "[center][b][font_size=36][color=gold]TROPHY ROOM[/color][/font_size][/b][/center]\n\n"
	
	# Loop through the master list and check if the player owns each one
	for id in master_list:
		var title = master_list[id]["title"]
		var desc = master_list[id]["desc"]
		
		if PlayerData.unlocked_achievements.has(id):
			# Unlocked: Bright white with a trophy icon
			display_text += "[center][b][font_size=24][color=white] " + title + " [/color][/font_size][/b]\n[font_size=16][color=white]" + desc + "[/color][/font_size][/center]\n\n"
		else:
			# Locked: Grayed out mystery text
			display_text += "[center][b][font_size=24][color=#4a4a4a] Locked [/color][/font_size][/b]\n[font_size=16][color=#ababab]Keep playing to reveal this achievement.[/color][/font_size][/center]\n\n"
			
	achievement_list.text = display_text

func _on_back_button_pressed() -> void:
	AudioManager.play_button_click()
	get_tree().change_scene_to_packed(start)
