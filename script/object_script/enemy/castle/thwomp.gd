extends Gravity

export var activate_range :Vector2 = Vector2(96,96)
export var smash_range :float = 64
export var raise_speed :float = 50
export var hit_block :bool = true
export var shake :bool = true
export var boom_res :PackedScene

onready var parent :Node = get_parent()
onready var view :Node = Berry.get_view(self)
onready var scene :Node = Berry.get_scene(self)
onready var origin_position :Vector2 = position

var state :int = 0
var hit_block_flag :bool = false
var delay :bool = false

export var brush_border :Rect2 = Rect2(-32,-33,64,66)
export var brush_offset :Vector2 = Vector2(16,18)
	
func _ready() ->void:
	gravity_direction = gravity_direction.rotated(rotation)
	$AreaShared.inherit(self)
	$HitBlock.default_direction = gravity_direction

func _physics_process(delta :float) ->void:
	# 停止
	if state == 0:
		if view.is_in_view(global_position,activate_range):
			var p: Node = scene.get_player_nearest(self)
			if smash_range > 0 && p != null:
				var p_pos :Vector2 = Berry.get_xform_position(self,p.global_position)
				var s :float = (position-p_pos).dot(gravity_direction.tangent())
				if abs(s) <= smash_range + 32*scale.x:
					state = 1
	
	# 下落
	if state == 1:
		if hit_block:
			$HitBlock.hit_block_hidden($HitBlock.default_direction, $HitBlock.default_range, true)
			if delay:
				$HitBlock.hit_block(true)
				hit_block_flag = true
				delay = false
				return
		gravity_process(delta,$AreaShared/WaterDetect.is_in_water())
		if !move_and_collide(gravity * delta*gravity_direction):
			hit_block_flag = false
		else:
			gravity = 0
			if !hit_block_flag && hit_block:
				delay = true
				return
			hit_block_flag = false
			state = 2
			$Timer.start()
			$Hit.play()
			if shake:
				var camera :Camera2D = view.get_current_camera()
				if camera != null:
					camera.shake_time = 0.15

			var gdir :Vector2 = Berry.get_global_direction(self,gravity_direction)
			var boom :Node = boom_res.instance()
			boom.get_node("SolidDetect").direction = gdir
			Berry.transform_copy(boom,self,$HitPos.relative())
			parent.add_child(boom)
			
			boom = boom_res.instance()
			boom.get_node("SolidDetect").direction = gdir
			Berry.transform_copy(boom,self,$HitPos.relative(true))
			parent.add_child(boom)
		
	# 上升	
	if state == 2 && $Timer.is_stopped():
		var gdir :Vector2 = Berry.get_global_direction(self,gravity_direction)
		var col :bool = move_and_collide(-raise_speed * delta*gdir) != null
		if col || position.distance_to(origin_position) <= raise_speed / 50:
			state = 0

func _on_Hurt_player_hurt() ->void:
	if $AnimatedSprite.animation != "laugh":
		$Laugh.play()
		$AnimatedSprite.animation = "laugh"
