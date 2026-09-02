extends Node2D

@export var projectile_scene: PackedScene = preload("res://modules/gold/gold.tscn")
@export var object_scene: PackedScene = preload("res://modules/object/object.tscn")
@export var enemy_scene: PackedScene = preload("res://modules/enemy/enemy.tscn")
@export var spawn_count: int = 3
@export var launch_velocity: float = 200.0


@onready var alert_timer = $Alert

var enemy_speed_mult:float = 1.0

func _ready():
	
	Global.game = self
	
	await get_tree().create_timer(4).timeout
	
	spawn_gold()
	spawn_objects()
	spawn_enemies()
	
	

func spawn_objects():
	if object_scene == null:
		return
	
	for i in range(12):
		var projectile = object_scene.instantiate()
		
		add_child(projectile)
		
		var random_direction = Vector2.UP.rotated(randf() * TAU)
		
		var offset = 400
		projectile.global_position = random_direction * offset
		
		if projectile is RigidBody2D:
			projectile.linear_velocity = random_direction * 10

func spawn_gold():
	if projectile_scene == null:
		return
	
	for i in range(max(0, Global.web_n - 2)):
		var inst = projectile_scene.instantiate()
		
		add_child(inst)
		#inst.target
		
		var random_direction = Vector2.UP.rotated(randf() * TAU)
		
		var offset = 30
		inst.global_position = random_direction * offset
		
		if inst is RigidBody2D:
			inst.linear_velocity = random_direction * launch_velocity


func spawn_enemies():
	if enemy_scene == null:
		return
	
	for i in range((Global.web_n - 2) / 2):
		var enemy = enemy_scene.instantiate()
		
		add_child(enemy)
		
		var random_direction = Vector2.UP.rotated(randf() * TAU)
		
		var offset = 200
		enemy.global_position = random_direction * offset
		
		if enemy is RigidBody2D:
			enemy.linear_velocity = random_direction * 10


func _on_web_entered():
	print("web entered")
	enemy_speed_mult = 2.0

func _on_web_exited():
	print("web exited")
	alert_timer.start()
	

func _on_alert_timeout() -> void:
	enemy_speed_mult = 1.0
