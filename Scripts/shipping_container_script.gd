extends Node

@export var machine : Machine

func _ready() -> void:
    machine.process_started.connect(ship_item)
    
    
func ship_item():
    machine.cancel_process()
    machine.cancel_output()
    ShippingManager.ship_item(machine.holding_items[0])
    machine.empty_machine()
    print("shipping item")
