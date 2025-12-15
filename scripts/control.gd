extends Control

signal discovery_mode_pressed
signal home_mode_pressed
signal search_pressed
signal exit_pressed

@onready var DiscoveryModeButton = get_node("MarginContainer/GridContainer/DiscoveryModeButton")
@onready var HomeModeButton = get_node("MarginContainer/GridContainer/HomeModeButton")
@onready var SearchButton = get_node("MarginContainer/GridContainer/SearchButton")
@onready var ExitButton = get_node("MarginContainer/GridContainer/ExitButton")

@onready var SearchAreaIndicator = get_node("DiscoveryMode/SearchAreaIndicator")
@onready var PriceLabel = get_node("DiscoveryMode/SearchAreaIndicator/PriceLabel")

@onready var coin_counter = get_node("CoinBar/CoinCounter")

func _ready():	
	DiscoveryModeButton.pressed.connect(
		func(): discovery_mode_pressed.emit()
	)
	HomeModeButton.pressed.connect(
		func(): home_mode_pressed.emit()
	)
	SearchButton.pressed.connect(
		func(): search_pressed.emit()
	)
	ExitButton.pressed.connect(
		func(): exit_pressed.emit()
	)
	
func set_ready_ui(active: bool):
	SearchButton.visible = !active
	ExitButton.visible = !active
	SearchAreaIndicator.visible = !active
	PriceLabel.visible = !active
	
func set_discovery_ui(active: bool):
	SearchButton.visible = active
	ExitButton.visible = active
	DiscoveryModeButton.visible = !active
	HomeModeButton.visible = !active
	SearchAreaIndicator.visible = active
	PriceLabel.visible = active
	
func set_home_ui(active: bool):
	ExitButton.visible = active
	HomeModeButton.visible = !active
	
func set_exit_ui(active: bool):
	SearchButton.visible = !active
	ExitButton.visible = !active
	DiscoveryModeButton.visible = active
	HomeModeButton.visible = active

func exit_discover_ui(active: bool):
	SearchAreaIndicator.visible = !active
	PriceLabel.visible = !active
	
func load_coins():
	return coin_counter.load_coins()
	
func save_coins(number):
	coin_counter.save_coins(number)

	
