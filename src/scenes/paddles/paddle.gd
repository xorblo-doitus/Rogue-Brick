extends AnimatableBody2D
class_name Paddle

const SPRITE_PART_SIZE: int = 16
## [member BallCollision.max_angle]
const MAX_ANGLE: float = PI / 2 - deg_to_rad(10)

@export var speed: float = 500
@export var size: float = 256:
	set(new):
		size = max(new, 16)
		update_size()
@export_range(0, 1, 0.01) var dead_zone: float = 0.4:
	set(new):
		dead_zone = new
		update_sprite()
@export var deviation_amount: float = PI / 4.0
@export var deviation_exp: float = 1

## Local to scene
@onready var shape: CapsuleShape2D = $CollisionShape2D.shape

## Calculated
var velocity: Vector2 = Vector2.ZERO


func _ready() -> void:
	shape = shape.duplicate()
	$CollisionShape2D.shape = shape
	
	update_size()

func _physics_process(delta) -> void:
	var start: Vector2 = global_position
	var stop: Vector2 = Vector2(
		clamp(
			move_toward(
			global_position.x,
			get_global_mouse_position().x,
			speed * delta
			),
			size / 2,
			ST.get_screen_width() - size / 2
		)
		,
		global_position.y
	)
	global_position = stop
	velocity = (stop - start) / delta


func handle_ball_collision(ball: Ball, collision: BallCollision) -> void:
	collision.max_angle = MAX_ANGLE
	
	var x = to_local(collision.get_position()).x
	var deviation_scalar: float = abs(x) - size * dead_zone / 2
	if deviation_scalar > 0:
		collision.deviation = (deviation_scalar / (size - size * dead_zone / 2)) ** deviation_exp * deviation_amount * sign(x)
#		collision.deviation = (deviation_scalar / (size - size * dead_zone / 2)) ** deviation_exp * deviation_amount * sign(x)


func update_size() -> void:
	shape.height = size
	update_sprite()


func update_sprite() -> void:
	%EndLeft.position.x = -size / 2
	%EndRight.position.x = size / 2
	
	%Middle.scale.x = (size - 18) / SPRITE_PART_SIZE
	
	%MarkerLeft.position.x = -size * dead_zone / 2
	%MarkerRight.position.x = size * dead_zone / 2
	
	
