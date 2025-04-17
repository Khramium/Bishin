extends CharacterBody2D


var target_position: Vector2
var swim_zone: Area2D
var fname = ""
var quip = ""
var wobble_time := 0.0
var speed = 35
var pond
var is_caught = false
var baited = false
var dead = false

@onready var sprite = $AnimatedSprite2D
signal on_da_line


func _ready():
	pass


func _physics_process(delta):
	if dead:
		queue_free()  # Remove the fish if it's dead
		return
	if get_last_slide_collision() and not is_caught and not baited:
		_set_new_target()
	wobble_time += delta * randi_range(1, 15)
	var direction = (target_position - global_position).normalized()
	var wobble = randi_range(1, 15)
	var perp = Vector2(-direction.y, direction.x)
	var wobble_offset = perp * sin(wobble_time) * wobble
	if is_caught or baited:
		%BodFeesh.disabled = true
		velocity = direction * speed
	else:
		velocity = (direction * speed) + wobble_offset
	if global_position.distance_to(target_position) < 25:
		if not is_caught and not baited:
			_set_new_target()
		elif baited:
			emit_signal("on_da_line")
			await get_tree().create_timer(0.3).timeout
			baited = false
		else:
			dead = true
			await get_tree().create_timer(0.05).timeout
	if not is_caught:
		sprite.flip_h = direction.x > 0
	else:
		sprite.look_at(target_position)
	move_and_slide()

func _set_new_target():
	var shape_node := swim_zone.get_node("SwimZone")
	var rect_shape := shape_node.shape as RectangleShape2D
	var size = rect_shape.extents * 2
	var local_point = Vector2(randf_range(-size.x / 2.0, size.x / 2.0), randf_range(-size.y / 2.0, size.y / 2.0))
	var global_point = shape_node.global_position + local_point
	target_position = global_point
	
func init_fish(name, pond_ref):
	fname = name
	pond = pond_ref
	%Name.text = fname
	sprite.play("swim")
	_set_new_target()
	
func get_caught():
	var target = get_tree().root.get_node("The Pond/Player/FishGo")
	target_position = target.global_position
	baited = false
	is_caught = true
	speed = 1500
