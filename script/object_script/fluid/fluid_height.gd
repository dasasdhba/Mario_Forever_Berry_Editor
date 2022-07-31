tool
extends Area2D

enum MODE {WATER, LAVA}
export var fluid_path :NodePath = @"" # 为空则在 room 的 node_array 查找
export(MODE) var mode :int = MODE.WATER
export var height :float = 0
export var speed :float = 50
export var instant: bool = false
export var preview :bool = true
export var preview_color :Color = Color(1,0,1,0.7)

var target :Area2D
var once :bool = false

export var brush_border :Rect2 = Rect2(0,0,32,32)
export var brush_offset :Vector2 = Vector2(0,0)

func _ready() ->void:
	if Engine.editor_hint:
		return
	if !is_connected("area_entered",self,"on_area_entered"):
		connect("area_entered",self,"on_area_entered")
	if mode == MODE.WATER:
		$Lava.queue_free()
	else:
		$Tide.queue_free()
	if !fluid_path.is_empty():
		var fluid :Node = get_node(fluid_path)
		if mode == MODE.WATER:
			if fluid.has_method("_water_auto"):
				target = fluid
				once = true
		elif fluid.has_method("_lava_auto"):
			target = fluid
			once = true

func _physics_process(_delta) ->void:
	if Engine.editor_hint:
		$AnimatedSprite.frame = mode
		update()
		return
	if once:
		return
	once = true
	var room :Room2D = Berry.get_room2d(self)
	if room == null || room.node_array.empty():
		queue_free()
	for i in room.node_array:
		if mode == MODE.WATER:
			if i.has_method("_water_auto"):
				target = i
				break
		elif i.has_method("_lava_auto"):
			target = i
			break
	if target == null:
		queue_free()

func on_area_entered(area :Area2D) ->void:
	if target == null:
		return
	if area.has_method("_player"):
		if instant:
			target.position.y = height
			target.height = height
			target.target_height = height
		elif target.target_height != height:
			target.target_height = height
			if mode == MODE.WATER:
				$Tide.play()
			else:
				$Lava.play()
			
func _draw() ->void:
	if !preview || !Engine.editor_hint:
		return
	var y :float = height-global_position.y
	draw_set_transform(Vector2.ZERO,-rotation,Vector2(1/scale.x,1/scale.y))
	draw_line(Vector2(16,16),Vector2(16,y+((y < 0) as int)*32),preview_color,2)
	draw_rect(Rect2(0,y,32,32),preview_color)
	draw_set_transform(Vector2.ZERO,0,Vector2.ONE)
