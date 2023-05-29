extends Node

## Input singleton running constantly


func _process(_delta) -> void:
	if Input.is_action_just_pressed("fullscreen"):
		# Get opposite state as current
		var now_fullscreen = get_window().mode != Window.MODE_FULLSCREEN
		
		print("set fullscreen to ", now_fullscreen)
		if now_fullscreen:
			get_window().mode = Window.MODE_FULLSCREEN
		else:
			get_window().mode = Window.MODE_WINDOWED
