
class_name PlacedObjectInfo

var object_node : Node3D 
var object_grid_pos : Vector2i

func _init(_object_node : Node3D,_object_grid_pos: Vector2i) -> void:
    object_node = _object_node
    object_grid_pos = _object_grid_pos
