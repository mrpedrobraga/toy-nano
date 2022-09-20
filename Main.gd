extends Control

@onready var text_edit : TextEdit = %Source
@onready var lex_result : RichTextLabel = %LexResult

func _on_lex_pressed():
	var tokens = TNTokenizer.tokenize(text_edit.text)
	lex_result.text = str(tokens)

func _on_runtimetest_pressed():
	var r = TNRuntime.new()
