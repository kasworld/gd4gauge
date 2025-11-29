extends Node3D

const WorldSize := Vector3(32,64,32)
const AnimationDuration := 1.0

var main_animation := Animation3D.new()
func main_animation_ended(_node :Node3D, _ani :Dictionary) -> void:
	if main_animation.is_empty():
		start_all_animation()
func start_rotate_animation(nd :Node3D, axis :int, ani_dur :float) -> void:
	var diff :float = [PI/2,-PI/2].pick_random()
	main_animation.start_rotate_subfield("ani_rot", nd, axis , nd.rotation[axis], nd.rotation[axis] + diff, ani_dur)
func start_all_animation() -> void:
	pass

var gauge_list :Array

func _ready() -> void:
	get_viewport().size_changed.connect(on_viewport_size_changed)
	var vp_size = get_viewport().get_visible_rect().size
	var 짧은길이 = min(vp_size.x,vp_size.y)
	$"왼쪽패널".size = Vector2(vp_size.x/2 - 짧은길이/2, vp_size.y)
	$오른쪽패널.size = Vector2(vp_size.x/2 - 짧은길이/2, vp_size.y)
	$오른쪽패널.position = Vector2(vp_size.x/2 + 짧은길이/2, 0)

	$OmniLight3D.position = Vector3(0,0,WorldSize.length())
	$OmniLight3D.omni_range = WorldSize.length()*2
	$FixedCameraLight.set_center_pos_far(
		Vector3.ZERO,
		Vector3(0, 0, WorldSize.x),
		WorldSize.length()*2)

	var msgrect = Rect2( vp_size.x * 0.1 ,vp_size.y * 0.4 , vp_size.x * 0.8 , vp_size.y * 0.25 )
	$TimedMessage.init(80, msgrect,
		"%s %s" % [
			ProjectSettings.get_setting("application/config/name"),
			ProjectSettings.get_setting("application/config/version")
			] )

	$TimedMessage.panel_hidden.connect(message_hidden)
	$TimedMessage.show_message("",0)

	$AxisArrow3D.set_size(10)
	for i in WorldSize.x:
		var irate := float(i) / WorldSize.z
		for j in WorldSize.z:
			var jrate := float(j) / WorldSize.z
			var bg = preload("res://bar_gauge/bar_gauge.tscn").instantiate().init(
				WorldSize.y, Vector3(0.9, WorldSize.y, 0.9),
				lerp( lerp(Color.RED, Color.YELLOW, irate) , lerp(Color.GOLD, Color.PINK, irate), jrate),
				lerp( lerp(Color.GREEN, Color.BLUE, irate) , lerp(Color.CYAN, Color.MAGENTA, irate), jrate),
				0.5,
				)
			bg.position = -WorldSize/2 + Vector3(i, 0, j)

			bg.set_current_value(WorldSize.y/2)
			gauge_list.append(bg)
			add_child(bg)

	wallbox_demo()

	main_animation.animation_ended.connect(main_animation_ended)
	start_all_animation()

func animate_gauge_rand() -> void:
	for i in gauge_list.size()/10:
		var bg = gauge_list.pick_random()
		bg.inc_current_value( [-1,1].pick_random() )

func animate_gauge_wave() -> void:
	var now := Time.get_unix_time_from_system()
	for i in WorldSize.x:
		for j in WorldSize.z:
			var bg = gauge_list[j*int(WorldSize.z)+i]
			bg.set_current_rate(
				((sin( now*2 + i/WorldSize.x ) + 1) / 4.0) +
				((cos( now*3 + j/WorldSize.z ) + 1) / 4.0)
				)

func wallbox_demo() -> void:
	$WallBox.mesh.size = WorldSize #+ Vector3(1,1,5)
	$WallBox.position = WorldSize/2 + Vector3(0,0,-WorldSize.z/2)
	$WallBox.mesh.material.albedo_color = Color(random_color(), 0.5)

func random_color()->Color:
	return NamedColorList.color_list.pick_random()[0]

func label_demo() -> void:
	if $"오른쪽패널/LabelPerformance".visible:
		$"오른쪽패널/LabelPerformance".text = """%d FPS (%.2f mspf)
Currently rendering: occlusion culling:%s
%d objects
%dK primitive indices
%d draw calls""" % [
		Engine.get_frames_per_second(),1000.0 / Engine.get_frames_per_second(),
		get_tree().root.use_occlusion_culling,
		RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_OBJECTS_IN_FRAME),
		RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_PRIMITIVES_IN_FRAME) * 0.001,
		RenderingServer.get_rendering_info(RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME),
		]
	if $"오른쪽패널/LabelInfo".visible:
		$"오른쪽패널/LabelInfo".text = "%s" % [ MovingCameraLight.GetCurrentCamera() ]

func on_viewport_size_changed():
	pass

func message_hidden(_s :String) -> void:
	pass

func _process(_delta: float) -> void:
	label_demo()
	animate_gauge_wave()
	main_animation.handle_animation()
	if $MovingCameraLightHober.is_current_camera():
		$MovingCameraLightHober.move_hober_around_z(Vector3.ZERO, (WorldSize.x+WorldSize.y)/2, WorldSize.length()*0.6 )
	elif $MovingCameraLightAround.is_current_camera():
		$MovingCameraLightAround.move_around_y(Vector3.ZERO, (WorldSize.x+WorldSize.y)/2, WorldSize.length()*0.6 )

func _on_카메라변경_pressed() -> void:
	MovingCameraLight.NextCamera()

func _on_button_fov_up_pressed() -> void:
	MovingCameraLight.GetCurrentCamera().fov_camera_inc()

func _on_button_fov_down_pressed() -> void:
	MovingCameraLight.GetCurrentCamera().fov_camera_dec()

var key2fn = {
	KEY_ESCAPE:_on_button_esc_pressed,
	KEY_ENTER:_on_카메라변경_pressed,
	KEY_INSERT:_on_button_fov_up_pressed,
	KEY_DELETE:_on_button_fov_down_pressed,
}
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		var fn = key2fn.get(event.keycode)
		if fn != null:
			fn.call()
	elif event is InputEventMouseButton and event.is_pressed():
		pass

func _on_button_esc_pressed() -> void:
	get_tree().quit()
