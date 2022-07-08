tool
extends EditorPlugin

onready var file = File.new()

static func get_main_screen(plugin:EditorPlugin)->int:
	var idx = -1
	var base:Panel = plugin.get_editor_interface().get_base_control()
	var button:ToolButton = find_node_by_class_path(
		base, ['VBoxContainer', 'HBoxContainer', 'HBoxContainer', 'ToolButton'], false
	)

	if not button: 
		return idx
	for b in button.get_parent().get_children():
		b = b as ToolButton
		if not b: continue
		if b.pressed:
			return b.get_index()
	return idx
	
static func get_selected_paths(fs_tree:Tree)->Array:
	var sel_items: = tree_get_selected_items(fs_tree)
	var result: = []
	for i in sel_items:
		i = i as TreeItem
		result.push_back(i.get_metadata(0))
	return result

static func get_fylesystem_tree(plugin:EditorPlugin)->Tree:
	var dock = plugin.get_editor_interface().get_file_system_dock()
	return find_node_by_class_path(dock, ['VSplitContainer','Tree']) as Tree

static func tree_get_selected_items(tree:Tree)->Array:
	var res = []
	var item = tree.get_next_selected(tree.get_root())
	while true:
		if not item: break
		res.push_back(item)
		item = tree.get_next_selected(item)
	return res

static func find_node_by_class_path(node:Node, class_path:Array, inverted:= true)->Node:
	var res:Node

	var stack = []
	var depths = []

	var first = class_path[0]
	
	var children = node.get_children()
	if not inverted:
		children.invert()

	for c in children:
		if c.get_class() == first:
			stack.push_back(c)
			depths.push_back(0)

	if !stack: return res
	
	var max_ = class_path.size()-1

	while stack:
		var d = depths.pop_back()
		var n = stack.pop_back()

		if d>max_:
			continue
		if n.get_class() == class_path[d]:
			if d == max_:
				res = n
				return res

			var children_ = n.get_children()
			if !inverted:
				children_.invert()
			for c in children_:
				stack.push_back(c)
				depths.push_back(d+1)

	return res

func _process(_delta) ->void:
	var path :Array = get_selected_paths(get_fylesystem_tree(self))
	if path.empty() || !file.file_exists(path.front()):
		return
	var res :Resource = load(path.front())
	if !res is PackedScene:
		return
	if get_main_screen(self) == 0:
		var sel :Array = get_editor_interface().get_selection().get_selected_nodes()
		for i in sel:
			if i is Brush2D:
				i._brush_process(res,sel,get_undo_redo())
				i.working = true
				break
			else:
				var j :Node = i.get_parent()
				var root :Node = i.get_tree().get_edited_scene_root().get_parent()
				var flag :bool = false
				while j != root:
					if j is Brush2D:
						j._brush_process(res,sel,get_undo_redo())
						j.working = true
						flag = true
						break
					j = j.get_parent()
				if flag:
					break
