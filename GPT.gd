@tool
extends Node
var received_message
@export var api_key = ""
var url = "https://api.openai.com/v1/chat/completions"

var headers: PackedStringArray = ["Content-Type: application/json; charset=utf-8", "Authorization: Bearer " + api_key]
@export var model = "gpt-3.5-turbo"
@export var max_tokens = 1024
@export var temperature = 0.5
var messages = []
var request: HTTPRequest

func _ready() -> void:

	request = HTTPRequest.new()
	add_child(request)
	request.connect("request_completed", _on_request_completed)
func tellgpt(player_dialogue):
	messages.append({
		"role": "user",
		"content": player_dialogue
		})
	var json = JSON.new()
	var body = json.stringify({
		"messages": messages,
		"temperature": temperature,
		"max_tokens": max_tokens,
		"model": model
	})
	var send_request = request.request(url, headers, HTTPClient.METHOD_POST, body)

func _on_request_completed(result, response_code, headers, body):
	var json = JSON.new()
	json.parse(body.get_string_from_utf8())
	var response = json.get_data()
	received_message = response
