extends Node3D
class_name WaveGauge

var gauge_list :Array
var box_size :Vector3
var color_list := [
	Color.RED, Color.YELLOW,
	Color.GOLD, Color.PINK,
	Color.GREEN, Color.BLUE,
	Color.CYAN, Color.MAGENTA,
]
func init(sz :Vector3, co_list :Array = color_list, gaprate :float = 0.5, alpha :float = 0.5) -> WaveGauge:
	box_size = sz
	for i in box_size.x:
		var irate := float(i) / box_size.z
		for j in box_size.z:
			var jrate := float(j) / box_size.z
			var bg = preload("res://bar_gauge/bar_gauge.tscn").instantiate().init(
				box_size.y, Vector3( 1- gaprate, box_size.y, 1-gaprate),
				lerp( lerp(co_list[0], co_list[1], irate) , lerp(co_list[2], co_list[3], irate), jrate),
				lerp( lerp(co_list[4], co_list[5], irate) , lerp(co_list[6], co_list[7], irate), jrate),
				alpha,
				gaprate
				)
			bg.position = -box_size/2 + Vector3(i, 0, j)
			gauge_list.append(bg)
			add_child(bg)
	return self

func animate_wave() -> void:
	var now := Time.get_unix_time_from_system()
	for i in box_size.x:
		for j in box_size.z:
			var bg = gauge_list[j*int(box_size.z)+i]
			bg.set_current_rate(
				((sin( now*2 + i/box_size.x*PI ) + 1) / 4.0) +
				((cos( now*3 + j/box_size.z*PI ) + 1) / 4.0)
				)
