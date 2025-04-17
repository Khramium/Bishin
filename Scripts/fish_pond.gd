extends Node

var fish_data = []
var pond = []
var fishcount = 15

func _ready():
	_load_fish_data()
	_fill_pond(fishcount)
	
	
func _load_fish_data():
	var fishlist = DirAccess.open("res://FishPile/FishFiles/")
	fishlist.list_dir_begin()
	var file_name = fishlist.get_next()
	while file_name != "":
		var path = "res://FishPile/FishFiles/" + file_name
		var json = _load_json(path)
		fish_data.append(json)
		file_name = fishlist.get_next()
	fishlist.list_dir_end()


func _load_json(path):
	var file = FileAccess.open(path, FileAccess.READ)
	if file:
		var content = file.get_as_text()
		var parsed = JSON.parse_string(content)
		return parsed
	return null
	

func _fill_pond(fc):
	for i in range(fc):
		var random_fish = pick_weighted_fish(fish_data)
		
func pick_weighted_fish(fish_data):
	var weights = []
	var total_weight = 0.0
	for fish in fish_data:
		var weight = 1.0 / float(fish["rarity"])
		weights.append(weight)
		total_weight += weight
	var rand = randf() * total_weight
	for i in range(fish_data.size()):
		rand -= weights[i]
		if rand <= 0:
			return fish_data[i]

func catch_random_fish():
	var data = pond.pick_random()
	pond.erase(data)
	return data
