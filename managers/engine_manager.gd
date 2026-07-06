extends Node

class SavedEngine:
	var path : String
	var version : String
	var release_type : String
	var type : String

var saved_engines : Array[SavedEngine] = []

func _ready() -> void:
	var engines = _get_avaible_engines()
	for engine in engines:
		add_engine(engine)
	
	SignalBusGlobal.download_finished.connect(_on_engine_downloaded)
	SignalBusGlobal.engine_uninstalled.connect(_on_engine_uninstalled)

func _on_engine_downloaded(output_path: String) -> void:
	var engine = output_path.get_file()
	add_engine(engine)

func _on_engine_uninstalled(engine_path: String) -> void:
	#var engine = output_path.get_file()
	print(saved_engines.size())
	for engine in saved_engines:
		if engine.path == engine_path:
			saved_engines.erase(engine)
	print(saved_engines.size())

func _is_engine_version_exists(version: String) -> bool:
	for engine in saved_engines:
		if engine.version == version:
			return true
	return false

func add_engine(engine: String) -> void:
	var saved_engine : SavedEngine = SavedEngine.new()
	saved_engine.path = SettingsManager.path.path_join('engine').path_join(engine)
	var split = engine.split('_')
	if split.size() == 1:
		saved_engine.version = split[0]
	elif split.size() == 2:
		saved_engine.version = split[0]
		saved_engine.release_type = split[1]
	elif split.size() == 3:
		saved_engine.version = split[0]
		saved_engine.release_type = split[1]
		saved_engine.type = split[2]
	saved_engines.append(saved_engine)
	print(saved_engines.size())

func _is_version_higher(v1: String, v2: String) -> bool:
	var parts1 = v1.split(".")
	var parts2 = v2.split(".")
	
	for i in range(min(parts1.size(), parts2.size())):
		var num1 = parts1[i].to_int()
		var num2 = parts2[i].to_int()
		
		if num1 > num2:
			return true
		elif num1 < num2:
			return false
			
	return parts1.size() > parts2.size()

func _is_version_lower(node_a: EngineItem, node_b: EngineItem) -> bool:
	var v1 = node_a.version 
	var v2 = node_b.version
	
	var parts1 = v1.split(".")
	var parts2 = v2.split(".")

	for i in range(min(parts1.size(), parts2.size())):
		var num1 = parts1[i].to_int()
		var num2 = parts2[i].to_int()
		
		if num1 > num2:
			return true
		elif num1 < num2:
			return false
			
	return parts1.size() > parts2.size()

func _get_avaible_engines() -> PackedStringArray:
	var engines_path : String = SettingsManager.path.path_join('engine')
	var engines : PackedStringArray = DirAccess.get_directories_at(engines_path)
	return engines
