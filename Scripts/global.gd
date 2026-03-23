extends Node

var is_game_over := false

const SCENES :Dictionary = {
	"main":"uid://dq185ba7g7220",
	"coin":"uid://buw41pk3sscrb",
	"sparkle":"uid://bih7g88xl275c",
	"splash":"uid://chi47vo2opelm"
}

const COIN_TYPES :Dictionary = {
	"normal": {
		"name": "normal",
		"type": "bronze",
		"scale":Vector2(1.0,1.0),
		"weight": 1.0,           # Standard mass
		"bounce": 0.3,           # Standard bounciness
		"friction": 0.5,         # Standard sliding resistance
		"water_increase": 1,   # Base amount the water rises
		"color": Color(0.8, 0.5, 0.2) # Bronze color for placeholder tinting
	},
	"heavy": {
		"name": "heavy",
		"type": "silver",
		"scale":Vector2(3.0,3.0),
		"weight": 3.0,           # High mass to pin other coins
		"bounce": 0.0,           # Zero bounce so it slams down
		"friction": 0.8,         # High friction so it doesn't slide easily
		"water_increase": 2.5,   # Displaces much more water due to size
		"color": Color(0.6, 0.6, 0.6) # Silver color
	},
	"bouncy": {
		"name": "bouncy",
		"type": "gold",
		"scale":Vector2(0.5,0.5),
		"weight": 0.5,           # Low mass, easily knocked around
		"bounce": 0.9,           # Extremely high bounce for chaos
		"friction": 0.2,         # Low friction to keep it moving
		"water_increase": 0.5,   # Displaces very little water
		"color": Color(1.0, 0.84, 0.0) # Gold color
	}
}
