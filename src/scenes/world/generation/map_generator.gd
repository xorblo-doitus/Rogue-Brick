extends RefCounted

class_name MapGenerator


const BUFFER_LENGTH: int = 20
const GENERATE_AT: int = 10

var rng: RandomNumberGenerator = RandomNumberGenerator.new()
## Array[Array[TileInfo]] (buffer[0] -> top row, buffer[len] -> bottom row)
var buffer: Array[Array] = []
## An intermediate buffer to always take 2 rows from the buffer
var offsetted_buffer: Array[Array] = []
var width = 22
var tile_map: TileMap
var tile_set: TileSet

var _distance: int = GENERATE_AT
var _generated_distance: int = GENERATE_AT

func _init(_tile_map):
	tile_map = _tile_map
	tile_set = tile_map.tile_set
	rng.randomize()
	repopulate()
	
	for __ in BUFFER_LENGTH:
		get_next_line()


func get_empty_array() -> Array[TileInfo]:
	var new: Array[TileInfo] = []
	for __ in range(width):
		new.append(TileInfo.new())
	return new

func repopulate() -> void:
	while len(buffer) < BUFFER_LENGTH:
		append_buffer_top()


func append_buffer_top() -> void:
	buffer.push_front(get_empty_array())


func get_cell(pos: Vector2i) -> TileInfo:
	return buffer[pos.y][pos.x]
func get_cell_xy(x: int, y: int) -> TileInfo:
	return buffer[y][x]


## positive offset moves toward bottom
func get_gen_line(offset: int = 0) -> int:
	return _distance - _generated_distance + offset


## Return tiles wich touch this cell
func get_neighbors(origin: Vector2i) -> Array[TileInfo]:
	var result: Array[TileInfo] = []
	for pos in tile_map.get_surrounding_cells(origin):
		result.append(get_cell(pos))
	print(len(result))
	return result
func get_neighbors_xy(x: int, y: int) -> Array[TileInfo]:
	return get_neighbors(Vector2i(x, y))


func is_empty(tile: TileInfo) -> bool:
	return tile.source_id < 0
func is_full(tile: TileInfo) -> bool:
	return tile.source_id >= 0
	

func get_empty_neighbors(origin: Vector2i) -> int:
	var count: int = 0
	for tile in get_neighbors(origin):
		if is_empty(tile):
			count += 1
	return count
func get_empty_neighbors_xy(x: int, y: int) -> int:
	return get_empty_neighbors(Vector2i(x, y))
	
	
func get_full_neighbors(origin: Vector2i) -> int:
	var count: int = 0
	for tile in get_neighbors(origin):
		if is_full(tile):
			count += 1
	return count
func get_full_neighbors_xy(x: int, y: int) -> int:
	return get_full_neighbors(Vector2i(x, y))
	

func generate_line() -> void:
	_generated_distance += 1
	var current_seed: int = rng.randi()
	
	var current_y: int = get_gen_line()
	var current_line: Array[TileInfo] = buffer[current_y]
	for x in range(width):
		@warning_ignore("integer_division")
		current_line[x].set_id(-1 if current_seed / (2 + x) % 10 > 5 else 1)
	
	current_y += 1
	current_line = buffer[current_y]
	for x in range(1, width - 1):
		if current_line[x].source_id > 0:
			if get_full_neighbors_xy(x, current_y) == 0:
				current_line[x].set_id(3,0)
			elif is_empty(current_line[x-1]) and is_empty(current_line[x+1]):
				current_line[x].set_id(2, 0)
			elif get_full_neighbors_xy(x, current_y) <= 1:
				current_line[x].set_id(3,0)
			elif (current_line[x-1].source_id > -1) != (current_line[x+1].source_id > -1):
#				if randf() > 0.2:
					current_line[x].set_id(-2,5)
#				else:
#					current_line[x].set_id(3,0)
#					for pos in tile_map.get_surrounding_cells(Vector2i(x, current_y)):
#						buffer[pos.y][pos.x].set_id(0, 0)
#					var pos: Vector2i = tile_map.get_neighbor_cell(Vector2i(x, get_gen_line(1)), TileSet.CELL_NEIGHBOR_TOP_LEFT_SIDE)
#					get_cell(pos).set_id(0, 0)


func generate_lines() -> void:
	while _generated_distance < _distance:
		generate_line()


func pop_buffer() -> Array[TileInfo]:
	var result: Array[TileInfo] = buffer.pop_back()
	repopulate()
	_distance += 1
	return result


func get_next_line() -> Array[TileInfo]:
	var result: Array[TileInfo]
	if offsetted_buffer:
		result = offsetted_buffer.pop_back()
	else:
		# Always take two entries of the buffer to prevent
		# coordinate conflict of Half Offset Square tile shape.
		result = pop_buffer()
		offsetted_buffer.append(pop_buffer())
	
	repopulate()
	generate_lines()
	
	return result
