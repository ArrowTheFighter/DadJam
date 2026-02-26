extends RayCast3D
@export var PlaceableTest : PackedScene
@export var player_inventory : PlayerInventory
@export var preview_material : StandardMaterial3D
@export var camera_node : Camera3D
var MeshPreview : Node3D
var selected_grid_pos : Vector2i
var selected_global_pos : Vector3
var has_selected_pos = false
var holding_item : Node3D
var holding_item_local_pos : Vector3
var outlined_object
var _object_rotation := 0
var object_rotation : int :
    get:
        return _object_rotation
    set(v):
        _object_rotation = posmod(v,4)
        
var detectedColliders : Array
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    player_inventory.selected_item_changed.connect(selected_item_changed)
    pass # Replace with function body.
func _input(event: InputEvent) -> void:
    
    if event.is_action_pressed("rotation_next"):
        object_rotation += 1
        print(object_rotation)
        set_preview_rotation(object_rotation)
    if event.is_action_pressed("rotation_previous"):
        object_rotation -= 1
        set_preview_rotation(object_rotation)
    
    if Input.is_action_just_pressed("place_object"):
        if !has_selected_pos:
            return
        if !GridManager.get_grid_pos_status(selected_grid_pos): 
            var machine_pos = selected_grid_pos
            var machine_rotation = object_rotation
            var item_to_place = player_inventory.get_selected_item()
            
            var instancedPlaceable = item_to_place.instantiate()
            get_tree().root.add_child(instancedPlaceable)
            
            # Save the target position and scale
            var target_pos = selected_global_pos
            var target_scale = instancedPlaceable.scale
            var target_rotation = instancedPlaceable.rotation_degrees
            target_rotation.y = 90 * object_rotation

            # Start at zero scale and slightly below or at target pos
            instancedPlaceable.scale = Vector3.ZERO
            instancedPlaceable.global_position = target_pos - Vector3(0, 0.2, 0)  # start a bit lower
            instancedPlaceable.rotation_degrees.y -= 180
        
            # Create a Tween
            var tween = create_tween()
            #instancedPlaceable.add_child(tween)  # can be added to object
            tween.set_parallel()
            tween.tween_property(instancedPlaceable, "rotation_degrees",target_rotation,0.3).set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_OUT)
            tween.tween_property(instancedPlaceable, "scale", target_scale, 0.2).set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_OUT)
            tween.tween_property(instancedPlaceable, "global_position", target_pos + Vector3(0, 0.5, 0), 0.3).set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_OUT)
            tween.tween_property(instancedPlaceable, "global_position", target_pos, 0.2).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN).set_delay(0.3)

            tween.play()
            GridManager.set_pos_filled(machine_pos)
            await get_tree().create_timer(0.51).timeout 
            GridManager.set_grid_pos(machine_pos,instancedPlaceable,machine_rotation)
            instancedPlaceable.initialize_machine(machine_pos,machine_rotation)
            
    if Input.is_action_just_pressed("remove_object"):
        if !has_selected_pos:
            return
        if GridManager.get_grid_pos_status(selected_grid_pos): 
            GridManager.remove_object_from_grid(selected_grid_pos)
                
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    if outlined_object != null:
        update_node_outline(outlined_object, 1)
        outlined_object = null
    var ItemDispenser = get_item_dispenser()
    if ItemDispenser != null and holding_item == null:
        
        update_node_outline(ItemDispenser,1.1)
        outlined_object = ItemDispenser
        if(MeshPreview != null):
            MeshPreview.queue_free()
        if Input.is_action_just_pressed("interact"):
            var itemInfo = ItemDispenser.item_info;
            var spawnedItem = itemInfo.get_item_scene().instantiate()
            
            get_tree().root.add_child(spawnedItem)
            
            holding_item = spawnedItem
            holding_item_local_pos = Vector3(.5,-.2,-1)
            holding_item.freeze = true
            holding_item.set_collision_layer_value(5,false)
            (holding_item as RigidBody3D).disable_mode = 4
        return
            
    var best_machine_with_pickup : Machine = get_best_machine_with_pickup()
    if best_machine_with_pickup != null and holding_item == null:
        update_node_outline(best_machine_with_pickup,1.1)
        outlined_object = best_machine_with_pickup
        if best_machine_with_pickup.can_take_item():
            if(MeshPreview != null):
                MeshPreview.queue_free()
            if Input.is_action_just_pressed("interact"):
                holding_item = best_machine_with_pickup.holding_items[0]
                holding_item.reparent(get_tree().root)
                holding_item_local_pos = Vector3(.5,-.2,-1)
                holding_item.freeze = true
                holding_item.set_collision_layer_value(5,false)
                best_machine_with_pickup.release_items()
                (holding_item as RigidBody3D).disable_mode = 4
                update_node_outline(best_machine_with_pickup,1.0)
                update_node_outline(holding_item,1.0)
        if Input.is_action_just_pressed("empty_machine"): 
              best_machine_with_pickup.empty_machine()
        return
    
    var best_pickup = get_best_pickup()
    if best_pickup != null and holding_item == null:
        update_node_outline(best_pickup,1.1)
        outlined_object = best_pickup
        if(MeshPreview != null):
            MeshPreview.queue_free()
        if Input.is_action_just_pressed("interact"):
            holding_item = best_pickup
            holding_item_local_pos = Vector3(.5,-.2,-1)
            holding_item.freeze = true
            holding_item.set_collision_layer_value(5,false)
            (holding_item as RigidBody3D).disable_mode = 4
        return
    
    
    if holding_item != null:
        holding_item.global_position = camera_node.to_global(holding_item_local_pos)
         #drop the item
    
    #Check if the raycast hits anything
    has_selected_pos = is_colliding()
    if(is_colliding()):
        var hitObject : Node3D = get_collider()
        
        if(hitObject != null and hitObject.is_in_group("Machine") and holding_item != null):
            if Input.is_action_just_pressed("interact"):
                if (hitObject as Machine).can_add_to_machine():
                    print(hitObject.name)
                    hitObject.add_item_to_machine(holding_item)
                    remove_holding_item()
                    return
        
        if(holding_item == null):
            
            #Get world space position for placement
            var roundedPos = Vector3(round_to_multiple_offset(get_collision_point().x,GridManager.GRID_SIZE,GridManager.GRID_SIZE * 0.5),0,round_to_multiple_offset(get_collision_point().z,GridManager.GRID_SIZE,GridManager.GRID_SIZE * 0.5))
            #Get grid pos
            var grid_pos = Vector2i.ZERO
            grid_pos.x = int((roundedPos.x - GridManager.GRID_SIZE * 0.5) / GridManager.GRID_SIZE)
            grid_pos.y = int((roundedPos.z - GridManager.GRID_SIZE * 0.5) / GridManager.GRID_SIZE)
            #Set selected grid pos
            selected_grid_pos = grid_pos
            
            if !GridManager.get_grid_pos_status(selected_grid_pos):
                
                #If we don't have a preview object, set one up
                if(MeshPreview == null):
                    spawn_display_mesh()
                
                #Set preview to world pos
                MeshPreview.global_position = roundedPos
                selected_global_pos = roundedPos
            
            elif(MeshPreview != null):
                MeshPreview.queue_free()
        
    #Remove preview if not hitting anything
    elif(MeshPreview != null):
        delete_display_mesh()
        
    if Input.is_action_just_pressed("interact") and holding_item != null:
        drop_holding_item()
        return
   
    pass

func selected_item_changed():
    delete_display_mesh()
    spawn_display_mesh()
    pass

func delete_display_mesh():
    if MeshPreview != null:
        MeshPreview.queue_free()

func spawn_display_mesh():
    var item_to_place = player_inventory.get_selected_item()
    MeshPreview = item_to_place.instantiate()
    
    disable_colliders_recursive(MeshPreview)
    apply_material_recursive(MeshPreview,preview_material)
    
    get_tree().root.add_child(MeshPreview)
    
    set_preview_rotation(object_rotation,true)

func set_preview_rotation(rotation_step , instant = false):
    if MeshPreview == null: 
        return
    if instant:
        MeshPreview.rotation_degrees.y = rotation_step * 90
        return
    var tween = create_tween()
    
    var target_angle = shortest_angle(MeshPreview.rotation_degrees.y, rotation_step)
    tween.tween_property(MeshPreview, "rotation_degrees:y", target_angle, 0.15)
    #MeshPreview.rotation_degrees.y = 90 * rotation_amount

func shortest_angle(from_deg: float, to_index: int) -> float:
    # Convert index (0-3) to target angle
    var to_deg = to_index * 90.0
    # Compute delta in [-180, 180]
    var delta = fmod(to_deg - from_deg + 180.0, 360.0) - 180.0
    return from_deg + delta

func round_to_multiple_offset(value: float, multiple: float, offset: float) -> float:
    return round((value - offset) / multiple) * multiple + offset
    
func apply_material_recursive(root: Node, material: Material) -> void:
    for child in root.get_children():
        if child is MeshInstance3D:
            var mesh = child.mesh
            if mesh:
                for i in mesh.get_surface_count():
                    child.set_surface_override_material(i, material)
        
        # Recurse into children
        apply_material_recursive(child, material)

func disable_colliders_recursive(root: Node) -> void:
    for child in root.get_children():
        if child is CollisionObject3D:
            child.set_deferred("freeze", true)
            child.collision_layer = 0
            child.collision_mask = 0
        if child is CollisionShape3D:
            child.set_deferred("disabled",true)

        disable_colliders_recursive(child)
        
func drop_holding_item():
    holding_item.freeze = false
    holding_item.set_collision_layer_value(5,true)
    (holding_item as RigidBody3D).disable_mode = CollisionObject3D.DISABLE_MODE_REMOVE
    holding_item = null
    holding_item_local_pos = Vector3.ZERO
    
func remove_holding_item():
    holding_item = null

func get_item_dispenser() -> Node3D:
    var dispenser: Node3D = null
    var smallest_dot: float = -1.0  

    for body in detectedColliders:
        if body.is_in_group("ItemDispenser"): 
            var dir_to_body = (body.global_transform.origin - camera_node.global_transform.origin).normalized()
            var forward = -camera_node.global_transform.basis.z  # Camera forward in Godot 4
            var dot = forward.dot(dir_to_body)

            if dot > smallest_dot: 
                smallest_dot = dot
                dispenser = body

    return dispenser

func get_best_pickup() -> Node3D:
    var best_pickup: Node3D = null
    var smallest_dot: float = -1.0  

    for body in detectedColliders:
        if body.is_in_group("Pickup"):  
            var dir_to_body = (body.global_transform.origin - camera_node.global_transform.origin).normalized()
            var forward = -camera_node.global_transform.basis.z 
            var dot = forward.dot(dir_to_body)

            if dot > smallest_dot: 
                smallest_dot = dot
                best_pickup = body

    return best_pickup
    
func get_best_machine_with_pickup() -> Node3D:
    var best_pickup: Node3D = null
    var smallest_dot: float = -1.0  

    for body in detectedColliders:
        if body.is_in_group("Machine"): 
            if (body as Machine).holding_items.size() <= 0:
                continue
            var dir_to_body = (body.global_transform.origin - camera_node.global_transform.origin).normalized()
            var forward = -camera_node.global_transform.basis.z  
            var dot = forward.dot(dir_to_body)

            if dot > smallest_dot:  
                smallest_dot = dot
                best_pickup = body

    return best_pickup
    

func _on_area_3d_body_entered(body: Node3D) -> void:
    detectedColliders.append(body)
    pass # Replace with function body.


func _on_area_3d_body_exited(body: Node3D) -> void:
    detectedColliders.erase(body)
    pass # Replace with function body.

func update_node_outline(node: Node, outline_size : float):
    if node is MeshInstance3D:
        _update_mesh_outline(node,outline_size)

    for child in node.get_children():
        update_node_outline(child,outline_size)

func _update_mesh_outline(mesh_instance: MeshInstance3D,outline_size :float):
    var mesh := mesh_instance.mesh
    if mesh == null:
        return

    for surface in range(mesh.get_surface_count()):
        var mat := mesh_instance.get_active_material(surface)
        if mat == null:
            continue

        # 1️⃣ Duplicate the base material
        var mat_instance := mat.duplicate()
        mat_instance.resource_local_to_scene = true

        # 2️⃣ Duplicate the next_pass (outline material)
        if mat_instance.next_pass:
            mat_instance.next_pass = mat_instance.next_pass.duplicate()
            mat_instance.next_pass.resource_local_to_scene = true

            if mat_instance.next_pass is ShaderMaterial:
                mat_instance.next_pass.set_shader_parameter(
                    "size",
                    outline_size
                )

        # 3️⃣ Assign per-instance material override
        mesh_instance.set_surface_override_material(surface, mat_instance)
