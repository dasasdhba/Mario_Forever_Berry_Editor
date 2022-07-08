extends Gravity
export var velocity :Vector2 = Vector2.ZERO
const rot_speed :float = 750.0
const destroy_range :float = 64.0

onready var view: Node = Berry.get_view(self)

func _process(delta) ->void:
	rotation_degrees += rot_speed * (2*((velocity.dot(gravity_direction.tangent()) >= 0) as int)-1) * delta

func _physics_process(delta) ->void:
	gravity_process(delta)
	var v :Vector2 = gravity*gravity_direction + velocity
	position += v * delta
	
	# 出界销毁
	var gdir :Vector2 = Berry.get_global_direction(self,gravity_direction)
	if !view.is_in_view_direction(global_position,destroy_range*scale,gdir):
		queue_free()
