extends StaticBody2D

export var default_item :PackedScene
export var hidden :bool = false
export var once :bool = false
export var hidden_mask :int = 1
export var fragment :PackedScene
export var score :int = 50

var item :Array
var is_brick: bool = true

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
			var r :bool = call("_break",inverse,restrict,attack)
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
		$Bump/HitCoin.hit_coin()
	return true
	
# 标识该物件可以打碎
func _break(inverse :bool = false, restrict :bool = false, attack :bool = false) ->bool:
	if !is_brick:
		return false
	if !inverse && attack:
		$Bump/AttackEnemy.attack()
		$Bump/HitCoin.hit_coin()
	if restrict:
		$AudioBump.play()
		$AnimatedSprite.ani_offset.y = ani_offset*(2*(inverse as int)-1)
		return false
	Audio.play($AudioBreak)
	Global.score += score
	var parent :Node = get_parent()
	for i in 4:
		var new :Node = fragment.instance()
		new.gravity_direction = Vector2.DOWN.rotated(rotation)
		match i:
			0:
				Berry.transform_copy(new,self,Vector2(4,4))
				new.gravity = -350
				new.speed = 200
			1:
				Berry.transform_copy(new,self,Vector2(-4,4))
				new.gravity = -350
				new.speed = -200
			2:
				Berry.transform_copy(new,self,Vector2(4,-4))
				new.gravity = -400
				new.speed = 100
			3:
				Berry.transform_copy(new,self,Vector2(-4,-4))
				new.gravity = -400
				new.speed = -100
		parent.add_child(new)
	queue_free()
	return true
	
# 载入物件
func item_update() ->void:
	for i in get_children():
		if i.has_method("_item") && !item.has(i):
			item.append(i)
			i.visible = false
			i.set_process(false)
			i.set_physics_process(false)
			is_brick = false
	
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
			is_brick = false
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
	if item.empty() && !is_brick:
		$AnimatedSprite.animation = "bump"
	else:
		$AnimatedSprite.animation = "normal"
