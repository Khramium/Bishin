extends Sprite2D

var full_text := "[ Space = Cast ]"
var body_inside := false
var waiting = false

signal cast_ready
signal done

#func _ready():
	#sprite.play("IDLE")

func _erase_text(zone, speed):
	for i in zone.text.length():
		zone.text = zone.text.left(zone.text.length() - 1)
		await get_tree().create_timer(speed).timeout

func _type_text(text, zone):
	for char in text:
		zone.text += char
		await get_tree().create_timer(0.01).timeout

func _erase_all_text(speed):
	for child in get_children():
		if child is Label:
			await _erase_text(child, speed)

func _reset():
	if %Activity.text == "":
		await _type_text(" Idle", %Activity)
		
func _drama(zone):
	zone.text = " waiting."
	var i = 0
	while i <= 3:
		zone.text += "."
		await get_tree().create_timer(0.1).timeout
		i += 1
	i = 0
	while i <= 3:
		zone.text = zone.text.rstrip(".")  # removes trailing periods
		await get_tree().create_timer(0.1).timeout
		i += 1

func _on_player_cast():
	var daddy = self.get_parent()
	var feesh = %FishPond.catch_random_fish()
	var fname = " " + feesh.fname
	var animname = feesh.fname
	var quip = ' "' + feesh.quip + '"'
	
	%Port.play("IDLE")
	animname = animname.to_lower()
	await _erase_all_text(0.01)	
	waiting = true
	feesh.target_position = %Bobber.global_position
	feesh.speed = 100
	feesh.baited = true
	while waiting:
		await _drama(%Activity)
	emit_signal("done")
	%Player.casted = false
	feesh.get_caught()
	await _erase_text(%Activity, 0.01)
	await _type_text(" CAUGHT FISH ", %Activity)
	%Port.play(animname)
	await _type_text(fname, %Line1)
	await _type_text(quip, %Line2)
	var fish = %FishPond.pick_weighted_fish(%FishPond.fish_data)
	daddy.spawn_fish(fish.name, fish.quip, %FishRestock)


func _on_player_shop():
	await _erase_all_text(0.01)
	await _type_text('"Welcome to Fish House!"', %Line2)


func _on_player_out():
	await _erase_all_text(0.01)
	_reset()
	%ShopZone.reset()
