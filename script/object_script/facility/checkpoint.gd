extends Area2D

var activate :bool = false

onready var room :Room2D = Berry.get_room2d(self)
onready var scene :Node = room.manager if room != null else Scene

# 用于标识
func _checkpoint() ->bool:
	return activate
	
func _ready() ->void:
	if !is_connected("area_entered",self,"on_area_entered"):
		connect("area_entered",self,"on_area_entered")
	if room == null || room.name != scene.checkpoint_room_name:
		return
	var length :int = scene.current_checkpoint.size()
	for i in length:
		if name == scene.current_checkpoint[i]:
			activate = true
			$AnimatedSprite.animation = "activated"
			if i == length - 1:
				# 坦克 CP
				var parent :Node = get_parent()
				if parent.has_method("_tank_node"):
					parent.checkpoint = true
					parent.origin_position = parent.position
					var width :float
					var view :Node = Berry.get_view(self)
					var angle :float = wrapf(parent.angle,-180,180)
					if (angle <= 45 && angle >= -45) || angle >= 135 || angle <= -135:
						width = view.current_border.size.x
					else:
						width = view.current_border.size.y
					var dir :Vector2 = Berry.vector2_rotate_degree(parent.angle)
					parent.position -= (width/2 + position.dot(dir))*dir
				
				# 复活位置
				scene.checkpoint_position = global_position + $RebornPos.relative(false,false,true)

func on_area_entered(area :Area2D) ->void:
	if activate:
		return
	if !area.has_method("_player"):
		return
	activate = true
	$Activated.play()
	$AnimatedSprite.animation = "activated"
	if room == null:
		print("Checkpoint will be invalid as there is no Room2D.")
		return
	if scene.checkpoint_room_name != room.name:
		scene.current_checkpoint.clear()
		scene.checkpoint_scene = scene.current_scene
		scene.checkpoint_room_name = room.name
	scene.current_checkpoint.append(name)
