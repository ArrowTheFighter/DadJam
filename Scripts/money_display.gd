extends Label


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    MoneyManager.money_updated.connect(set_display)
    pass # Replace with function body.


func set_display(amount : int):
    print("setting money display to = " + str(amount))
    var new_text = "Money: " + str(amount)
    text = new_text
