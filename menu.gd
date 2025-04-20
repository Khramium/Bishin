extends Control

func _ready():
	%"Start Button".grab_focus()

func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scripts/the_pond.tscn")

func _on_quit_button_pressed():
	get_tree().quit()
