tool
extends StaticBody2D

export var flip :bool = false
export var first_time :float = 0
export var wait_time :float = 4
export var number :int = 20
export var launch_interval :float = 0.04
export var speed :float = 312.5
export var gravity :float = 0
export var activate_range :Vector2 = Vector2(32,32)
export var popcorn :PackedScene

var timer :float = 0
var count :int = 0
var first :bool = false
var launch :bool = false

var view :Node
var parent :Node
var dir :int = -1

export var brush_border :Rect2 = Rect2(-16,-16,32,32)
export var brush_offset :Vector2 = Vector2(16,16)

func _ready() ->void:
	if !Engine.editor_hint:
		view = Berry.get_view(self)
		parent = get_parent()
		$Sprite.flip_h = flip
		if flip:
			dir = 1
		
func _physics_process(delta) ->void:
	if Engine.editor_hint:
		$Sprite.flip_h = flip
		return
	if !view.is_in_view(global_position,activate_range*scale):
		return
	if !launch:
		timer += delta
		if !first:
			if timer >= first_time:
				first = true
				timer = 0
				launch = true
				$Launch.play()
		elif timer >= wait_time:
			timer = 0
			launch = true
			$Launch.play()
	else:
		timer += delta
		if timer >= launch_interval:
			timer = 0
			var new :Node = popcorn.instance()
			Berry.transform_copy(new,self,$LaunchPos.relative(flip))
			new.gravity_direction = Vector2.DOWN.rotated(rotation)
			new.speed = speed*dir
			new.gravity = gravity
			parent.add_child(new)
			parent.move_child(new,get_index()-1)
			count += 1
		if count >= number:
			count = 0
			launch = false
