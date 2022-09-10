extends AnimatedSprite

export var start_index :int = 0
export var speed_normal :float = 50
export var speed_max :float = 400

var once :bool = false
var speed :float = 0
var dir :Vector2 = Vector2.RIGHT
var acc :bool = false # 加速
var finish :bool = false

signal player_finish

onready var room :Room2D = Berry.get_room2d(self)

func player_init() ->void:
	var ready :bool = false
	var first :Node = null
	for i in get_tree().get_nodes_in_group("_rect_col2d_path_node"):
		if i.index > start_index:
			i.visible = false
		else:
			i.visible = true
		if i.type == i.TYPE.LEVEL && i.index == start_index:
			ready = true
			global_position = i.global_position
			dir = Berry.vector2_rotate_degree(90*i.dir)
			if i.player_ani == i.ANI.SWIM:
				animation = "swim"
		if i.first:
			first = i
	if !ready && first != null:
		global_position = first.global_position
		dir = Berry.vector2_rotate_degree(90*first.dir)
		if first.player_ani == first.ANI.SWIM:
			animation = "swim"
		
func is_over_path(path :Node) ->bool:
	if dir == Vector2.RIGHT:
		if global_position.x >= path.global_position.x:
			return true
	elif dir == Vector2.LEFT:
		if global_position.x <= path.global_position.x:
			return true
	elif dir == Vector2.DOWN:
		if global_position.y >= path.global_position.y:
			return true
	elif global_position.y <= path.global_position.y:
		return true
	return false
	
func check_path() ->void:
	for i in $RectCollision2D.get_overlapping_rect("path_node"):
		if !i.visible && is_over_path(i):
			i.visible = true
			if i.player_ani == i.ANI.SWIM:
				animation = "swim"
			elif i.player_ani == i.ANI.WALK:
				animation = "walk"
			if i.type == i.TYPE.PATH:
				var new_dir :Vector2 = Berry.vector2_rotate_degree(90*i.dir)
				if dir != new_dir:
					global_position = i.global_position
					dir = new_dir
			else:
				global_position = i.global_position
				finish = true
				emit_signal("player_finish")
				return

func _physics_process(delta :float) ->void:
	if !once:
		player_init()
		once = true
	if !acc:
		if room.mobile:
			acc = Input.is_mouse_button_pressed(BUTTON_LEFT)
		else:
			acc = Input.is_action_pressed("ui_jump")
	if !finish:
		speed = speed_max if acc else speed_normal
		position += speed*dir * delta
		check_path()
	if dir == Vector2.RIGHT:
		flip_h = false
	elif dir == Vector2.LEFT:
		flip_h = true
