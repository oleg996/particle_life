extends Control


@export var sim:Node2D
	

	


func _on_h_slider_value_changed(value: float) -> void:
	sim.drag = value ;
	print(value)


func _on_button_pressed() -> void:
	
	for i in sim.forces.size():
		sim.forces[i] = randf_range(-1,1)
		
	sim.update_forces()
	_readforces()

func force_slider_value_changed(value: float) -> void:
	sim.force = value * 3


func rep_force_changed(value: float) -> void:
	sim.rep_force = value * 3
	
	
func _ready() -> void:

	
	await get_tree().process_frame
	$VBoxContainer/GridContainer.columns = sim.cels_type;
	_init_table()
	_readforces()

func _init_table():
	for f in sim.forces:
		var label = SpinBox.new()
		label.rounded = false
		label.step = 0.1
		label.value = f;
		label.min_value = -1
		label.max_value = 1
		$VBoxContainer/GridContainer.add_child(label)

func _readforces():
	for ch:SpinBox in $VBoxContainer/GridContainer.get_children():
		var index = $VBoxContainer/GridContainer.get_children().find(ch)
		ch.value = sim.forces[index]
	


func _on_button_2_pressed() -> void:
	var obg:Array  = $VBoxContainer/GridContainer.get_children()
	for i in obg.size():
		var sel:SpinBox = obg[i]
		sim.forces[i] = sel.value
	sim.update_forces()


func force_dist(value: float) -> void:
	sim.force_dist = value


func rep_force_dist(value: float) -> void:
	sim.rep_force_dist = value


func speed(value: float) -> void:
	sim.speed = value;
