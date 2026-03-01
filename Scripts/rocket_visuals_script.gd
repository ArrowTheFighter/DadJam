extends Node

@onready var node_3d: Node3D = $"../ConveyorTest/part_Rocket/rig_Rocket/Skeleton3D/Node3D"
@onready var node_3d_2: Node3D = $"../ConveyorTest/part_Rocket/rig_Rocket/Skeleton3D/Node3D2"


@export var machine : Machine
@export var start_pos : Node3D
@export var middle_pos : Node3D
@export var end_pos : Node3D

func _ready() -> void:
    machine.input_started.connect(input_started)
    machine.output_started.connect(output_started)
    machine.process_started.connect(process_started)
    pass
    
func process_started():
    var tween = create_tween()
    
    tween.tween_property(node_3d,"rotation_degrees:x",0,0.5).set_trans(Tween.TRANS_CIRC)
    tween.tween_interval(0.2)
    tween.tween_property(node_3d,"rotation_degrees:x",150,0.5).set_trans(Tween.TRANS_CIRC)
    
    var tween2 = create_tween()
    
    tween2.tween_property(node_3d_2,"rotation_degrees:x",0,0.5).set_trans(Tween.TRANS_CIRC)
    tween2.tween_interval(0.2)
    tween2.tween_property(node_3d_2,"rotation_degrees:x",-150,0.5).set_trans(Tween.TRANS_CIRC)
    pass
    
func input_started(item_number):
    var tween = create_tween()
    #item_parent.global_position = start_pos.global_positionsd
    tween.tween_property(machine.display_points[item_number],"global_position",middle_pos.global_position,machine.input_duration)
    
    pass
    
func output_started():
    var tween = create_tween()
    tween.tween_property(machine.display_points[0],"global_position",end_pos.global_position,machine.output_duration)
    
    pass
