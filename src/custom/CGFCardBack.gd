extends CardBackGlow

var font_scaled : float = 1
var _base_label_min_size := Vector2.ZERO
var _base_font_size := 12

func _ready() -> void:
	viewed_node = $Viewed
	var label : Label = $Label
	_base_label_min_size = label.custom_minimum_size
	_base_font_size = label.get_theme_font_size("font")
	
# Since we have a label on top of our image, we use this to scale the label
# as well
# We don't care about the viewed icon, since it will never be visible
# in the viewport focus.
func scale_to(scale_multiplier: float) -> void:	
	if font_scaled != scale_multiplier:
		var label : Label = $Label
		label.custom_minimum_size = _base_label_min_size * scale_multiplier
		# We need to adjust the Viewed Container
		# a bit more to make the text land in the middle
#		$"VBoxContainer/CenterContainer".rect_min_size *= scale_multiplier * 1.5
		label.add_theme_font_size_override("font", int(round(_base_font_size * scale_multiplier)))
		font_scaled = scale_multiplier
	
