extends RichTextLabel

export(Array, String, MULTILINE) var Chat

func setbb(n: int):
	bbcode_text = Chat[n]
