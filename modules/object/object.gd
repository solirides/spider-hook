extends RigidBody2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	generate_shape()

func generate_shape():
	var points = []
	var radius = 50
	var n = 8
	for i in range(n):
		points.append(Vector2(1,0).rotated(2*PI*i/float(n)) * randf_range(0.4,1)*radius)
	
	var poly = Geometry2D.convex_hull(points)
	
	$CollisionShape2D.shape = ConvexPolygonShape2D.new()
	$CollisionShape2D.shape.points = PackedVector2Array(poly)
	$Polygon2D.polygon = PackedVector2Array(poly)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
