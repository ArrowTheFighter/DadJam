extends Node

@export var machine : Machine
@export var item_parent : Node3D
@export var start_pos : Node3D
@export var middle_pos : Node3D
@export var end_pos : Node3D

func _ready() -> void:
    machine.input_started.connect(input_started)
    machine.output_started.connect(output_started)
    pass
    
    
func input_started():
    var tween = create_tween()
    item_parent.global_position = start_pos.global_position
    tween.tween_property(item_parent,"global_position",middle_pos.global_position,machine.input_duration)
    
    pass
    
func output_started():
    var tween = create_tween()
    tween.tween_property(item_parent,"global_position",end_pos.global_position,machine.output_duration)
    
    pass
