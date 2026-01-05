extends CollisionShape3D

const MAX_TILT_ANGLE: float = PI / 4
const TILT_TIME: float = 1.0
const TILT_SPEED: float = MAX_TILT_ANGLE / TILT_TIME

enum RotorDirection {FORWARDS, CENTERED, BACKWARDS}

var desired_direction: RotorDirection = RotorDirection.CENTERED


func set_desired_direction(direction: RotorDirection) -> void:
    self.desired_direction = direction


func _move_towards_desired_direction(delta: float) -> void:
    var tilt_delta: float = self.TILT_SPEED * delta

    match self.desired_direction:
        RotorDirection.FORWARDS:
            if self.rotation.x > -self.MAX_TILT_ANGLE:
                self.rotation.x -= tilt_delta
                if self.rotation.x < -self.MAX_TILT_ANGLE:
                    self.rotation.x = -self.MAX_TILT_ANGLE
        RotorDirection.BACKWARDS:
            if self.rotation.x < self.MAX_TILT_ANGLE:
                self.rotation.x += tilt_delta
                if self.rotation.x > self.MAX_TILT_ANGLE:
                    self.rotation.x = self.MAX_TILT_ANGLE
        RotorDirection.CENTERED:
            if self.rotation.x < 0:
                self.rotation.x += tilt_delta
                if self.rotation.x > 0:
                    self.rotation.x = 0
            elif self.rotation.x > 0:
                self.rotation.x -= tilt_delta
                if self.rotation.x < 0:
                    self.rotation.x = 0


func _physics_process(delta: float) -> void:
    self._move_towards_desired_direction(delta)


func get_tilt() -> float:
    return self.rotation.x / self.MAX_TILT_ANGLE
