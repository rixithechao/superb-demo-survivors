# RandomIntEditor.gd
extends EditorProperty


# The main controls for editing the property.
var property_hbox = HSplitContainer.new()
var property_control_stat = MenuButton.new()
var property_control_value = LineEdit.new()
# An internal value of the property.
var chosen_stat = OldStatSheetData.StatType.DAMAGE
var chosen_value = 0
var current_value = {0:chosen_stat, 1:chosen_value}
# A guard against internal changes when the property is updated.
var updating = false


var debug_info = []


var property_control_stat_popup

var enum_names = OldStatSheetData.StatType.keys()
var enum_string = String(enum_names)
var enum_length = OldStatSheetData.NUM_STATS



func _init():
	# Add the control as a direct child of EditorProperty node.
	# Make sure the control is able to retain the focus.
	add_child(property_hbox)
	property_hbox.add_child(property_control_stat)
	add_focusable(property_control_stat)

	property_control_stat_popup = property_control_stat.get_popup()

	for i in enum_length:
		property_control_stat_popup.add_item(enum_names[i])

	property_hbox.add_child(property_control_value)
	add_focusable(property_control_value)
	
	# Setup the initial state and connect to the signal to track changes.
	refresh_control_values()
	property_control_stat_popup.connect("index_pressed", self, "_on_change_stat")
	property_control_value.connect("text_entered", self, "_on_change_value")


func _on_change_stat(new_index):
	# Ignore the signal if the property is currently being updated.
	if (updating):
		return

	# Generate a new random integer between 0 and 99.
	chosen_stat = new_index
	refresh_control_values()
	emit_changed(get_edited_property(), current_value)
	
	print(debug_info)


func _on_change_value(new_text):
	# Ignore the signal if the property is currently being updated.
	if (updating):
		return
	
	chosen_value = float(new_text)
	refresh_control_values()
	emit_changed(get_edited_property(), current_value)

	print(debug_info)


func update_property():
	# Read the current value from the property.
	var new_value = get_edited_object()[get_edited_property()]
	if (new_value == current_value):
		return

	# Update the control with the new value.
	updating = true
	current_value = new_value
	chosen_stat
	refresh_control_values()
	updating = false

func refresh_control_values():
	property_control_stat.text = enum_names[chosen_stat]
	property_control_value.text = String(chosen_value)
	current_value.clear()
	current_value[0] = chosen_stat
	current_value[1] = chosen_value
	pass
