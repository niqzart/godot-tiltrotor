extends RigidBody3D


class PIDController:
    var p_coefficient: float = 1
    var i_coefficient: float = 0.1
    var d_coefficient: float = 0.5

    var setpoint: float = 0.0

    var integral_sum: float = 0.0
    var last_error: float = 0.0

    func calculate(current_value: float, delta: float) -> float:
        var error: float = self.setpoint - current_value
        self.integral_sum += error * delta

        var derivative_term: float = (error - self.last_error) / delta
        self.last_error = error

        return (
            self.p_coefficient * error
            + self.i_coefficient * self.integral_sum
            + self.d_coefficient * derivative_term
        )

    func reset() -> void:
        self.integral_sum = 0.0
        self.last_error = 0.0


var x_angle_pid = PIDController.new()
var z_angle_pid = PIDController.new()

var pid_enabled = true


func _process(_delta: float) -> void:
    if Input.is_action_just_pressed("enable_pid"):
        self.pid_enabled = not self.pid_enabled
        if self.pid_enabled:
            self.x_angle_pid.reset()
            self.z_angle_pid.reset()


func _physics_process(delta: float) -> void:
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

    if self.pid_enabled:
        # if Input.is_anything_pressed():  # TODO: do this once
        #     self.x_angle_pid.reset()
        #     self.z_angle_pid.reset()
        # else:
        self.apply_torque(Vector3.RIGHT * self.x_angle_pid.calculate(self.rotation.x, delta))
        self.apply_torque(Vector3.BACK * self.z_angle_pid.calculate(self.rotation.z, delta))
