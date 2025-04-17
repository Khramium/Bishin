extends CharacterBody2D


var target_position: Vector2
var swim_zone: Area2D
var fname = ""
var wobble_time := 0.0
var speed = 35

@onready var sprite = $AnimatedSprite2D


func _ready():
	%Name.text = fname
	sprite.play("swim")
	_set_new_target()


func _physics_process(delta):
	if get_last_slide_collision(): _set_new_target()
	wobble_time += delta * randi_range(1, 15)
	var direction = (target_position - global_position).normalized()
	var wobble = randi_range(1, 15)
	var perp = Vector2(-direction.y, direction.x)
	var wobble_offset = perp * sin(wobble_time) * wobble
	velocity = (direction * speed) + wobble_offset

	if global_position.distance_to(target_position) < 10:
		_set_new_target()
	move_and_slide()
	sprite.flip_h = direction.x > 0

func _set_new_target():
	var shape_node := swim_zone.get_node_or_null("SwimZone")
	var rect_shape := shape_node.shape as RectangleShape2D
	var size = rect_shape.extents * 2
	var local_point = Vector2(randf_range(-size.x / 2.0, size.x / 2.0), randf_range(-size.y / 2.0, size.y / 2.0))
	var global_point = shape_node.global_position + local_point
	target_position = global_point
	
func _remove_from_scene():
	queue_free()
