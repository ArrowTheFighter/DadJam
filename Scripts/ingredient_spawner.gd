extends Node

@export var item :ItemInfo
@export var machine : Machine
@export var spawnPos : Node3D

func _ready() -> void:
    machine.output_finished.connect(spawn_item)
    await get_tree().create_timer(0.1).timeout
    spawn_item()
    pass
    
func spawn_item():
    await get_tree().create_timer(5).timeout
    var item_scene = item.get_item_scene()
    var instanced_item = item_scene.instantiate()
    get_tree().root.add_child(instanced_item)
    instanced_item.global_position = spawnPos.global_position
    machine.add_item_to_machine(instanced_item)
    pass
