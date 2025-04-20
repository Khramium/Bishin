extends Area2D
var full_text := "[Space = Leave]"
var body_inside = false
signal leave_ready


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	%LeavePrompt.text = ""
	%LeavePrompt.visible = false


func _process(delta):
	if body_inside and Input.is_action_just_pressed("ui_accept"):
		get_tree().change_scene_to_file("res://menu.tscn")

func reset():
	%LeavePrompt.visible = true
	body_inside = true
	await _type_text(full_text)
	
func _on_body_entered(body):
	reset()

func _type_text(text):
	%LeavePrompt.text = ""
	for i in text.length():
		%LeavePrompt.text += text[i]
		await get_tree().create_timer(0.01).timeout

func _on_body_exited(body):
	body_inside = false
	%LeavePrompt.visible = false


func _erase_text():
	while %LeavePrompt.text.length() > 0:
		%LeavePrompt.text = %LeavePrompt.text.left(%LeavePrompt.text.length() - 1)
		await get_tree().create_timer(0.01).timeout
