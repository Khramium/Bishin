extends CharacterBody2D


var path_node: Path2D
var leave_node: Path2D
var the_pond
var fly_speed = 150.0
var walk_speed = 80.0
var target_position: Vector2
var moving = true
var flying = true
var busy = true
var leaving = false
var rng = RandomNumberGenerator.new()
var boredom = 0
var stuck_timer = 0.0
const MAX_STUCK_TIME = 0.5
var last_position: Vector2
var wobble_time := 0.0
signal dead

# when bird leave turn off Y-sort and set z level to above
@onready var sprite = $AnimatedSprite2D

func _ready():
	pick_random_target()
	busy = true
	
func pick_random_target():
	var tree = the_pond.rand_tree()
	var choose = 1
	# var choose = randi() & 2 # lookup later, web code
	var spot = path_node
	if choose == 1:
		# perch
		var perch_path: Path2D = tree.get_perch_spots()
		spot = perch_path # This is the Path2D
		
	
	var curve = spot.curve
	var length = curve.get_baked_length()
	var offset = randf() * length
	target_position = curve.sample_baked(offset)
	moving = true
	print("Bird target position set to: ", target_position)
	
func _pick_smarter_target(stuck_dir):
	var curve = path_node.curve
	var length = curve.get_baked_length()
	flying = true
	for i in range(10):
		var offset = randf() * length
		var candidate = curve.sample_baked(offset)
		var dir = (candidate - global_position).normalized()
		if dir.dot(stuck_dir) < -0.3:
			target_position = candidate
			moving = true
			return
	pick_random_target()

func what_bird_doin():
	var desire = rng.randi_range(0, 3)
	busy = true
	# Leave
	if desire == 0:
		if sprite.animation != "idle":
			sprite.play("idle")
		boredom += 1
		if boredom <= 1:
			busy = false
			desire = 1
		else:
			path_node = leave_node
			pick_random_target()
			flying = true
			sprite.play("fly")
			leaving = true
			emit_signal("dead")

	# Peck
	elif desire == 1:
		sprite.play("peck")
		await get_tree().create_timer(1.7).timeout
		sprite.play("idle")
		busy = false  # Set busy to false, allowing a new action to be picked later
	
	# Wander
	elif desire == 2:
		
		var whatdo = randi_range(0, 2)
		if whatdo == 2:
			flying = true
		pick_random_target()  # Pick a new target for wandering
		moving = true
	
	# Lie Down
	elif desire == 3:
		if sprite.animation != "idle":
			sprite.play("idle")
		busy = false  # Set busy to false so new actions can be picked

func _physics_process(delta):
	if not moving or path_node == null:
		return

	var direction = (target_position - global_position).normalized()
		
	var wobble = randi_range(1, 35)
	if flying:
		%Bod.disabled = true
		wobble_time += delta * 8.0 # controls speed of sway
		var perp = Vector2(-direction.y, direction.x) # perpendicular vector
		var wobble_offset = perp * sin(wobble_time) * wobble # amplitude
		velocity = (direction * fly_speed) + wobble_offset
		sprite.play("fly")
	else:
		wobble_time += delta * 4.0 # controls speed of sway
		var perp = Vector2(-direction.y, direction.x) # perpendicular vector
		var wobble_offset = perp * sin(wobble_time) * (wobble / 2) # amplitude
		velocity = (direction * walk_speed) + wobble_offset
		sprite.play("wander")

	move_and_slide()
	sprite.flip_h = direction.x < 0

	if global_position.distance_to(target_position) < 5:
		velocity = Vector2.ZERO
		moving = false
		flying = false
		busy = false
		stuck_timer = 0.0
		if leaving:
			queue_free()
		sprite.play("idle")
	else:
		if global_position.distance_to(last_position) < 1.0:
			stuck_timer += delta
			if stuck_timer > MAX_STUCK_TIME:
				_pick_smarter_target(direction)
				stuck_timer = 0.0
		else:
			stuck_timer = 0.0
	last_position = global_position

func _on_patience_timeout():
	if not busy:
		flying = false
		%Bod.disabled = false
		what_bird_doin()
