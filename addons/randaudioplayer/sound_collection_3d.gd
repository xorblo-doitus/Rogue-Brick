@tool
@icon("icons/AudioStreamPlayer3D.svg")
extends Node3D
class_name SoundCollection3D

@export_range(0, 20, 0.1) var volume_range: float = 1
@export_range(0, 1, 0.1) var pitch_range: float = 0.1
## Used to trigger [method play_debug] from the editor
@export var test_sound: bool = false:
	set(new):
		test_sound = new
		if new:
			play_debug()
## If true, empty
@export var ignore_empty: bool = false:
	set(new):
		ignore_empty = new

var sounds: Array[AudioStreamPlayer3D] = []
var playing: Node3D

func _init() -> void:
	playing = Node3D.new()
	playing.name = "Playing"
	add_child(playing, false, INTERNAL_MODE_BACK)
	
	child_entered_tree.connect(add)
	child_exiting_tree.connect(remove)


func add(child) -> bool:
	if child is AudioStreamPlayer3D:
		sounds.append(child)
		return true
	return false


func remove(child) -> void:
	if child is AudioStreamPlayer3D:
		sounds.erase(child)


func play() -> AudioStreamPlayer3D:
	if len(sounds) == 0:
		if not ignore_empty:
			push_error("SoundCollection3D has not any AudioStreamPlayer3D child.")
		return
	var sound: AudioStreamPlayer3D = sounds.pick_random().duplicate()
	playing.add_child(sound)
	
	sound.volume_db = randf_range(-volume_range, volume_range)
	sound.pitch_scale = 1 + randf_range(-pitch_range, pitch_range)
	
	sound.finished.connect(sound.queue_free)
	
	sound.play()
	return sound


## Play each sound variant with the highest random cases
func play_debug() -> void:
	play()
	for sound in sounds:
		var clone: AudioStreamPlayer3D = sound.duplicate()
		playing.add_child(clone)
		
		var init_pitch = clone.pitch_scale
		var init_volume = clone.volume_db
		
		for pitch_mul in range(-1, 2):
			for volume_mul in range(-1, 2):
				clone.pitch_scale = init_pitch + pitch_range * pitch_mul
				clone.volume_db = init_volume + volume_range * volume_mul
				clone.play()
				await clone.finished
				
				if not test_sound:
					clone.queue_free()
					return
		
		clone.queue_free()
		test_sound = false
