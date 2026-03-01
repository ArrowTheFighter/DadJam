extends RigidBody3D 


@export var item_info : ItemInfo

func _ready() -> void:
    GridManager.set_pos_filled(GridManager.gloabl_to_grid_pos(global_position))
