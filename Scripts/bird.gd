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
var perching = false
var rng = RandomNumberGenerator.new()
var boredom = 0
var stuck_timer = 0.0
const MAX_STUCK_TIME = 0.5
var last_position: Vector2
var wobble_time := 0.0
var tree
var doing = "Grounding"
signal dead

# when bird leave turn off Y-sort and set z level to above
@onready var sprite = $AnimatedSprite2D

func _ready():
	pick_random_target()
	busy = true
	
func pick_random_target():
	tree = the_pond.rand_tree()
	var choose = randi() & 2 # lookup later, web code
	var spot = path_node
	if leaving == true:
		spot = leave_node
	if choose != 2:
		perching = true
		var perch_path: Path2D = tree.get_perch_spots()
		spot = perch_path
		doing = "Perching"
	else:
		perching = false
	var curve = spot.curve
	var length = curve.get_baked_length()

	var offlimits = tree.get_nono()
	var local_polygon = offlimits.polygon
	var global_polygon = []
	for point in local_polygon:
		global_polygon.append(offlimits.to_global(point))
	
	var offset = randf() * length
	var candidate = spot.to_global(curve.sample_baked(offset))
	while Geometry2D.is_point_in_polygon(candidate, global_polygon):
		offset = randf() * length
		candidate = spot.to_global(curve.sample_baked(offset))
	target_position = candidate
	moving = true

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
			doing = "Leaving"
			emit_signal("dead")

	# Peck
	elif desire == 1:
		if not perching:
			sprite.play("peck")
			doing = "Pecking"
			await get_tree().create_timer(1.7).timeout
		if sprite.animation != "idle":
			sprite.play("idle")
		doing = "Sitting"
		busy = false  # Set busy to false, allowing a new action to be picked later
		
	
	# Wander
	elif desire == 2:
		
		var whatdo = randi_range(0, 2)
		if whatdo == 2 or perching == true:
			flying = true
			doing = "Flying"
		else:
			doing = "Walking"
		pick_random_target()  # Pick a new target for wandering
		moving = true
	
	# Lie Down
	elif desire == 3:
		if sprite.animation != "idle":
			sprite.play("idle")
		busy = false  # Set busy to false so new actions can be picked
		doing = "Sitting"

func _physics_process(delta):
	%BirdDebug.text = doing + " [" + str(int(%Patience.time_left)) + "]"
	if not moving or path_node == null:
		return

	var direction = (target_position - global_position).normalized()
	var trunk = tree.get_trunk()
		
	var wobble = randi_range(1, 35)
	if flying or perching:
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
		doing = "Sitting"
			# Orient the bird to face away from the trunk
		if trunk:
			direction = (global_position - trunk.global_position).normalized()
			sprite.flip_h = direction.x < 0
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
