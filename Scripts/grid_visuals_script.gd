extends MeshInstance3D



func _ready():
    var mat := get_active_material(0)
    mat.set_shader_parameter("grid_size", GridManager.GRID_SIZE)
