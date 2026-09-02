extends Camera2D

@export var target:Node

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#print(global_position)
	#global_position = target.global_position
	var speed = 8
	var follow = 0.6
	var final_pos = target.global_position + (get_global_mouse_position() - self.global_position)*0.5*follow
	global_position = lerp(global_position, final_pos, speed*delta)
	
	
	
