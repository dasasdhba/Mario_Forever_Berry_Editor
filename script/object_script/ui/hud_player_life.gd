extends Label

onready var origin :String = text

func _process(_delta):
	text = origin + " × " + String(Global.life)
