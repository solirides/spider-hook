extends RigidBody2D

@export var gforce:float = 100
@export var move_speed: float = 1000.0
@export var launch_speed: float = 3000.0
@export var grapple_pull_force: float = 3500.0
@export var hook_scene: PackedScene  = preload("res://modules/player/hook.tscn") 
@export var gui: Node

var health = 100
var immune = false
var grapple_ready: bool = true
var is_grappling: bool = false
var active_hook: RigidBody2D = null
var grapple_target: PhysicsBody2D
var alive = true
var last_hit_or_heal_time = 0

func _ready():
	add_to_group("player")
	Global.player = self
	
	var poly = []
	var radius = 20
	var n = 24
	for i in range(n):
		poly.append(Vector2(1,0).rotated(2*PI*i/float(n))*radius)
	
	#$CollisionShape2D.shape.points = PackedVector2Array(poly)
	$Polygon2D.polygon = PackedVector2Array(poly)

func _physics_process(_delta):
	#var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	#apply_central_force(input_dir * move_speed)

	if Input.is_action_just_pressed("left_mouse") and not is_grappling:
		if grapple_ready:
			grapple_ready = false
			$Timer.start()
			launch_hook()
			$CanvasLayer/Rope.animate()
		
	
	if Input.is_action_just_released("left_mouse"):
		release_grapple()

	if is_grappling:
		handle_grapple_physics()
	
	var time = Time.get_ticks_msec()
	if time - last_hit_or_heal_time >= 12 * 1000:
		last_hit_or_heal_time = time

func _process(_delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	if active_hook:
		pass
		#draw_line(Vector2(0,0), to_local(active_hook.global_position), Color(1,1,1,1), 3)

func handle_grapple_physics():
	if active_hook == null:
		release_grapple()
		return
	
	var pull_dir = (active_hook.global_position - global_position).normalized()
	apply_central_force(pull_dir * grapple_pull_force)
	if grapple_target != null:
		if grapple_target is RigidBody2D:
			grapple_target.apply_central_force(-pull_dir * grapple_pull_force)

func launch_hook():
	if not hook_scene:
		return
	var hook = hook_scene.instantiate()
	hook.global_position = global_position
	var dir = (get_global_mouse_position() - global_position).normalized()
	get_parent().add_child(hook)
	# add to scene after setting pos so physics interpolation doesn't freak out
	
	hook.apply_central_impulse(dir * hook.mass * launch_speed)
	self.apply_central_impulse(-dir * hook.mass * launch_speed) 
	
	hook.anchored.connect(_on_hook_anchored)
	hook.missed.connect(_on_hook_missed)
	active_hook = hook

func _on_hook_anchored(body, pos):
	grapple_target = body
	is_grappling = true

func _on_hook_missed():
	#active_hook = null
	#is_grappling = false
	release_grapple()

func release_grapple():
	is_grappling = false
	if active_hook:
		active_hook.queue_free()
		active_hook = null


func _on_body_entered(body: Node) -> void:
	if body.is_in_group("Gold"):
		print("Gold collected!")
		body.collect()
	if body.is_in_group("Enemy"):
		take_damage(20)


func _on_timer_timeout() -> void:
	grapple_ready = true


func take_damage(amount):
	if immune:
		return
	health -= amount
	immune = true
	print("Take damage")
	last_hit_or_heal_time = Time.get_ticks_msec()
	
	var tween = create_tween()
	
	for i in range(4):
		tween.tween_property(self, "modulate", Color(1,0,0,1), 0.1).set_trans(Tween.TRANS_SINE)
		tween.tween_property(self, "modulate", Color(1,1,1,1), 0.1).set_trans(Tween.TRANS_SINE)
	tween.tween_interval(0.5)
	tween.tween_callback(set_unimmune)
	
	if health <= 0 and alive:
		die()
		

func set_unimmune():
	immune = false

func die():
	print("player died")
	alive = false
	var tween = create_tween()
	
	tween.tween_property(self, "scale", Vector2(1.1, 1.1), 0.3).set_trans(Tween.TRANS_SINE)
	
	tween.parallel().tween_property(self, "scale", Vector2.ZERO, 5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.parallel().tween_property(self, "rotation", 30*PI, 5).set_trans(Tween.TRANS_SINE)
	
	gui.show_end_screen()
	
