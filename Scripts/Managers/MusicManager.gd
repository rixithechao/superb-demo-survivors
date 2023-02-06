extends Node


var source
var playback
var pause_time = 0

var fade_mult : float = 1
var fade_seconds : float = 1
var fade_direction : int = 0

var current_track


const TRACKS = {
	"MENU_MAIN" : preload("res://Data Objects/Soundtrack/MusicData_Menu_Main.tres"),
	"STAGE_DEBUG" : preload("res://Data Objects/Soundtrack/MusicData_Stage_Debug.tres"),
	"STAGE_ISLANDS" : preload("res://Data Objects/Soundtrack/MusicData_Stage_Islands01.tres"),
}


func play(track = null):
	print("MUSIC PLAYED")

	var new_track = (track != current_track)
	var fading_out = (fade_mult <= 1  and  fade_direction <= 0)
	
	if  new_track:
		current_track = track
		source.stop()
		if  track != null:
			source.stream = track.audio_stream

	if  fading_out:
		fade_direction = 0
		fade_mult = 1

	if  not source.playing:
		source.play(0)
		playback = source.get_stream_playback()

func play_by_name(name: String):
	play(TRACKS[name])

func stop():
	print("MUSIC STOPPED")
	source.stop()
	playback = null
	fade_mult = 1
	fade_direction = 0

func pause():
	print("MUSIC PAUSED")
	pause_time = source.get_playback_position()
	source.stop()
	fade_mult = 1
	fade_direction = 0

func resume():
	print("MUSIC RESUMED")
	source.play(pause_time)
	fade_mult = 1
	fade_direction = 0


func fade_in(seconds : float = 1):
	print("MUSIC FADED IN")
	fade_direction = 1
	fade_seconds = seconds

func fade_out(seconds : float = 1):
	print("MUSIC FADED OUT")
	fade_direction = -1
	fade_seconds = seconds




func _ready():
	pause_mode = Node.PAUSE_MODE_PROCESS


func _process(delta):
	fade_mult = clamp(fade_mult + fade_direction*delta/fade_seconds, 0, 1)
	if  (fade_mult == 0  and  fade_direction == -1)  or  (fade_mult == 1  and  fade_direction == 1):
		fade_direction = 0

	source.volume_db = lerp(-80,0, fade_mult)

