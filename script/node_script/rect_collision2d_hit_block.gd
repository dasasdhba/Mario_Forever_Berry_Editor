extends RectCollision2D

export var default_direction :Vector2 = Vector2.UP
export var default_range :float = 8
export var auto_hit_hidden :bool = true

# 顶砖块
func hit_block(inverse :bool = false, restrict :bool = false, attack :bool = false) ->bool:
	var r :bool = false
	var t :bool = false
	for i in get_overlapping_rect("block"):
		var j: Node = i.get_parent()
		if j.has_method("_block"):
			t = j._block(inverse,restrict,attack)
			if !r && t:
				r = t
	return r

# 隐藏砖
func hit_block_hidden(direction :Vector2 = default_direction, hit_range :float = default_range, inverse :bool = false, restrict :bool = false, attack :bool = false) ->bool:
	var arr: Array = []
	for i in get_overlapping_rect("block"):
		var j: Node = i.get_parent()
		if j.has_method("_hidden") && j._hidden():
			arr.append(j)

	if arr.empty():
		return false

	var r :bool = false
	if hit_range <= 0:
		for i in arr:
			i._block(inverse,restrict,attack)
			r = true
		arr.clear()
		return r

	var newarr :Array = []
	for i in get_overlapping_rect("block",-hit_range*direction):
		var j: Node = i.get_parent()
		if j.has_method("_hidden") && j._hidden():
			newarr.append(j)
	
	for i in arr:
		if !newarr.has(i):
			i._block(inverse,restrict,attack)
			r = true
	
	newarr.clear()		
	arr.clear()
	return r

func _physics_process(_delta) ->void:
	if auto_hit_hidden:
		hit_block_hidden(default_direction,default_range)
