extends KinematicBody2D

export var ACCELERATION = 2500
export var MAX_SPEED = 140
export var FRICTION = 0.57

enum {
	IDLE,
	WANDER,
	CHASE
}

var velocity = Vector2.ZERO

var state = CHASE

onready var Zona = $Zona

func _physics_process(delta):
	match state:
		IDLE:
			velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
			seek_player()
		
		WANDER:
			pass
		
		CHASE:
			var player = Zona.player
			if player != null:
				var direction = (player.global_position - global_position).normalized()
				velocity = velocity.move_toward(direction * MAX_SPEED, ACCELERATION * delta)
	
	velocity = move_and_slide(velocity)

func seek_player():
	if Zona.can_see_player():
		state = CHASE
