extends Node

#class DefaultEngine:
	#var version : String
	#var path : String

@export var path : String = ProjectSettings.globalize_path("user://")
var os_name : String = OS.get_name()
var os_arch : String = ""
#var default_engine : DefaultEngine

func _ready() -> void:
	_get_computer_specification()
	
	#if not default_engine:
		#_get_highest_version_engine()
#
#func _get_highest_version_engine() -> void:
	#var engines = DownloadManager._get_avaible_engines()
	#var max_engine_version : String = "0.0.0"
	#var max_engine : String = ""
	#for engine in engines:
		#var split = engine.split('_')
		#var version_str = split[0] # Np. "0.6.725"
#
		#if DownloadManager._is_version_higher(version_str, max_engine_version):
			#max_engine_version = version_str
			#max_engine = engine
	#_set_default_engine(max_engine)

#func _set_default_engine(version: String) -> void:
	#if default_engine && default_engine.version == version:
		#return
	#default_engine = DefaultEngine.new()
	#var engine_path = Settings.path.path_join('engine').path_join(version)
	#if DirAccess.dir_exists_absolute(engine_path):
		#default_engine.version = version
		#default_engine.path = engine_path
		#SignalBusGlobal.default_engine_changed.emit(version)


func _get_computer_specification() -> void:
	os_name = OS.get_name().to_lower()
	var is_arm_64: bool = OS.has_feature("arm64")
	var is_arm_32: bool = OS.has_feature("arm") and not is_arm_64
	var is_64_bit: bool = OS.has_feature("64")
	
	match os_name:
		"windows":
			if is_arm_64:
				os_arch = "arm64"
			elif is_arm_32:
				os_arch = "arm32"
			else:
				os_arch = "64bit" if is_64_bit else "32bit"
		"linux":
			os_arch = "x86_64" if is_64_bit else "x86_32"
		"macos":
			os_arch = "macos"
		_:
			os_arch = "unknown"
