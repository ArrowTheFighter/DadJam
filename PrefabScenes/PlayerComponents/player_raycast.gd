extends RayCast3D
@export var PlaceableTest : PackedScene
@export var player_inventory : PlayerInventory
var MeshPreview : MeshInstance3D 
var selected_grid_pos : Vector2i
var selected_global_pos : Vector3
var has_selected_pos = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass # Replace with function body.
func _input(event: InputEvent) -> void:
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

            # Start at zero scale and slightly below or at target pos
            instancedPlaceable.scale = Vector3.ZERO
            instancedPlaceable.global_position = target_pos - Vector3(0, 0.2, 0)  # start a bit lower

            # Create a Tween
            var tween = create_tween()
            #instancedPlaceable.add_child(tween)  # can be added to object
            tween.set_parallel()
            tween.tween_property(instancedPlaceable, "rotation_degrees:y",180,0.3).set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_OUT)
            tween.tween_property(instancedPlaceable, "scale", target_scale, 0.2).set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_OUT)
            tween.tween_property(instancedPlaceable, "global_position", target_pos + Vector3(0, 0.5, 0), 0.3).set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_OUT)
            tween.tween_property(instancedPlaceable, "global_position", target_pos, 0.2).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN).set_delay(0.3)

            tween.play()
            
            
            GridManager.set_grid_pos(selected_grid_pos,instancedPlaceable)
    if Input.is_action_just_pressed("remove_object"):
        if !has_selected_pos:
            return
        if GridManager.get_grid_pos_status(selected_grid_pos): 
            GridManager.remove_object_from_grid(selected_grid_pos)
                
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    #Check if the raycast hits anything
    has_selected_pos = is_colliding()
    if(has_selected_pos):
        #Get world space position for placement
        var roundedPos = Vector3(round_to_multiple_offset(get_collision_point().x,3,1.5),1,round_to_multiple_offset(get_collision_point().z,3,1.5))
        #Get grid pos
        var grid_pos = Vector2i.ZERO
        grid_pos.x = int((roundedPos.x - 1.5) / 3.0)
        grid_pos.y = int((roundedPos.z - 1.5) / 3.0)
        #Set selected grid pos
        selected_grid_pos = grid_pos
        
        if !GridManager.get_grid_pos_status(selected_grid_pos):
            
            #If we don't have a preview object, set one up
            if(MeshPreview == null):
                MeshPreview = MeshInstance3D.new()
                MeshPreview.mesh = BoxMesh.new()
                MeshPreview.scale = Vector3.ONE * 2
                var preview_material := StandardMaterial3D.new()
                preview_material.albedo_color = Color(0.968, 0.143, 0.0, 0.5)
                preview_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
                MeshPreview.material_override = preview_material
                get_tree().root.add_child(MeshPreview)
            
            
            #Set preview to world pos
            MeshPreview.global_position = roundedPos
            selected_global_pos = roundedPos
            
        elif(MeshPreview != null):
            MeshPreview.queue_free()
        
    #Remove preview if not hitting anything
    elif(MeshPreview != null):
        MeshPreview.queue_free()
    pass

func round_to_multiple_offset(value: float, multiple: float, offset: float) -> float:
    return round((value - offset) / multiple) * multiple + offset
