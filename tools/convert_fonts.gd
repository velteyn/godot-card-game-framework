#!/usr/bin/env -S godot47 --headless --script
extends SceneTree

func _init():
	var ubuntu = load("res://themes/darktheme/fonts/Ubuntu-L.ttf")
	if ubuntu:
		var err = ResourceSaver.save(ubuntu, "res://themes/darktheme/fonts/UbuntuFont.res")
		print("UbuntuFont save err: ", err)
	else:
		print("Failed to load Ubuntu-L.ttf")

	var reanie = load("res://themes/darktheme/fonts/Reenie_Beanie/ReenieBeanie-Regular.ttf")
	if reanie:
		var err = ResourceSaver.save(reanie, "res://themes/darktheme/fonts/ReanieBeanie.res")
		print("ReanieBeanie save err: ", err)
	else:
		print("Failed to load ReenieBeanie-Regular.ttf")

	quit()
