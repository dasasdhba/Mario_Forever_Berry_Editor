extends StaticBody2D

export var coin :PackedScene
export var hidden :bool = false
export var once :bool = false
export var hidden_mask :int = 1

var timeout :bool = false
var last :bool = false

const ani_offset :int = 8

onready var height = $AnimatedSprite.frames.get_frame("normal",0).get_height()

# 标识该物件是否隐藏
func _hidden() ->bool:
	return hidden

# 标识该物件可以被顶
func _block(inverse :bool = false, _restrict :bool = false, attack :bool = false) ->bool:
	if hidden:
		hidden = false
		visible = true
		collision_mask = hidden_mask
	if last:
		return false
	if timeout:
		last = true
	if $Timer.is_stopped() && !last:
		$Timer.start()
	var new :Node = coin.instance()
	add_child(new)
	new._item((1-2*(inverse as int))*Vector2.UP)
	$AnimatedSprite.ani_offset.y = ani_offset*(2*(inverse as int)-1)
	if !inverse && attack:
		$Bump/AttackEnemy.attack()
	return true
	
func _ready() ->void:
	if hidden:
		if once:
			var scene :Node = Berry.get_scene(self)
			if scene.death_hint:
				queue_free()
		visible = false
		collision_mask = 0
	
func _process(_delta) ->void:
	# 动画
	if last:
		$AnimatedSprite.animation = "bump"
	else:
		$AnimatedSprite.animation = "normal"

func _on_Timer_timeout() ->void:
	timeout = true
