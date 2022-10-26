# 需要设置父节点为 enemy_area，敌人需要有 delta_position 用于防误判
extends Node

export var height :float = 16 # 踩判定高度
export var attack :int = 1
export var force :bool = false
export var delay_time :float = 0.2 # 两次判定的间隔
export var root_layer :int = 2

onready var parent: Area2D = get_parent()
onready var root :Node = Berry.get_parent_ext(self,root_layer)

func delay(time :float) ->void:
	$Timer.wait_time = time
	$Timer.start()

func stomp_detect(player_area :AreaExact) ->void:
	if !$Timer.is_stopped():
		return
	var p: Node = player_area.get_parent()
	if height <= 0:
		if attack > 0:
			p.player_hurt(attack,force)
		return
	if (p.delta_position-root.delta_position).dot(p.gravity_direction) < 0:
		if attack > 0:
			p.player_hurt(attack,force)
		return
	else:
		var delta_pos :Vector2 = p.gravity_direction*(height - root.delta_position.dot(p.gravity_direction) + p.delta_position.dot(p.gravity_direction))
		if player_area.overlaps_exact(parent,-delta_pos):
			if attack > 0:
				p.player_hurt(attack,force)
			return
		parent.attacked.append(["stomp",p])
		parent.get_node("Attacked").def_process()
		if delay_time > 0:
			delay(delay_time)
