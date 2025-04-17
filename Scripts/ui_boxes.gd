extends Sprite2D

var full_text := "[ Space = Cast ]"
var body_inside := false
var activity := ""

signal cast_ready
signal done

func _erase_text(zone, speed):
	for i in zone.text.length():
		zone.text = zone.text.left(zone.text.length() - 1)
		await get_tree().create_timer(speed).timeout

func _type_text(text, zone):
	for char in text:
		zone.text += char
		await get_tree().create_timer(0.05).timeout

func _erase_all_text(speed):
	for child in get_children():
		if child is Label:
			await _erase_text(child, speed)

func _reset():
	if %Activity.text == "":
		await _type_text(" Idle", %Activity)
		
func _drama(zone):
	var duration := randf_range(1.0, 4.0)
	var timer := 0.0
	zone.text = " Casting."
	
	while timer < duration:
		var i = 0
		while i <= 3:
			zone.text += "."
			await get_tree().create_timer(0.1).timeout
			timer += 0.1
			i += 1
		i = 0
		while i <= 3:
			zone.text = zone.text.rstrip(".")  # removes trailing periods
			await get_tree().create_timer(0.1).timeout
			timer += 0.1
			i += 1

func _on_player_cast() -> void:
	var feesh = %FishPond._get_random_fish()
	var fname = " " + feesh.name
	var quip = ' "' + feesh.quip + '"'

	await _erase_all_text(0.01)
	await _drama(%Activity)
	await _erase_text(%Activity, 0.01)
	await _type_text(" CAUGHT FISH ", %Activity)
	await _type_text(fname, %Line1)
	await _type_text(quip, %Line2)

	emit_signal("done")
