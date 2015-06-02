float gamma;

// Texture deets
Texture2D screenGrab;

sampler TextureSampler = sampler_state
{
	Texture = < screenGrab > ;
};

 // -------------------------------------- The Pixel Shader -------------------------------------- \\

float4 PixelShaderFunction(float2 TexCoord : TEXCOORD0) : COLOR0
{
	// Sample each pixel from the completed screen render.
	float4 input = tex2D(TextureSampler, TexCoord);

	float4 output = input;

	// Correct the gamma of each color component.
	output.r = pow(input.r, 1 / gamma);
	output.g = pow(input.g, 1 / gamma);
	output.b = pow(input.b, 1 / gamma);

	// Return the processed color.
	return output;
}

technique Technique1
{
	pass Pass1
	{
		PixelShader = compile ps_2_0 PixelShaderFunction();
	}
}

