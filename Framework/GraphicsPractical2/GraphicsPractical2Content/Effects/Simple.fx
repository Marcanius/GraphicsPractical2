//------------------------------------------- Defines -------------------------------------------

#define Pi 3.14159265

//------------------------------------- Top Level Variables -------------------------------------

// Top level variables can and have to be set at runtime

// Matrices for 3D perspective projection 
float4x4 View, Projection, World, WorldIT;
float4 DiffuseColor, AmbientColor, SpecularColor;
float3 LightPosition, CameraPosition;
float DiffuseIntensity, AmbientIntensity, SpecularIntensity, SpecularPower;
bool HasTexture, NormalColoring, ProceduralColoring, HasNormalMap;
Texture2D DiffuseTexture, NormalMap;
SamplerState textureSample
{
	AddressU = Wrap;
	AddressV = Wrap;
};

//---------------------------------- Input / Output structures ----------------------------------

// The input of the vertex shader.
struct VertexShaderInput
{
	float4 Position3D : POSITION0;
	float4 Normal : NORMAL0;
	float2 UVcoord : TEXCOORD0;
};

// The output of the vertex shader. 
// After being passed through the interpolator/rasterizer it is also the input of the pixel shader. 
struct VertexShaderOutput
{
	float4 Position2D : POSITION0;
	float4 Normal : TEXCOORD0;
	float2 ProceduralCoord : TEXCOORD1;
	float2 UVcoord : TEXCOORD2;
	float4 AmbientColor : TEXCOORD3;
	float4 DiffuseColor : TEXCOORD4;
	float4 SpecularColor : TEXCOORD5;
};

//------------------------------------------ Functions ------------------------------------------

// Coloring using the surface normals.
float4 NormalColor(VertexShaderOutput input)
{
	return input.Normal;
}

// Coloring using the surface normals, in a checkerboard pattern.
float4 ProceduralColor(VertexShaderOutput input)
{
	// Getting the world space x and y of the vertex
	float x = input.ProceduralCoord.x;
	float y = input.ProceduralCoord.y;

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

// Ambient Shading
float4 AmbientLighting()
{
	return AmbientColor * AmbientIntensity;
}

// Lambert Shading
float4 DiffuseLighting(float3 LightPosition, float3 VertexPosition, float3 Normal)
{
	// The angle between the light source and the normal vector of the vertex.
	float LdotNN = dot(normalize(LightPosition - VertexPosition), Normal);

	return DiffuseColor * DiffuseIntensity * max(0.0f, LdotNN);
}

// Blinn-Phong Shading
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

float4 NormalMapping(VertexShaderOutput input)
{
	float4 surfaceNormal = input.Normal;

		// Get the vectors from the normal map
		float4 mapNormal = normalize(NormalMap.Sample(textureSample, input.UVcoord));
		// transform the vector from the normal map, so they align corectly with the surface normals
		float4 mapNormalT = normalize(mapNormal - (0, 0, 1, 0));
		// Add the mapNormal and surfaceNormal
		float4 result = mapNormalT + surfaceNormal;
		// Normalize the resultNormal;
		result = normalize(result);

	return result;
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

		// The normal used for assignments 1.1 and 1.2.
		output.Normal = input.Normal;
	// The procedural coordinates used for assignment 1.2.
	output.ProceduralCoord = input.Position3D.xy;
	// The UV coordinates used for texture sampling in assignments 3 and 4.2.
	output.UVcoord = input.UVcoord;
	// The shaded color used in assignments 2.1 and beyond.
	output.AmbientColor = AmbientLighting();
	output.DiffuseColor = DiffuseLighting(LightPosition, input.Position3D, transformNormalN);
	output.SpecularColor = SpecularLighting(LightPosition, CameraPosition, input.Position3D, transformNormalN);

	return output;
}

float4 SimplePixelShader(VertexShaderOutput input) : COLOR0
{
	// Drawing the Quad
	if (HasTexture)
	{
		// Sample the cobblestone texture
		float4 textureColor = DiffuseTexture.Sample(textureSample, input.UVcoord);

			if (!HasNormalMap)
			{
				return textureColor;
			}
			else
			{
				return NormalMapping(input);
			}
	}
	// Not drawing the quad, color the teapot using..:
	// .. the normals of the vertices.
	else if (NormalColoring)
	{
		return NormalColor(input);
	}

	// .. a checkerboard pattern and the normals of the vertices.
	else if (ProceduralColoring)
	{
		return ProceduralColor(input);
	}
	// .. a shaded version of red.
	else
	{
		return input.AmbientColor + input.DiffuseColor + input.SpecularColor;
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