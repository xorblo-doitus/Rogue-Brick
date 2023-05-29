extends Node


const DEBUG_WINDOW_SIZE = Vector2i(640, 360)
const DEBUG_WINDOW_POS = Vector2i(700, 350)


func _ready() -> void:
	if OS.is_debug_build():
		setup_debug()


func setup_debug() -> void:
	var window = get_window()
	window.always_on_top = true
	window.size = DEBUG_WINDOW_SIZE
	window.position = DEBUG_WINDOW_POS
