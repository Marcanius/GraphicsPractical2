float4x4 World;
float4x4 View;
float4x4 Projection;

float gamma;

struct VertexShaderInput
{
	float4 Position : POSITION0;
};

struct VertexShaderOutput
{
	float4 Position : POSITION0;
	float4 Color : COLOR0;
};

float4 GammaCorrection(float4 input) : COLOR0
{
	// Red
	float red = 1 / pow(input.r, 1 / gamma);
	// Green
	float green = 1 / pow(input.g, 1 / gamma);
	// Blue
	float blue = 1 / pow(input.b, 1 / gamma);

	return ((red, green, blue, 1));
}

VertexShaderOutput VertexShaderFunction(VertexShaderInput input)
{
	VertexShaderOutput output;

	float4 worldPosition = mul(input.Position, World);
		float4 viewPosition = mul(worldPosition, View);
		output.Position = mul(viewPosition, Projection);

	output.Color = (float4)1;

	return output;
}

float4 PixelShaderFunction(VertexShaderOutput input) : COLOR0
{
	//	return GammaCorrection(input.Color);

	return float4(1, 0, 0, 1);
}

technique Technique1
{
	pass Pass1
	{
		VertexShader = compile vs_2_0 VertexShaderFunction();
		PixelShader = compile ps_2_0 PixelShaderFunction();
	}
}

