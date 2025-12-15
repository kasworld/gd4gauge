extends MultiMeshShape
class_name BarGauge

signal max_reached( b :BarGauge)
signal zero_reached( b :BarGauge)

func init_bar_gauge(count :int, sz :Vector3, co1 :Color, co2 :Color, alpha :float = 1.0 , gaprate :float = 0.1) -> BarGauge:
	var mesh := BoxMesh.new()
	mesh.size = Vector3(sz.x, sz.y / count * (1-gaprate) , sz.z)
	init_with_color(mesh, Color(Color.WHITE, alpha), count)
	for i in count:
		var rate := (i as float) / (count as float)
		var pos3d := Vector3(0,rate*sz.y,0) # grow upward
		set_inst_pos(i, pos3d)
		set_inst_color(i, lerp(co1, co2, rate) )
	return self

func normalize_current_value() -> void:
	if get_visible_count() <= 0:
		set_visible_count(0)
		zero_reached.emit(self)
	elif get_visible_count() >= get_total_count():
		set_visible_count(get_total_count())
		max_reached.emit(self)

func set_current_value( i :int) -> void:
	normalize_current_value()
	set_visible_count(i)

func inc_current_value( n :int = 1 ) -> void:
	set_visible_count(get_visible_count()+n)
	normalize_current_value()

func dec_current_value( n :int = 1 ) -> void:
	set_visible_count(get_visible_count()-n)
	normalize_current_value()

func set_current_rate( v :float) -> void:
	set_visible_count(int(v * get_total_count()))
	normalize_current_value()

func calc_current_rate() -> float:
	return float(get_visible_count()) / float(get_total_count())
