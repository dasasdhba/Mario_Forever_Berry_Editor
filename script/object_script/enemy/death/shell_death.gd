extends Node

export var score :int = 100

var once: bool = false

onready var parent: Node = get_parent()
onready var rand: RandomNumberGenerator = Berry.get_rand(self)

func _on_attacked(atk :Array) ->void:
	if once:
		return
	if atk[0] != "shell" && atk[0] != "star" && atk[0] != "lava":
		if !(atk[0] == "stomp" && parent.speed == 0):
			var s :Node = Lib.score.instance()
			s.score = score
			s.position = parent.position
			parent.get_parent().add_child(s)
	
	if atk[0] == "stomp":
		if parent.speed == 0:
			parent.speed = parent.shell_speed
			if parent.position.direction_to(atk[1].position).dot(parent.gravity_direction.tangent()) > 0:
				parent.direction = -1
			else:
				parent.direction = 1
		else:
			parent.speed = 0
	else:
		once = true
		var death: Node = Lib.enemy_death.instance()
		Berry.transform_copy(death,parent)
		death.gravity_direction = parent.gravity_direction
		var spr: AnimatedSprite = parent.get_node("AnimatedSprite").duplicate()
		spr.disabled = true
		spr.flip_v = true
		death.add_child(spr)
		death.gravity = -350
		death.speed = 50*rand.randi_range(-2,2)
		parent.get_parent().add_child(death)
		parent.queue_free()
