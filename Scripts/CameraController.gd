extends Camera2D


func _process(_delta):
	CameraManager.positions.TL = $TL.global_position
	CameraManager.positions.TR = $TR.global_position
	CameraManager.positions.BL = $BL.global_position
	CameraManager.positions.BR = $BR.global_position
	#if  PlayerManager.instance != null  and  get_parent() != PlayerManager.instance:
	#	PlayerManager.instance.add_child(self)
	pass

func _ready():
	CameraManager.instance = self
	CameraManager.spawn_area = $SpawnArea
	CameraManager.despawn_area = $DespawnArea
	CameraManager.spawn_shape = $SpawnArea/SpawnShape
	CameraManager.despawn_shape = $DespawnArea/DespawnShape
