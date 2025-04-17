extends Node2D


var path_node: Path2D
var swim_spot: Area2D
var rng = RandomNumberGenerator.new()
var birdcount = 0
var treelist: Array = []
var fishnames

func add_tree(tree):
	treelist.append(tree)
	
func rand_tree():
	var tree = treelist[randi() % treelist.size()]
	return tree

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
	new_bird.the_pond = self
	%BirdSpawns.progress_ratio = randf()
	new_bird.global_position = %BirdSpawns.global_position
	add_child(new_bird)
	
func _spawn_fish(fname):
	var new_fish = preload("res://Scripts/feesh.tscn").instantiate()
	new_fish.swim_zone = %FishHouse
	new_fish.fname = fname
	%FishSpawns.progress_ratio = randf()
	new_fish.global_position = %FishSpawns.global_position
	add_child(new_fish)

	
func _ready():
	var treecount = 13
	var progress = 0.0
	var progressA = 1.0 / treecount
	
	for i in range(treecount):
		var jitter = rng.randf_range(-0.02, 0.02) # small offset for natural spacing
		var this_progress = clamp(progress + jitter, 0.05, 0.8)
		
		var new_tree = preload("res://Enviroment Assets/tree_01.tscn").instantiate()
		%TreeSpawns.progress_ratio = this_progress
		new_tree.global_position = %TreeSpawns.global_position
		add_child(new_tree)
		add_tree(new_tree)
		
		# Add grass under tree
		for _i in range(3):
			var new_grass = preload("res://Scripts/grass.tscn").instantiate()
			%TreeSpawns.progress_ratio = clamp(this_progress + rng.randf_range(-0.01, 0.01), 0.0, 1.0)
			new_grass.global_position = %TreeSpawns.global_position
			add_child(new_grass)
		
		progress += progressA
	for i in range(15):
		_spawn_fish(%FishPond.pond[i].name)

func _on_bird_dead():
	birdcount -= 1

func _on_wave_timer_timeout():
	spawn_wave()

func _on_bird_timer_timeout():
	if birdcount <= 10:
		spawn_bird()
		birdcount += 1
