extends Node



func _ready() -> void:
	if !OS.has_feature("web"):
		return
	
	add_child(preload("res://src/porting/html_ui.tscn").instantiate())
	
	while not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		await Wait.ms(0)
		pass
	get_window().mode = Window.MODE_FULLSCREEN
	for __ in range(100):
		await Wait.ms(20)
		get_window().mode = Window.MODE_WINDOWED
