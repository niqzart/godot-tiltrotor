extends RigidBody3D


func _physics_process(_delta: float) -> void:
    var right_force: Vector3 = self.transform.basis.y * 5
    var left_force: Vector3 = self.transform.basis.y * 5

    self.apply_force(right_force, self.transform.basis.x * 2)
    self.apply_force(left_force, self.transform.basis.x * -2)
