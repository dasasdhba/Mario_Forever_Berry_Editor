# 火球运动
extends Gravity

export var speed :float = 400
export var direction :int = 1
export var bounce_speed :float = 250

var boom_once :bool = false

func _ready() ->void:
	$AreaShared.inherit(self)

func _process(_delta) ->void:
	# 动画
	$Sprite.flip_h = direction != 1
	$Sprite/Rotation.direction = direction
	
func _physics_process(delta) ->void:
	# 重力
	gravity_process(delta,$AreaShared/WaterDetect.is_in_water())
	if is_on_floor():
		gravity = -bounce_speed
		
	# 应用物理
	var gdir :Vector2 = Berry.get_global_direction(self,gravity_direction)
	var velocity :Vector2 = gravity*gdir + speed*direction*gdir.tangent()
	move_and_slide(velocity,-gdir,true)

	# 爆炸
	if is_on_wall() || is_on_ceiling():
		boom()

func boom() ->void:
	if boom_once:
		return
	boom_once = true
	Audio.play($AudioHit)
	var new :AnimatedSprite = Lib.boom.instance()
	new.position = position
	new.scale = scale
	get_parent().add_child(new)
	queue_free()
