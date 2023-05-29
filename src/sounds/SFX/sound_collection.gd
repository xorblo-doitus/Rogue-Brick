extends Node2D
class_name SoundCollectionOld

@export_range(0, 10, 0.1) var volume_range: float = 0.1
@export_range(0, 1, 0.1) var pitch_range: float = 0.1

func play():
	var sound = get_children().pick_random()
	sound.volume_db = randf_range(-volume_range, volume_range)
	sound.pitch_scale = 1 + randf_range(-pitch_range, pitch_range)
	sound.play()
	return sound
