shader_type particles;

uniform sampler2D data;

uniform int count;

void start() {
	// Called when a particle is spawned.
}

void process() {
	ivec2 size = textureSize(data,0);
	ivec2 tpos = ivec2(int(mod(float(INDEX),float(size.x))),
				int(float(INDEX)/float(size.x)));
	vec4 pos = texelFetch(data,tpos,0);

	TRANSFORM[0].xy = vec2(0.1,0);
	TRANSFORM[1].xy = vec2(0,0.1);

	TRANSFORM[3].xy = vec2(pos.r,pos.g);

	uint index = INDEX%uint(count);
	if(index == uint(1)){
		COLOR = vec4(1,0,0,1);


	}else if(index == uint(2)){
		COLOR = vec4(1,1,0,1);
	}else if(index == uint(3)){
		COLOR = vec4(1,1,1,1);
	}else if(index == uint(4)){
		COLOR = vec4(0,1,1,1);
	}else if(index == uint(5)){
		COLOR = vec4(1,0,1,1);
	}else if(index == uint(6)){
		COLOR = vec4(0,1,0,1);
	}
	else{
		COLOR = vec4(0,0,1,1);
	}



}
