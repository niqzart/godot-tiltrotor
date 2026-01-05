extends CollisionShape3D

enum RotorDirection {FORWARDS, CENTERED, BACKWARDS}

var desired_direction: RotorDirection = RotorDirection.CENTERED


func set_desired_direction(direction: RotorDirection) -> void:
    self.desired_direction = direction


const MAX_TILT_ANGLE: float = PI / 4
const TILT_TIME: float = 1.0
const TILT_SPEED: float = MAX_TILT_ANGLE / TILT_TIME

const ROTOR_DIRECTION_TO_DESIRED_ANGLE: Dictionary[RotorDirection, float] = {
    RotorDirection.FORWARDS: -MAX_TILT_ANGLE,
    RotorDirection.CENTERED: 0,
    RotorDirection.BACKWARDS: MAX_TILT_ANGLE,
}


func _move_towards_desired_direction(delta: float) -> void:
    var desired_angle: float = self.ROTOR_DIRECTION_TO_DESIRED_ANGLE[self.desired_direction]
    var tilt_delta: float = self.TILT_SPEED * delta
    if self.rotation.x < desired_angle:
        self.rotation.x += tilt_delta
        if self.rotation.x > desired_angle:
            self.rotation.x = desired_angle
    elif self.rotation.x > desired_angle:
        self.rotation.x -= tilt_delta
        if self.rotation.x < desired_angle:
            self.rotation.x = desired_angle


var tilt: float:
    get: return self.rotation.x / self.MAX_TILT_ANGLE


enum PoverMode {HOVER, BOOSTED, REVERSE}

var power_mode: PoverMode = PoverMode.HOVER


func set_power_mode(mode: PoverMode) -> void:
    self.power_mode = mode


const HOVER_POWER: float = 5
const MAX_POWER: float = HOVER_POWER * 2
const POVER_MODE_TO_DESIRED_POWER: Dictionary[PoverMode, float] = {
    PoverMode.HOVER: self.HOVER_POWER,
    PoverMode.BOOSTED: self.MAX_POWER,
    PoverMode.REVERSE: -self.MAX_POWER,
}
const POWER_UPDATE_SPEED: float = 40

var current_combined_power: float = self.POVER_MODE_TO_DESIRED_POWER[PoverMode.HOVER]


func _move_towards_desired_power(delta: float) -> void:
    var desired_power: float = self.POVER_MODE_TO_DESIRED_POWER[self.power_mode]
    var power_delta: float = self.POWER_UPDATE_SPEED * delta
    if self.current_combined_power < desired_power:
        self.current_combined_power += power_delta
        if self.current_combined_power > desired_power:
            self.current_combined_power = desired_power
    elif self.current_combined_power > desired_power:
        self.current_combined_power -= power_delta
        if self.current_combined_power < desired_power:
            self.current_combined_power = desired_power


func _physics_process(delta: float) -> void:
    self._move_towards_desired_direction(delta)
    self._move_towards_desired_power(delta)


func get_current_vertical_power() -> float:
    var max_vertical_output = (1 - abs(self.tilt) * 0.4) * MAX_POWER
    return clamp(self.current_combined_power, -max_vertical_output, max_vertical_output)
