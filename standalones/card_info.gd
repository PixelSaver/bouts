extends Resource
class_name CardInfo

@export var name := "Card"
@export var icon: Texture2D = preload("res://assets/icon.svg")
@export var description := "Lorem ipsum dolore n stuff"
@export var upgrade : UpgradeManager.Upgrades 
