float4x4 World;
float4x4 View;
float4x4 Projection;

// Variables.
bool HasNormalMap;
Texture2D DiffuseTexture, NormalMap;

SamplerState textureSample
{
	AddressU = Wrap;
	AddressV = Wrap;
};

// The input of the vertex shader.
struct VertexShaderInput
{
    float4 Position : POSITION0;
	float4 Normal : NORMAL0;
	float4 UVCoords : TEXCOORD0;
};

// The output of the vertex shader.
// After being passed through the interpolator/rasterizer it is also the input of the pixel shader.
struct VertexShaderOutput
{
    float4 Position2D : POSITION0;
	float4 Normal : TEXCOORD0;
	float3 Position3D : TEXCOORD1;
	float2 UVCoords : TEXCOORD2;
};

//------------------------------------------ Fuctions --------------------------------------

float4 SampleNormalMap(VertexShaderOutput input)
{
	return NormalMap.Sample(textureSample, input.UVCoords);
}


//---------------------------------------- Technique: Simple ----------------------------------------

VertexShaderOutput SimpleVertexShader(VertexShaderInput input)
{
	// Create an empty output struct
    VertexShaderOutput output = (VertexShaderOutput)0;

	// Do matrix manipulations for the perspective projection and the world transform.
    float4 worldPosition = mul(input.Position, World);
    float4 viewPosition = mul(worldPosition, View);

    output.Position2D = mul(viewPosition, Projection);

	output.Normal = input.Normal;
	output.Position3D = input.Position.xyz;
	output.UVCoords = input.UVCoords;

    return output;
}

float4 SimplePixelShader(VertexShaderOutput input) : COLOR0
{
	// Sample the cobblestone texture.
	float4 textureColor = DiffuseTexture.Sample(textureSample, input.UVCoords);

	// Apply normalmapping
	if (HasNormalMap)
	{
		// Create an adjusted normal from the normal map

		// Create Diffused shading using the adjusted normal.

		// Create Specular shading using the adjusted normal.

		// Return the textureColor, shaded.
	}

	return textureColor;
}

technique Technique1
{
    pass Pass1
    {
        VertexShader = compile vs_2_0 SimpleVertexShader();
        PixelShader = compile ps_2_0 SimplePixelShader();
    }
}
