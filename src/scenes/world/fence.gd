@tool
extends Node2D

## La distance en plus en dehors de l'écran
@export_range(-10, 20, 1, "or_less", "or_greater", "suffix:px") var margin: int = 0:
	set(new):
		margin = new
		change()
## L'épaisseur de la bordure
@export_range(1, 50, 1, "or_greater", "suffix:px") var width: int = 20:
	set(new):
		width = new
		change()

@export_flags_2d_physics var collision_layer: int:
	set(new):
		collision_layer = new
		for child in get_children():
			if "collision_layer" in child:
				child.collision_layer = new


var is_ready: bool = false
func change(can_change: bool = Engine.is_editor_hint() and is_ready):
	if not can_change:
		return
	
	$Up/HorizontalShape.shape.size = Vector2i(ST.get_screen_width() + 2*(width+margin), width)
	$Up.position = Vector2(ST.get_screen_width()/2., -margin -width/2.)
	$Down.position = Vector2(ST.get_screen_width()/2., margin + ST.get_screen_height() + width/2.)
	
	$Right/VerticalShape.shape.size = Vector2i(width, ST.get_screen_height() + 2*(width+margin))
	$Left.position = Vector2(-margin - width/2., ST.get_screen_height()/2.)
	$Right.position = Vector2(margin + ST.get_screen_width() + width/2., ST.get_screen_height()/2.)
	
	
func _ready():
	is_ready = true
	change(true)
