tool
extends Node

func _ready() ->void:
	if !Engine.editor_hint:
		queue_free()
		
func _process(_delta) ->void:
	var parent :Label = get_parent()
	var t :int = parent.get_parent().level_time
	if t > 0:
		parent.text = "TIME\n"+String(t)
	else:
		parent.text = ""
