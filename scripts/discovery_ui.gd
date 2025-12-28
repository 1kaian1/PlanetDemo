extends Control

signal search_pressed

@onready var SearchButton
@onready var SearchAreaIndicator
@onready var PriceLabel
@onready var coin_counter

func _enter_tree():
	SearchButton = get_node("MarginContainer/SearchButton")
	SearchAreaIndicator = get_node("MarginContainer2/SearchAreaIndicator")
	PriceLabel = get_node("MarginContainer2/SearchAreaIndicator/PriceLabel")
	coin_counter = get_node("CoinBar/CoinCounter")

func _ready():
	SearchButton.pressed.connect(
		func(): search_pressed.emit()
	)
	
func set_home_ui(active: bool):
	SearchButton.visible = !active
	SearchAreaIndicator.visible = !active
	PriceLabel.visible = !active
	
func set_discovery_ui(active: bool):
	SearchButton.visible = active
	SearchAreaIndicator.visible = active
	PriceLabel.visible = active
	
func load_coins():
	return coin_counter.load_coins()
	
func save_coins(number):
	coin_counter.save_coins(number)

	
