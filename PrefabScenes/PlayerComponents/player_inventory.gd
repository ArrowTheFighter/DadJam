extends Node
class_name PlayerInventory

signal selected_item_changed

var selected_item = 0
@export var items : Array[PackedScene]

func _input(event: InputEvent) -> void:
    if event.is_action_pressed("hotbar_next"):
        selected_item += 1
        if selected_item > items.size() - 1:
            selected_item = 0
        selected_item_changed.emit()
    elif event.is_action_pressed("hotbar_previous"):
        selected_item -= 1
        if selected_item < 0:
            selected_item = items.size() - 1
        selected_item_changed.emit()
    
func get_selected_item() -> PackedScene:
    return items[selected_item]
        
