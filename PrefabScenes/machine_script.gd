extends Node3D
class_name Machine
@export var recipe_info : RecipeInfo
@export var display_points : Array[Node3D]
@export_flags("+X","-X","+Z","-Z") var input_dir
@export var output_dir : Direction
var input_positions : Array[Vector2i]
var out_position : Vector2i
var holding_items : Array[Pickup]
var machine_grid_position : Vector2i
var machine_rotation : int
var machine_finished := false
@export var input_duration : float
@onready var input_timer: Timer = $InputTimer
@export var process_duration : float
@onready var process_timer: Timer = $ProcessTimer
@export var output_duration : float
@onready var output_timer: Timer = $OutputTimer


signal input_started
signal process_started
signal output_started

enum Direction {
    PositiveX,
    NegativeX,
    PositiveZ,
    NegativeZ,
}
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    input_timer.wait_time = input_duration
    input_timer.timeout.connect(start_process)
    
    process_timer.wait_time = process_duration
    process_timer.timeout.connect(process_ended)
    
    output_timer.wait_time = output_duration
    output_timer.timeout.connect(output_ended)
    
    GridManager.grid_updated.connect(grid_updated)
    pass # Replace with function body.
    
func initialize_machine(grid_position : Vector2i,rotation_step):
    machine_grid_position = grid_position
    machine_rotation = rotation_step
    
    var offset := direction_to_grid_offset(output_dir,machine_rotation)
    out_position = machine_grid_position + offset
    
    pass
    
func grid_updated():
    if machine_finished and holding_items != []:
        push_item_to_output()
    pass

func add_item_to_machine(pickup : Pickup):
    machine_finished = false
    holding_items.append(pickup)
    display_item(pickup)
    input_timer.start()
    input_started.emit()
    
func start_process():
    if process_duration <= 0:
        process_ended()
        return
    process_timer.start()
    process_started.emit()
    
func process_ended():
    #var instanced_item
    #if(recipe_info != null and recipe_info.recipe_output != null):
        #var output_item_scene = recipe_info.recipe_output.get_item_scene()
        #instanced_item = output_item_scene.instantiate()
        #get_tree().root.add_child(instanced_item)
        #
    #var outputItem = instanced_item
    #if recipe_info.output_intake_item:
        #outputItem = holding_items[0]
        #
    #for point in display_points:
        #if point.get_child_count() > 0:
            #point.get_child(0).queue_free()
            #
    #holding_items = []         
    #holding_items.append(outputItem)
    #display_item(outputItem)
        #
    output_timer.start()
    output_started.emit()
        
func output_ended():
    push_item_to_output()


func push_item_to_output():
    print("machine_finished")
    machine_finished = true
    var output_machine = GridManager.get_machine_at_grid_position(out_position)
    if !output_machine:
        return
    
    print("found next machine")
    var instanced_item
    if(recipe_info != null and recipe_info.recipe_output != null):
        var output_item_scene = recipe_info.recipe_output.get_item_scene()
        instanced_item = output_item_scene.instantiate()
        get_tree().root.add_child(instanced_item)
        
    var outputItem = instanced_item
    if recipe_info.output_intake_item:
        outputItem = holding_items[0]
        
    print(outputItem.name)
    output_machine.add_item_to_machine(outputItem)
    for point in display_points:
        if point.get_child_count() > 0:
            point.get_child(0).queue_free()
        
    holding_items = []
    
    print("finished moving item")
    pass

func display_item(pickup :Pickup):
    for point in display_points:
        if point.get_child_count() <= 0:
            pickup.reparent(point)
            pickup.position = Vector3.ZERO
            pickup.freeze = true
            
func direction_to_local_offset(dir: Direction) -> Vector2i:
    match dir:
        Direction.PositiveX:
            return Vector2i(1, 0)
        Direction.NegativeX:
            return Vector2i(-1, 0)
        Direction.PositiveZ:
            return Vector2i(0, 1)
        Direction.NegativeZ:
            return Vector2i(0, -1)
        _:
            return Vector2i.ZERO
        
func rotate_offset(offset: Vector2i, rotation_step: int) -> Vector2i:
    var r := rotation_step % 4
    match r:
        0:
            return offset
        1:
            return Vector2i(offset.y, -offset.x)
        2:
            return Vector2i(-offset.x, -offset.y)
        3:
            return Vector2i(-offset.y, offset.x)
        _:
            return offset
    
func direction_to_grid_offset(dir: Direction, rotation_step: int) -> Vector2i:
    var local_offset := direction_to_local_offset(dir)
    return rotate_offset(local_offset, rotation_step)
    
func draw_debug_cube(position: Vector3, size: float = 0.5, color: Color = Color.RED):
    var mesh_instance := MeshInstance3D.new()

    var mesh := BoxMesh.new()
    mesh.size = Vector3.ONE * size
    mesh_instance.mesh = mesh

    var material := StandardMaterial3D.new()
    material.albedo_color = color
    material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
    material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
    mesh_instance.material_override = material

    mesh_instance.global_position = position

    get_tree().current_scene.add_child(mesh_instance)
