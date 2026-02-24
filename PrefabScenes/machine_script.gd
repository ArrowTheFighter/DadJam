extends Node3D
class_name Machine

@export var display_points : Array[Node3D]

var input_positions : Array[Vector2i]
var out_position : Vector2i
var holding_items : Array[ItemInfo]


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass # Replace with function body.

func add_item_to_machine(item_info : ItemInfo):
    holding_items.append(item_info)
    display_item(item_info)

func display_item(item_info :ItemInfo):
    var instanced_item = item_info.item_scene.instantiate()
    for point in display_points:
        if point.get_child_count() <= 0:
            point.add_child(instanced_item)
            instanced_item.position = Vector3.ZERO
