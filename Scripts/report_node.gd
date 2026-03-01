extends Control

@onready var money_label: Label = $MoneyLabel

func show_report(money_earned,disliked_qualitites,liked_qualities):
    visible = true
    get_tree().get_first_node_in_group("MouseCaptureGroup").release_mouse()
    
    money_label.text = "$" + str(money_earned)
    pass
    
func hide_report():
    visible = false
    get_tree().get_first_node_in_group("MouseCaptureGroup").capture_mouse()
