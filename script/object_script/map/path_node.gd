tool
extends RectCollision2D

enum TYPE {PATH, LEVEL}
enum DIR {RIGHT, DOWN, LEFT, UP, AUTOMATIC}
enum ANI {NONE, WALK, SWIM}
export var first :bool = false # 起点
export(TYPE) var type :int = TYPE.PATH
export(DIR) var dir :int = DIR.AUTOMATIC
export(ANI) var player_ani :int = ANI.NONE

var index :int = 1
var once :bool = false

export var brush_border :Rect2 = Rect2(-8,-8,16,16)
export var brush_offset :Vector2 = Vector2(0,0)

# 用于标识 brush2d 摆放
func _brush() ->void:
	pass

func _ready() ->void:
	if Engine.editor_hint:
		return
	rect_init()
	$Path.visible = type == TYPE.PATH
	$Level.visible = type == TYPE.LEVEL
	visible = false

func _physics_process(_delta) ->void:
	if Engine.editor_hint:
		$Path.visible = type == TYPE.PATH
		$Level.visible = type == TYPE.LEVEL
		$Path/First.visible = first
		$Arrow.visible = dir != DIR.AUTOMATIC
		if $Arrow.visible:
			$Arrow.rotation = dir*PI/2
		return
		
	# 初始化
	if first && !once:
		get_direction()
		once = true
	
func get_path_node(direction :int) ->Node:
	var array :Array = get_overlapping_rect("path_node", 8*Berry.vector2_rotate_degree(90*direction))
	if array.empty():
		return null
	return array.back()
	
func set_index(path :Node) ->void:
	if type == TYPE.PATH:
		path.index = index
	else:
		path.index = index + 1

func get_direction() ->int:
	if dir == DIR.AUTOMATIC:
		var up :Node = get_path_node(DIR.UP)
		var down :Node = get_path_node(DIR.DOWN)
		var left :Node = get_path_node(DIR.LEFT)
		var right :Node = get_path_node(DIR.RIGHT)
		
		if right != null && right.dir != DIR.LEFT:
			dir = DIR.RIGHT
			set_index(right)
			right.get_direction()
			return dir
		if up != null && up.dir != DIR.DOWN:
			dir = DIR.UP
			set_index(up)
			up.get_direction()
			return dir
		if down != null && down.dir != DIR.UP:
			dir = DIR.DOWN
			set_index(down)
			down.get_direction()
			return dir
		if left != null && left.dir != DIR.RIGHT:
			dir = DIR.LEFT
			set_index(left)
			left.get_direction()
			return dir
	else:
		var another :Node = get_path_node(dir)
		if another != null:
			set_index(another)
			another.get_direction()
	return dir
