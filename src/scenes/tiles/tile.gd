extends StaticBody2D
class_name Tile


signal destroyed(pos)

@export var health: int = 1:
	set(new):
		health = new
		update_sprite()

## When true, the ball will pass trough this tile on breaking it.
@export var pass_on_break: bool = false

@onready var sprite: AnimatedSprite2D = $Sprite
@onready var breakSFX: SoundCollection2D = $Sounds/Break


func _ready() -> void:
#	health = randi_range(1, 5)
	health = health
	pass

## Modifies BallCollision accordingly to what happen
func handle_ball_collision(ball: Ball, collision: BallCollision) -> void:
	health -= ball.hardness
	
	if health < 1:
		if pass_on_break:
			collision.bounce = false
		breakSFX.play().finished.connect(queue_free)
		destroy()


func update_sprite() -> void:
	if sprite:
		var new = str(health)
		if sprite.sprite_frames.has_animation(new):
			sprite.play(new)


func destroy() -> void:
	collision_layer = 0
	hide()
	destroyed.emit(position)
