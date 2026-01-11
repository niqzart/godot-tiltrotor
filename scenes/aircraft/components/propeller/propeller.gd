extends RigidBody3D


var rigid_body: RigidBody3D


func _attach_to_parent() -> void:
    var parent = self.get_parent()
    if not is_instance_of(parent, RigidBody3D):
        push_warning("Invalid parent, skipping attachment process")
        self.rigid_body = self
        return

    self.rigid_body = parent

    for child_node in self.get_children():
        child_node.call_deferred("reparent", self.rigid_body)

    self.freeze = true

    # TODO: move parent's center of gravity & update the mass based on the rigid body


func _ready() -> void:
    self._attach_to_parent()


@onready var blades = $Blades


func _physics_process(_delta: float) -> void:
    var force = self.rigid_body.basis * Vector3(0, 2.5, 0)
    force *= 2.5 / force.y
    self.rigid_body.apply_force(force, self.rigid_body.basis * self.blades.position)
