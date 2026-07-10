#!/usr/bin/env -S godot47 --headless --script
extends SceneTree

func _init():
	var classes := []
	var dirs = ["res://src/core/", "res://src/custom/"]

	for entry in ProjectSettings.get_global_class_list():
		var path: String = entry.path
		for d in dirs:
			if path.begins_with(d):
				classes.append({
					"class": entry.class,
					"base": entry.base,
					"language": entry.language,
					"path": path,
					"is_abstract": false,
					"is_tool": false,
				})
				break

	# Write the cache
	var cf = ConfigFile.new()
	cf.set_value("", "list", classes)
	cf.save("res://.godot/global_script_class_cache.cfg")
	print("Saved ", classes.size(), " classes")
	quit()
