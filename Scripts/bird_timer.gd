extends Timer


func _on_timeout() -> void:
	%BirdTimer.wait_time = randi_range(15, 50)
