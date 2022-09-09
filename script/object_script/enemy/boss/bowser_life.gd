extends Node

export var health :int = 5
export var hit_count :int = 5
export var invincible_time :float = 2
export var score :int = 10000
export var death_res :PackedScene

var hit_counter :int = 0
var invincible :bool = false
var i_timer :float = 0

onready var parent :Node = get_parent()
onready var anim :AnimatedSprite = parent.get_node("AnimatedSprite")
onready var attacked :Node = parent.get_node("AreaShared/Attacked")
onready var stomped :RectCollision2D = parent.get_node("AreaShared/Stomped")

func _physics_process(delta :float) ->void:
	if invincible:
		i_timer += delta
		anim.modulate.a = 1 - 0.3*(1-cos(deg2rad(750*i_timer)))
		if i_timer >= invincible_time:
			i_timer = 0
			invincible = false
			anim.modulate.a = 1
			attacked.disabled = false
			stomped.height = 16

func hurt() ->void:
	hit_counter = 0
	health -= 1
	if health <= 0:
		death()
	else:
		$Hurt.play()
		invincible = true
		attacked.disabled = true
		stomped.height = 0
		
func death() ->void:
	Audio.play($Death)
	
	var new :Node = death_res.instance()
	Berry.transform_copy(new,parent)
	new.get_node("AnimatedSprite").flip_h = anim.flip_h
	
	var s :Node = Lib.score.instance()
	s.score = score
	s.position = parent.position
	
	var root :Node = parent.get_parent()
	root.add_child(new)
	root.add_child(s)
	
	parent.queue_free()

func _on_Attacked_attacked(atk :Array) ->void:
	if atk[0] == "stomp":
		hurt()
		return
	hit_counter += 1
	if hit_counter >= hit_count:
		hurt()
