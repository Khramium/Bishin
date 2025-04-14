extends CanvasLayer


var rng = RandomNumberGenerator.new()

func _ready():
	var treecount = 15
	var trees = 0
	var progress = 0.0
	var progressA = 1.0 / treecount
	
	while treecount > trees:
		var progressB = progress + progressA + rng.randf_range(0.01, 0.02)

		var new_tree = preload("res://Enviroment Assets/tree_01.tscn").instantiate()
		%TreeSpawns.progress_ratio = clamp(progress, 0.0, 1.0)
		new_tree.global_position = %TreeSpawns.global_position
		new_tree.z_index = treecount - trees
		add_child(new_tree)

		progress = progressB 
		trees += 1
