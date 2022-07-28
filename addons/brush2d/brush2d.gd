tool
extends Node2D
class_name Brush2D, "icon.png"

export var grid: Vector2 = Vector2(16,16)
export var default_border :Rect2 = Rect2(-16,-16,32,32)
export var default_offset :Vector2 = Vector2(16,16)
export var force_border :bool = false
export var force_offset :bool = false

export var preview :bool = true
export var preview_alpha :float = 0.5
export var preview_border :bool = true
export var border_color :Color = Color(0.9,0.4,0.3,0.7)

export var paint_button :int = BUTTON_LEFT
export var erase_button :int = BUTTON_RIGHT
export var copy_key :int = KEY_C
export var cut_key :int = KEY_X
export var click_restrict_key : int = KEY_SHIFT
export var click_only :bool = true

var working :bool = false

var border :Rect2
var offset :Vector2

var copy_list :Array = []
var paint_restrict :bool = false
var erase_restrict :bool = false
var copy_restrict :bool = false
var cut_restrict :bool = false

var preview_res :Resource = null
var preview_node :Node
var preview_list :Array
var preview_rect :Rect2 = Rect2(Vector2.ZERO,Vector2.ZERO)

var brush_last = null
var mouse_last :Vector2 = Vector2(INF,INF)

func get_brush(node :Node) ->void:
	if !force_border && node.get("brush_border") != null:
		border = node.brush_border
		border.position.x *= node.scale.x
		border.position.y *= node.scale.y
		border.end.x *= node.scale.x
		border.end.y *= node.scale.y
		if node.rotation != 0:
			var tl :Vector2 = border.position.rotated(rotation)
			var tr: Vector2 = Vector2(border.end.x,border.position.y).rotated(rotation)
			var bl: Vector2 = Vector2(border.position.x,border.end.y).rotated(rotation)
			var br: Vector2 = border.end.rotated(rotation)
			var xlist :Array = [tl.x,tr.x,bl.x,br.x]
			var ylist :Array = [tl.y,tr.y,bl.y,br.y]
			border.position.x = xlist.min()
			border.position.y = ylist.min()
			border.end.x = xlist.max()
			border.end.y = ylist.max()
			xlist.clear()
			ylist.clear()
	else:
		border = default_border
	
	if !force_offset && node.get("brush_offset") != null:
		offset = node.brush_offset
		offset.x *= node.scale.x
		offset.y *= node.scale.y
		offset.rotated(node.rotation)
	else:
		offset = default_offset
	
func get_list_brush(list :Array) ->void:
	get_brush(list[0])
	var min_pos :Vector2 = Vector2(INF,INF)
	var max_pos :Vector2 = Vector2(-INF,-INF)
	var min_border :Vector2
	for i in list:
		get_brush(i)
		if min_pos.x > i.position.x+border.position.x:
			min_pos.x = i.position.x+border.position.x
			min_border.x = border.position.x
		if min_pos.y > i.position.y+border.position.y:
			min_pos.y = i.position.y+border.position.y
			min_border.y = border.position.y
		max_pos.x = max(max_pos.x,i.position.x+border.end.x)
		max_pos.y = max(max_pos.y,i.position.y+border.end.y)
	border = Rect2(min_border,max_pos-min_pos)
	
func add_child_copy(list :Array, pos :Vector2) ->void:
	var fpos :Vector2 = list[0].position
	var editor_owner :Node = get_tree().get_edited_scene_root()
	for i in list:
		i.position += -fpos + pos
		add_child(i)
		i.set_owner(editor_owner)
		set_children_owner(i,editor_owner)
		
func add_child_list(list :Array) ->void:
	var editor_owner :Node = get_tree().get_edited_scene_root()
	for i in list:
		add_child(i)
		i.set_owner(editor_owner)
		set_children_owner(i,editor_owner)
		
func remove_child_list(list :Array) ->void:
	for i in list:
		remove_child(i)
		
func set_children_owner(node :Node, new_onwer :Node) ->void:
	var children :Array = node.get_children()
	if children.empty():
		return
	for i in children:
		if i.owner == null:
			i.set_owner(new_onwer)
			set_children_owner(i,new_onwer)

func _brush_process(res :Resource, sel :Array, undo :UndoRedo) ->void:
	var check :bool = false
	if res is PackedScene:
		var check_node: Node = res.instance()
		if check_node is Node2D:
			check = true
		check_node.queue_free()
	if !check && copy_list.empty():
		border = default_border
		offset = default_offset
		brush_last = null
	
	var pos :Vector2 = get_global_mouse_position() - global_position
	var grid_pos :Vector2
	grid_pos.x = floor(pos.x/grid.x)*grid.x
	grid_pos.y = floor(pos.y/grid.y)*grid.y
	
	# preview
	if preview:
		if copy_list.empty():
			if !preview_list.empty():
				for i in preview_list:
					if is_instance_valid(i):
						i.queue_free()
				preview_list.clear()
			if check:
				if preview_res != res:
					preview_res = res
					if is_instance_valid(preview_node):
						preview_node.queue_free()
					preview_node = res.instance()
					add_child(preview_node)
				if !(brush_last is String) || brush_last != res:
					get_brush(preview_node)
					brush_last = res
				if is_instance_valid(preview_node):
					preview_node.position = grid_pos + offset
					preview_node.modulate.a = preview_alpha
					move_child(preview_node,get_child_count())
			else:
				free_preview()
		else:
			if is_instance_valid(preview_node):
				preview_node.queue_free()
				preview_res = null
			if preview_list.empty():
				for i in copy_list:
					var new :Node = i.duplicate()
					add_child(new)
					preview_list.append(new)
			if !(brush_last is Array):
				get_list_brush(copy_list)
				brush_last = copy_list
			var fpos :Vector2 = preview_list[0].position
			var child_count :int = get_child_count()
			for i in preview_list:
				i.position += -fpos + grid_pos + offset
				i.modulate.a = preview_alpha
				move_child(i,child_count)
	
	# paint
	if Input.is_mouse_button_pressed(paint_button) && !paint_restrict:
		if (!click_only && Input.is_key_pressed(click_restrict_key)) || (click_only && !Input.is_key_pressed(click_restrict_key)):
			paint_restrict = true
		if copy_list.empty():
			if check:
				var new :Node = res.instance()
				if !preview && (!(brush_last is String) || brush_last != res):
					get_brush(new)
					brush_last = res
				var new_pos :Vector2 = grid_pos + offset
				var c1 :bool = new_pos.x + border.end.x <= mouse_last.x + border.position.x || new_pos.x + border.position.x >= mouse_last.x + border.end.x
				var c2 :bool = new_pos.y + border.end.y <= mouse_last.y + border.position.y || new_pos.y + border.position.y >= mouse_last.y + border.end.y
				if !(c1 || c2):
					new.queue_free()
				else:
					mouse_last = new_pos
					undo.create_action("brush2d_paint")
					undo.add_do_method(self, "add_child",new,true)
					undo.add_do_method(new,"set_owner",get_tree().get_edited_scene_root())
					undo.add_do_property(new, "position", new_pos)
					undo.add_undo_method(self, "remove_child",new)
					undo.commit_action()
		else:
			if !preview && !(brush_last is Array):
				get_list_brush(copy_list)
				brush_last = copy_list
			var new_pos :Vector2 = grid_pos + offset
			var c1 :bool = new_pos.x + border.end.x <= mouse_last.x + border.position.x || new_pos.x + border.position.x >= mouse_last.x + border.end.x
			var c2 :bool = new_pos.y + border.end.y <= mouse_last.y + border.position.y || new_pos.y + border.position.y >= mouse_last.y + border.end.y
			if c1 || c2:
				mouse_last = new_pos
				var new_list :Array = []
				for i in copy_list:
					new_list.append(i.duplicate())
				undo.create_action("brush2d_copy")
				undo.add_do_method(self,"add_child_copy",new_list,new_pos)
				undo.add_undo_method(self,"remove_child_list",new_list)
				undo.commit_action()
	else:
		mouse_last = Vector2(INF,INF)
		
	# erase
	if Input.is_mouse_button_pressed(erase_button) && !erase_restrict:
		if (!click_only && Input.is_key_pressed(click_restrict_key)) || (click_only && !Input.is_key_pressed(click_restrict_key)):
			erase_restrict = true
		var free_list :Array = []
		for i in get_children():
			if i == preview_node || preview_list.has(i):
				continue
			get_brush(i)
			brush_last = null
			var c1 :bool = pos.x > i.position.x + border.position.x && pos.x < i.position.x + border.end.x
			var c2 :bool = pos.y > i.position.y + border.position.y && pos.y < i.position.y + border.end.y
			if c1 && c2:
				free_list.append(i)
		if !free_list.empty():
			var erase_list :Array = free_list.duplicate()
			undo.create_action("brush2d_erase")
			undo.add_do_method(self, "remove_child_list",erase_list)
			undo.add_undo_method(self, "add_child_list",erase_list)
			undo.commit_action()
			free_list.clear()
			
	# preview border
	if preview_border:
		preview_rect = Rect2(grid_pos+offset+border.position,border.size)
		update()
	
func _copy_process(res :Resource, sel :Array, undo :UndoRedo) ->void:
	# copy
	if Input.is_key_pressed(copy_key) && !copy_restrict:
		copy_restrict = true
		copy_list.clear()
		brush_last = null
		if !preview_list.empty():
			for i in preview_list:
				if is_instance_valid(i):
					i.queue_free()
			preview_list.clear()
		for i in sel:
			if i.has_method("_brush_process"):
				continue
			copy_list.append(i.duplicate())
	
	# cut
	if Input.is_key_pressed(cut_key) && !cut_restrict:
		cut_restrict = true
		copy_list.clear()
		brush_last = null
		if !preview_list.empty():
			for i in preview_list:
				if is_instance_valid(i):
					i.queue_free()
			preview_list.clear()
		var free_list :Array = []
		for i in sel:
			if i.has_method("_brush_process"):
				continue
			copy_list.append(i.duplicate())
			free_list.append(i)
		if !free_list.empty():
			var erase_list :Array = free_list.duplicate()
			undo.create_action("brush2d_erase")
			undo.add_do_method(self, "remove_child_list",erase_list)
			undo.add_undo_method(self, "add_child_list",erase_list)
			undo.commit_action()
			free_list.clear()
			
func free_preview() ->void:
	preview_res = null
	if is_instance_valid(preview_node):
		preview_node.queue_free()
	if !preview_list.empty():
		for i in preview_list:
			if is_instance_valid(i):
				i.queue_free()
		preview_list.clear()
		
func _draw() ->void:
	if !Engine.editor_hint || !preview_border || !working:
		return
	draw_rect(preview_rect,border_color,false,2)
	
func _process(_delta):
	if !Engine.editor_hint:
		return
		
	if paint_restrict && !Input.is_mouse_button_pressed(paint_button):
		paint_restrict = false
		
	if erase_restrict && !Input.is_mouse_button_pressed(erase_button):
		erase_restrict = false
		
	if copy_restrict && !Input.is_key_pressed(copy_key):
		copy_restrict = false
		
	if cut_restrict && !Input.is_key_pressed(cut_key):
		cut_restrict = false
		
	if working:
		working = false
		if !preview:
			free_preview()
		if !preview_border:
			update()
		return
		
	free_preview()
	update()
