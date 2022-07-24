extends Label

export var interval :float = 0.5

var timer :float = 0

func _process(delta) ->void:
	timer += delta
	if timer >= interval:
		timer = 0
		visible = !visible
