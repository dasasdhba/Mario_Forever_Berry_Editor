tool
extends Area2D

export var size :Vector2 = Vector2(128,256)
export var horizontal_speed :float = 100
export var vertical_speed :float = 50
export var bubble_number :int = 16
export var bubble_speed :float = 100
export var bubble_time :float = 3

func _ready() ->void:
	if Engine.editor_hint:
		return
	particle_setup()
	$CollisionShape2D.shape.extents = size/2

func _physics_process(delta) ->void:
	if Engine.editor_hint:
		particle_setup()
		return
	for i in get_overlapping_areas():
		if i.has_method("_player"):
			var p :Node = i.get_parent()
			if p.water && p.pipe == 0:
				p.position += vertical_speed*Vector2.DOWN.rotated(rotation) * delta
				var p_pos :Vector2 = get_parent().global_transform.xform_inv(p.global_position)
				var hdir :Vector2 = Vector2.RIGHT.rotated(rotation)
				var d :float = (position - p_pos).dot(hdir)
				if abs(d) >= horizontal_speed * delta:
					var dir :Vector2 = sign(d)*hdir
					p.position += horizontal_speed*dir * delta
		
func particle_setup() ->void:
	$Particles2D.visibility_rect = Rect2(Vector2(-size.x/2,0),size)
	$Particles2D.position = Vector2(0,-size.y/2)
	if $Particles2D.amount != bubble_number:
		$Particles2D.amount = bubble_number
	$Particles2D.lifetime = bubble_time
	var material :ParticlesMaterial = $Particles2D.process_material
	material.initial_velocity = bubble_speed
	material.emission_box_extents = Vector3(size.x/2,0,1)
