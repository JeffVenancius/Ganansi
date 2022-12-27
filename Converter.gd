extends Control


"""
TODO - create a button to copy the array.
TODO - List colors so the user can change the character and/or color
TODO - different chars algorithm


Get image total size (region rect later)
Divide by hframes
Divide by vframes
for each frame, which will start at the multiplication of h/w frame and end by the the base size of the h/w size, do something
"""

onready var spr = $Sprite

var char_array = []
var stop = false
var fps = 10.0


func _ready() -> void:
	$VBoxContainer/HBoxContainer2/SpinBox.value = fps
	$Panel.hide()
	$HBoxContainer.hide()
	$VBoxContainer/Button2.hide()
	$VBoxContainer/HBoxContainer2.hide()
	$VBoxContainer/VBoxContainer/Control.hide()
	$VBoxContainer.set_anchors_and_margins_preset(Control.PRESET_CENTER, Control.PRESET_MODE_KEEP_SIZE, 0)
	spr.position = Vector2(600,258)
	$HBoxContainer.rect_position = Vector2(601, 233)

func textConverter():
	stop = false
	var frame_pixels = []
	var img: Image = spr.texture.get_data()
	img.lock()
	var totalFrames = (spr.hframes * spr.vframes) -1
	var frame_width = spr.texture.get_width()/ spr.hframes+1
	var frame_height = spr.texture.get_height()/ spr.vframes+1
	var frames_array = []
	for v in spr.vframes:
		var vregion = v + 1
		for h in spr.hframes:
			var hregion = h + 1
			var frame_rect = Rect2((frame_width * hregion) - frame_width , (frame_height * vregion) - frame_height, frame_width-1, frame_height-1)
			frames_array.append(frame_rect)


	for i in frames_array:
		frame_pixels.append([])
		for j in range(i.position.y,clamp(i.end.y, 0, spr.texture.get_height())):
			frame_pixels[-1].append([])
			for k in range(i.position.x,clamp(i.end.x, 0, spr.texture.get_width())):
				frame_pixels[-1][-1].append(img.get_pixelv(Vector2(k,j)))


	for i in frame_pixels:
		var chars = ""
		var last_color
		for y in i:
			for x in y:
				if last_color == x.to_html():
					chars += get_char(x)
				else:
					chars += '[/color][color=#' + x.to_html() + ']' + get_char(x)
				last_color = x.to_html()
			chars += '\n'
			
		char_array.append(chars.trim_prefix('[/color]') + '[/color]')
	
	anim(char_array)

func anim(arr):
	var a = 0
	if not stop:
		for i in arr:
			$RichTextLabel.bbcode_text = i
			spr.frame = a
			a += 1
			yield(get_tree().create_timer(fps), "timeout")
	if not stop:
		anim(arr)
	else:
		$RichTextLabel.bbcode_text = ""
		spr.frame = 0
		spr.hframes = 1
		spr.vframes = 1
		spr.hide()


func get_char(color:Color):
	return "#"


func _on_Button_pressed() -> void:
	stop = true
	print(stop)
	$FileDialog.popup()
	$VBoxContainer.hide()


func _on_FileDialog_file_selected(path: String) -> void:
	spr.texture = load(path)
	$Panel.show()
	$HBoxContainer.show()
	spr.show()

func _on_hframes_value_changed(value: float) -> void:
	spr.hframes = int(value)

func _on_vframes_value_changed(value: float) -> void:
	spr.vframes = int(value)

func _on_zoom_minus_pressed() -> void:
	if spr.scale.x > 1:
		spr.scale.x -= 1
		spr.scale.y -= 1


func _on_zoom_plus_pressed() -> void:
	spr.scale.x += 1
	spr.scale.y += 1



func _on_back_pressed() -> void:
	if spr.frame > 0:
		spr.frame -= 1


func _on_next_pressed() -> void:
	if spr.frame < spr.hframes * spr.vframes - 1:
		spr.frame += 1


func _on_convert_pressed() -> void:
	char_array = []
	$Panel.hide()
	$VBoxContainer/Button2.show()
	$VBoxContainer/VBoxContainer/Control.show()
	textConverter()
	spr.position = Vector2(518,96)
	$HBoxContainer.rect_position = Vector2(518, 64)
	$VBoxContainer/HBoxContainer2.show()
	$VBoxContainer.show()
	$VBoxContainer.set_anchors_and_margins_preset(Control.PRESET_TOP_RIGHT, Control.PRESET_MODE_KEEP_SIZE, 10)

func _on_copy_pressed() -> void:
	OS.set_clipboard(var2str(char_array))


func _on_fps_value_changed(value: float) -> void:
	if value == 0:
		stop = true
	else:
		fps = 60/value/60


func _on_FileDialog_popup_hide() -> void:
	if !$Panel.visible:
		$VBoxContainer.show()
