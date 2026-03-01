extends HSlider

var player_camera
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    player_camera = find_descendant_of_type(get_tree().get_first_node_in_group("Player"),PlayerCamera)
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func value_changed(value):
    player_camera.sensitivity = value
    pass
    
func find_descendant_of_type(node : Node,script: Script) -> Node:
    for child in node.get_children():
        if child.get_script() == script:
            return child

        var found := find_descendant_of_type(child, script)
        if found:
            return found

    return null
