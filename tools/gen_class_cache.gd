#!/usr/bin/env -S godot47 --headless --script
extends SceneTree

func _init():
	var classes := []
	var dirs = ["res://src/core/", "res://src/custom/"]
	
	for d in dirs:
		var dir = DirAccess.open(d)
		if dir:
			dir.list_dir_begin()
			var f = dir.get_next()
			while f != "":
				if f.ends_with(".gd"):
					var path = d + f
					var script = load(path)
					if script and script is GDScript:
						var base_class = ""
						if script.get_base() != "GDScript":
							base_class = script.get_base()
						var class_name = GlobalScriptServer.get_global_class_name(path)
						if class_name != "":
							classes.append({
								"class": class_name,
								"base": base_class,
								"language": "GDScript",
								"path": path,
								"is_abstract": false,
								"is_tool": false,
							})
				f = dir.get_next()
			dir.list_dir_end()
	
	# Write the cache
	var cf = ConfigFile.new()
	cf.set_value("", "list", classes)
	cf.save("res://.godot/global_script_class_cache.cfg")
	print("Saved ", classes.size(), " classes")
	quit()
