extends Node

export var score :int = 100
export var shell: PackedScene
export var shell_delta_pos :Vector2 = Vector2(0,9)

var once: bool = false

onready var parent: Node = get_parent()
onready var rand: RandomNumberGenerator = Berry.get_rand(self)

func _on_attacked(atk :Array) ->void:
	if once:
		return
	once = true
	if atk[0] != "shell" && atk[0] != "star" && atk[0] != "lava":
		var s :Node = Lib.score.instance()
		s.score = score
		s.position = parent.position
		parent.get_parent().add_child(s)
	
	if atk[0] == "stomp":
		var new :Node = shell.instance()
		Berry.transform_copy(new,parent,shell_delta_pos)
		new.direction = parent.direction
		new.gravity_direction = parent.gravity_direction
		new.get_node("AreaShared").get_node("Stomped").call_deferred("delay",0.2)
		parent.get_parent().add_child(new)
	else:
		var death: Node = Lib.enemy_death.instance()
		Berry.transform_copy(death,parent)
		death.gravity_direction = parent.gravity_direction
		var spr: AnimatedSprite = $Sprite.duplicate()
		spr.visible = true
		death.add_child(spr)
		death.gravity = -350
		death.speed = 50*rand.randi_range(-2,2)
		parent.get_parent().add_child(death)
	parent.queue_free()
