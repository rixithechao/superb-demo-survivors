extends Camera2D


func _process(_delta):
	#if  PlayerManager.instance != null  and  get_parent() != PlayerManager.instance:
	#	PlayerManager.instance.add_child(self)
	pass

func _ready():
	CameraManager.instance = self
	CameraManager.spawn_area = $SpawnArea
	CameraManager.despawn_area = $DespawnArea
	CameraManager.spawn_shape = $SpawnArea/SpawnShape
	CameraManager.despawn_shape = $DespawnArea/DespawnShape
