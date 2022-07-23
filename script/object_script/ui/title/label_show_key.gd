extends Label

export var action :String = ""
export var wait :bool = false
export var wait_text :String = "PRESS A KEY..."

var key_text :String = ""

func _ready() ->void:
	update_key()

func update_key() ->void:
	var event :InputEventKey = Berry.get_input_event_key(action)
	if event == null:
		return
	key_text = OS.get_scancode_string(event.get_scancode_with_modifiers())

func _process(_delta) ->void:
	if !wait:
		text = key_text
	else:
		text = wait_text
