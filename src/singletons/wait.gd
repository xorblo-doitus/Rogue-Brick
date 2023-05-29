extends Node

## Utility for waiting easily

@onready var tree := get_tree()

func minutes(time: float) -> void:
	await secondes(time*60)

func secondes(time: float) -> void:
	await tree.create_timer(time).timeout

func ms(time: float) -> void:
	await secondes(time/1000)
