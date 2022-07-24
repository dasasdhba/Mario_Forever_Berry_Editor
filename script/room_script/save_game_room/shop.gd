extends Node2D

export var fade_speed :float = 1
signal bonus_get(life)

var fade :bool = false
var sprite :Array

func _ready() ->void:
	sprite_add($MushroomRed/Sprite)
	sprite_add($FireFlower/AnimatedSprite)
	sprite_add($Beet/AnimatedSprite)
	sprite_add($Lui/AnimatedSprite)
	
func sprite_add(spr :Node) ->void:
	var new :Node = spr.duplicate()
	Berry.transform_copy(new,spr.get_parent())
	new.visible = false
	add_child(new)
	sprite.append(new)
	
func fade_ready() ->void:
	fade = true
	for i in get_children():
		if i.has_method("_item"):
			i.queue_free()
	for i in sprite:
		i.visible = true

func _physics_process(delta :float) ->void:
	if !fade:
		if !has_node("MushroomRed"):
			emit_signal("bonus_get",1)
			fade_ready()
		elif !has_node("FireFlower") || !has_node("Beet") || !has_node("Lui"):
			emit_signal("bonus_get",2)
			fade_ready()
	else:
		modulate.a -= fade_speed * delta
		if modulate.a <= 0:
			queue_free()
