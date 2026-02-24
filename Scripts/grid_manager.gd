extends Node

const GRID_SIZE = 1.5
var grid_spots_status = Set.new()

var StoredObjects : Array[PlacedObjectInfo]

signal grid_updated
# Called when the node enters the scene tree for the first time.

func get_grid_pos_status(pos: Vector2i) -> bool:
    return grid_spots_status.contains(pos)
    
func get_machine_at_grid_position(pos: Vector2i):
    for i in range(StoredObjects.size()):
        if StoredObjects[i].object_grid_pos == pos:
            return StoredObjects[i].object_node
    return null

func set_pos_filled(pos : Vector2i):
    grid_spots_status.add(pos)
    
func set_grid_pos(pos : Vector2i, object_node: Node3D,object_rotation : int):
        grid_spots_status.add(pos)
        var placed_object_info = PlacedObjectInfo.new(object_node,pos,object_rotation)
        StoredObjects.append(placed_object_info)
        grid_updated.emit()
        
func remove_object_from_grid(pos: Vector2i):
    if !get_grid_pos_status(pos):
        return
    for i in range(StoredObjects.size()):
        if StoredObjects[i].object_grid_pos == pos:
            StoredObjects[i].object_node.queue_free()
            grid_spots_status.remove(pos)
            StoredObjects.erase(StoredObjects[i])
            break
    grid_updated.emit()
            
    
