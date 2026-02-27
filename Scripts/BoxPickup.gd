extends Pickup
@export var positions : Array[Node3D]



func add_items_to_box(items : Array[ItemInfo]):
    for i in range(items.size()):
        var item_scene = items[i].get_item_scene().instantiate()
        var mesh_only_node = extract_meshes(item_scene)
        positions[i].add_child(mesh_only_node)
        mesh_only_node.position = Vector3.ZERO
    pass

func extract_meshes(root: Node) -> Node3D:
    var container := Node3D.new()
    container.name = root.name + "_Meshes"

    _collect_meshes_recursive(root, container)
    return container
    
func _collect_meshes_recursive(current: Node, container: Node3D) -> void:
    if current is MeshInstance3D:
        var mesh_copy := current.duplicate()
        container.add_child(mesh_copy)

    for child in current.get_children():
        _collect_meshes_recursive(child, container)
