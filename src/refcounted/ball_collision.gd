extends RefCounted
class_name BallCollision

## Default speed adjustment
const SPEED_ADJUSTMENT: float = 0.25

var kinematic_collision: KinematicCollision2D
var bounce: bool = true
## Deviation applied after bouncing in radians
var deviation: float = 0
## The maximum angle to the collision normal the bounce can go, this prevent a deviation
## wich would make the velocity point back to the collided object
var max_angle: float = 90
## The part of current difference between ball's speed and current ball's moving speed
## that will be removed
var speed_adjustment: float = SPEED_ADJUSTMENT
var bounciness: float = 1

func _init(_kinematic_collision: KinematicCollision2D) -> void:
	kinematic_collision = _kinematic_collision


## [method KinematicCollision2D.get_position]
func get_position() -> Vector2:
	return kinematic_collision.get_position()

## [method KinematicCollision2D.get_normal]
func get_normal() -> Vector2:
	return kinematic_collision.get_normal()
