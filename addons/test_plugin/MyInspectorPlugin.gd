# MyInspectorPlugin.gd
extends EditorInspectorPlugin

var StatChangeEntryEditor = preload("res://addons/test_plugin/StatChangeEntryEditor.gd")


func can_handle(object):
	# We support all objects in this example.
	return true


func parse_property(object, type, path, hint, hint_text, usage):
	# We handle properties of type integer.
	if  object is StatChangeData  and  type==TYPE_DICTIONARY  and  not ("resource_" in path):

		#print(object, "\n", type, "\n", path, "\n\n")

		# Create an instance of the custom property editor and register
		# it to a specific property path.
		var stat_editor = StatChangeEntryEditor.new()
		stat_editor.debug_info = [object, type, path, hint, hint_text, usage]
		add_property_editor(path, stat_editor)
#		add_property_editor_for_multiple_properties(
#			"TEST",
#			[
#				"chosen_stat",
#				"current_value",
#			],
#			StatChangeEntryEditor.new()
#		)

		# Inform the editor to remove the default property editor for
		# this property type.
		return true
	else:
		return false
