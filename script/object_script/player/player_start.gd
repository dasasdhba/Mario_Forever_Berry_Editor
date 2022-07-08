# 初始化玩家
extends Node2D

export var player :String = "PlayerMario"
enum DIR {LEFT = -1, RIGHT = 1}
export(DIR) var direction :int = 1

func _physics_process(delta) ->void:
	if !Player.has_node(player):
		queue_free()
	var p :Node = Player.recover(player,get_parent())
	Berry.transform_copy(p,self)
	p.gravity_direction = p.gravity_direction.rotated(rotation)
	p.move_direction = direction
	p.animated_node.flip_h = direction == -1
	var scene :Node = Berry.get_scene(self)
	if !scene.current_player.has(p):
		scene.current_player.append(p)
	if scene.checkpoint_position is Vector2:
		p.global_position = scene.checkpoint_position
		scene.checkpoint_position = 0
	var camera :Camera2D = Berry.get_view(self).get_current_camera()
	if camera != null:
		camera.camera_event(delta)
	queue_free()
