# 火球运动
extends Gravity

export var speed :float = 0
export var destroy_range :Vector2 = Vector2(16,16)

var direction :int = 1

onready var view :Node = Berry.get_view(self)

func _ready() ->void:
	$AreaShared.inherit(self)

func _process(_delta) ->void:
	# 动画
	direction = -1
	if speed >= 0:
		direction = 1
	$Sprite.flip_h = direction != 1
	$Sprite/Rotation.direction = direction
	
func _physics_process(delta) ->void:
	# 重力
	gravity_process(delta,$AreaShared/WaterDetect.is_in_water())
		
	# 应用物理
	var velocity :Vector2 = gravity*gravity_direction + speed*gravity_direction.tangent()
	position += velocity * delta

	# 出界销毁
	var gdir :Vector2 = Berry.get_global_direction(self,gravity_direction)
	if !view.is_in_limit_direction(global_position,destroy_range*scale,gdir):
		queue_free()
