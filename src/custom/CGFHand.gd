extends Hand


func _ready() -> void:
	super()
	$Control/ManipulationButtons/DiscardRandom.connect("pressed", Callable(self, '_on_DiscardRandom_Button_pressed'))
