extends Node2D


var path_node: Path2D
var rng = RandomNumberGenerator.new()
var birdcount = 0

func spawn_wave():
	var new_wave = preload("res://Enviroment Assets/wave.tscn").instantiate()
	 # randf picks a number between 0 and 1
	%SpawnPoint.progress_ratio = randf()
	new_wave.global_position = %SpawnPoint.global_position
	add_child(new_wave)

func spawn_bird():
	var new_bird = preload("res://Scripts/bird.tscn").instantiate()
	new_bird.dead.connect(_on_bird_dead)
	new_bird.path_node = $TreeSpots
	new_bird.leave_node = %BirdZone
	%BirdSpawns.progress_ratio = randf()
	new_bird.global_position = %BirdSpawns.global_position
	add_child(new_bird)
	
func _ready():
	var treecount = 30
	var trees = 0
	var progress = 0.0
	var progressA = 1.0 / treecount
	
	while treecount > trees:
		var grass = 0
		var progressB = progress + progressA + rng.randf_range(0.01, 0.1)
		var new_tree = preload("res://Enviroment Assets/tree_01.tscn").instantiate()
		%TreeSpawns.progress_ratio = clamp(progress, 0.0, 1.0)
		new_tree.global_position = %TreeSpawns.global_position
		while grass < 3:
			var new_grass = preload("res://Scripts/grass.tscn").instantiate()
			var progressG = randf()
			%TreeSpawns.progress_ratio = progressG
			new_grass.global_position = %TreeSpawns.global_position
			add_child(new_grass)
			grass += 1
		# new_tree.z_index = trees - treecount
		add_child(new_tree)
		

		progress = progressB 
		trees += 1

func _on_bird_dead():
	birdcount -= 1

func _on_wave_timer_timeout():
	spawn_wave()

func _on_bird_timer_timeout():
	if birdcount <= 10:
		spawn_bird()
		birdcount += 1
