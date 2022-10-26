extends Area2D
class_name AreaExact, "icon/area_exact.png"

# 为了方便起见，不考虑 collision_mask 和 collision_layer
func overlaps_exact(col :CollisionObject2D, delta_pos :Vector2 = Vector2.ZERO) ->bool:
	for i in get_shape_owners():
		var i_owner :Node2D = shape_owner_get_owner(i)
		if i_owner.disabled:
			continue
		var i_trans :Transform2D = i_owner.global_transform
		i_trans.origin += Berry.get_global_position(self,delta_pos)
		for j in col.get_shape_owners():
			var j_owner :Node2D = col.shape_owner_get_owner(j)
			if j_owner.disabled:
				continue
			for k in shape_owner_get_shape_count(i):
				var i_shape :Shape2D = shape_owner_get_shape(i,k)
				for l in col.shape_owner_get_shape_count(j):
					var j_shape :Shape2D = col.shape_owner_get_shape(j,l)
					if i_shape.collide(i_trans,j_shape,j_owner.global_transform):
						return true
	return false
