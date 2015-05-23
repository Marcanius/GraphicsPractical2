//------------------------------------------- Defines -------------------------------------------

#define Pi 3.14159265

//------------------------------------- Top Level Variables -------------------------------------

// Top level variables can and have to be set at runtime

// Matrices for 3D perspective projection 
float4x4 View, Projection, World;
float4 DiffuseColor, AmbientColor;
float3 LightPosition;
float DiffuseIntensity, AmbientIntensity;

//---------------------------------- Input / Output structures ----------------------------------

// Each member of the struct has to be given a "semantic", to indicate what kind of data should go in
// here and how it should be treated. Read more about the POSITION0 and the many other semantics in 
// the MSDN library
struct VertexShaderInput
{
	float4 Position3D : POSITION0;
	float4 Normal : NORMAL0;
};

// The output of the vertex shader. After being passed through the interpolator/rasterizer it is also 
// the input of the pixel shader. 
// Note 1: The values that you pass into this struct in the vertex shader are not the same as what 
// you get as input for the pixel shader. A vertex shader has a single vertex as input, the pixel 
// shader has 3 vertices as input, and lets you determine the color of each pixel in the triangle 
// defined by these three vertices. Therefor, all the values in the struct that you get as input for 
// the pixel shaders have been linearly interpolated between there three vertices!
// Note 2: You cannot use the data with the POSITION0 semantic in the pixel shader.
struct VertexShaderOutput
{
	float4 Position2D : POSITION0;
	float4 Color : COLOR0;
	float2 Texcoord : TEXCOORD0;
};

//------------------------------------------ Functions ------------------------------------------

// Implement the Coloring using normals assignment here
float4 NormalColor(VertexShaderOutput input)
{
	return input.Color;
}

// Implement the Procedural texturing assignment here
float4 ProceduralColor(VertexShaderOutput input, int x, int y)
{
	float bit = ((cos(x % 2) + sin(y % 2)) * (cos(x % 2) + cos(y % 2))) % 2;
	return float4(((bit - 0.5) * 2) * input.Color.r,
		((bit - 0.5) * 2) * input.Color.g,
		((bit - 0.5) * 2) * input.Color.b,
		1);
}

//---------------------------------------- Technique: Simple ----------------------------------------

VertexShaderOutput SimpleVertexShader(VertexShaderInput input)
{
	// Allocate an empty output struct
	VertexShaderOutput output = (VertexShaderOutput)0;

	// Do the matrix multiplications for perspective projection and the world transform
	float4 worldPosition = mul(input.Position3D, World);
		float4 viewPosition = mul(worldPosition, View);
		output.Position2D = mul(viewPosition, Projection);

	float3x3 rotationAndScale = (float3x3)World;
		float3 transformNormal = mul(input.Normal, rotationAndScale);
		float3 transformNormalN = normalize(transformNormal);
		float lightNormalDot = dot(normalize(LightPosition), transformNormalN);

	float4 lambertShading = DiffuseColor * DiffuseIntensity * max(0.0, lightNormalDot);
		float4 ambientLight = AmbientColor * AmbientIntensity;

		output.Color = lambertShading + ambientLight;
	output.Texcoord = input.Position3D.xy * 7;

	return output;
}

float4 SimplePixelShader(VertexShaderOutput input) : COLOR0
{
	return NormalColor(input);
	//return ProceduralColor(input, input.Texcoord.x, input.Texcoord.y);
}

technique Simple
{
	pass Pass0
	{
		VertexShader = compile vs_2_0 SimpleVertexShader();
		PixelShader = compile ps_2_0 SimplePixelShader();
	}
}