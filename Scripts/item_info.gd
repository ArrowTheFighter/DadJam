@tool 
extends Resource
class_name ItemInfo

@export var item_name : String
@export_file(".tscn") var item_scene_path : String

func get_item_scene():
    var scene : PackedScene = load(item_scene_path)
    return scene
