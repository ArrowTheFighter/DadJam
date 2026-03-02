extends Node
@onready var cube_023: MeshInstance3D = $"../ConveyorTest/SM_Machine_Arrow_Colored_01/Cube_023"
@onready var cube_024: MeshInstance3D = $"../ConveyorTest/SM_Machine_Arrow_Colored_01/Cube_024"

@export var machine : Machine
@export var start_pos : Node3D
@export var middle_pos : Node3D
@export var end_pos : Node3D
@export var animation_player: AnimationPlayer 

func _ready() -> void:
    machine.input_started.connect(input_started)
    machine.output_started.connect(output_started)
    machine.process_started.connect(process_started)
    machine.process_finished.connect(process_ended)
    await get_tree().create_timer(0.1).timeout
    var tween = create_tween()
    tween.tween_property(cube_023,"rotation_degrees:y",95,0.5).set_trans(Tween.TRANS_BACK)
    
    
    var tween2 = create_tween()
    tween2.tween_property(cube_024,"rotation_degrees:y",-95,0.5).set_trans(Tween.TRANS_BACK)
    pass
    
    
func input_started(item_number):
    var tween = create_tween()
    #item_parent.global_position = start_pos.global_positionsd
    tween.tween_property(machine.display_points[item_number],"global_position",middle_pos.global_position,machine.input_duration)
    
    pass
    
func process_started():
    if animation_player != null:
        animation_player.play("anim_Mixer_Middle")
    
    var tween = create_tween()
    tween.tween_property(cube_023,"rotation_degrees:y",0,0.5).set_trans(Tween.TRANS_BACK)
    
    
    var tween2 = create_tween()
    tween2.tween_property(cube_024,"rotation_degrees:y",0,0.5).set_trans(Tween.TRANS_BACK)
    
    pass
    
func process_ended(ingredients):
    if animation_player != null:
        animation_player.pause()
    var tween = create_tween()
    tween.tween_property(cube_023,"rotation_degrees:y",95,0.5).set_trans(Tween.TRANS_BACK)
    
    
    var tween2 = create_tween()
    tween2.tween_property(cube_024,"rotation_degrees:y",-95,0.5).set_trans(Tween.TRANS_BACK)
    pass
    
func output_started():
    var tween = create_tween()
    tween.tween_property(machine.display_points[0],"global_position",end_pos.global_position,machine.output_duration)
    
    pass
