extends AreaExact

export var default_direction :Vector2 = Vector2.UP
export var default_range :float = 8
export var auto_hit_hidden :bool = true

# 顶砖块
func hit_block(inverse :bool = false, restrict :bool = false, attack :bool = false) ->bool:
	var r :bool = false
	var t :bool = false
	for i in get_overlapping_bodies():
		if i.has_method("_block"):
			t = i._block(inverse,restrict,attack)
			if !r && t:
				r = t
	return r

# 隐藏砖
func hit_block_hidden(direction :Vector2 = default_direction, hit_range :float = default_range, inverse :bool = false, restrict :bool = false, attack :bool = false) ->bool:
	var r :bool = false
	var t :bool = false
	for i in get_overlapping_bodies():
		if i.has_method("_block") && i.has_method("_hidden") && i._hidden():
			if hit_range <= 0 || !overlaps_exact(i,-hit_range*direction):
				t = i._block(inverse,restrict,attack)
				if !r && t:
					r = t
	return r

func _physics_process(_delta) ->void:
	if auto_hit_hidden:
		hit_block_hidden(default_direction,default_range)
