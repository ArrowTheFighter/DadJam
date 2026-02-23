extends Node

var grid_spots_status : Array[Vector2i]

var StoredObjects : Array[PlacedObjectInfo]
# Called when the node enters the scene tree for the first time.

func get_grid_pos_status(pos: Vector2i) -> bool:
    return grid_spots_status.has(pos)
    
func set_grid_pos(pos : Vector2i, object_node: Node3D):
        grid_spots_status.append(pos)
        var placed_object_info = PlacedObjectInfo.new(object_node,pos)
        StoredObjects.append(placed_object_info)
        
func remove_object_from_grid(pos: Vector2i):
    if !get_grid_pos_status(pos):
        return
    for i in range(StoredObjects.size()):
        if StoredObjects[i].object_grid_pos == pos:
            StoredObjects[i].object_node.queue_free()
            grid_spots_status.erase(pos)
            StoredObjects.erase(StoredObjects[i])
            break
            
    
