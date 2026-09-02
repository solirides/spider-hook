extends Node2D

@export var player: Node2D

func _process(_delta):
	if player == null:
		return
	
	var pos_1 = (player.global_position)
	var pos_2 = (player.active_hook.global_position if player.active_hook else pos_1)
	
	material.set_shader_parameter("point_a", pos_1)
	material.set_shader_parameter("point_b", pos_2)
