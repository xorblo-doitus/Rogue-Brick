extends Node2D


@onready var settings: Control = $Settings


func _ready():
#	$TileMap.queue_free()
#	print(Vector2.UP.rotated())
	pass


@warning_ignore("unused_parameter")
func _process(delta):
	pass


func _on_open_settings_pressed() -> void:
	settings.visible = !settings.visible
