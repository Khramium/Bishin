extends Node
# Trying to keep all save related bullshit in this one script
# if you are reading this, hi!
var save_dict = {
	"FISH" : false,
	"FISH 2" : false,
	"SEA BASS" : false,
	"CLOWNFISH" : false,
	"COD" : false,
	"PINKO" : false,
	"RAINBOW TROUT" : false,
	"BREAD" : false,
	"HALIBUT" : false,
	"SKRIMP" : false,
	"BLAHAJ" : false,
	"CRAB" : false,
	"JOHN DORY" : false,
	"PUFFERFISH" : false,
	"COOL FISH" : false,
	"BRYSON" : false,
	"CREATURE" : false,
	"ANGLER FISH" : false,
	"RAT BOY GENIUS" : false,
	"BLOOPER" : false,
	"THIS GUY" : false,
	"FISHERMAN" : false,
	"BIG FISH BOSS" : false,
	"UNFATHOMABLE HORROR" : false,
	"DEV FISH" : false,
	"INVISIFISH" : false,
	"OLD BOOT" : false,
	"THE LOOKER" : false
}

func ready():
	var SaveData = load_save()
	%Fishpendiun.save = SaveData

func _load_json(path):
	var file = FileAccess.open(path, FileAccess.READ)
	if file:
		var content = file.get_as_text()
		var parsed = JSON.parse_string(content)
		return parsed
	return null

func load_save():
	if not FileAccess.file_exists("user://savegame.save"):
		_first_save()
	var daya
	var save_file = FileAccess.open("user://savegame.save", FileAccess.READ)
	if save_file:
		var json_string = save_file.get_as_text()
		var save_data = JSON.parse_string(json_string)
		save_file.close()
		return save_data
	else:
		printerr("Error: Could not open save file for reading.")
		return null

func write_save_data():
	save_dict = %Fishpendium.save
	return save_dict

func save():
	var data = write_save_data()
	# /home/lavie/.local/share/godot/app_userdata/Bishin/
	var save_file = FileAccess.open("user://savegame.save", FileAccess.WRITE)
	var json_string = JSON.stringify(data)
	save_file.store_line(json_string)
	# load_save()
	
func _first_save():
	var savey = save_dict
	print("Making first save: " + str(savey))
	var save_file = FileAccess.open("user://savegame.save", FileAccess.WRITE)
	var json_string = JSON.stringify(savey)
	save_file.store_line(json_string)
	save_file.close()
