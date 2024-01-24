shader_type canvas_item;

uniform vec4 bottomColor : source_color = vec4(0.15, 0, 0.4, 1.0);
uniform vec4 topColor : source_color = vec4(0.37, 0.0, 1., 1.);

uniform float direction = -50.;
uniform float speed = 10.0;
uniform float width = 0.01;
uniform float height = -0.2;
uniform float opacity = 0.5;

float Remap(float In, vec2 InMinMax, vec2 OutMinMax)
{
    return OutMinMax.x + (In - InMinMax.x) * (OutMinMax.y - OutMinMax.x) / (InMinMax.y - InMinMax.x);
}

void fragment() {
	//ScrollUV over time
	vec2 uv = TEXTURE_PIXEL_SIZE * vec2((UV * direction).x, TIME * speed + (UV * direction).y);
	
	//Calculate triangle wave shape based on pixel-space UVs
	float wave = Remap(sin(uv.x / width), vec2(-1, 1), vec2(0,1)) * width;
	float outWave = Remap(mod(wave + uv.y, height), vec2(0, height), vec2(0,1));
	
	//Apply color
	COLOR = texture(TEXTURE, UV) + mix(bottomColor, topColor, outWave) * opacity * COLOR.a;
}