extends Node

var current_money : int = 100

signal money_updated(new_amount)

func _ready() -> void:
    ShippingManager.on_money_earned.connect(add_money)
    await get_tree().create_timer(0.01).timeout
    money_updated.emit(current_money)
    
func _input(event: InputEvent) -> void:
    if event.is_action_pressed("add_money"):
        add_money(100)
    
func add_money(money : int):
    current_money += money
    money_updated.emit(current_money)
    
func remove_money(money : int):
    current_money = maxi(0,current_money - money)
    money_updated.emit(current_money)
    
func can_afford(price : int) -> bool:
    return current_money >= price
