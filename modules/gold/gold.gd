extends RigidBody2D


var collected = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var poly = []
	var radius = 30
	var n = 5
	for i in range(n):
		poly.append(Vector2(1,0).rotated(2*PI*i/float(n))*radius)
	
	# this shape is shared by all instances
	$CollisionShape2D.shape.points = PackedVector2Array(poly)
	$Polygon2D.polygon = PackedVector2Array(poly)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func collect():
	# avoid double counting
	if collected:
		return
	
	collected = true
	Global.score += 1
	
	set_deferred("collision_layer", 0)
	set_deferred("collision_mask", 0)
	
	var tween = create_tween()
	
	tween.tween_property(self, "scale", Vector2(1.2, 1.2), 0.2).set_trans(Tween.TRANS_SINE)
	
	tween.parallel().tween_property(self, "scale", Vector2.ZERO, 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(self, "rotation", PI * 2, 0.5).set_trans(Tween.TRANS_SINE)
	
	tween.tween_callback(queue_free)
	
