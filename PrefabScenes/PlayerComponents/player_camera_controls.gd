extends Camera3D
class_name PlayerCamera

@export var HorizontalSensitivity := 2.0
@export var VerticalSensitivity := 1.0
var sensitivity = 1.0
const MOUSE_SCALE := 0.05
var skipMouseCheck = false

func _ready() -> void:
    get_tree().get_nodes_in_group("MouseCaptureGroup")[0].MouseReleased.connect(mouse_released_this_frame)

func _input(event: InputEvent) -> void:
    #Fix for the player snapping when releasing the mouse
    if skipMouseCheck:
        skipMouseCheck = false
        return
    if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED: return
    #rotate the camera when moving the mouse
    if event is InputEventMouseMotion:
        #Rotate the camera horizontally
        rotation_degrees.y -= event.relative.x * HorizontalSensitivity * MOUSE_SCALE * sensitivity
        #Rotate the camera vertically
        rotation_degrees.x = clampf(rotation_degrees.x - event.relative.y * VerticalSensitivity * MOUSE_SCALE * sensitivity,-90,90)
        
        
        
        
#function for checking when the mouse was released
func mouse_released_this_frame():
    skipMouseCheck = true
