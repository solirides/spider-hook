extends ColorRect

@export var player: Node2D
@onready var camera = get_viewport().get_camera_2d()

var amplitude = 2
var thickness = 2
var speed = 30
var frequency = 0.1

var amp_tween:Tween
var f_tween:Tween

func _on_hook_anchored(body, pos):
	animate()

func animate():
	amp_tween = create_tween()
	amplitude = 50
	amp_tween.tween_property(self, "amplitude", 2, 0.2).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	
	f_tween = create_tween()
	frequency = 0.8
	f_tween.tween_property(self, "frequency", 0.1, 0.2).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	
	

func _process(_delta):
	if camera:
		var viewport_size = get_viewport_rect().size
		var world_top_left = camera.global_position - (viewport_size / 2.0)
		
		global_position = world_top_left
		
		size = viewport_size
	
	if player == null:
		return
	
	var pos_1 = (player.global_position)
	var pos_2 = (player.active_hook.global_position if player.active_hook else pos_1)
	
	material.set_shader_parameter("point_a", pos_1)
	material.set_shader_parameter("point_b", pos_2)
	material.set_shader_parameter("amplitude", amplitude)
	material.set_shader_parameter("speed", speed)
	material.set_shader_parameter("thickness", thickness)
	material.set_shader_parameter("frequency", frequency)
