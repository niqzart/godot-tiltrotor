extends RigidBody3D


func _physics_process(_delta: float) -> void:
    var right_position: Vector3 = self.transform.basis.x * 2
    var left_position: Vector3 = self.transform.basis.x * -2

    var right_force: Vector3 = self.transform.basis.y
    var left_force: Vector3 = self.transform.basis.y

    if Input.is_action_pressed("right_rotor_forwards"):
        right_position += self.transform.basis.z
        right_force -= self.transform.basis.z
    elif Input.is_action_pressed("right_rotor_backwards"):
        right_position -= self.transform.basis.z
        right_force += self.transform.basis.z

    if Input.is_action_pressed("left_rotor_forwards"):
        left_position += self.transform.basis.z
        left_force -= self.transform.basis.z
    elif Input.is_action_pressed("left_rotor_backwards"):
        left_position -= self.transform.basis.z
        left_force += self.transform.basis.z

    if Input.is_action_pressed("right_rotor_up"):
        right_force *= 10
    elif Input.is_action_pressed("right_rotor_down"):
        right_force *= -10
    else:
        right_force *= 5

    if Input.is_action_pressed("left_rotor_up"):
        left_force *= 10
    elif Input.is_action_pressed("left_rotor_down"):
        left_force *= -10
    else:
        left_force *= 5

    self.apply_force(right_force, right_position)
    self.apply_force(left_force, left_position)
