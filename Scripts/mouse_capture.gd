extends Node

signal MouseReleased

var pause_menu_open := false
var can_capture_mouse = true
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
    pass # Replace with function body.
func _input(event: InputEvent) -> void:
    if can_capture_mouse: 
        if event is InputEventMouseButton:
            Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
        
    if Input.is_action_just_pressed("ui_cancel"):
        if !pause_menu_open:
            get_tree().get_first_node_in_group("PauseMenu").visible = true
            pause_menu_open = true
            release_mouse()
            MouseReleased.emit()
        else:
            get_tree().get_first_node_in_group("PauseMenu").visible = false
            pause_menu_open = false
            capture_mouse()
    
        
        
func release_mouse():
    can_capture_mouse = false
    Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
    MouseReleased.emit()
    
func capture_mouse():
    can_capture_mouse = true
    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
        
