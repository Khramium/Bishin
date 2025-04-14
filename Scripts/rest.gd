extends Timer

signal gettup

func _ready():
	var rest = randf_range(1, 3)
	self.wait_time = rest

func _on_timeout():
	emit_signal("gettup")
	self.stop()
