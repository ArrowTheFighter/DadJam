extends MarginContainer

@onready var texture_rect: TextureRect = $VBoxContainer/MarginContainer/TextureRect
@onready var color_rect: ColorRect = $VBoxContainer/MarginContainer/ColorRect
@onready var label: Label = $VBoxContainer/Label

func set_selected():
    color_rect.color.a = 0
    
func set_unselected():
    color_rect.color.a = 0.5
    
func set_cost_text(text : String):
    label.text = text
