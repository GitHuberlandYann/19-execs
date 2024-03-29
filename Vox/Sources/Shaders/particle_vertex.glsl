#version 150 core

/* specifications is packed
 * 0xFF = x coord in texture atlas
 * 0xFF00 = y coord in texture atlas
 * 0x1 << 16
 * 0x1 << 17 x texture half-pixel correction
 * 0x1 << 18 y texture half-pixel correction
 * 0x7 << 19 Atlas index
 * 0x3 << 22
 * 0xF000000 block light
 * 0xF0000000 sky light
*/
in int specifications;
in vec3 position;

uniform mat4 view;
uniform mat4 proj;
uniform int internal_light;

out vec2 Texcoord;
out float FaceShadow;
flat out int Atlas;

void main()
{
	gl_Position = proj * view * vec4(position, 1.0);
	float x_half = (((specifications & (1 << 17)) == 0) ? 0.0001220703125 : -0.0001220703125);
	float y_half = (((specifications & (1 << 18)) == 0) ? 0.0001220703125 : -0.0001220703125);
	Texcoord = vec2((specifications & 0xFF) / 256.0f + x_half, ((specifications >> 8) & 0xFF) / 256.0f + y_half);
	int blockLight = ((specifications >> 24) & 0xF);
	int skyLight = internal_light - (15 - ((specifications >> 28) & 0xF));
	int shadow = 15 - max(blockLight, skyLight);
	FaceShadow = max(0, (100 - 7 * shadow) * 0.01f);
	Atlas = ((specifications >> 19) & 0x7);
}
