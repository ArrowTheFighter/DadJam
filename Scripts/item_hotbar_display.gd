extends MarginContainer

@onready var texture_rect: TextureRect = $VBoxContainer/MarginContainer/TextureRect
@onready var color_rect: ColorRect = $VBoxContainer/MarginContainer/ColorRect
@onready var label: Label = $VBoxContainer/Label
@onready var panel: PanelContainer = $VBoxContainer/MarginContainer/PanelContainer

func set_selected():
    panel.self_modulate.a = 1
    
func set_unselected():
    panel.self_modulate.a = 0
    
func set_cost_text(text : String):
    label.text = text
