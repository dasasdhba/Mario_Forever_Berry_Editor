extends Gravity

export var destroy_range :int = 320 # 销毁范围
export var view_destroy :bool = false # 出屏即销毁

var lava :bool = false

onready var view: Node = Berry.get_view(self)

func _physics_process(delta) ->void:
	if !$Timer.is_stopped():
		return
	
	if lava:
		gravity = 100
	else:
		gravity_process(delta,$Area2D/WaterDetect.is_in_water())
	position += gravity*gravity_direction * delta
	
	var gdir :Vector2 = Berry.get_global_direction(self,gravity_direction)
	if view_destroy:
		if !view.is_in_view_direction(global_position,destroy_range*scale,gdir):
			queue_free()
	elif !view.is_in_limit_direction(global_position,destroy_range*scale,gdir):
			queue_free()

func _on_Timer_timeout():
	Audio.play($Fall)

func _on_Area2D_area_entered(area :Area2D) ->void:
	if lava:
		return
	elif area is Lava:
		lava = true
		Audio.play($Lava)
