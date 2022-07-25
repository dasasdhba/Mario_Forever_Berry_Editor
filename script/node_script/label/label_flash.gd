extends Label

export var interval :float = 0.5
export var disabled :bool = false

var timer :float = 0

func _process(delta) ->void:
	if disabled:
		visible = false
		return
	timer += delta
	if timer >= interval:
		timer = 0
		visible = !visible
