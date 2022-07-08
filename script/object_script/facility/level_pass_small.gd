extends AnimatedSprite

enum DIR {LEFT = -1, RIGHT = 1}
export(DIR) var direction :int = DIR.RIGHT
export var next_scene :PackedScene
export var pass_res :PackedScene

var pass_line :bool = false

onready var parent :Node = get_parent()
onready var scene :Node = Berry.get_scene(self)

func _ready():
	if parent.has_method("_level_pass"):
		if position.x < 0:
			direction = DIR.RIGHT
		else:
			direction = DIR.LEFT
		parent.direction = direction
		pass_line = true
		
func _physics_process(_delta) ->void:
	for i in scene.current_player:
		if !i.clear && i.is_on_floor():
			var p_pos :Vector2 = parent.global_transform.xform_inv(i.global_position)
			if p_pos.y < position.y - 16 || p_pos.y > position.y + 100:
				continue
			if direction == DIR.RIGHT:
				if p_pos.x < position.x:
					continue
			elif p_pos.x > position.x:
				continue
			level_pass(i)
			break
			
func level_pass(player :Node) ->void:
	var score :Node = Lib.score.instance()
	score.position = parent.global_transform.xform_inv(player.global_position)
	parent.add_child(score)
	if pass_line:
		parent._level_pass()
	else:
		var new :Node = pass_res.instance()
		new.visible = false
		new.next_scene = next_scene
		add_child(new)
		new._level_pass()
