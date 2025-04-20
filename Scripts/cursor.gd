extends AnimatedSprite2D
var online = false
var exit = true
var typing = false

func _process(delta):
	if not online: return
	if Input.is_action_just_pressed("ui_up") and exit == false:
		if online:
			%UISound.play()
		%Cursor.global_position = Vector2(1220.879, 44.2281)
		exit = true
		%Player.exitable = true
	if Input.is_action_just_pressed("ui_down") and exit == true:
		if online:
			%UISound.play()
		%Cursor.global_position = Vector2(1220.879, 139.2281)
		exit = false
		%Player.exitable = false
	if Input.is_action_just_pressed("ui_accept") and exit == false and not typing:
		if online:
			%UISound.play()
		%SaveStuff.save()
		await %UiBoxes._erase_text(%Line2, 0.01)
		if typing == false:
			typing = true
			await %UiBoxes._type_text('"Got it all written down!"', %Line2)
			await get_tree().create_timer(1).timeout
			typing = false

func _on_fishpendium_cursormode():
	online = true
