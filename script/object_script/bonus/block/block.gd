extends StaticBody2D

export var default_item :PackedScene
export var hidden :bool = false
export var once :bool = false
export var hidden_mask :int = 1

var item :Array

const ani_offset :int = 8

onready var height = $AnimatedSprite.frames.get_frame("normal",0).get_height()

# 标识该物件是否隐藏
func _hidden() ->bool:
	return hidden

# 标识该物件可以被顶
func _block(inverse :bool = false, restrict :bool = false, attack :bool = false) ->bool:
	if hidden:
		hidden = false
		visible = true
		collision_mask = hidden_mask
	if item.empty():
		if has_method("_break"):
			var r :bool = call("_break",inverse,restrict)
			return r
		return false
	var new :Node = item.pop_front()
	new._item((1-2*(inverse as int))*Vector2.UP)
	new.visible = true
	new.set_process(true)
	new.set_physics_process(true)
	$AnimatedSprite.ani_offset.y = ani_offset*(2*(inverse as int)-1)
	if !inverse && attack:
		$Bump/AttackEnemy.attack()
	return true
	
# 载入物件
func item_update() ->void:
	for i in get_children():
		if i.has_method("_item") && !item.has(i):
			item.append(i)
			i.visible = false
			i.set_process(false)
			i.set_physics_process(false)
	
func _ready() ->void:
	item_update()
	if item.empty() && default_item != null:
		var new :Node = default_item.instance()
		if new.has_method("_item"):
			add_child(new)
			new.visible = false
			new.set_process(false)
			new.set_physics_process(false)
			item.append(new)
		else:
			new.queue_free()
	if hidden:
		if once:
			var scene :Node = Berry.get_scene(self)
			if scene.death_hint:
				queue_free()
		visible = false
		collision_mask = 0

func _process(_delta) ->void:
	# 动画
	if item.empty():
		$AnimatedSprite.animation = "bump"
	else:
		$AnimatedSprite.animation = "normal"
