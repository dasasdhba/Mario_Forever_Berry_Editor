# 不支持旋转
tool
extends StaticBody2D

export var flip :bool = false
export var first_time :float = 0
export var wait_time :float = 3
export var launch_interval :float = 0.04
export var speed_max :float = 100
export var gravity_up :float = 400
export var gravity_random :float = 150
export var activate_range :Vector2 = Vector2(64,64)
export var gear :PackedScene

var timer :float = 0
var first :bool = false

var view :Node
var parent :Node
var rand :RandomNumberGenerator

export var brush_border :Rect2 = Rect2(-16,-16,32,32)
export var brush_offset :Vector2 = Vector2(16,16)

# 用于标识 brush2d 摆放
func _brush() ->void:
	pass

func _ready() ->void:
	if !Engine.editor_hint:
		view = Berry.get_view(self)
		parent = get_parent()
		rand = Berry.get_rand(self)
		$Sprite.flip_v = flip
		
func _physics_process(delta) ->void:
	if Engine.editor_hint:
		$Sprite.flip_v = flip
		return
	if !view.is_in_view(global_position,activate_range*scale):
		return
	timer += delta
	if !first:
		if timer >= first_time:
			first = true
			timer = 0
			launch()
	elif timer >= wait_time:
		timer = 0
		launch()

func launch() ->void:
	$Launch.play()
	var boom :Node = Lib.boom.instance()
	Berry.transform_copy(boom,self,$LaunchPos.relative(false,flip))
	parent.add_child(boom)
	var new :Node = gear.instance()
	Berry.transform_copy(new,self,$LaunchPos.relative(false,flip))
	new.gravity_direction = Vector2.DOWN.rotated(rotation)
	new.speed = rand.randf_range(-speed_max,speed_max)
	if !flip:
		new.gravity = -(gravity_up + rand.randf()*gravity_random)
	parent.add_child(new)
