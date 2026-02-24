extends Node

@export var machine : Machine
@export var item_parent : Node3D
@export var start_pos : Node3D
@export var end_pos : Node3D

func _ready() -> void:
    machine.machine_started.connect(machine_started)
    pass
    
    
func machine_started():
    var tween = create_tween()
    item_parent.global_position = start_pos.global_position
    tween.tween_property(item_parent,"global_position",end_pos.global_position,machine.machine_process_duration)
    
    pass
    
