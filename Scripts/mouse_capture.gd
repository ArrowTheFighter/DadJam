extends Node

signal MouseReleased
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
    pass # Replace with function body.
func _input(event: InputEvent) -> void:
    if Input.is_action_just_pressed("ui_cancel"):
        Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
        MouseReleased.emit()
    if event is InputEventMouseButton:
        Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
        
        
        
