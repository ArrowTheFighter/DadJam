extends Node3D
class_name Machine

const DIR_X_POS := 1 << 0 # +X
const DIR_X_NEG := 1 << 1 # -X
const DIR_Z_POS := 1 << 2 # +Z
const DIR_Z_NEG := 1 << 3 # -Z

@export var recipe_info : RecipeInfo
@export var display_points : Array[Node3D]
@export_flags("+X","-X","+Z","-Z") var input_dir
@export var output_dir : Direction
var input_positions : Array[Vector2i]
var out_position : Vector2i
@export var max_items : int = 1
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
    input_positions = bitmask_to_grid_offsets(input_dir, rotation_step)
    
    GridManager.grid_was_updated()
    
    pass
    
func get_input_grid_positions() -> Array[Vector2i]:
    var positions : Array[Vector2i]
    for pos in input_positions:
        var grid := Vector2i(
            machine_grid_position.x + pos.x,
            machine_grid_position.y + pos.y
        )
        positions.append(grid)
    return positions
    
func grid_updated():
    if machine_finished and holding_items != []:
        push_item_to_output()
    pass

func can_add_to_machine() -> bool:
    return holding_items.size() < max_items

func add_item_to_machine(pickup : Pickup):
    machine_finished = false
    holding_items.append(pickup)
    display_item(pickup,pickup.global_position)
    input_timer.start()
    input_started.emit()
    
func start_process():
    if process_duration <= 0:
        process_ended()
        return
    process_timer.start()
    process_started.emit()
    
func process_ended():
    convert_items_to_recipe_output()
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
    if !output_machine.can_add_to_machine():
        return
    if !output_machine.get_input_grid_positions().has(machine_grid_position):
        return
    print("found next machine")
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
    #print(outputItem.name)
    output_machine.add_item_to_machine(holding_items[0])
    for point in display_points:
        if point.get_child_count() > 0:
            point.get_child(0).queue_free()
        #
    holding_items = []
    
    GridManager.grid_was_updated()
    pass


func convert_items_to_recipe_output():
    if recipe_info.output_intake_item:
        return
    var instanced_item
    if(recipe_info != null and recipe_info.recipe_output != null):
        var output_item_scene = recipe_info.recipe_output.get_item_scene()
        instanced_item = output_item_scene.instantiate()
        get_tree().root.add_child(instanced_item)
        
    var outputItem = instanced_item
        
    for point in display_points:
        if point.get_child_count() > 0:
            point.get_child(0).free()
        
    holding_items = []
    
    holding_items.append(outputItem)
    display_item(outputItem, display_points[0].global_position)

func display_item(pickup :Pickup,pos : Vector3):
    for point in display_points:
        if point.get_child_count() <= 0:
            point.global_position = pos
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
    
    
func bit_to_local_offset(bit: int) -> Vector2i:
    match bit:
        DIR_X_POS:
            return Vector2i(1, 0)
        DIR_X_NEG:
            return Vector2i(-1, 0)
        DIR_Z_POS:
            return Vector2i(0, 1)
        DIR_Z_NEG:
            return Vector2i(0, -1)
        _:
            return Vector2i.ZERO
    
func bitmask_to_grid_offsets(mask: int, rotation_step: int) -> Array[Vector2i]:
    var result: Array[Vector2i] = []

    var bits := [
        DIR_X_POS,
        DIR_X_NEG,
        DIR_Z_POS,
        DIR_Z_NEG
    ]

    for bit in bits:
        if mask & bit != 0:
            var local := bit_to_local_offset(bit)
            var rotated := rotate_offset(local, rotation_step)
            result.append(rotated)

    return result
    
func draw_input_debug():
    for pos in input_positions:
        var grid := Vector3(
            machine_grid_position.x + pos.x,
            0,
            machine_grid_position.y + pos.y
        )

        var world_pos := grid * GridManager.GRID_SIZE
        world_pos.x += GridManager.GRID_SIZE * 0.5
        world_pos.z += GridManager.GRID_SIZE * 0.5
        world_pos.y = 1

        draw_debug_cube(world_pos)
    
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
