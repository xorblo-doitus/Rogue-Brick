extends RefCounted

class_name MapGenerator


const BUFFER_LENGTH: int = 20
const GENERATE_AT: int = 10

var rng: RandomNumberGenerator = RandomNumberGenerator.new()
## Array[Array[TileInfo]]
var buffer: Array[Array] = []
var width = 22

var _distance: int = 0

func _init():
	rng.randomize()
	repopulate()
	
	for __ in GENERATE_AT:
		pop()


func get_empty_array() -> Array[TileInfo]:
	var new: Array[TileInfo] = []
	for __ in range(width):
		new.append(TileInfo.new())
	return new

func repopulate() -> void:
	while len(buffer) < BUFFER_LENGTH:
		append_buffer()


func append_buffer() -> void:
	buffer.append(get_empty_array())


func generate_line() -> void:
	_distance += 1
	var current_line: Array[TileInfo] = buffer[GENERATE_AT]
	var current_seed: int = rng.randi()
	for x in range(width):
		@warning_ignore("integer_division")
		current_line[x].set_id(-1 if current_seed / (2 + x) % 10 > 5 else 1)
	
	current_line = buffer[GENERATE_AT - 1]
	for x in range(1, width - 1):
		if current_line[x].source_id != -1:
			if current_line[x-1].source_id < 0 and current_line[x+1].source_id < 0:
				current_line[x].set_id(2)
			elif (current_line[x-1].source_id > -1) != (current_line[x+1].source_id > -1):
				current_line[x].set_id(-2,5)

func pop() -> Array[TileInfo]:
	var result = buffer.pop_front()
	repopulate()
	generate_line()
	
	return result
