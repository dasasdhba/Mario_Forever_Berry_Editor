extends Gravity

export var speed :float = 0 # 横向速度
export var alpha_speed :float = 2 # 透明度变化速度
export var destroy_range :int = 128 # 销毁范围
export var view_destroy :bool = false # 出屏即销毁

onready var view: Node = Berry.get_view(self)

var disappear :bool = false

func _process(delta) ->void:
	if disappear:
		modulate.a -= alpha_speed * delta
		if modulate.a <= 0:
			queue_free()

func _physics_process(delta) ->void:
	if !is_on_floor():
		gravity_process(delta,$Area2D/WaterDetect.is_in_water())
	var gdir :Vector2 = Berry.get_global_direction(self,gravity_direction)
	move_and_slide(gravity*gdir + speed*gdir.tangent(),-gdir,true)
	if is_on_floor():
		gravity = 0
		if $Timer.is_stopped() && !disappear:
			$Timer.start()
	
	if view_destroy:
		if !view.is_in_view_direction(global_position,destroy_range*scale,gdir):
			queue_free()
	elif !view.is_in_limit_direction(global_position,destroy_range*scale,gdir):
			queue_free()
		
func _on_Timer_timeout() ->void:
	disappear = true
