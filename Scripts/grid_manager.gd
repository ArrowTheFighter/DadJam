extends Node

var grid_spots_status : Array[Vector2i]
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass
    
func get_grid_pos_status(pos: Vector2i) -> bool:
    return grid_spots_status.has(pos)
    
func set_grid_pos(pos : Vector2i,full: bool):
    if full:
        grid_spots_status.append(pos)
    else:
        grid_spots_status.erase(pos)
    
