extends Label

onready var origin_text :String = text

func _ready() ->void:
	pause_key_update()
	
func pause_key_update() ->void:
	var event :InputEvent
	for i in InputMap.get_action_list("ui_pause"):
		if i is InputEvent:
			event = i
			break
	var pause_key :String = OS.get_scancode_string(event.get_scancode_with_modifiers())
	text = origin_text.replace("%s",pause_key)
