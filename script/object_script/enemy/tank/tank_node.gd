extends TileMap

export var wait_time :float = 3
export var speed :float = 50
export var angle :float = 180
export var length :float = 10016

var end :bool = false
var checkpoint :bool = false
var origin_position :Vector2

onready var scene :Node = Berry.get_scene(self)
onready var track :AnimatedTexture = tile_set.tile_get_texture(tile_set.find_tile_by_name("tile_tank_track.tres 5"))

# 用于标识
func _tank_node() ->void:
	pass

func _ready() ->void:
	if checkpoint:
		return
	origin_position = position
	$Timer.wait_time = wait_time
	$Timer.start()
	
func _physics_process(delta) ->void:
	if !$Timer.is_stopped() || end:
		if !track.pause:
			track.pause = true
		return
	if track.pause:
		track.pause = false
	
	# 坦克滚屏惯性
	for i in scene.current_player:
		if i.on_floor_snap:
			var area :Area2D = i.get_node("AreaShared")
			var on_tank :bool = true
			for j in area.get_overlapping_areas():
				if j.has_method("_tank"):
					on_tank = false
			i.on_tank = on_tank
		var parent :Node = i.get_parent()
		if i.on_tank:
			if parent != self:
				parent.remove_child(i)
				add_child(i)
				i.position += parent.global_position - global_position
		elif parent == self:
			remove_child(i)
			var out :Node = get_parent()
			out.add_child(i)
			out.move_child(i,get_index()+1)
			i.position += global_position - out.global_position
	
	# 运动
	position += speed * Berry.vector2_rotate_degree(angle) * delta
	if position.distance_to(origin_position) >= length:
		position = origin_position + length * Berry.vector2_rotate_degree(angle)
		end = true
