extends Node

var is_game_over := false

const SCENES :Dictionary = {
	"main":"uid://dq185ba7g7220",
	"coin":"uid://buw41pk3sscrb",
	"sparkle":"uid://bih7g88xl275c",
	"splash":"uid://chi47vo2opelm",
	"start":"uid://b3k3jajoe6tme",
	"game_over":"uid://cbfhggauibbmm",
}

const WISHES : Dictionary = {
	"chain": {
		"id": "chain",
		"name": "Chain Reaction",
		"desc": "Your next click pops the target + 4 random coins anywhere.",
		"cost": 25 # Cheap, fast way to clear a little space.
	},
	"bronze_banish": {
		"id": "bronze_banish",
		"name": "Bronze Banish",
		"desc": "Instantly pops EVERY Bronze coin on the screen.",
		"cost": 50 # Clears the bulk clutter, leaves the high-value coins behind.
	},
	"bomb": {
		"id": "bomb",
		"name": "Coin Bomb",
		"desc": "Your next click creates a blast radius, popping nearby coins.",
		"cost": 75 # Great for clearing out a specific heavy pile-up.
	},
	"time_freeze": {
		"id": "time_freeze",
		"name": "Breathing Room",
		"desc": "Stops the coin spawner from dropping anything for 5 seconds.",
		"cost": 90 # Pure survival utility. Gives them time to click normally.
	},
	"wipe": {
		"id": "wipe",
		"name": "Fountain Sweep",
		"desc": "Instantly pops EVERY coin on the screen.",
		"cost": 150 # The ultimate panic button. Massive net loss of Favor, but saves the run.
	}
}

# Variable to track if the player has an active wish waiting to be clicked
var active_wish: String = ""
const COIN_TYPES :Dictionary = {
	"normal": {
		"name": "normal",
		"type": "bronze",
		"score": 1,
		"weight": 1.0,           # Standard mass
		"bounce": 0.3,           # Standard bounciness
		"friction": 0.5,         # Standard sliding resistance
		"water_increase": 1,   # Base amount the water rises
	},
	"heavy": {
		"name": "heavy",
		"type": "gold",
		"score": 3,
		"weight": 3.0,           # High mass to pin other coins
		"bounce": 0.0,           # Zero bounce so it slams down
		"friction": 0.8,         # High friction so it doesn't slide easily
		"water_increase": 2.5,   # Displaces much more water due to size
	},
	"bouncy": {
		"name": "bouncy",
		"type": "silver",
		"score": 5,
		"weight": 0.5,           # Low mass, easily knocked around
		"bounce": 0.9,           # Extremely high bounce for chaos
		"friction": 0.2,         # Low friction to keep it moving
		"water_increase": 0.5,   # Displaces very little water
	}
}
