extends Control

@onready var label: Label = $Label


func set_text(text : String,color : Color = Color.WHITE):
    label.text = text
    label.label_settings = label.label_settings.duplicate()
    label.label_settings.font_color = color
