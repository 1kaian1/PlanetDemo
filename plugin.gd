@tool
extends EditorPlugin


func _enter_tree() -> void:
	add_custom_type("ChatGPT", "HTTPRequest", preload("res://addons/GodotGPT/GPT.gd"), preload("res://addons/GodotGPT/icon.png"))

func _exit_tree() -> void:
	remove_custom_type("ChatGPT")
