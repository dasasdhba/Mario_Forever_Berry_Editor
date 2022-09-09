extends Sprite

export var draw_offset :Vector2 = Vector2(-42,-14)
export var hp :int = 5
export var first_hp :int = 20
export var line_min_count :int = 10
export var hp_tex :Texture
export var hp_tex_thick :Texture

export var alpha_min :float = 0.5
export var alpha_max :float = 1
export var alpha_speed :float = 3

var adjust :bool = false
var line_count :int = 0

onready var col :CollisionShape2D = $Area2D/CollisionShape2D
onready var extents_x_origin :float = col.shape.extents.x
onready var sep :float = hp_tex.get_width()

func _draw() ->void:
	if hp <= 0:
		return
	if hp <= line_count:
		for i in hp:
			draw_texture(hp_tex,draw_offset+i*sep*Vector2.LEFT)
	else:
		for i in line_count:
			var tex :Texture = hp_tex if i >= hp-line_count else hp_tex_thick
			draw_texture(tex,draw_offset+i*sep*Vector2.LEFT)
	
func _process(delta) ->void:
	if !adjust:
		if modulate.a < alpha_max:
			modulate.a += alpha_speed * delta
		else:
			modulate.a = alpha_max
	else:
		if modulate.a > alpha_min:
			modulate.a -= alpha_speed * delta
		else:
			modulate.a = alpha_min

func _physics_process(_delta) ->void:
	line_count = max(ceil(first_hp/2.0),line_min_count) as int
	update()
	
	var width :float = hp*sep if hp <= line_count else line_count*sep
	col.shape.extents.x = extents_x_origin + width/2
	col.position.x = -width/2
	
	adjust = false
	for i in $Area2D.get_overlapping_areas():
		if i.has_method("_player"):
			adjust = true
			break
