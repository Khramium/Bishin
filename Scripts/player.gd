extends CharacterBody2D

var cancast = false
var canmove = true
var busy = false
signal cast

const SPEED = 200.0
@onready var sprite = $AnimatedSprite2D

func _ready():
	sprite.play("idle")
	
func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta


	var direction := Input.get_axis("ui_left", "ui_right")
	if direction and not busy:
		canmove = true
	if not busy and canmove == true:
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
		canmove = false
		busy = true
		await %CastZone._erase_text()
		sprite.play("cast")
		await get_tree().create_timer(0.9).timeout
		sprite.play("fishidle")
		emit_signal("cast")


func _on_cast_zone_cast_ready():
	if not busy:
		_cast_rod()


func _on_ui_boxes_done():
	# Add anim to hold fish until done done
	sprite.play("done")
	await get_tree().create_timer(0.9).timeout
	sprite.play("idle")
	busy = false
