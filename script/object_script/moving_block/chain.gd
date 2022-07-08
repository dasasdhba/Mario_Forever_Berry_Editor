extends StaticBody2D

enum TYPE {HEAD, BODY, TAIL}
enum MODE {AUTOMATIC, PLAYER_STAND_ON}
enum DIR {RIGHT,DOWN,LEFT,UP}

export(TYPE) var type :int = TYPE.HEAD
export var generate :bool = true
export var number :int = 5
export(MODE) var mode :int = MODE.PLAYER_STAND_ON
export var speed :float = 50
export(DIR) var direction :int = DIR.RIGHT
export var gravity_direction :int = DIR.DOWN

var activate :bool = false
var head :StaticBody2D

var last_pos :Vector2
var origin_pos :Vector2
var origin_dir :int
var first_chain :StaticBody2D
var tail :StaticBody2D = null
var count :int = 0

# 用于标识
func _chain() ->int:
	return type

func _ready() ->void:
	$AreaShared.inherit(self)
	if type == TYPE.HEAD:
		last_pos = position
		origin_pos = position
		origin_dir = direction
	elif type == TYPE.TAIL:
		$AudioChain.queue_free()
	else:
		$OnScreen.queue_free()
		$AudioChain.queue_free()
	
# head 初始化
func setup() ->void:
	if type != TYPE.HEAD:
		return
	activate = true
	head = self
	var parent :Node = get_parent()
	
	# 非创建模式
	if !generate:
		number = 1
		for i in get_children():
			if i.has_method("_chain") && i._chain() != TYPE.HEAD:
				number += 1
				i.activate = true
				i.head = self
				Berry.transform_copy(i,self,i.position)
				remove_child(i)
				parent.add_child(i)
				parent.move_child(i,get_index() + (i.type == TYPE.TAIL) as int)
				if i.type == TYPE.TAIL:
					tail = i
	
	# 创建第一个 Chain
	var new :StaticBody2D = duplicate(DUPLICATE_USE_INSTANCING)
	new.type = TYPE.BODY
	new.position = position
	new.direction = direction
	new.activate = true
	new.head = self
	parent.add_child(new)
	parent.move_child(new,get_index())
	first_chain = new

# head 创建链条
func create_chain(force :bool = false, t :int = TYPE.BODY, pos :Vector2 = position, dir :int = direction) ->bool:
	if type != TYPE.HEAD:
		return false
	var unit :Vector2 = $Sprite.texture.get_size()
	var d :float
	if direction == DIR.LEFT || direction == DIR.RIGHT:
		d = unit.x
	else:
		d = unit.y
	if last_pos.distance_to(position) >= d || force:
		var new :StaticBody2D = duplicate(DUPLICATE_USE_INSTANCING)
		new.type = t
		var delta_pos :Vector2 = pos - origin_pos
		var new_pos :Vector2 = origin_pos + Vector2(round(delta_pos.x/unit.x)*unit.x,round(delta_pos.y/unit.y)*unit.y)
		new.position = new_pos
		last_pos = new_pos
		new.direction = dir
		new.activate = true
		new.head = self
		var parent :Node = get_parent()
		parent.add_child(new)
		parent.move_child(new,get_index() + (new.type == TYPE.TAIL) as int)
		if t == TYPE.TAIL:
			tail = new
		return true
	return false
	
# tail 销毁链条
func destroy_chain() ->void:
	if type != TYPE.TAIL:
		return
	for i in $AreaShared.get_overlapping_areas():
		var p :Node = i.get_parent()
		if p.has_method("_chain") && p._chain() == TYPE.BODY && p.head == head && p.direction == direction:
			var destroy :bool = false
			if direction == DIR.RIGHT:
				if position.x >= p.position.x:
					destroy = true
			elif direction == DIR.LEFT:
				if position.x <= p.position.x:
					destroy = true
			elif direction == DIR.UP:
				if position.y <= p.position.y:
					destroy = true
			elif position.y >= p.position.y:
				destroy = true
			if destroy:
				p.queue_free()
	
func _physics_process(delta) ->void:
	if !activate:
		if mode == MODE.PLAYER_STAND_ON:
			for i in $AreaShared.get_overlapping_areas():
				if i.has_method("_player_bottom") && i.get_parent().is_on_floor():
					activate = true
					break
		else:
			activate = true
		if activate:
			if type != TYPE.HEAD:
				var parent: Node = get_parent()
				if parent.has_method("_chain") && parent._chain() == TYPE.HEAD:
					parent.setup()
				else:
					queue_free()
			else:
				setup()
		return
	
	if type == TYPE.BODY:
		return
	else:
		var delta_pos :Vector2 = -position
		var velocity :Vector2 = speed * Berry.vector2_rotate_degree(90*direction)
		position += velocity * delta
	
		if type == TYPE.HEAD:
			# 创建链条
			if generate:
				if count < max(0,number-2):
					if create_chain():
						count += 1
				elif create_chain(false,TYPE.TAIL,origin_pos,origin_dir):
					first_chain.queue_free()
					create_chain(true)
					generate = false
			else:
				create_chain()
			
			# 音效
			if $OnScreen.is_on_screen():
				if !$AudioChain.playing:
					$AudioChain.play()
			elif tail.get_node("OnScreen").is_on_screen() && $AudioChain.playing:
				$AudioChain.stop()
		else:
			# 销毁链条
			destroy_chain()
			
			# 音效
			if $OnScreen.is_on_screen() && !head.get_node("AudioChain").playing:
				head.get_node("AudioChain").play()
		
		# 转向
		for i in $AreaShared.get_overlapping_areas():
			if i.has_method("_chain_direction"):
				var i_pos :Vector2 = get_parent().global_transform.xform_inv(i.global_position)
				if position.distance_to(i_pos) <= speed * delta:
					var r :float = Berry.mod_range(i.rotation_degrees,0,360)
					if direction != round(r/90):
						position = i_pos
						direction = round(r/90) as int
		
		delta_pos += position
		collision_fix(delta_pos)

func collision_fix(velocity :Vector2 = Vector2.ZERO) ->void:
	if gravity_direction == DIR.UP || gravity_direction == DIR.DOWN:
		constant_linear_velocity = Vector2(0,velocity.y)
	else:
		constant_linear_velocity = Vector2(velocity.x,0)
