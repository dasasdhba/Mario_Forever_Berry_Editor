extends Label

onready var origin_text :String = text

func _ready() ->void:
	pause_key_update()
	
func pause_key_update() ->void:
	var event :InputEventKey = Berry.get_input_event_key("ui_pause")
	if event == null:
		text = ""
		return
	var pause_key :String = OS.get_scancode_string(event.get_scancode_with_modifiers())
	text = origin_text.replace("%s",pause_key)
