extends Node

@export var machine : Machine
@export var planet_num : int
func _ready() -> void:
    machine.process_started.connect(ship_item)
    
    
func ship_item():
    await get_tree().create_timer(0.51).timeout 
    machine.cancel_process()
    machine.cancel_output()
    print("shipping with planet num = " + str(planet_num))
    match planet_num:
        1:
            ShippingManager.ship_item(machine.holding_items[0])
            print("shipping item to planet 1")
        2:
            ShippingManager.ship_item_planet_2(machine.holding_items[0])
            print("shipping item to planet 2")
        3:
            ShippingManager.ship_item_planet_3(machine.holding_items[0])
            print("shipping item to planet 3")
    machine.empty_machine()
