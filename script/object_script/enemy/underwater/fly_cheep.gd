extends Gravity

export var speed :float = 50 # 速度
enum DIR {LEFT = -1, RIGHT = 1}
export(DIR) var direction :int = -1 # 初始方向
export var destroy_range :float = 64

var delta_position :Vector2

onready var view: Node = Berry.get_view(self)

func _ready() ->void:
	gravity_direction = gravity_direction.rotated(rotation)
	
func _physics_process(delta) ->void:
	delta_position = -position
	
	gravity_process(delta)
	
	var velocity :Vector2 = gravity*gravity_direction + speed*direction*gravity_direction.tangent()
	position += velocity * delta
	
	delta_position += position
	
	# 出界销毁
	if gravity > 0:
		var gdir :Vector2 = Berry.get_global_direction(self,gravity_direction)
		if !view.is_in_view_direction(global_position,destroy_range*scale,gdir*gravity_direction.tangent()):
			queue_free()
