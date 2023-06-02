extends Node



func _ready() -> void:
	if !OS.has_feature("web"):
		return
	
	add_child(preload("res://src/porting/html_ui.tscn").instantiate())
	
	# Fix the window size bug of Godot 4 (automatically readjust size)
	JavaScriptBridge.eval("document.querySelector("#canvas").height = 0;")
	
#	var true_size: Vector2 = Vector2(
#		JavaScriptBridge.eval("""document.querySelector("#canvas").width"""),
#		JavaScriptBridge.eval("""document.querySelector("#canvas").height""")
#	)
#	print("True sze is ", true_size)
#	print("window_size_is ", get_window().size)
#	if true_size.x != get_window().size.x and true_size.y != get_window().size.y:
#		await Wait.secondes(1)
#		JavaScriptBridge.eval("""
#		document.querySelector("#canvas").height = %s;
#		""" % get_window().size.y)
#		while not Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
#			await Wait.ms(0)
#			pass
#		get_window().mode = Window.MODE_FULLSCREEN
#		for __ in range(100):
#			await Wait.ms(20)
#			get_window().mode = Window.MODE_WINDOWED
