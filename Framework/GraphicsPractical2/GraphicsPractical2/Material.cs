using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Microsoft.Xna.Framework;
using Microsoft.Xna.Framework.Graphics;

namespace GraphicsPractical2
{
    public struct Material
    {
        // Color of the ambient light
        public Color AmbientColor;
        // Intensity of the ambient light
        public float AmbientIntensity;

        // Light source with direction
        public Vector3 LightPosition;
        // The color of the surface (can be ignored if texture is used, or not if you want to blend)
        public Color DiffuseColor;
        // The intensity of the diffuse reflection
        public float DiffuseIntensity;

        // Color of the specular highlight (mostly equal to the color of the light source)
        public Color SpecularColor;
        // The intensity factor of the specular highlight, controls it's size
        public float SpecularIntensity;
        // The power term of the specular highlight, controls it's smoothness
        public float SpecularPower;

        // Special surface color, use normals as color
        public bool NormalColoring;
        // Special surface color, procedural colors
        public bool ProceduralColoring;


        // Flushes all variables to the given effect.
        public void SetEffectParameters(Effect effect)
        {
            effect.Parameters["AmbientColor"].SetValue(this.AmbientColor.ToVector4());
            effect.Parameters["AmbientIntensity"].SetValue(this.AmbientIntensity);

            effect.Parameters["LightPosition"].SetValue(this.LightPosition);
            effect.Parameters["DiffuseColor"].SetValue(this.DiffuseColor.ToVector4());
            effect.Parameters["DiffuseIntensity"].SetValue(this.DiffuseIntensity);

            effect.Parameters["SpecularColor"].SetValue(this.SpecularColor.ToVector4());
            effect.Parameters["SpecularIntensity"].SetValue(this.SpecularIntensity);
            effect.Parameters["SpecularPower"].SetValue(this.SpecularPower);

            effect.Parameters["NormalColoring"].SetValue(this.NormalColoring);
            effect.Parameters["ProceduralColoring"].SetValue(this.ProceduralColoring);
        }
    }
}