float4x4 World;
float4x4 View;
float4x4 Projection;

float gamma;

// Texture deets
Texture2D screenGrab;

sampler TextureSampler = sampler_state
{
	Texture = < screenGrab > ;
};

float4 GammaCorrection(float4 input) : COLOR0
{
	// Red
	float red = 1 / pow(input.r, 1 / gamma);
	// Green
	float green = 1 / pow(input.g, 1 / gamma);
	// Blue
	float blue = 1 / pow(input.b, 1 / gamma);

	// Test
	red = 0.5;
	green = 0.8;
	blue = 0.2;

	return (float4)(0, 0, 0, 1.0);
}

float4 PixelShaderFunction(float2 TexCoord : TEXCOORD0) : COLOR0
{
	float4 input = tex2D(TextureSampler, TexCoord);

	float4 output = input;
	output.r = pow(input.r, 1 / gamma);
	output.g = pow(input.g, 1 / gamma);
	output.b = pow(input.b, 1 / gamma);

	return output;
}

technique Technique1
{
	pass Pass1
	{
		PixelShader = compile ps_2_0 PixelShaderFunction();
	}
}

