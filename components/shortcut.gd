extends Node
class_name ShortcutComponent

# it seams like shortcuts ignore the pressed/released flag and only trigger on pressed
# https://github.com/godotengine/godot/issues/75318
# ... therefore we need a custom implementation

@export var action: StringName
@export var on_pressed: bool = false

var _button: Button

func _ready() -> void:
	_button = get_parent() as Button

	if not _button:
		# disable self if parent is not a Button
		push_warning("ShortcutComponent: Parent node must be of type Button! [%s]" % get_path())
		process_mode = Node.PROCESS_MODE_DISABLED

func _process(_delta: float) -> void:
	if not _button:
		return

	if not _button.is_visible_in_tree():
		return

	if action.is_empty():
		return

	if on_pressed:
		if Input.is_action_just_pressed(action):
			_button.pressed.emit()
	else:
		if Input.is_action_just_released(action):
			_button.pressed.emit()
