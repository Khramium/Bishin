extends AnimatedSprite2D
var online = false
var exit = true

func _process(delta):
	if not online: return
	if Input.is_action_just_pressed("ui_up") and exit == false:
		%Cursor.global_position = Vector2(1220.879, 44.2281)
		exit = true
		%Player.exitable = true
	if Input.is_action_just_pressed("ui_down") and exit == true:
		%Cursor.global_position = Vector2(1220.879, 139.2281)
		exit = false
		%Player.exitable = false

func _on_fishpendium_cursormode():
	online = true
