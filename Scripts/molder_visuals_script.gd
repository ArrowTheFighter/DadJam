extends Node
@onready var animation_player: AnimationPlayer = $"../ConveyorTest/part_Molder/AnimationPlayer"

@export var machine : Machine
@export var start_pos : Node3D
@export var middle_pos : Node3D
@export var end_pos : Node3D

func _ready() -> void:
    machine.input_started.connect(input_started)
    machine.output_started.connect(output_started)
    machine.process_started.connect(process_started)
    machine.process_finished.connect(process_finished)
    animation_player.play("anim_Mold_Open_001")
    pass
    
    
func process_started():
    animation_player.play("anim_Mold_Close")
    pass

    
func process_finished(ingredients):
    animation_player.play("anim_Mold_Open_001")
    
func input_started(item_number):
    var tween = create_tween()
    #item_parent.global_position = start_pos.global_positionsd
    tween.tween_property(machine.display_points[item_number],"global_position",middle_pos.global_position,machine.input_duration)
    
    pass
    
func output_started():
    var tween = create_tween()
    tween.tween_property(machine.display_points[0],"global_position",end_pos.global_position,machine.output_duration)
    
    pass


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
    if anim_name == "anim_Mold_Close":
        animation_player.play("anim_Mold_Bake")
    pass # Replace with function body.
