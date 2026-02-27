extends CharacterBody3D


@export var player_speed = 7.0
const JUMP_VELOCITY = 10.0


@export var Camera: Node3D


func _physics_process(delta: float) -> void:
    
    # Add the gravity.
    if not is_on_floor():
        velocity += get_gravity() * delta

    # Handle jump.
    if Input.is_action_just_pressed("ui_accept") and is_on_floor():
        velocity.y = JUMP_VELOCITY

    # Get the input direction and handle the movement/deceleration.
    # As good practice, you should replace UI actions with custom gameplay actions.
    var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
    var camera_right := Camera.global_transform.basis.x
    var player_up = Vector3.UP
    var player_basis = Basis(camera_right,Vector3.UP,camera_right.cross(Vector3.UP))
    
    
    var direction := (player_basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
    if direction:
        velocity.x = direction.x * player_speed
        velocity.z = direction.z * player_speed
    else:
        velocity.x = move_toward(velocity.x, 0, player_speed)
        velocity.z = move_toward(velocity.z, 0, player_speed)

    move_and_slide()
