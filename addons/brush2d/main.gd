tool
extends EditorPlugin

var file :File = null
var button :HBoxContainer = null
var viewport :Viewport = null
var brush :Brush2D = null
var mouse_check_delay :bool = false

func button_check() ->bool:
	return button != null && button.visible && button.get_node("ToolButton").pressed
	
func popup_check() ->bool:
	for i in get_editor_interface().get_base_control().get_children():
		if i is Popup && i.visible:
			return true
	return false

func mouse_check() ->bool:
	if mouse_check_delay:
		if Input.is_mouse_button_pressed(BUTTON_LEFT) || Input.is_mouse_button_pressed(BUTTON_RIGHT) || Input.is_mouse_button_pressed(BUTTON_MIDDLE):
			return false
		mouse_check_delay = false
	if viewport == null:
		viewport = find_viewport_2d(get_node("/root/EditorNode"), 0)
	var canvas_pos :Vector2 = Vector2.ZERO
	var c :Node = viewport.get_parent()
	while c != null && c is Control:
		canvas_pos += c.rect_position
		c = c.get_parent()
	var canvas_rect :Rect2 = Rect2(canvas_pos + 20*Vector2.ONE,viewport.get_parent().rect_size-36*Vector2.ONE)
	var mouse_pos :Vector2 = get_editor_interface().get_viewport().get_mouse_position()
	var result :bool = canvas_rect.has_point(mouse_pos)
	if !result && (Input.is_mouse_button_pressed(BUTTON_LEFT) || Input.is_mouse_button_pressed(BUTTON_RIGHT) || Input.is_mouse_button_pressed(BUTTON_MIDDLE)):
		mouse_check_delay = true
	return result

func select_update(_pressed :bool = false) ->void:
	var select :EditorSelection = get_editor_interface().get_selection()
	var sel :Array = select.get_selected_nodes()
	select.clear()
	if brush != null:
		select.add_node(brush)
	if !button_check():
		select.clear()
		for i in sel:
			select.add_node(i)

func handles(object :Object) ->bool:
	if !button_check():
		return false
	return get_brush2d(object) != null
		
func forward_canvas_gui_input(event :InputEvent) ->bool:
	if !button_check():
		return false
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT || event.button_index == BUTTON_RIGHT:
			return true
	return false
	
func _enter_tree() ->void:
	if file == null:
		file = File.new()
	if button == null:
		button = load("res://addons/brush2d/tool_button.res").instance()
		var button_node :ToolButton = button.get_node("ToolButton")
		if !button_node.is_connected("toggled",self,"select_update"):
			button_node.connect("toggled",self,"select_update")

func _process(_delta) ->void:
	_enter_tree()
	var path :Array = get_selected_paths(get_fylesystem_tree(self))
	var res :Resource = null
	if !path.empty() && file.file_exists(path.front()):
		res = load(path.front())
	brush = null
	var sel :Array = []
	if get_main_screen(self) == 0:
		sel = get_editor_interface().get_selection().get_selected_nodes()
		for i in sel:
			var b :Brush2D = get_brush2d(i)
			if b != null:
				brush = b
				break
	
	if brush != null:
		if !button.visible:
			add_control_to_container(CONTAINER_CANVAS_EDITOR_MENU,button)
			button.visible = true
			select_update()
		if !popup_check():
			brush._copy_process(res,sel,get_undo_redo())
			if button_check() && mouse_check():
				brush._brush_process(res,sel,get_undo_redo())
				brush.working = true
	elif button.visible:
		remove_control_from_container(CONTAINER_CANVAS_EDITOR_MENU,button)
		button.visible = false
	
func _exit_tree() ->void:
	if is_instance_valid(button):
		button.queue_free()

static func get_brush2d(object :Object) ->Object:
	if !object.has_method("get_parent"):
		return null
	if object is Brush2D:
		return object
	var i :Node = object.get_parent()
	var root :Node = object.get_tree().get_edited_scene_root().get_parent()
	while i != root:
		if i is Brush2D:
			return i
		i = i.get_parent()
	return null

static func find_viewport_2d(node :Node, recursive_level :int = 0) ->Node:
	if node.get_class() == "CanvasItemEditor":
		return node.get_child(1).get_child(0).get_child(0).get_child(0).get_child(0)
	else:
		recursive_level += 1
		if recursive_level > 15:
			return null
		for child in node.get_children():
			var result :Node = find_viewport_2d(child, recursive_level)
			if result != null:
				return result
		return null

static func get_main_screen(plugin :EditorPlugin) ->int:
	var idx :int = -1
	var base :Panel = plugin.get_editor_interface().get_base_control()
	var button :ToolButton = find_node_by_class_path(
		base, ['VBoxContainer', 'HBoxContainer', 'HBoxContainer', 'ToolButton'], false
	)

	if !button: 
		return idx
	for b in button.get_parent().get_children():
		b = b as ToolButton
		if !b:
			continue
		if b.pressed:
			return b.get_index()
	return idx

static func get_selected_paths(fs_tree :Tree) ->Array:
	var sel_items: Array = tree_get_selected_items(fs_tree)
	var result: Array = []
	for i in sel_items:
		i = i as TreeItem
		result.append(i.get_metadata(0))
	return result

static func get_fylesystem_tree(plugin: EditorPlugin) ->Tree:
	var dock :FileSystemDock = plugin.get_editor_interface().get_file_system_dock()
	return find_node_by_class_path(dock, ['VSplitContainer','Tree']) as Tree

static func tree_get_selected_items(tree: Tree) ->Array:
	var res :Array = []
	var item :TreeItem = tree.get_next_selected(tree.get_root())
	while true:
		if !item:
			break
		res.push_back(item)
		item = tree.get_next_selected(item)
	return res

static func find_node_by_class_path(node :Node, class_path :Array, inverted :bool = true) ->Node:
	var res :Node

	var stack :Array = []
	var depths :Array = []

	var first :String = class_path[0]
	
	var children :Array = node.get_children()
	if !inverted:
		children.invert()

	for c in children:
		if c.get_class() == first:
			stack.append(c)
			depths.append(0)

	if !stack:
		return res
	
	var max_ :int = class_path.size()-1

	while stack:
		var d :int = depths.pop_back()
		var n :Node = stack.pop_back()

		if d > max_:
			continue
		if n.get_class() == class_path[d]:
			if d == max_:
				res = n
				return res
			
			var children_ :Array = n.get_children()
			if !inverted:
				children_.invert()
			for c in children_:
				stack.append(c)
				depths.append(d+1)

	return res
