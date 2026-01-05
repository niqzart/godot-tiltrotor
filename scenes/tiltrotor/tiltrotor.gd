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

var pid_enabled = false


func _update_rotor_color() -> void:
    $RightRotor/Mesh.mesh.material.albedo_color = (
        Color("#ff5e61") if self.pid_enabled else Color("#c15dff")
    )


func _ready() -> void:
    self._update_rotor_color()


func _process(_delta: float) -> void:
    if Input.is_action_just_pressed("enable_pid"):
        self.pid_enabled = not self.pid_enabled
        if self.pid_enabled:
            self.x_angle_pid.reset()
            self.z_angle_pid.reset()
        self._update_rotor_color()


enum InputMode {
    COPLEX_V1,
    COPLEX_V2,
}


var hover_input_mode: InputMode = InputMode.COPLEX_V2


func _apply_forces_from_inputs_complex_v1() -> void:
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


const DEFAULT_ROTOR_POWER: float = 5

const MAX_ROTOR_TILT_ANGLE: float = PI / 4
const ROTOR_TILT_SNAP_THRESHOLD: float = 0.05
const ROTOR_TILT_SPEED: float = 0.8


func _apply_forces_from_inputs_complex_v2() -> void:
    if Input.is_action_pressed("right_rotor_collective_forwards"):
        $RightRotor.set_desired_direction($RightRotor.RotorDirection.FORWARDS)
    elif Input.is_action_pressed("right_rotor_collective_backwards"):
        $RightRotor.set_desired_direction($RightRotor.RotorDirection.BACKWARDS)
    else:
        $RightRotor.set_desired_direction($RightRotor.RotorDirection.CENTERED)

    if Input.is_action_pressed("left_rotor_collective_forwards"):
        $LeftRotor.set_desired_direction($LeftRotor.RotorDirection.FORWARDS)
    elif Input.is_action_pressed("left_rotor_collective_backwards"):
        $LeftRotor.set_desired_direction($LeftRotor.RotorDirection.BACKWARDS)
    else:
        $LeftRotor.set_desired_direction($LeftRotor.RotorDirection.CENTERED)

    var right_rotor_tilt: float = $RightRotor.rotation.x / self.MAX_ROTOR_TILT_ANGLE
    var left_rotor_tilt: float = $LeftRotor.rotation.x / self.MAX_ROTOR_TILT_ANGLE

    var right_max_power_factor: float = 1.2 + (1 - abs(right_rotor_tilt)) * 0.8
    var left_max_power_factor: float = 1.2 + (1 - abs(left_rotor_tilt)) * 0.8

    var right_power: float = self.DEFAULT_ROTOR_POWER
    var left_power: float = self.DEFAULT_ROTOR_POWER

    if Input.is_action_pressed("right_rotor_collective_up"):
        right_power *= right_max_power_factor
    elif Input.is_action_pressed("right_rotor_collective_down"):
        right_power *= -right_max_power_factor

    if Input.is_action_pressed("left_rotor_collective_up"):
        left_power *= left_max_power_factor
    elif Input.is_action_pressed("left_rotor_collective_down"):
        left_power *= -left_max_power_factor

    var right_force_direction: Vector3 = (
        self.transform.basis.y + self.transform.basis.z * right_rotor_tilt
    )
    var left_force_direction: Vector3 = (
        self.transform.basis.y + self.transform.basis.z * left_rotor_tilt
    )

    var right_position: Vector3 = self.transform.basis.x * 2
    var left_position: Vector3 = self.transform.basis.x * -2

    if Input.is_action_pressed("right_rotor_cyclic_forwards"):
        right_position += self.transform.basis.z
    elif Input.is_action_pressed("right_rotor_cyclic_backwards"):
        right_position -= self.transform.basis.z

    if Input.is_action_pressed("left_rotor_cyclic_forwards"):
        left_position += self.transform.basis.z
    elif Input.is_action_pressed("left_rotor_cyclic_backwards"):
        left_position -= self.transform.basis.z

    self.apply_force(right_force_direction * right_power, right_position)
    self.apply_force(left_force_direction * left_power, left_position)


func _physics_process(delta: float) -> void:
    print(self.global_position, self.global_rotation)

    match self.hover_input_mode:
        InputMode.COPLEX_V1:
            self._apply_forces_from_inputs_complex_v1()
        InputMode.COPLEX_V2:
            self._apply_forces_from_inputs_complex_v2()

    if self.pid_enabled:
        # if Input.is_anything_pressed():  # TODO: do this once
        #     self.x_angle_pid.reset()
        #     self.z_angle_pid.reset()
        # else:
        self.apply_torque(Vector3.RIGHT * self.x_angle_pid.calculate(self.rotation.x, delta))
        self.apply_torque(Vector3.BACK * self.z_angle_pid.calculate(self.rotation.z, delta))
