extends Label

onready var scene :Node = Berry.get_scene(self)

func _process(_delta) ->void:
	text = "× "+String(Global.coin)
	
func _physics_process(_delta) ->void:
	if !scene.current_player.empty() && Global.coin >= 100:
		# warning-ignore:integer_division
		var l :int = Global.coin / 100
		Global.coin %= 100
		var p :Node = scene.current_player.front()
		var life :Node = Lib.life.instance()
		life.life = l
		p.add_child(life)
