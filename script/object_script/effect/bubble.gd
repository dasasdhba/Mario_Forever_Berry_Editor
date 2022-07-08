extends Node2D

var direction :Vector2 = Vector2.UP
onready var rand :RandomNumberGenerator = Berry.get_rand(self)

func _process(delta) ->void:
	# 透明度
	modulate.a -= 0.4 * delta
	if modulate.a <= 0:
		queue_free()

func _physics_process(delta) ->void:
	# 运动与出水破裂
	position += 50*((rand.randi() % 3)*direction + ((rand.randi() % 3)-1)*direction.tangent()) * delta
	if !has_node("AnimatedSprite"):
		queue_free()
	else:
		if !$Area2D/WaterDetect.is_in_water():
			$AnimatedSprite.play()
		else:
			$AnimatedSprite.stop()
			$AnimatedSprite.frame = 0
		
