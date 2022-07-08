# 不支持旋转
extends StaticBody2D

export var brush_border :Rect2 = Rect2(-16,-32,32,32)
export var brush_offset :Vector2 = Vector2(16,32)

onready var scene :Node = Berry.get_scene(self)
onready var view :Node = Berry.get_view(self)
onready var camera :Camera2D = view.get_current_camera()

# 用于标识 brush2d 摆放
func _brush() ->void:
	pass

func _physics_process(_delta) ->void:
	var ytop :float = 0
	if camera != null:
		ytop = camera.limit_top
	var ymin :float = INF
	for i in scene.current_player:
		if i.global_position.y < ymin:
			ymin = i.global_position.y
	if global_position.y == ytop:
		scale.y = max(10,10 + (ytop-ymin)/32)
	else:
		scale.y = 1
