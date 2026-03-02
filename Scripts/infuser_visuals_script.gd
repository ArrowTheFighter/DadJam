extends Node

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
    pass
    
    
func input_started(item_number):
    var tween = create_tween()
    #item_parent.global_position = start_pos.global_positionsd
    tween.tween_property(machine.display_points[item_number],"global_position",middle_pos.global_position,machine.input_duration)
    
    pass
    
func process_started():
    animation_player.play("anim_Injector")
    pass
    
func process_ended(ingredients):
    animation_player.pause()
    pass
    
func output_started():
    var tween = create_tween()
    tween.tween_property(machine.display_points[0],"global_position",end_pos.global_position,machine.output_duration)
    
    pass
