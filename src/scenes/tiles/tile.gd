extends StaticBody2D
class_name Tile


signal destroyed(pos)

@export var health: int = 1:
	set(new):
		health = new
		update_sprite()
@export var bounciness: float = 1
@export var speed_adjustment: float = BallCollision.SPEED_ADJUSTMENT
## When true, the ball will pass trough this tile on breaking it.
@export var pass_on_break: bool = false
@export var auto_frame: bool = true

@onready var sprite: AnimatedSprite2D = $Sprite
@onready var breakSFX: SoundCollection2D = $Sounds/Break
@onready var bounceSFX: SoundCollection2D = $Sounds/Bounce


func _ready() -> void:
	sprite.speed_scale += (randf() - 0.5) * 0.1
	get_tree().create_timer(randf() * 2).timeout.connect(sprite.play)
#	health = randi_range(1, 5)
	health = health
	pass

## Modifies BallCollision accordingly to what happen
func handle_ball_collision(ball: Ball, collision: BallCollision) -> void:
	collision.bounciness = bounciness
	collision.speed_adjustment = speed_adjustment
	
	health -= ball.hardness
	if health < 1:
		if pass_on_break:
			collision.bounce = false
		breakSFX.play().finished.connect(queue_free)
		destroy()
	else:
		bounceSFX.play()


func update_sprite() -> void:
	if auto_frame and sprite:
		var new = str(health)
		if sprite.sprite_frames.has_animation(new):
			sprite.play(new)


func destroy() -> void:
	collision_layer = 0
	hide()
	destroyed.emit(position)
