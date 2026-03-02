extends Control
const UI_MACHINE_TAB = preload("uid://d2ar4maphqm3o")
@onready var v_box_container: VBoxContainer = $Panel/ScrollContainer/CenterContainer/VBoxContainer

var inventory_is_open := false 
var player_inventory : PlayerInventory
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    var player_node = get_tree().get_first_node_in_group("Player")
    player_inventory = find_descendant_of_type(player_node, PlayerInventory)
    
    spawn_machine_list(player_inventory)
    pass # Replace with function body.

func _input(event: InputEvent) -> void:
    if event.is_action_pressed("toggle_inventory"):
        print("toggle inventory pressed")
        var mouse_capture = get_tree().get_first_node_in_group("MouseCaptureGroup")
       
        if inventory_is_open:
            mouse_capture.capture_mouse()
            visible = false
            inventory_is_open = false
        else:
            mouse_capture.release_mouse()
            visible = true
            inventory_is_open = true
        

func spawn_machine_list(inventroy : PlayerInventory):
    var i = 0
    for machine in inventroy.items:
        var machine_tag = UI_MACHINE_TAB.instantiate()
        v_box_container.add_child(machine_tag)
        var instanced_machine = machine.instantiate()
        var machine_button = machine_tag.setup_tab(instanced_machine,i)
        instanced_machine.queue_free() 
        machine_tag.machine_tab_pressed.connect(machine_tab_pressed)
        i += 1
        
        
func machine_tab_pressed(number):
    player_inventory.select_item(number)
    var mouse_capture = get_tree().get_first_node_in_group("MouseCaptureGroup")
    mouse_capture.capture_mouse()
    visible = false
    inventory_is_open = false
    pass
    
func find_descendant_of_type(node : Node,script: Script) -> Node:
    for child in node.get_children():
        if child.get_script() == script:
            return child

        var found := find_descendant_of_type(child, script)
        if found:
            return found

    return null
