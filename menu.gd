extends Control

func _ready():
	%BGM.play()
	%"Start Button".grab_focus()

func _on_start_button_pressed() -> void:
	%UISound.play()
	get_tree().change_scene_to_file("res://Scripts/the_pond.tscn")

func _on_quit_button_pressed():
	%UISound.play()
	get_tree().quit()
