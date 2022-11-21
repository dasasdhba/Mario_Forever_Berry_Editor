# 基于 Node2D 节点的图层，与 CanvasLayer 不同，更方便坐标比较

extends Node2D
class_name Layer2D, "icon/layer_2d.png"

enum MODE {IDLE, PHYSICS}
export(MODE) var process_mode :int = MODE.PHYSICS # 应与 Camera 保持一致
export var scroll_scale :Vector2 = Vector2.ONE # 视差参数

onready var origin_pos :Vector2 = global_position
onready var view :Node = Berry.get_view(self)

func _scroll_process(_delta :float) ->void:
    var left :float = view.current_border.position.x
    global_position = origin_pos + left*(Vector2.ONE - scroll_scale)

func _process(delta :float) ->void:
    if process_mode == MODE.IDLE:
        _scroll_process(delta)

func _physics_process(delta :float) ->void:
    if process_mode == MODE.PHYSICS:
        _scroll_process(delta)