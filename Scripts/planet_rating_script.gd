extends VBoxContainer
@onready var label: Label = $Label
@onready var label_2: Label = $Label2

@export var planet_num : int
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    match planet_num:
        1:
            ShippingManager.planet_1_shipped.connect(shipped)
        2:
            ShippingManager.planet_2_shipped.connect(shipped)
        3:
            ShippingManager.planet_3_shipped.connect(shipped)
    pass # Replace with function body.


func shipped(score):
    var text = xo_rating_text(score)
    label_2.text = text
    pass

func xo_rating_text(score: int) -> String:
    score = clamp(score, 0, 5)

    var parts: Array[String] = []

    for i in range(5):
        parts.append("XO" if i < score else "--")

    return " ".join(parts)
