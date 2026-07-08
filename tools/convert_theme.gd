#!/usr/bin/env -S godot47 --headless --script
extends SceneTree

func _init():
	# First save the fonts
	var ubuntu = load("res://themes/darktheme/fonts/Ubuntu-L.ttf")
	if ubuntu:
		var err = ResourceSaver.save(ubuntu, "res://themes/darktheme/fonts/UbuntuFont.res")
		print("UbuntuFont save: ", err)
	else:
		print("Ubuntu font load failed")

	var reanie = load("res://themes/darktheme/fonts/Reenie_Beanie/ReenieBeanie-Regular.ttf")
	if reanie:
		var err = ResourceSaver.save(reanie, "res://themes/darktheme/fonts/ReanieBeanie.res")
		print("ReanieBeanie save: ", err)
	else:
		print("Reanie font load failed")

	# Now try to convert the theme
	var theme = load("res://themes/darktheme/darktheme.theme")
	if theme:
		print("Theme loaded: ", theme.resource_path)
		var err = ResourceSaver.save(theme, "res://themes/darktheme/darktheme.theme")
		print("Theme re-save: ", err)
	else:
		print("Theme not loaded")

	quit()
