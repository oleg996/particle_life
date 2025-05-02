extends Camera2D

var zoom_v = 1;
var move = false;

func _process(delta: float) -> void:
	if move:
		position -=  Input.get_last_mouse_velocity()*delta / zoom_v
		position.clamp(Vector2(0,0),Vector2(10000,10000))


func  _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom_v = clamp(zoom_v*0.9,0.2,10)
			zoom = Vector2(zoom_v,zoom_v)
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom_v = clamp(zoom_v*1.1,0.2,10)
			zoom = Vector2(zoom_v,zoom_v)
		if event.button_index == MOUSE_BUTTON_MIDDLE:
			move = event.pressed
