extends Node

onready var parent :Area2D = get_parent()
onready var root: Node = parent.get_parent()
onready var stomp :RectCollision2D = parent.get_node("Stomped")
onready var turn: Node = parent.get_node("Turn")
onready var atk: Node = parent.get_node("Attacked")

func _physics_process(_delta):
	if root.speed == 0:
		if stomp.attack > 0:
			stomp.attack *= -1
		atk.shell_attack = false
		atk.atk_count = 0
		turn.disabled = false
		parent.enemy_turn = true
		if !stomp.get_node("Timer").is_stopped():
			return
		for i in parent.get_overlapping_areas():
			if i.has_method("_player"):
				$Kick.play()
				root.speed = root.shell_speed
				stomp.delay(0.2)
				var p: Node = i.get_parent()
				if root.position.direction_to(p.position).dot(root.gravity_direction.tangent()) > 0:
					root.direction = -1
				else:
					root.direction = 1
				break
	else:
		if stomp.attack < 0:
			stomp.attack *= -1
		atk.shell_attack = true
		turn.disabled = true
		parent.enemy_turn = false
