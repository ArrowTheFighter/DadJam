extends Node3D
class_name Machine

const DIR_X_POS := 1 << 0 # +X
const DIR_X_NEG := 1 << 1 # -X
const DIR_Z_POS := 1 << 2 # +Z
const DIR_Z_NEG := 1 << 3 # -Z

@export_category("Machine Info")
@export var machine_name : String
@export var machine_cost : int = 10
@export_multiline() var machine_description : String
@export var machine_icon : Texture

@export_category("Machine settings")
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
@export_category("Level_Setup")
@export var set_spot_filled_on_startup := false
@export var placement_arrow_path: NodePath
@onready var placement_arrow: Node3D = get_node(placement_arrow_path) if placement_arrow_path != NodePath("") else null

signal input_started(input_number)
signal process_started
signal output_started

signal process_finished(ingredients : Array[Pickup])
signal output_finished()


enum Direction {
    PositiveX,
    NegativeX,
    PositiveZ,
    NegativeZ,
}
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    if set_spot_filled_on_startup:
        machine_rotation = (int(round(rotation_degrees.y / 90)) + 4) % 4
        var grid_pos = GridManager.gloabl_to_grid_pos(global_position)
        GridManager.set_grid_pos(grid_pos,self,machine_rotation)
        initialize_machine(grid_pos,machine_rotation)
    
    input_timer.wait_time = input_duration
    input_timer.timeout.connect(start_process)
    
    process_timer.wait_time = process_duration
    process_timer.timeout.connect(process_ended)
    
    output_timer.wait_time = output_duration
    output_timer.timeout.connect(output_ended)
    
    GridManager.grid_updated.connect(grid_updated)
    pass # Replace with function body.
    
func initialize_machine(grid_position : Vector2i,rotation_step):
    print("setting up machine with roation of " + str(rotation_step))
    machine_grid_position = grid_position
    machine_rotation = rotation_step
    
    var offset := direction_to_grid_offset(output_dir,machine_rotation)
    out_position = machine_grid_position + offset
    input_positions = bitmask_to_grid_offsets(input_dir, rotation_step)
    print(input_positions)
    
    GridManager.grid_was_updated()
    
    pass
    
func set_placement_preview_enabled(enabled: bool) -> void:
    if placement_arrow:
        placement_arrow.visible = enabled
    
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
    input_started.emit(holding_items.size() - 1)
    if input_duration <= 0:
        input_timer.timeout.emit()
    else:
        input_timer.start()
    
func start_process():
    if !recipe_info.output_intake_item and !items_match_recipe():
        print("didn't have correct recipe")
        return
    process_started.emit()
    if process_duration <= 0:
        process_timer.timeout.emit()
    else:
        process_timer.start()
    
func process_ended():
    convert_items_to_recipe_output()
    output_started.emit()
    if output_duration <= 0:
        output_timer.timeout.emit()
    else:
        output_timer.start()
        
func output_ended():
    push_item_to_output()

func items_match_recipe() -> bool:
    var items_match := 0
    var item_check_array = holding_items.duplicate()

    for item in recipe_info.recipe_requirements:
        for holding_item in item_check_array:
            if holding_item.item_info == item:
                items_match += 1
                item_check_array.erase(holding_item)
                break

    print(items_match)
    return items_match == recipe_info.recipe_requirements.size()
    

func push_item_to_output():
    
    machine_finished = true
    var output_machine = GridManager.get_machine_at_grid_position(out_position)
    if !output_machine:
        return
    if !output_machine.can_add_to_machine():
        return
    if !output_machine.get_input_grid_positions().has(machine_grid_position):
        return
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
    if holding_items.size() <= 0:
        return
    output_machine.add_item_to_machine(holding_items[0])
    release_items()
    output_finished.emit()
    pass

func cancel_process():
    process_timer.stop()
    
func cancel_output():
    output_timer.stop()
    
func empty_machine(broadcast = true):
    for point in display_points:
        if point.get_child_count() > 0:
            point.get_child(0).free()
        
        #
    #for i in range(holding_items.size() - 1, -1, -1):
        #holding_items[i].free()
    holding_items = []
    if broadcast:
        GridManager.grid_was_updated()

func release_items():
    ##for point in display_points:
        ##if point.get_child_count() > 0:
            ##point.get_child(0).reparent(get_tree().root)
        ###
    holding_items = []
    GridManager.grid_was_updated()
    
func can_take_item() -> bool:
    return machine_finished

func convert_items_to_recipe_output():
    if recipe_info.output_intake_item:
        return
    var instanced_item
    if(recipe_info != null and recipe_info.recipe_output != null):
        var output_item_scene = recipe_info.recipe_output.get_item_scene()
        instanced_item = output_item_scene.instantiate()
        get_tree().root.add_child(instanced_item)
        
    var outputItem = instanced_item
    var ingredients : Array[Pickup]
    for item in holding_items:
        ingredients.append(item.duplicate())
        for quality in item.item_qualities:
            if !outputItem.item_qualities.has(quality):
                outputItem.item_qualities.append(quality)
    empty_machine(false)
    
    apply_qualities(outputItem)
    holding_items.append(outputItem)
    
    display_item(outputItem, display_points[0].global_position)
    
    process_finished.emit(ingredients)
    
    for item in ingredients:
        item.queue_free()
    GridManager.grid_was_updated()


func apply_qualities(pickup : Pickup):
    
    #Remove qualities
    if recipe_info.removed_quality_1 != QualityEnum.Property.NONE:
        if pickup.item_qualities.has(recipe_info.removed_quality_1):
            pickup.item_qualities.erase(recipe_info.removed_quality_1)
    
    if recipe_info.removed_quality_2 != QualityEnum.Property.NONE:
        if pickup.item_qualities.has(recipe_info.removed_quality_2):
            pickup.item_qualities.erase(recipe_info.removed_quality_2)
    
    if recipe_info.removed_quality_3 != QualityEnum.Property.NONE:
        if pickup.item_qualities.has(recipe_info.removed_quality_3):
            pickup.item_qualities.erase(recipe_info.removed_quality_3)  
    
    #Add qualities
    if recipe_info.added_quality_1 != QualityEnum.Property.NONE:
        if !pickup.item_qualities.has(recipe_info.added_quality_1):
            #if pickup.item_qualities.size() < pickup.item_info.max_qualities:
            pickup.item_qualities.append(recipe_info.added_quality_1)
            print("adding quality " + QualityEnum.Property.keys()[recipe_info.added_quality_1])
    
    if recipe_info.added_quality_2 != QualityEnum.Property.NONE:
        if !pickup.item_qualities.has(recipe_info.added_quality_2):
            #if pickup.item_qualities.size() < pickup.item_info.max_qualities:
            pickup.item_qualities.append(recipe_info.added_quality_2)
            print("adding quality " + QualityEnum.Property.keys()[recipe_info.added_quality_2])
    
    if recipe_info.added_quality_3 != QualityEnum.Property.NONE:
        if !pickup.item_qualities.has(recipe_info.added_quality_3):
            #if pickup.item_qualities.size() < pickup.item_info.max_qualities:
            pickup.item_qualities.append(recipe_info.added_quality_3)     
            print("adding quality " + QualityEnum.Property.keys()[recipe_info.added_quality_3])
            
      
    

func display_item(pickup :Pickup,pos : Vector3):
    for i in range (display_points.size()):
        if display_points[i].get_child_count() <= 0:
            display_points[i].global_position = pos
            pickup.reparent(display_points[i])
            pickup.position = Vector3.ZERO
            pickup.freeze = true
            pickup.set_collision_layer_value(5,false)
            return
            
            
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
    
func draw_debug_cube(position: Vector3, size: float = 0.5, color: Color = Color.LIME_GREEN):
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
