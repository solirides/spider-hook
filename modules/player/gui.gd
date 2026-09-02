extends Control




# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$ColorRect.visible = false
	$ColorRect.modulate = Color(1,1,1,0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("die"):
		dev_death()
	$Label2.text = "score: " + str(Global.score)

func show_end_screen():
	var tween = create_tween()
	tween.tween_property($ColorRect, "modulate", Color(1,1,1,1), 1.0)
	$ColorRect.visible = true
	$ColorRect/Label2.text = "score: " + str(Global.score)

func dev_death():
	Global.player.take_damage(1000)
	print("Sus")
