//------------------------------------------- Defines -------------------------------------------

#define Pi 3.14159265

//------------------------------------- Top Level Variables -------------------------------------

// Top level variables can and have to be set at runtime

// Matrices for 3D perspective projection 
float4x4 View, Projection, World;
float4 DiffuseColor, AmbientColor, SpecularColor;
float3 LightPosition, CameraPosition;
float DiffuseIntensity, AmbientIntensity, SpecularIntensity, SpecularPower;
bool NormalColoring, ProceduralColoring;

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
	float2 ProceduralCoord : TEXCOORD0;
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
	int x2 = (x) % 2;
	int y2 = (y) % 2;

	if (x2 != y2)
		return float4(
		input.Color.r,
		input.Color.g,
		input.Color.b,
		1);
	else
		return float4(
		1 - input.Color.r,
		1 - input.Color.g,
		1 - input.Color.b,
		1);
}

float3 TransformNormal(VertexShaderInput Input, float4x4 World)
{
	float3x3 rotationAndScale = (float3x3)World;
	float3 normalT = mul(Input.Normal, rotationAndScale);
	return normalize(normalT);
}

float4 AmbientLighting()
{
	return AmbientColor * AmbientIntensity;
}

float4 DiffuseLighting(float3 LightPosition, float3 Normal)
{
	// The angle between the light source and the normal vector of the vertex.
	float LdotNN = dot(normalize(LightPosition), Normal);

	return DiffuseColor * DiffuseIntensity * max(0.0, LdotNN);
}

float4 SpecularLighting(float3 LightPosition, float3 CameraPosition, float3 VertexPosition, float3 Normal)
{
	// Calculate the vector to the light source, and normalize it.
	float3 lVector = normalize(LightPosition - VertexPosition);
		// Calculate the vector to the camera, and normalize it.
		float3 vVector = normalize(CameraPosition - VertexPosition);
		// Calculate the half vector, halfway between the light source and the camera.
		float3 hVector = normalize(lVector + vVector);

		// Angle between the half-Vector and the normal
		float HdotN = max(0.0f, dot(hVector, Normal));

	return SpecularColor * SpecularIntensity * pow(HdotN, SpecularPower);
}

//---------------------------------------- Technique: Simple ----------------------------------------

VertexShaderOutput SimpleVertexShader(VertexShaderInput input)
{
	// Allocate an empty output struct.
	VertexShaderOutput output = (VertexShaderOutput)0;

	// Do the matrix multiplications for perspective projection and the world transform.
	float4 worldPosition = mul(input.Position3D, World);
		float4 viewPosition = mul(worldPosition, View);
		output.Position2D = mul(viewPosition, Projection);

	// Matrixing the normal Vector.
	float3 transformNormalN = TransformNormal(input, World);

		// Outputting the color.
		output.Color =
		AmbientLighting()
		+ DiffuseLighting(LightPosition, transformNormalN)
		+ SpecularLighting(LightPosition, CameraPosition, input.Position3D, transformNormalN);

	output.ProceduralCoord = input.Position3D.xy * 7;

	return output;
}

float4 SimplePixelShader(VertexShaderOutput input) : COLOR0
{
	if (NormalColoring)
	return NormalColor(input);
	else if (ProceduralColoring)
		return ProceduralColor(input, input.ProceduralCoord.x * 7, input.ProceduralCoord.y * 7);
	else
		return (float4)0;
}

technique Simple
{
	pass Pass0
	{
		VertexShader = compile vs_2_0 SimpleVertexShader();
		PixelShader = compile ps_2_0 SimplePixelShader();
	}
}