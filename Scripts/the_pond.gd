extends Node2D

# To Do
# Add auto-fish toggle
# Add fishpendium

var path_node: Path2D
var swim_spot: Area2D
var rng = RandomNumberGenerator.new()
var birdcount = 0
var treelist: Array = []
var fishnames
var fish_id_counter = 0

func add_tree(tree):
	treelist.append(tree)
	
func rand_tree():
	var tree = treelist[rng.randi() % treelist.size()]
	return tree
	
func spawn_thing(thing, spawnpoint):
	spawnpoint.progress_ratio = randf()
	var guy = thing.instantiate()
	guy.global_position = spawnpoint.global_position
	add_child(guy)
	return guy
	
func spawn_wave():
	spawn_thing(preload("res://Enviroment Assets/wave.tscn"), %SpawnPoint)

func spawn_bird():
	var new_bird = spawn_thing(preload("res://Scripts/bird.tscn"), %BirdSpawns)
	new_bird.dead.connect(_on_bird_dead)
	new_bird.path_node = $TreeSpots
	new_bird.leave_node = %BirdZone
	new_bird.the_pond = self
	
func spawn_fish(fname, quip, zone):
	var new_fish = spawn_thing(preload("res://Scripts/feesh.tscn"), zone)
	new_fish.on_da_line.connect(_on_fish_on_da_line)
	new_fish.swim_zone = %FishHouse
	new_fish.fname = fname
	new_fish.quip = quip
	new_fish.name = "fish_" + str(fish_id_counter)
	fish_id_counter += 1
	new_fish.init_fish(fname, self)
	%FishPond.pond.append(new_fish)
	return new_fish

	
func _ready():
	%BGM.play()
	var count = 13
	var progress = 0.0
	var progressA = 1.0 / count
	for i in range(count):
		var fish = %FishPond.pick_weighted_fish(%FishPond.fish_data)
		spawn_fish(fish.name, fish.quip, %FishSpawns)
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

func _on_bird_dead():
	birdcount -= 1

func _on_wave_timer_timeout():
	spawn_wave()

func _on_bird_timer_timeout():
	if birdcount <= 10:
		spawn_bird()
		birdcount += 1

func _on_fish_on_da_line():
	%UiBoxes.waiting = false
