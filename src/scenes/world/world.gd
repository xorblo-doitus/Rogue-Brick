extends Node2D



func _ready():
#	$TileMap.queue_free()
	pass


@warning_ignore("unused_parameter")
func _process(delta):
#	$TileMap.custom_set_cell(0, Vector2i(0, 0), 1, Vector2(0, 0))
	$TileMap.set_cell(0, Vector2i(0, 0), 1, Vector2(0, 0), 1)
	print($TileMap.get_cell_source_id(0, Vector2i(0, 0)))
	pass
