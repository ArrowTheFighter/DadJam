extends HBoxContainer

const ITEM_HOTBAR_DISPLAY = preload("uid://b0xnxjhp10ild")
var player_inventory : PlayerInventory

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    
    var PlayerNode = get_tree().get_first_node_in_group("Player")
    player_inventory = find_descendant_of_type(PlayerNode,PlayerInventory)
    
    for item in player_inventory.items:
        var instanced_diplay = ITEM_HOTBAR_DISPLAY.instantiate()
        add_child(instanced_diplay)
        var instanced_item = item.instantiate()
        instanced_diplay.set_cost_text("$" + str(instanced_item.machine_cost))
        instanced_item.queue_free()
    
    player_inventory.selected_item_changed.connect(hotbar_item_changed)
    hotbar_item_changed()
    pass # Replace with function body.
    


func hotbar_item_changed():
    for display in get_children():
        display.set_unselected()
    get_child(player_inventory.selected_item).set_selected()
    pass
    
func find_descendant_of_type(node : Node,script: Script) -> Node:
    for child in node.get_children():
        if child.get_script() == script:
            return child

        var found := find_descendant_of_type(child, script)
        if found:
            return found

    return null
