extends Gravity

export var speed :float = 100
enum DIR {LEFT = -1, RIGHT = 1}
export(DIR) var direction :int = 1
export var jump_height :float = 0
export var state :int = 1
export var force :bool = false
export var auto_mushroom :bool = true
export var mushroom :PackedScene
export var score: int = 1000
export var activate :bool = false
export var activate_range :float = 48
export var auto_destroy :bool = true
export var destroy_range :float = 48

onready var view: Node = Berry.get_view(self)

# 标识该物件可装入问号砖，并作出顶后的反应
func _item(dir :Vector2 = Vector2.UP) ->void:
	if state > 1 && auto_mushroom && Player.get_player_state_max() == 0:
		var new :Node = mushroom.instance()
		Berry.transform_copy(new,self)
		get_parent().add_child(new)
		new._item(dir)
		queue_free()
		return
	activate = true
	$Sprout.z_index = z_index
	z_index = get_parent().z_index + 1
	$Sprout.start(dir,get_parent().height)
	$AudioSprout.play()

# 检查是否在问号砖中
func is_in_block() ->bool:
	return get_parent().has_method("_block")
	
func _ready() ->void:
	$AreaShared.inherit(self)
	gravity_direction = gravity_direction.rotated(rotation)
	
func _physics_process(delta) ->void:
	if is_in_block():
		return
	
	# 激活
	if !activate:
		activate = view.is_in_view(position,activate_range*scale)
		return
	
	# 简单物理运动
	gravity_process(delta,$AreaShared/WaterDetect.is_in_water())
	var jump :float = sqrt(2*jump_height*gravity_acceleration)
	if enemy_movement(delta,speed*direction,jump):
		direction *= -1
		
	# 出界销毁
	if auto_destroy:
		var gdir :Vector2 = Berry.get_global_direction(self,gravity_direction)
		if !view.is_in_limit_direction(global_position,destroy_range*scale,gdir):
			queue_free()

func _on_AreaShared_area_entered(area :Area2D) ->void:
	if is_in_block() || !activate:
		return
	if area.has_method("_player"):
		$Get.get_bonus(area.get_parent())
