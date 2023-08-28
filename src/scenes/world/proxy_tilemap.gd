extends TileMap


var generator: MapGenerator = MapGenerator.new(self)

var _distance = 0

func _init():
	child_entered_tree.connect(add)
	position.x = -tile_set.tile_size.x / 2.
	grow(10, false)


func add(child: Node) -> void:
	if child.has_signal("destroyed"):
		child.destroyed.connect(remove)


func remove(at: Vector2) -> void:
	erase_cell(0, local_to_map(at))


func custom_set_cell(layout: int, coords: Vector2i, source_id: int = -1, atlas_coords: Vector2i = Vector2.ZERO, alternative_tile: int = 0) -> void:
	set_cell(layout, coords, source_id, atlas_coords, alternative_tile)
	var source := tile_set.get_source(source_id)
	if source is TileSetScenesCollectionSource:
		var scene: PackedScene = source.get_scene_tile_scene(1)
		if scene:
			var new: Node = scene.instantiate()
			new.position = map_to_local(coords)
			add_child(new)


func grow(amount: int = 1, animate: bool = true) -> void:
	for __ in amount:
		_distance += 1
		var y: int = -_distance
		
		if animate:
			create_tween().tween_property(self, "position", Vector2(position.x, _distance * tile_set.tile_size.y), 0.2)
		else:
			position = Vector2(position.x, _distance * tile_set.tile_size.y)
		
		var line: Array[TileInfo] = generator.get_next_line()
		
		for x in len(line):
			set_cell(0, Vector2i(x, y), line[x].source_id, Vector2.ZERO, line[x].sub_id)
