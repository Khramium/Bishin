extends AnimatedSprite2D
var open = false
var bonus = "open]"

func _process(delta):
	if %Fishpendium.is_playing(): return
	if open:
		_roll()
	else:
		_unroll()

func _unroll():
	if Input.is_action_just_pressed("info"):
		%Fishpendium.play("shutter")
		open = true
		bonus = "close]"
		_type_text()

func _roll():
	if Input.is_action_just_pressed("info"):
		%Fishpendium.play_backwards("shutter")
		open = false
		bonus = "open]"
		_type_text()
		
func _type_text():
	await _erase_text()
	for i in bonus.length():
		$Header.text += bonus[i]
		await get_tree().create_timer(0.03).timeout

func _erase_text():
	while $Header.text.length() > 19:
		$Header.text = $Header.text.left($Header.text.length() - 1)
		await get_tree().create_timer(0.03).timeout
