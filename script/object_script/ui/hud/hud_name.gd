tool
extends Label

func _ready() ->void:
	var parent: Control = get_parent()
	if parent.name_override:
		text = "WORLD\n" + String(parent.name_left) + "-" + String(parent.name_right)

func _process(_delta) ->void:
	if !Engine.editor_hint:
		return
	var parent: Control = get_parent()
	if parent.name_override:
		text = "WORLD\n" + String(parent.name_left) + "-" + String(parent.name_right)
