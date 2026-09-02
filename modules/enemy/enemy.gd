extends RigidBody2D

var target:Node2D
@export var speed:float = 250
var start_time:int
var health = 100

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var poly = []
	var radius = 18
	var l = 3
	var n = 7
	for i in range(n*2):
		poly.append(Vector2(1,0).rotated(2*PI*i/float(n*2))*(radius - l*(i%2)))
	
	$Polygon2D.polygon = PackedVector2Array(poly)
	
	start_time = Time.get_ticks_msec()

func _physics_process(delta: float) -> void:
	target = Global.player
	if target:
		var dir = (target.global_position - global_position).normalized()
		#dir = dir.rotated(0.3 * PI * (1 - floor(fmod((start_time/1000), 1))))
		var s = speed
		if Global.game:
			s *= Global.game.enemy_speed_mult
		self.apply_central_force(dir * s)
		


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func take_damage(amount):
	health -= amount
	print("enemy take damage")
	var tween = create_tween()
	
	for i in range(4):
		tween.tween_property(self, "modulate", Color(1,0,0,1), 0.1).set_trans(Tween.TRANS_SINE)
		tween.tween_property(self, "modulate", Color(1,1,1,1), 0.1).set_trans(Tween.TRANS_SINE)
	tween.tween_interval(0.5)
	
	if health <= 0:
		die()

func die():
	var tween = create_tween()
	
	tween.tween_property(self, "scale", Vector2(1.2, 1.2), 0.2).set_trans(Tween.TRANS_SINE)
	
	tween.parallel().tween_property(self, "scale", Vector2.ZERO, 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(self, "rotation", PI * 2, 0.5).set_trans(Tween.TRANS_SINE)
	
	tween.tween_callback(queue_free)
