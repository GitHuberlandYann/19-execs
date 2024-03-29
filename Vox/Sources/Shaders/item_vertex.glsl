#version 150 core

/* specifications is packed
 * 0xF = x coord in texture atlas
 * 0xF0 = y coord in texture atlas
 // * 0x200 = xoffset in texture atlas
 // * 0x400 = yoffset in texture atlas
 * 0x7 << 19 faceLight [0=100, 1=92, 2=88, 3=84, 4=80, 5=76]
 * 0xF000000 block light
 * 0xF0000000 sky light
*/
in int specifications;
in ivec2 position;

uniform int internal_light;
uniform int window_width;
uniform int window_height;

out vec2 Texcoord;
out float FaceShadow;

void main()
{
	gl_Position = vec4((2.0 * position.x) / window_width - 1.0, -((2.0 * position.y) / window_height - 1.0), 0.0, 1.0);
	Texcoord = vec2((specifications & 0xF) / 16.0f, ((specifications >> 4) & 0xF) / 16.0f);
	int blockLight = ((specifications >> 24) & 0xF);
	int skyLight = internal_light - (15 - ((specifications >> 28) & 0xF));
	int shadow = 15 - max(blockLight, skyLight);
	int faceLight = 100;
	if (((specifications >> 19) & 0x7) > 0) {
		faceLight -= 8 + (((specifications >> 19) & 0x7) << 2);
	}
	FaceShadow = max(0.05, max(10, faceLight - 7 * shadow) / 100.0f);
}
