extends Node2D

export var score :int = 100
var direction :Vector2 = Vector2.UP
const jump :float = 250.0 # 动画跃起速度
const deceleration :float = 500.0 # 减速度

onready var velocity = jump*direction

func _physics_process(delta):
	position += velocity * delta
	velocity -= deceleration*direction * delta

func _on_AnimatedSprite_animation_finished():
	var new :Node2D = Lib.score.instance()
	new.position = position
	new.score = score
	get_parent().add_child(new)
	queue_free()
