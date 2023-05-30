extends RefCounted
class_name TileInfo


var source_id: int = -1
var sub_id: int = 0


## use -2 to use default
func _init(_source_id: int = -2, _sub_id: int = -2) -> void:
	set_id(_source_id, _sub_id)


## use -2 to let current
func set_id(_source_id: int = -2, _sub_id: int = -2) -> TileInfo:
	if _source_id != -2:
		source_id = _source_id
	if _sub_id != -2:
		sub_id = _sub_id
	return self
