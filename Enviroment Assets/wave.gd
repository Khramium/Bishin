extends CharacterBody2D


var speed = 80

func _ready():
	$AnimatedSprite2D.play("waves")

func _physics_process(delta):
	var direction = Vector2.LEFT
	velocity = direction * speed
	move_and_slide()

func _on_timer_timeout():
	queue_free()
