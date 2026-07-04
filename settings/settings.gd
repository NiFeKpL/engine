extends Node

@export var path : String = "user://"
var os_name : String = OS.get_name()
var os_arch : String = ""

func _ready() -> void:
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
