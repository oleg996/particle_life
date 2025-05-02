extends Node2D

var points_pos = []
var points_vel = []
var points_type = []

var points_den = []
var pticle_image: Image
var pticle_texture: ImageTexture


var points_count = 30000

@export var drag = 0.01;
@export var force = 1;
@export var rep_force = 1;

@export var cels_type:int = 7;

@export var force_dist = 50

@export var rep_force_dist = 10

@export var speed = 1;


var field_size = 1000;


var size = int(ceil(sqrt(points_count)))



var rd : RenderingDevice
var compute_shader : RID
var pipeline : RID
var bindings : Array
var uniform_set : RID

var pos_buffer : RID
var vel_buffer : RID
var params_buffer : RID
var params_uniform : RDUniform
var particle_data_bufer : RID


var forces_buffer : RID
var forces_uniform : RDUniform


var forces = [];


func _ready() -> void:
	
	points_count = Data.p_am
	field_size = Data.w_size
	cels_type = Data.p_types
	
	for i in cels_type*cels_type:
		forces.append(randf_range(-1,1))
	
	
	for i in points_count:
		points_vel.append(Vector2(0,0))
		points_den.append(Vector2(0,0))
		var pos = Vector2(randf_range(0,field_size),randf_range(0,field_size))
		points_pos.append(pos)
		points_type.append(i % 2);
		
	pticle_image = Image.create(size,size,false,Image.FORMAT_RGBAH)
	pticle_texture = ImageTexture.create_from_image(pticle_image)
	$GPUParticles2D.amount = points_count
	$GPUParticles2D.process_material.set_shader_parameter("count",cels_type)
	$GPUParticles2D.process_material.set_shader_parameter("data",pticle_texture)
	$GPUParticles2D.visibility_rect = Rect2(-100,-100,field_size,field_size)
	_setup_shader()
	_upddate_gpu(0)
	




func _process(delta: float) -> void:
	_get_from_gpu()
	update_texture()
	_upddate_gpu(delta)
	get_window().title = "points:"+str(points_count)+"/FPS"+str(Engine.get_frames_per_second())
	





func _createbuf(data):
	var datubuffer := PackedVector2Array(data).to_byte_array()
	return rd.storage_buffer_create(datubuffer.size(),datubuffer)
func _cr_uniform(data_buf,type,binding):
	var data_uni = RDUniform.new()
	data_uni.binding = binding;
	data_uni.uniform_type = type
	data_uni.add_id(data_buf)
	return data_uni
	
	
	
func  _setup_shader():
	rd = RenderingServer.create_local_rendering_device()
	
	var shader_file := load("res://shader/shader.glsl")
	var shader_spirv = shader_file.get_spirv()
	compute_shader = rd.shader_create_from_spirv(shader_spirv)
	pipeline = rd.compute_pipeline_create(compute_shader)
	
	
	pos_buffer = _createbuf(points_pos)
	var boid_pos_uniform = _cr_uniform(pos_buffer,RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER,0)
	
	vel_buffer = _createbuf(points_vel)
	var boid_vel_uniform = _cr_uniform(vel_buffer,RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER,1)
	var params_bytes = PackedFloat32Array(
		[points_count,
		cels_type,
		size,
		field_size,
		field_size,
		0,
		drag,
		force,
		rep_force,
		force_dist,
		rep_force_dist
		]).to_byte_array()
	
	
	params_buffer = rd.storage_buffer_create(params_bytes.size(),params_bytes)
	
	
	params_uniform = _cr_uniform(params_buffer,RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER,2)
	var fmt := RDTextureFormat.new()
	fmt.width = size
	fmt.height = size
	fmt.format = RenderingDevice.DATA_FORMAT_R16G16B16A16_SFLOAT
	fmt.usage_bits = RenderingDevice.TEXTURE_USAGE_CAN_UPDATE_BIT | RenderingDevice.TEXTURE_USAGE_STORAGE_BIT | RenderingDevice.TEXTURE_USAGE_CAN_COPY_FROM_BIT
	
	var view := RDTextureView.new()
	particle_data_bufer = rd.texture_create(fmt,view,[pticle_image.get_data()])
	
	var boid_data_unniform = _cr_uniform(particle_data_bufer,RenderingDevice.UNIFORM_TYPE_IMAGE,3)
	
	var datubuffer := PackedFloat32Array(forces).to_byte_array()
	
	
	
	forces_buffer = rd.storage_buffer_create(datubuffer.size(),datubuffer);
	
	forces_uniform = _cr_uniform(forces_buffer,RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER,4)
	
	bindings = [boid_pos_uniform,boid_vel_uniform,params_uniform,boid_data_unniform,forces_uniform]
	
	

func _upddate_gpu(delta):
	rd.free_rid(params_buffer)
	var mpos  = get_global_mouse_position()
	var params_bytes = PackedFloat32Array(
		[points_count,
		cels_type,
		size,
		field_size,
		field_size,
		delta*speed,
		drag,
		force,
		rep_force,
		force_dist,
		rep_force_dist]).to_byte_array()
	
	
	params_buffer = rd.storage_buffer_create(params_bytes.size(),params_bytes) 
	
	
	params_uniform.clear_ids()
	params_uniform.add_id(params_buffer)
	uniform_set = rd.uniform_set_create(bindings,compute_shader,0)
	
	
	var computelist := rd.compute_list_begin()
	
	rd.compute_list_bind_compute_pipeline(computelist,pipeline)
	rd.compute_list_bind_uniform_set(computelist,uniform_set,0)
	
	rd.compute_list_dispatch(computelist,ceil(points_count/1024.),1,1)
	rd.compute_list_end()
	rd.submit()
	
func _get_from_gpu():
	rd.sync()
func _exit_tree() -> void:
		_get_from_gpu()
		rd.free_rid(uniform_set)
		rd.free_rid(particle_data_bufer)
		rd.free_rid(pos_buffer)
		rd.free_rid(vel_buffer)
		rd.free_rid(params_buffer)
		rd.free_rid(pipeline)
		rd.free_rid(compute_shader)
		rd.free()
		
func update_texture() -> void:
	var boids_image_data = rd.texture_get_data(particle_data_bufer,0)
	pticle_image.set_data(size,size,false,Image.FORMAT_RGBAH,boids_image_data)
	pticle_texture.update(pticle_image)

func update_forces():
	rd.free_rid(forces_buffer)
	
	var datubuffer := PackedFloat32Array(forces).to_byte_array()
	
	
	
	forces_buffer = rd.storage_buffer_create(datubuffer.size(),datubuffer);
	
	forces_uniform.clear_ids()
	forces_uniform.add_id(forces_buffer)
	uniform_set = rd.uniform_set_create(bindings,compute_shader,0)
