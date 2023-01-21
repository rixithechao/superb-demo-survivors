extends Camera2D


func _process(_delta):
	#if  self.target == null:
	#	self.target = PlayerManager.instance
	pass

func _ready():
	CameraManager.instance = self
	CameraManager.spawn_area = $SpawnArea
	CameraManager.despawn_area = $DespawnArea
	CameraManager.spawn_shape = $SpawnArea/SpawnShape
	CameraManager.despawn_shape = $DespawnArea/DespawnShape
