# 全局共用资源，避免在其他脚本直接写资源路径而降低工程灵活性
extends Node

# UI
export var score :PackedScene
export var life :PackedScene

# 特效
export var fade :PackedScene
export var water_spray :PackedScene
export var lava_spray :PackedScene
export var boom :PackedScene

# 敌人
export var enemy_death: PackedScene
