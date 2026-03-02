extends Control

@onready var label: Label = $HBoxContainer/Label

func set_text(text):
    label.text = text
