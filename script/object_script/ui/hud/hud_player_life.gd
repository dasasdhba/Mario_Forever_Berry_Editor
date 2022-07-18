extends Label

onready var origin :String = text

func _process(_delta) ->void:
	text = origin + " × " + String(Global.life)
