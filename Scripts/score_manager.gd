extends ProgressBar


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    ShippingManager.on_score_updated.connect(score_update)
    pass # Replace with function body.


func score_update(score : int):
    value = score
