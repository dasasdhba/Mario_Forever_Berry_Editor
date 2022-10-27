extends Area2D

enum MODE {PLAYER, CAMERA, CHECKPOINT}
export(MODE) var mode :int = MODE.PLAYER
export var offset :Vector2 = Vector2.ZERO
export var smooth :bool = false
export var limit_smooth :bool = false
export var once :bool = false
export var region_path :NodePath = @"" # 为空则检测父节点

var border :Rect2

onready var view :Node = Berry.get_view(self)
onready var camera: Camera2D = view.get_current_camera()

func _ready():
	if !is_connected("area_entered",self,"on_area_entered"):
		connect("area_entered",self,"on_area_entered")
	if !region_path.is_empty():
		var region :Node = get_node(region_path)
		if region.has_method("_camera_region"):
			border = Rect2(region.global_position,region.global_scale)
			return
	var parent :Node = get_parent()
	if parent.has_method("_camera_region"):
		border = Rect2(parent.global_position,parent.global_scale)
	else:
		if camera == null:
			return
		border = Rect2(camera.limit_left,camera.limit_top,camera.limit_right-camera.limit_left,camera.limit_bottom-camera.limit_top)

func setup() ->void:
	if camera == null:
		return
	if !camera.smooth_limit:
		camera.smoothing_enabled = smooth
	camera.limit_smoothed = limit_smooth
	if limit_smooth && !camera.smoothing_enabled:
		camera.smoothing_enabled = true
		camera.smooth_limit = true
	camera.offset = offset
	camera.limit_left = border.position.x as int
	camera.limit_top = border.position.y as int
	camera.limit_right = border.end.x as int
	camera.limit_bottom = border.end.y as int
	if once || mode == MODE.CHECKPOINT:
		queue_free()
		
func on_area_entered(area :Area2D) ->void:
	if mode == MODE.PLAYER:
		if area.has_method("_player"):
			setup()
	elif mode == MODE.CAMERA:
		if area.get_parent() == camera:
			setup()
	elif area.has_method("_checkpoint"):
		if area._checkpoint():
			setup()
