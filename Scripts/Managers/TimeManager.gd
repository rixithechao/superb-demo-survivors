extends Node

var _cached_seconds = 0
var _cached_minutes = 0

var current_time = 0
var time_rate = 1

var total_seconds_passed = 0 setget ,get_total_seconds_passed
var seconds_passed = 0 setget ,get_seconds_passed
var minutes_passed = 0 setget ,get_minutes_passed

signal new_second
signal new_minute


func get_total_seconds_passed():
	return (floor(current_time) as int)
	pass

func get_seconds_passed():
	return (floor((current_time as int) % 60) as int)
	pass

func get_minutes_passed():
	return (floor(get_total_seconds_passed()/60) as int)
	pass


func _process(delta):
	current_time += delta*time_rate

	if get_seconds_passed() != _cached_seconds:
		_cached_seconds = get_seconds_passed()
		emit_signal("new_second")

	if get_minutes_passed() != _cached_minutes:
		_cached_minutes = get_minutes_passed()
		emit_signal("new_minute")
