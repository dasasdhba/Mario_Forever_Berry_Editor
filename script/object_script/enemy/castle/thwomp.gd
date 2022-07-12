extends Gravity

export var activate_range :Vector2 = Vector2(96,96)
export var smash_range :float = 64
export var raise_speed :float = 50
export var hit_block :bool = true
export var shake :bool = true
export var boom_res :PackedScene

onready var parent :Node = get_parent()
onready var view :Node = Berry.get_view(self)
onready var origin_position :Vector2 = position

var state :int = 0
var delay :bool = false

export var brush_border :Rect2 = Rect2(-32,-48,64,96)
export var brush_offset :Vector2 = Vector2(16,18)

# 用于标识 brush2d 摆放
func _brush() ->void:
	pass
	
func _ready() ->void:
	gravity_direction = gravity_direction.rotated(rotation)
	$AreaShared.inherit(self)
	$RectHitBlock.default_direction = gravity_direction

func _physics_process(delta :float) ->void:
	# 停止
	if state == 0:
		if view.is_in_view(global_position,activate_range):
			var p: Node = Berry.get_player_nearest(self)
			if smash_range > 0 && p != null:
				var p_pos :Vector2 = parent.global_transform.xform_inv(p.global_position)
				var s :float = Berry.distance_to_line(position,p_pos,gravity_direction.angle())
				if s <= smash_range + 32*scale.x:
					state = 1
	
	# 下落
	if state == 1:
		if !delay:
			gravity_process(delta,$AreaShared/WaterDetect.is_in_water())
		if hit_block:
			$RectHitBlock.hit_block_hidden($RectHitBlock.default_direction, $RectHitBlock.default_range, true)
		delay = false
		if move_and_collide(gravity * delta*gravity_direction):
			if hit_block && gravity > 0:
				if $RectHitBlock.hit_block(true):
					delay = true
			if !delay:
				state = 2
				$Timer.start()
				$Hit.play()
				if shake:
					var camera :Camera2D = view.get_current_camera()
					if camera != null:
						camera.shake_time = 0.15
				
			gravity = 0
			
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
