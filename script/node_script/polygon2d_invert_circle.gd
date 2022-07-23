extends Polygon2D

export var radius :float = 0

var rect :PoolVector2Array

onready var size :Vector2 = get_viewport_rect().size
onready var center :Vector2 = size/2
onready var max_radius :float = Vector2.ZERO.distance_to(center)

func _ready() ->void:
	rect.append(Vector2.ZERO)
	rect.append(Vector2(0,size.y))
	rect.append(size)
	rect.append(Vector2(size.x,0))

func _process(_delta) ->void:
	if !visible:
		return
	if radius > 0:
		polygon = get_circle_points(center,radius)
		invert_enable = true
		invert_border = max(size.x,size.y)*10
	else:
		polygon = rect
		invert_enable = false
	
func get_circle_points(pos :Vector2, r :float, maxerror :float = 0.25) ->PoolVector2Array:
	if r <= 0.0:
		return PoolVector2Array([])
	var maxpoints :int = 1024
	var numpoints :int = ceil(PI / acos(1.0 - maxerror / r)) as int
	numpoints = clamp(numpoints, 3, maxpoints) as int
	
	var points :PoolVector2Array = []
	
	for i in numpoints:
		var phi :float = i * PI * 2.0 / numpoints
		points.append(pos + r*Vector2(sin(phi), cos(phi)))
	return points
