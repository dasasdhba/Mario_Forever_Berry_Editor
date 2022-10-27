tool
extends Node2D
class_name BrushParam, "icon_param.png"

export var enable_border :bool = true
export var border :Rect2 = Rect2(-16,-16,32,32)
export var enable_offset :bool = true
export var offset :Vector2 = Vector2(16,16)
export var preview :bool = false
export var preview_color :Color = Color(1,0.5,1,1)

func _ready() ->void:
    if !Engine.editor_hint:
        queue_free()

func _draw() ->void:
    if preview:
        draw_rect(border,preview_color,false,2)

func _process(_delta) ->void:
    update()