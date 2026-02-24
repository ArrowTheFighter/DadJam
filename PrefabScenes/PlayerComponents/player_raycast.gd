extends ShapeCast3D
@export var PlaceableTest : PackedScene
@export var player_inventory : PlayerInventory
@export var preview_material : StandardMaterial3D
@export var camera_node : Camera3D
var MeshPreview : Node3D
var selected_grid_pos : Vector2i
var selected_global_pos : Vector3
var has_selected_pos = false
var _object_rotation := 0
var holding_item : Node3D
var holding_item_local_pos : Vector3
var object_rotation : int :
    get:
        return _object_rotation
    set(v):
        _object_rotation = posmod(v,4)
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass # Replace with function body.
func _input(event: InputEvent) -> void:
    
    if event.is_action_pressed("rotation_next"):
        _object_rotation += 1
        set_preview_rotation(_object_rotation)
    if event.is_action_pressed("rotation_previous"):
        _object_rotation -= 1
        set_preview_rotation(_object_rotation)
    
    if Input.is_action_just_pressed("place_object"):
        if !has_selected_pos:
            return
        if !GridManager.get_grid_pos_status(selected_grid_pos): 
            var item_to_place = player_inventory.get_selected_item()
            
            var instancedPlaceable = item_to_place.instantiate()
            get_tree().root.add_child(instancedPlaceable)
            
            # Save the target position and scale
            var target_pos = selected_global_pos
            var target_scale = instancedPlaceable.scale
            var target_rotation = instancedPlaceable.rotation_degrees
            target_rotation.y = 90 * _object_rotation

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
            
            
            GridManager.set_grid_pos(selected_grid_pos,instancedPlaceable,_object_rotation)
    if Input.is_action_just_pressed("remove_object"):
        if !has_selected_pos:
            return
        if GridManager.get_grid_pos_status(selected_grid_pos): 
            GridManager.remove_object_from_grid(selected_grid_pos)
                
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    if holding_item != null:
        holding_item.global_position = camera_node.to_global(holding_item_local_pos)
         #drop the item
    
    #Check if the raycast hits anything
    has_selected_pos = is_colliding()
    if(is_colliding()):
        var hitObject : Node3D = get_collider(0)
        if (hitObject.is_in_group("Pickup")):
            if(MeshPreview != null):
                MeshPreview.queue_free()
            if Input.is_action_just_pressed("interact"):
                holding_item = hitObject
                holding_item_local_pos = Vector3(.5,-.2,-1)
                holding_item.freeze = true
                holding_item.set_collision_layer_value(5,false)
                (holding_item as RigidBody3D).disable_mode = 4
                print("interacting with pickup")
            return
        elif(hitObject.is_in_group("Machine") and holding_item != null):
            print("looking at machine with item")
            if Input.is_action_just_pressed("interact"):
                print(hitObject.name)
                hitObject.add_item_to_machine(holding_item.item_info)
                drop_holding_item()
                return
        
        if(holding_item == null):
            
            #Get world space position for placement
            var roundedPos = Vector3(round_to_multiple_offset(get_collision_point(0).x,GridManager.GRID_SIZE,GridManager.GRID_SIZE * 0.5),0,round_to_multiple_offset(get_collision_point(0).z,GridManager.GRID_SIZE,GridManager.GRID_SIZE * 0.5))
            #Get grid pos
            var grid_pos = Vector2i.ZERO
            grid_pos.x = int((roundedPos.x - GridManager.GRID_SIZE * 0.5) / GridManager.GRID_SIZE)
            grid_pos.y = int((roundedPos.z - GridManager.GRID_SIZE * 0.5) / GridManager.GRID_SIZE)
            #Set selected grid pos
            selected_grid_pos = grid_pos
            
            if !GridManager.get_grid_pos_status(selected_grid_pos):
                
                #If we don't have a preview object, set one up
                if(MeshPreview == null):
                    var item_to_place = player_inventory.get_selected_item()
                    MeshPreview = item_to_place.instantiate()
                    
                    disable_colliders_recursive(MeshPreview)
                    apply_material_recursive(MeshPreview,preview_material)
                    
                    get_tree().root.add_child(MeshPreview)
                    
                    set_preview_rotation(_object_rotation)
                
                #Set preview to world pos
                MeshPreview.global_position = roundedPos
                selected_global_pos = roundedPos
            
            elif(MeshPreview != null):
                MeshPreview.queue_free()
        
    #Remove preview if not hitting anything
    elif(MeshPreview != null):
        MeshPreview.queue_free()
    
    if Input.is_action_just_pressed("interact") and holding_item != null:
        drop_holding_item()
        return
   
    pass

func set_preview_rotation(rotation_amount):
    if MeshPreview == null: 
        return
    
    MeshPreview.rotation_degrees.y = 90 * rotation_amount
    

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
            child.collision_layer = 0
            child.collision_mask = 0

        disable_colliders_recursive(child)
        
func drop_holding_item():
    holding_item.freeze = false
    holding_item.set_collision_layer_value(5,true)
    (holding_item as RigidBody3D).disable_mode = CollisionObject3D.DISABLE_MODE_REMOVE
    holding_item = null
    holding_item_local_pos = Vector3.ZERO
