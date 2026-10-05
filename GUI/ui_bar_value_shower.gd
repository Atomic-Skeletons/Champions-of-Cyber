extends Label


func _ready() -> void:
	var bar : Range = get_parent().get_parent()
	
	bar.value_changed.connect(set_text_from_value)
	set_text_from_value(bar.value)

func set_text_from_value(value: float):
	text = str(int(value))
