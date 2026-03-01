extends PanelContainer
@onready var machine_name: Label = $"ui_mcahine_tab/HBoxContainer/VBoxContainer/Machine Name"
@onready var machine_price: Label = $"ui_mcahine_tab/HBoxContainer/VBoxContainer/Machine Price"
@onready var machine_description: Label = $ui_mcahine_tab/HBoxContainer/MachineDescription
@onready var ui_mcahine_tab: Button = $ui_mcahine_tab

signal machine_tab_pressed(number)
var machine_number

func setup_tab(machine : Machine,number):
    ui_mcahine_tab.pressed.connect(tab_pressed)
    machine_number = number
    
    machine_name.text = machine.machine_name
    machine_price.text = "$" + str(machine.machine_cost)
    machine_description.text = machine.machine_description
    
    pass
    
func tab_pressed():
    machine_tab_pressed.emit(machine_number)
