extends CharacterBody2D

var cancast = false
var casted = false
var canmove = true
var busy = false
var line_wobble_time := 0.0
signal cast

const SPEED = 200.0
const POINT_COUNT = 20
@onready var sprite = $AnimatedSprite2D
@onready var marker = %Bobber

func _ready():
	sprite.play("idle")
	
func _physics_process(delta: float) -> void:
	# Add the gravity.
	if casted:
		line_wobble_time += delta
		_update_fishing_line()
	if not is_on_floor():
		velocity += get_gravity() * delta
	var direction := Input.get_axis("ui_left", "ui_right")
	if not busy and canmove:
		if direction:
			velocity.x = direction * SPEED
			sprite.play("walking")
			sprite.flip_h = direction < 0
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			sprite.play("idle")
		move_and_slide()
	
func _cast_rod():
	if Input.is_action_just_pressed("ui_accept"):
		%Bob.progress_ratio = randf()
		canmove = false
		busy = true
		await %CastZone._erase_text()
		sprite.play("cast")
		await get_tree().create_timer(0.9).timeout
		casted = true
		sprite.play("fishidle")
		_update_fishing_line()
		emit_signal("cast")


func _on_cast_zone_cast_ready():
	if not busy:
		_cast_rod()


func _on_ui_boxes_done():
	%Line.visible = false
	sprite.play("done")
	await get_tree().create_timer(0.9).timeout
	sprite.play("idle")
	busy = false
	canmove = true


func _update_fishing_line():
	%Line.visible = true
	var line = %Line
	line.clear_points()

	var start_pos = %LineTip.global_position
	var end_pos = %Bob.global_position
	marker.global_position = end_pos
	var distance = start_pos.distance_to(end_pos)
	var bend_strength = clamp(distance * 0.1, 10, 60)
	var vertical_bounce = sin(line_wobble_time * PI * 2.0) * 1.75

	for i in POINT_COUNT:
		var t = i / float(POINT_COUNT - 1)
		var pos = start_pos.lerp(end_pos, t)

		var arc = -sin(t * PI) * bend_strength

		var wobble = 0.0
		if i != 0:  # Don't wobble the first point
			wobble = sin((line_wobble_time * 2.0) + t * PI * 4.0) * 1.5  # way less wobble

		pos.y += arc + wobble + vertical_bounce
		line.add_point(line.to_local(pos))
