extends RigidBody3D


func _physics_process(_delta: float) -> void:
    print(self.position, self.rotation)
