extends VBoxContainer
const UI_QUALITY_DISPLAY = preload("uid://6vvha3oweedu")


func _ready() -> void:
    var PlayerNode = get_tree().get_first_node_in_group("Player")
    var player_raycast : PlayerRaycast = find_descendant_of_type(PlayerNode,PlayerRaycast)
    player_raycast.item_picked_up.connect(setup_pickup_tabs)
    player_raycast.item_dropped.connect(clear_tabs)
    
func setup_pickup_tabs(pickup : Pickup):
    print("setting up pickup display")
    add_tab(pickup.item_info.item_name,Color.GRAY)
    for quality in pickup.item_qualities:
        var text : String = QualityEnum.Property.keys()[quality]
        var adjusted : String = text.to_lower()
        adjusted[0] = adjusted[0].to_upper()
        var tab = add_tab(adjusted)
        move_child(tab,0)

func add_tab(text : String,color : Color = Color.WHITE) -> Node:
    var new_tab = UI_QUALITY_DISPLAY.instantiate()
    
    add_child(new_tab)
    new_tab.set_text(text,color)
    return new_tab
    
func clear_tabs():
    for child in get_children():
        child.queue_free()

func find_descendant_of_type(node : Node,script: Script) -> Node:
    for child in node.get_children():
        if child.get_script() == script:
            return child

        var found := find_descendant_of_type(child, script)
        if found:
            return found

    return null
