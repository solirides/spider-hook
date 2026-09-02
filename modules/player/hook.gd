extends RigidBody2D

signal anchored(body, pos) 
signal missed

var travel_distance: float = 0.0
var max_range: float = 1200.0

func _ready() -> void:
	contact_monitor = true
	max_contacts_reported = 3

func _physics_process(delta):
	travel_distance += linear_velocity.length() * delta
	if travel_distance > max_range:
		emit_signal("missed")
		queue_free()

func _on_body_entered(body):
	if body.is_in_group("Player"):
		return
	
	if body is RigidBody2D:
		linear_velocity = Vector2.ZERO
		set_deferred("freeze", true)
		set_deferred("collision_layer", 0)
		set_deferred("collision_mask", 0)
		call_deferred("reparent", body)
	else:
		set_deferred("freeze", true)
		set_deferred("collision_layer", 0)
		set_deferred("collision_mask", 0)
	
	emit_signal("anchored", body, global_position)
