class_name Bullet
extends RigidBody2D

@export_range(0.1, 1000, 0.1) var fuze_length = 2.

var was_shot : bool :
	get:
		return not fuze.is_stopped()
var fuze := Timer.new()

func _ready():
	top_level = true
	contact_monitor = true
	max_contacts_reported = 1
	gravity_scale = 0
	
	add_child(fuze)
	fuze.wait_time = fuze_length
	fuze.one_shot = true
	fuze.timeout.connect(remove)

func shoot(target : Vector2, speed : float, from : Vector2, spread_factor: float, vel_rand_factor: float):
	global_position = from
	
	var angle_delta = randf_range(-1., 1.) * spread_factor / 2. * PI/6.
	var dir = (target - self.global_position).normalized().rotated(angle_delta)
	
	look_at(to_global(dir))
	rotate(PI/2)
	
	var speed_rand_fact = randf_range(-1., 1.) * vel_rand_factor/2. + 1.
	apply_central_force(dir * speed * speed_rand_fact)
	
	fuze.start()

func _on_body_entered(body):
	if was_shot:
		remove()

func remove():
	queue_free()
