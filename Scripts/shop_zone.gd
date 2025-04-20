extends Area2D
var full_text := "[Space = Enter]"
var body_inside = false
signal shop_ready

#EXIT MUST BE ON TOP

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	%ShopPrompt.text = ""
	%ShopPrompt.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if body_inside:
		emit_signal("shop_ready")

func reset():
	%ShopPrompt.visible = true
	body_inside = true
	await _type_text(full_text)
	
func _on_body_entered(body):
	reset()

func _type_text(text):
	%ShopPrompt.text = ""
	for i in text.length():
		%ShopPrompt.text += text[i]
		await get_tree().create_timer(0.01).timeout

func _on_body_exited(body):
	body_inside = false
	await _erase_text()
	%ShopPrompt.visible = false
	%UiBoxes._erase_text(%Line1, 0.01)
	%UiBoxes._erase_text(%Line2, 0.01)
	if %Activity.text != " Idle":
		await %UiBoxes._erase_text(%Activity, 0.01)
		await %UiBoxes._type_text(" Idle ", %Activity)
	%Port.play("IDLE")


func _erase_text():
	while %ShopPrompt.text.length() > 0:
		%ShopPrompt.text = %ShopPrompt.text.left(%ShopPrompt.text.length() - 1)
		await get_tree().create_timer(0.01).timeout
