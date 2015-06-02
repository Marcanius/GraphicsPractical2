//------------------------------------------- Defines -------------------------------------------

#define Pi 3.14159265

//------------------------------------- Top Level Variables -------------------------------------

// Top level variables can and have to be set at runtime

// Matrices for 3D perspective projection 
float4x4 View, Projection, World, WorldIT;
float4 DiffuseColor, AmbientColor, SpecularColor;
float3 LightPosition, CameraPosition;
float DiffuseIntensity, AmbientIntensity, SpecularIntensity, SpecularPower;
bool NormalColoring, ProceduralColoring;

//---------------------------------- Input / Output structures ----------------------------------

// The input of the vertex shader.
struct VertexShaderInput
{
	float4 Position3D : POSITION0;
	float4 Normal : NORMAL0;
};

// The output of the vertex shader. 
// After being passed through the interpolator/rasterizer it is also the input of the pixel shader. 
struct VertexShaderOutput
{
	float4 Position2D : POSITION0;
	float4 Normal : TEXCOORD0;
	float3 Position3D : TEXCOORD1;
};

//------------------------------------------ Functions ------------------------------------------

// Coloring using the surface normals, in a checkerboard pattern.
float4 ProceduralColor(VertexShaderOutput input)
{
	// Getting the world space x and y of the vertex.
	float x = input.Position3D.x;
	float y = input.Position3D.y;

	// Creating a checkerboard by grouping mulitple x's and y's into the correct bit (0 or 1).
	int checkerX = (int)(abs(x) * 5) % 2;
	int checkerY = (int)(abs(y) * 5) % 2;

	// Topleft and LowerRight Quadrant.
	if (sign(x) != sign(y))
	{
		// "Black" checkers.
		if (checkerX != checkerY)
			return input.Normal;
		// "White" checkers.
		else
			return -input.Normal;
	}
	// TopRight and LowerLeft Quadrant.
	else
	{
		// "Black" checkers.
		if (checkerX == checkerY)
			return input.Normal;
		// "White" checkers.
		else
			return -input.Normal;
	}
}

// Lambert Shading
float DiffuseShading(float3 Position, float3 LightPosition, float3 Normal)
{
	// The angle between the light source and the normal vector of the vertex.
	float LdotNN = dot(normalize(LightPosition - Position), Normal);

	return DiffuseIntensity * max(0.0f, LdotNN);
}

// Blinn-Phong Shading
float SpecularShading(float3 Position, float3 LightPosition, float3 CameraPosition, float3 Normal)
{
	// Calculate the vector to the light source, and normalize it.
	float3 lVector = normalize(LightPosition - Position);

		// Calculate the vector to the camera, and normalize it.
		float3 vVector = normalize(CameraPosition - Position);

		// Calculate the half vector, halfway between the light source and the camera.
		float3 hVector = normalize(lVector + vVector);

		// Angle between the half-Vector and the normal
		float HdotN = max(0.000000001f, dot(hVector, Normal));

	return SpecularIntensity * pow(HdotN, SpecularPower);
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
	float3 transformNormalN = normalize(mul((float3)input.Normal, WorldIT));
		output.Normal.xyz = transformNormalN;

	// The normal used for assignments 1.1 and 1.2.
	output.Normal = input.Normal;


	// The world space coordinates of the vertex used for assignment 1.2, and calculating the different shadings.
	output.Position3D = input.Position3D.xyz;

	return output;
}

float4 SimplePixelShader(VertexShaderOutput input) : COLOR0
{
	// Color the teapot using..:
	// .. the normals of the vertices.
	if (NormalColoring)
	{
		return input.Normal;
	}

	// .. a checkerboard pattern and the normals of the vertices.
	else if (ProceduralColoring)
	{
		return ProceduralColor(input);
	}

	// .. a shaded version of red.
	else
	{
		return AmbientColor * AmbientIntensity
			+ DiffuseColor * DiffuseShading(input.Position3D, LightPosition, input.Normal)
			+ SpecularColor * SpecularShading(input.Position3D, LightPosition, CameraPosition, input.Normal);
	}
}

technique Simple
{
	pass Pass0
	{
		VertexShader = compile vs_2_0 SimpleVertexShader();
		PixelShader = compile ps_2_0 SimplePixelShader();
	}
}