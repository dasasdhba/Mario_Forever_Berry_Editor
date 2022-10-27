extends Area2D

enum MODE {PLAYER, CAMERA, CHECKPOINT}
export(MODE) var mode :int = MODE.PLAYER
enum BEHAVIOR {MOVE, STOP}
export(BEHAVIOR) var behavior :int = BEHAVIOR.MOVE
export var speed :float = 50
export var angle :float = 0
export var smooth_stop :bool = true
export var immediate :bool = false
export var position_override :bool = false
export var camera_position :Vector2 = Vector2.ZERO
export var once :bool = true

onready var view :Node = Berry.get_view(self)
onready var camera: Camera2D = view.get_current_camera()

func _ready():
	if !is_connected("area_entered",self,"on_area_entered"):
		connect("area_entered",self,"on_area_entered")

func setup() ->void:
	if camera == null:
		return
	if behavior == BEHAVIOR.STOP:
		camera.mode = camera.MODE.FOLLOW
		camera.limit_smoothed = smooth_stop
		if smooth_stop && !camera.smoothing_enabled:
			camera.smoothing_enabled = true
			camera.smooth_limit = true
	else:
		camera.force_speed = speed
		camera.force_angle = angle
		camera.mode = camera.MODE.FORCE
		if position_override:
			camera.global_position = camera_position
		if immediate:
			camera.force_center()
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
