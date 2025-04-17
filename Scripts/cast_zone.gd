extends Area2D
var full_text := "[ Space = Cast ]"
var body_inside = false
signal cast_ready


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	%CastPrompt.text = ""
	%CastPrompt.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if body_inside:
		emit_signal("cast_ready")


func _on_body_entered(body):
	%CastPrompt.visible = true
	body_inside = true
	await _type_text(full_text)
		
func _type_text(text):
	%CastPrompt.text = ""
	for i in text.length():
		%CastPrompt.text += text[i]
		await get_tree().create_timer(0.01).timeout

func _on_body_exited(body):
	body_inside = false
	await _erase_text()
	%CastPrompt.visible = false
	%UiBoxes._erase_text(%Line1, 0.01)
	%UiBoxes._erase_text(%Line2, 0.01)
	if %Activity.text != " Idle":
		await %UiBoxes._erase_text(%Activity, 0.01)
		await %UiBoxes._type_text(" Idle", %Activity)


func _erase_text():
	while %CastPrompt.text.length() > 0:
		%CastPrompt.text = %CastPrompt.text.left(%CastPrompt.text.length() - 1)
		await get_tree().create_timer(0.01).timeout
