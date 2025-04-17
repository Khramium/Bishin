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
		var random_fish = fish_data.pick_random()
		pond.append(random_fish)
		
func _get_random_fish():
	var caught = pond.pick_random()
	pond.erase(caught)
	_fill_pond(1)
#	caught.remove_from_scene()
	return caught
