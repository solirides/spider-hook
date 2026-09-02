extends Node2D

# Configuration constants to ensure consistency between drawing and physics
const RING_SPACING = 400
const INNER_RINGS_COUNT = 4
const OUTER_RING_THICKNESS_MULT = 1.4
const LINE_WIDTH_SPOKE = 5
const LINE_WIDTH_RING = 3
var line_width_mult = 1.0

var start_time: int = 0
var color_tween: Tween = null
var web_container: Node2D
var web_t: float = 1.0

func _ready() -> void:
	start_time = Time.get_ticks_msec()
	web_container = Node2D.new()
	add_child(web_container)
	
	# Start the infinite animation loop
	await get_tree().create_timer(3).timeout
	start_web_cycle()

func _process(_delta: float) -> void:
	queue_redraw()
	#
	#if Input.is_action_just_pressed("ui_up"):
		##pass
		#update_web_physics()
	#if Input.is_action_just_pressed("ui_down"):
		## Manual trigger if needed, though start_web_cycle handles it now
		#animate_web_to_value(Global.web_n)

func _draw() -> void:
	var window_size = get_window().size
	var center = Vector2(0, 0)
	var outer_radius = RING_SPACING * (INNER_RINGS_COUNT + 1)
	
	var n = floor(web_t) + 1
	for i in range(n):
		var theta = 2 * PI * i / web_t
		var theta2 = 2 * PI * (i + 1) / web_t
		if i == n - 1:
			theta2 = 0
		
		# Draw Spoke
		draw_line(center, center + Vector2(1, 0).rotated(theta) * RING_SPACING * (INNER_RINGS_COUNT + 3), Color.WHITE, LINE_WIDTH_SPOKE * line_width_mult)
		
		# Draw Inner Rings
		for j in range(1, INNER_RINGS_COUNT + 1):
			var radius = RING_SPACING * j
			draw_line(center + Vector2(1, 0).rotated(theta) * radius, center + Vector2(1, 0).rotated(theta2) * radius, Color.WHITE, LINE_WIDTH_RING * line_width_mult)
		
		# Draw Outer Ring
		draw_line(center + Vector2(1, 0).rotated(theta) * outer_radius, center + Vector2(1, 0).rotated(theta2) * outer_radius, Color.WHITE, LINE_WIDTH_RING * line_width_mult * OUTER_RING_THICKNESS_MULT)

func update_web_physics(active:bool = true) -> void:
	print("update_web_physics")
	for child in web_container.get_children():
		child.queue_free()
	
	# in case player is in web
	if Global.player != null:
			#if Global.player in child.get_overlapping_bodies():
		_on_web_body_exited(Global.player)
	
	# don't create new collisions
	if active == false:
		return
	
	var window_size = get_window().size
	var center = Vector2(0, 0)
	var outer_radius = RING_SPACING * (INNER_RINGS_COUNT + 1)
	var n = floor(web_t) + 1
	
	for i in range(n):
		var theta = 2 * PI * i / web_t
		var theta2 = 2 * PI * (i + 1) / web_t
		if i == n - 1:
			theta2 = 0
		
		# Spoke Area
		var spoke_end = center + Vector2(1, 0).rotated(theta) * window_size.x
		create_line_area(center, spoke_end)
		
		# Inner Ring Areas
		for j in range(1, INNER_RINGS_COUNT + 1):
			var radius = RING_SPACING * j
			var ring_start = center + Vector2(1, 0).rotated(theta) * radius
			var ring_end = center + Vector2(1, 0).rotated(theta2) * radius
			create_line_area(ring_start, ring_end)
		
		# Outer Ring Static Body
		var outer_start = center + Vector2(1, 0).rotated(theta) * outer_radius
		var outer_end = center + Vector2(1, 0).rotated(theta2) * outer_radius
		create_static_line(outer_start, outer_end)

func start_web_cycle() -> void:
	var cycle_tween = create_tween()
	var line_tween = create_tween()
	
	# 1. Animate up to current Global.web_n
	var t1 = 2.0 * Global.web_n
	cycle_tween.tween_callback(Global.game.spawn_gold)
	cycle_tween.tween_property(self, "web_t", Global.web_n, t1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	line_width_mult = 1.0
	line_tween.tween_interval(t1)
	
	# 2. Pause for a moment
	var t2 = 12.0
	cycle_tween.tween_callback(update_web_physics)
	cycle_tween.tween_callback(Global.game.spawn_gold)
	cycle_tween.tween_callback(Global.game.spawn_enemies)
	cycle_tween.tween_interval(t2)
	line_tween.tween_property(self, "line_width_mult", 5.0, min(0.8, t2)).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	line_tween.tween_interval(t2 - min(0.8, t2))
	
	
	# 3. Animate back to 1
	var t3 = 4.0
	cycle_tween.tween_callback(update_web_physics.bind(false))
	cycle_tween.tween_callback(Global.game.spawn_objects)
	cycle_tween.tween_property(self, "web_t", max(1.0, Global.web_n - 3), t3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	line_tween.tween_property(self, "line_width_mult", 1.0, min(0.8, t3)).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	# 4. Increment Global value and repeat
	cycle_tween.tween_callback(func(): 
		Global.web_n += 1
		start_web_cycle()
	)

func animate_web_to_value(target_value: float) -> void:
	var tween = create_tween()
	tween.tween_property(self, "web_t", target_value, 2.0 * target_value).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func create_line_area(from: Vector2, to: Vector2) -> void:
	var area = Area2D.new()
	var collision = CollisionShape2D.new()
	var segment = SegmentShape2D.new()
	
	segment.a = from
	segment.b = to
	collision.shape = segment
	area.add_child(collision)
	web_container.add_child(area)
	
	area.body_entered.connect(_on_web_body_entered)
	area.body_exited.connect(_on_web_body_exited)
	
	area.set_collision_layer_value(3, true)
	area.set_collision_layer_value(1, false)
	area.set_collision_mask_value(1, true)

func create_static_line(from: Vector2, to: Vector2) -> void:
	var body = StaticBody2D.new()
	var collision = CollisionShape2D.new()
	var segment = SegmentShape2D.new()
	
	segment.a = from
	segment.b = to
	collision.shape = segment
	body.add_child(collision)
	web_container.add_child(body)
	
	for i in [1, 2, 3, 4]:
		body.set_collision_mask_value(i, true)
	body.set_collision_layer_value(3, true)

func _on_web_body_entered(body: Node2D) -> void:
	#print(body.is_in_group("Player"))
	if !body.is_in_group("Player"):
		return
	
	#print(Global.game)
	if Global.game:
		Global.game._on_web_entered()
	
	if color_tween: color_tween.kill()
	color_tween = create_tween()
	color_tween.tween_property(self, "modulate", Color.RED, 0.1)

func _on_web_body_exited(body: Node2D) -> void:
	if !body.is_in_group("Player"):
		return
	
	if Global.game:
		Global.game._on_web_exited()
	
	if color_tween: color_tween.kill()
	color_tween = create_tween()
	color_tween.tween_property(self, "modulate", Color.WHITE, 1.0)
