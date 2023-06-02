extends CharacterBody2D
class_name Ball


const DEFAULT_SIZE: float = 32
const MIN_SPEED: float = 100

@export var speed: float = 700.0
@export var max_speed: float = 2000.0
@export var hardness: int = 1:
	set(new):
		hardness = new
		@warning_ignore("narrowing_conversion")
		process_physics_priority = hardness * 10 + size / DEFAULT_SIZE
@export var friction: float = 0.1
@export var size: float = DEFAULT_SIZE:
	set(new):
		size = new
		@warning_ignore("narrowing_conversion")
		process_physics_priority = hardness * 10 + size / DEFAULT_SIZE
		update_size()

## Local to scene
@onready var shape: CircleShape2D = $CollisionShape2D.shape

@onready var bounceSFX: SoundCollection2D = $Sounds/Bounce


func _ready():
	shape = shape.duplicate()
	$CollisionShape2D.shape = shape
	update_size()
	
	launch(PI/2)

func _physics_process(delta):
	cap_velocity()
	var remainder: Vector2 = velocity * delta
	
	if OS.is_debug_build() and Input.is_action_pressed("debug_rotate"):
		remainder = remainder.rotated(PI * delta)
	
	# Repeat collision handling not infinitely
	for __ in 10:
		var collision: KinematicCollision2D = move_and_collide(remainder)
		
		if not collision:
			velocity = ST.align(velocity, remainder)
			return
		
		var ball_collision = BallCollision.new(collision)
		var collider = collision.get_collider()
		
		if collider.has_method("handle_ball_collision"):
			collider.handle_ball_collision(self, ball_collision)
		
		if ball_collision.bounce:
			remainder = collision.get_remainder()
			remainder = remainder.bounce(collision.get_normal())
			bounceSFX.play()
		
		if ball_collision.deviation:
#			remainder = ST.align(remainder, remainder + collision.get_normal().rotated(PI/2) * ball_collision.deviation)
			remainder = remainder.rotated(ball_collision.deviation)
		
		adjust_speed(ball_collision.speed_adjustment)
		
		if "constant_linear_velocity" in collider and not collider.constant_linear_velocity.is_zero_approx():
			remainder = absorb_velocity(remainder, collider.constant_linear_velocity)
		elif "velocity" in collider and not collider.velocity.is_zero_approx() and not collider is Ball:
			remainder = absorb_velocity(remainder, collider.velocity)
		
		print("start ", rad_to_deg(remainder.angle_to(collision.get_normal())))
		prints(collision.get_normal(), remainder)
		if abs(remainder.angle_to(collision.get_normal())) > ball_collision.max_angle:
			remainder = remainder.rotated(remainder.angle_to(collision.get_normal()) - (ball_collision.max_angle * sign(remainder.angle_to(collision.get_normal()))))
		print(rad_to_deg(remainder.angle_to(collision.get_normal())))
		
	push_warning("Unterminated collision handling.")


#func get_tile_collider(collider: KinematicCollision2D) -> Tile:
#	if collider.get_collider() is Tile:
#		return collider.get_collider()


# Move current speed towards
func adjust_speed(adjustment: float = 0.5) -> void:
#	velocity = velocity.move_toward(
#		velocity.normalized() * speed,
#		adjustment * (velocity.length() - (velocity.normalized() * speed).length())
#	)
	velocity = (
		velocity.normalized()
		* (
			velocity.length() * (1-adjustment)
			 + speed * adjustment
		)
	)


func cap_velocity() -> void:
	if velocity.length() == 0:
		launch()
	elif velocity.length() > max_speed:
		velocity *= max_speed / velocity.length()
	elif velocity.length() < MIN_SPEED:
		velocity *= MIN_SPEED / velocity.length()


func launch(dir: float = -PI/4) -> void:
	velocity = Vector2(speed, 0).rotated(dir)


func absorb_velocity(remainder: Vector2, other_velocity: Vector2) -> Vector2:
#	var new = velocity + other_velocity * friction
#	velocity *= (new.length() / velocity.length())
	velocity = ST.align(velocity, remainder)
	print("vel ", velocity)
	velocity += other_velocity * friction
	print(velocity)
	prints("rem", remainder, ST.align(remainder, velocity))
	return ST.align(remainder, velocity)
#	return remainder # Changing remainder cause too much TPing


func update_size() -> void:
	if shape:
		shape.radius = size / 2
		%Sprite.scale = size / DEFAULT_SIZE * Vector2.ONE


#func break_block(tilemap: TileMap, global_pos: Vector2) -> void:
#	var target = global_to_map(tilemap, global_pos)
#	if tilemap.get_cell_source_id(0, target) == -1:
#		tilemap.erase_cell(0, global_to_map(tilemap, global_pos - Vector2(1, -1)))
#	else:
#		tilemap.erase_cell(0, target)
#
#
#func global_to_map(tilemap: TileMap, global_pos: Vector2) -> Vector2i:
#	return tilemap.local_to_map(tilemap.to_local(global_pos))
#func try_move() -> KinematicCollision2D:
#	return move_and_collide()
