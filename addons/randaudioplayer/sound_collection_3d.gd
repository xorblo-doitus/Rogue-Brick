@tool
@icon("icons/AudioStreamPlayer3D.svg")
extends Node3D
class_name SoundCollection3D


## Used to add randomness to sound effects.
##
## Holds multiples [AudioStreamPlayer3D] as child, and choose randomly one to play
## when [method play] is called.
## Adds also randomness to volume and pitch.
## Support simultaneous _playing: Calling [method play] before previous sound has finished
## will not stop it, and both _sounds will be audible.
## [br][br]
## [b]Note:[/b] You should avoid increasing volume, 


## When searching min and max by iterating, step is equal to this.
const EXTREMUM_SEARCH_INTERVAL: float = 0.05


## Volume is shifted randomly between [-volume_range, volume_range].
## Use [method @GlobalScope.linear_to_db].
## Will not apply if [member volume_curve] is not [code]null[/code].
@export_range(0, 5, 0.001, "allow_greater") var volume_range: float = 0.1
## Pitch is shifted randomly between [-pitch_range, pitch_range].
## Will not apply if [member pitch_curve] is not [code]null[/code].
@export_range(0, 1, 0.001, "allow_greater") var pitch_range: float = 0.1

## One image of this curve will be taken randomly to shift volume.
## Use [method @GlobalScope.linear_to_db].
## Sampled over x = [0, 1] interval.
@export var volume_curve: Curve
## One image of this curve will be taken randomly to shift pitch.
## Sampled over x = [0, 1] interval.
@export var pitch_curve: Curve

## If true, no error will be trown when this SoundCollection3D has not any AudioStreamPlayer3D.
@export var ignore_empty: bool = false:
	set(new):
		ignore_empty = new

## Used to trigger [method play_debug] from the editor.
@export var test_sound: bool = false:
	set(new):
		test_sound = new
		if new:
			play_debug()


var _sounds: Array[AudioStreamPlayer3D] = []
var _playing: Node3D


func _init() -> void:
	_playing = Node3D.new()
	_playing.name = "_playing"
	add_child(_playing, false, INTERNAL_MODE_BACK)
	
	child_entered_tree.connect(add)
	child_exiting_tree.connect(remove)


## Add [param node] to [member _sounds] if it's an [AudioStreamPlayer3D].
## Return [code]true[/code] if success.
func add(node: Node) -> bool:
	if node is AudioStreamPlayer3D:
		_sounds.append(node)
		return true
	return false


## Remove [param node] if it's in [member _sounds].
func remove(node: Node) -> void:
	if node is AudioStreamPlayer3D:
		_sounds.erase(node)


## Return a random shift determined by [member volume_curve],
## or [member volume_range] if curve is [code]null[/code].
func get_random_linear_volume_shift() -> float:
	if volume_curve:
		return volume_curve.sample(randf_range(0, 1))
	
	return randf_range(-volume_range, volume_range)


## Return a random shift determined by [member pitch_curve],
## or [member pitch_range] if curve is [code]null[/code].
func get_random_pitch_shift() -> float:
	if pitch_curve:
		return pitch_curve.sample(randf_range(0, 1))
	
	return randf_range(-pitch_range, pitch_range)


## Play a random sound with random volume and pitch.
func play() -> AudioStreamPlayer3D:
	if len(_sounds) == 0:
		if not ignore_empty:
			push_error("SoundCollection3D has not any AudioStreamPlayer3D child.")
		return
	var sound: AudioStreamPlayer3D = _sounds.pick_random().duplicate()
	_playing.add_child(sound)
	
	sound.volume_db = linear_to_db(db_to_linear(sound.volume_db) + get_random_linear_volume_shift())
	sound.pitch_scale = sound.pitch_scale + get_random_pitch_shift()
	
	sound.finished.connect(sound.queue_free)
	
	sound.play()
	return sound


# Return [min, average, max] found of [param curve].
func _search_min_max(curve: Curve) -> Array[float]:
	# Initialise min and max with the least possible values.
	var min: float = curve.max_value
	var max: float = curve.min_value
	var min_x: float = -1
	var max_x: float = -1
	
	# Find approximatively where are the minimum and maximum
	for x_int in range(0, 1 / EXTREMUM_SEARCH_INTERVAL):
		var x: float = x_int * EXTREMUM_SEARCH_INTERVAL
		var y: float = curve.sample(x)
		if y < min:
			min = y
			min_x = x
		elif y > max:
			max = y
			max_x = x
	
	# Go down the pit
	if min_x != -1:
		var shift: float = EXTREMUM_SEARCH_INTERVAL
		while shift > 0.000_001:
			shift /= 2.0
			var y: float = curve.sample(min_x + shift)
			if y < min:
				min = y
				min_x = min_x + shift
			y = curve.sample(min_x - shift)
			if y < min:
				min = y
				min_x = min_x - shift
				
	# Go up the mountain
	if max_x != -1:
		var shift: float = EXTREMUM_SEARCH_INTERVAL
		while shift > 0.000_000_001:
			shift /= 2.0
			var y: float = curve.sample(max_x + shift)
			if y > max:
				max = y
				max_x = max_x + shift
			y = curve.sample(max_x - shift)
			if y > max:
				max = y
				max_x = max_x - shift
	
	return [min, (min + max) / 2, max]


## Return [min, average, max] of possible volumes.
func get_linear_volume_extremums() -> Array[float]:
	if volume_curve == null:
		return [-volume_range, 0 , volume_range]
	
	return _search_min_max(volume_curve)


## Return [min, average, max] of possible pitches.
func get_pitch_extremums() -> Array[float]:
	if pitch_curve == null:
		return [-pitch_range, 0 , pitch_range]
	
	return _search_min_max(pitch_curve)


## Play each sound variant with every possible variant made of
## [min/average/max] [volume/pitch] shift (3² = 9 sounds).
## When using curves, min/none/max will be searched with [constant EXTREMUM_SEARCH_INTERVAL].
func play_debug() -> void:
	var volume_extremums: Array[float] = get_linear_volume_extremums()
	var pitch_extremums: Array[float] = get_pitch_extremums()
	
	print("Volumes tested: ", volume_extremums)
	print("Pitches tested: ", pitch_extremums)
	
	for sound in _sounds:
		var clone: AudioStreamPlayer3D = sound.duplicate()
		_playing.add_child(clone)
		
		var init_pitch = clone.pitch_scale
		var init_volume_linear = db_to_linear(clone.volume_db)
		
		
		for pitch_shift in pitch_extremums:
			for volume_shift in volume_extremums:
				clone.pitch_scale = init_pitch + pitch_shift
				clone.volume_db = linear_to_db(init_volume_linear + volume_shift)
				clone.play()
				await clone.finished
				
				if not test_sound:
					clone.queue_free()
					return
		
		clone.queue_free()
	test_sound = false
