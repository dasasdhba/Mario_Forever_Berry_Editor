tool
extends StaticBody2D

export var flip :bool = false
export var launch_time_first :float = 0.5
export var launch_time :float = 1.5
export var launch_time_random :float = 3
export var launch_range :float = 64
export var activate_range :float = 32
export var bullet_res :PackedScene

var timer :float = 0
var total :float = 0

var parent :Node
var view :Node
var scene :Node
var rand :RandomNumberGenerator

func _ready() ->void:
	if Engine.editor_hint:
		return
	$Sprite.flip_v = flip
	total = launch_time_first
	parent = get_parent()
	view = Berry.get_view(self)
	scene = Berry.get_scene(self)
	rand = Berry.get_rand(self)
	
func _physics_process(delta :float) ->void:
	if Engine.editor_hint:
		$Sprite.flip_v = flip
		return
	
	if !view.is_in_view(global_position,activate_range*scale):
		return
		
	var count :bool = true
	var p: Node = scene.get_player_nearest(self)
	if timer < total && p != null:
		var p_pos :Vector2 = Berry.get_xform_position(self,p.global_position)
		var s :float = (position-p_pos).dot(Vector2.RIGHT.rotated(rotation))
		if abs(s) <= launch_range + 16*scale.x:
			count = false
			
	if count:
		timer += delta
		
	if timer >= total && p != null:
		timer = 0
		total = launch_time + rand.randf_range(0,launch_time_random)
		
		var new :Node = bullet_res.instance()
		Berry.transform_copy(new,self)
		var dir :int = -1
		var p_pos :Vector2 = Berry.get_xform_position(self,p.global_position)
		if position.direction_to(p_pos).dot((Vector2.DOWN.rotated(rotation)).tangent()) > 0:
			dir = 1
		new.direction = dir
		new.activate = true
		new.layer_adjust = true
		new.z_index = z_index - 1
		parent.add_child(new)
		
		var boom :Node = Lib.boom.instance()
		Berry.transform_copy(boom,self,$LaunchPoint.relative(dir == -1))
		parent.add_child(boom)
		
		$Sound.play()
