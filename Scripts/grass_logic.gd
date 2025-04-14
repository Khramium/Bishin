extends AnimatedSprite2D


func _ready():
	self.speed_scale = randf()
	self.play("grass")
