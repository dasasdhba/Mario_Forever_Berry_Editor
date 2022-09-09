extends Area2D

export var speed :float = 300
export var speed_follow :float = 100
export var direction :int = 1
export var auto_destroy :bool = true
export var destroy_range :float = 128

var follow :bool = false
var follow_position :Vector2 = Vector2.ZERO

onready var view :Node = Berry.get_view(self)

func _physics_process(delta :float) ->void:
	# 动画
	$AnimatedSprite.flip_h = direction != 1
	$AnimatedSprite.offset.x = -5*direction
	
	# 运动
	var velocity :Vector2 = direction*speed*Vector2.RIGHT.rotated(rotation)
	
	if follow:
		var vdir :Vector2 = velocity.normalized().tangent()
		var d :float = (position - follow_position).dot(vdir)
		if abs(d) >= speed_follow * delta:
			velocity -= speed_follow*sign(d)*vdir
			
	position += velocity * delta

	# 出界销毁
	if auto_destroy:
		if !view.is_in_view_direction(global_position,destroy_range*scale,velocity.normalized()):
			queue_free()
