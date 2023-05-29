extends RefCounted
class_name BallCollision

var kinematic_collision: KinematicCollision2D
var bounce: bool = true
## Deviation applied after bouncing in radians
var deviation: float = 0

func _init(_kinematic_collision: KinematicCollision2D) -> void:
	kinematic_collision = _kinematic_collision

## [method KinematicCollision2D.get_position]
func get_position() -> Vector2:
	return kinematic_collision.get_position()
