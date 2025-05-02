extends Node2D
@onready var p_am = $VBoxContainer/particle_amount/OptionButton;

@onready var w_size = $"VBoxContainer/world size/OptionButton"

@onready var p_types = $VBoxContainer/particle_types/OptionButton
func  _ready() -> void:
	p_am.add_item("1000")
	p_am.add_item("5000")
	p_am.add_item("10000")
	p_am.add_item("20000")
	p_am.add_item("30000")
	p_am.add_item("50000")
	
	w_size.add_item("1000")
	w_size.add_item("5000")
	w_size.add_item("10000")
	
	p_types.add_item("2")
	p_types.add_item("3")
	p_types.add_item("4")
	p_types.add_item("5")
	p_types.add_item("6")
	p_types.add_item("7")



func start_button() -> void:
	
	Data.p_am = int(p_am.get_item_text(p_am.selected))
	
	Data.w_size = int(w_size.get_item_text(w_size.selected))
	
	Data.p_types = int(p_types.get_item_text(p_types.selected))
	
	get_tree().change_scene_to_file("res://main.tscn")
