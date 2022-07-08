extends Gravity
export var speed :float = 200
const rot_speed :float = 1500.0

onready var view: Node = Berry.get_view(self)

func _process(delta) ->void:
	$Sprite.flip_h = speed < 0
	rotation_degrees += rot_speed * (2*((speed >= 0) as int)-1) * delta

func _physics_process(delta) ->void:
	gravity_process(delta)
	var velocity :Vector2 = gravity*gravity_direction + speed*gravity_direction.tangent()
	position += velocity * delta
	
	# 出界销毁
	var gdir :Vector2 = Berry.get_global_direction(self,gravity_direction)
	if !view.is_in_view_direction(global_position,16*scale,gdir):
		queue_free()
