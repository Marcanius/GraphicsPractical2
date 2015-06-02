using System;
using System.Collections.Generic;
using System.Linq;
using Microsoft.Xna.Framework;
using Microsoft.Xna.Framework.Audio;
using Microsoft.Xna.Framework.Content;
using Microsoft.Xna.Framework.GamerServices;
using Microsoft.Xna.Framework.Graphics;
using Microsoft.Xna.Framework.Input;
using Microsoft.Xna.Framework.Media;

namespace GraphicsPractical2
{
    public class Game1 : Microsoft.Xna.Framework.Game
    {
        // Often used XNA objects
        private GraphicsDeviceManager graphics;
        private SpriteBatch spriteBatch;
        private FrameRateCounter frameRateCounter;

        // Game objects and variables
        private Camera camera;

        // Model
        private Model model;
        private Material modelMaterial;

        // Quad
        private Effect QuadEffect;
        private VertexPositionNormalTexture[] quadVertices;
        private short[] quadIndices;
        private Matrix quadTransform;
        private Texture2D cobblestone;

        // Post-Processing
        Effect postProcessing;
        RenderTarget2D postRenderTarget;

        public Game1()
        {
            this.graphics = new GraphicsDeviceManager(this);
            this.Content.RootDirectory = "Content";
            // Create and add a frame rate counter
            this.frameRateCounter = new FrameRateCounter(this);
            this.Components.Add(this.frameRateCounter);
        }

        protected override void Initialize()
        {
            // Copy over the device's rasterizer state to change the current fillMode
            this.GraphicsDevice.RasterizerState = new RasterizerState() { CullMode = CullMode.None };
            // Set up the window
            this.graphics.PreferredBackBufferWidth = 800;
            this.graphics.PreferredBackBufferHeight = 600;
            this.graphics.IsFullScreen = false;
            // Let the renderer draw and update as often as possible
            this.graphics.SynchronizeWithVerticalRetrace = false;
            this.IsFixedTimeStep = false;
            // Flush the changes to the device parameters to the graphics card
            this.graphics.ApplyChanges();
            // Initialize the camera
            this.camera = new Camera(new Vector3(0, 50, 100), new Vector3(0, 0, 0), new Vector3(0, 1, 0));

            this.IsMouseVisible = true;

            // The rendertarget for the postprocessing.
            postRenderTarget = new RenderTarget2D(
                GraphicsDevice,
                GraphicsDevice.PresentationParameters.BackBufferWidth,
                GraphicsDevice.PresentationParameters.BackBufferHeight,
                false,
                GraphicsDevice.PresentationParameters.BackBufferFormat,
                DepthFormat.Depth24);

            base.Initialize();
        }

        protected override void LoadContent()
        {
            // Create a SpriteBatch object.
            this.spriteBatch = new SpriteBatch(this.GraphicsDevice);

            // Load the texture for the quad.
            cobblestone = Content.Load<Texture2D>("Textures/CobblestonesDiffuse");

            // Load the "Simple" effect.
            Effect effect = this.Content.Load<Effect>("Effects/Simple");

            // Filling modelMaterial.
            modelMaterial.NormalColoring = false;
            modelMaterial.ProceduralColoring = false;

            modelMaterial.DiffuseColor = Color.Red;
            modelMaterial.DiffuseIntensity = 1f;
            modelMaterial.LightPosition = new Vector3(50, 50, 50);
            modelMaterial.DiffuseTexture = cobblestone;

            modelMaterial.AmbientIntensity = 0.2f;
            modelMaterial.AmbientColor = Color.Red;

            modelMaterial.SpecularColor = Color.White;
            modelMaterial.SpecularIntensity = 2.0f;
            modelMaterial.SpecularPower = 25.0f;

            // Flushing the modelMaterial to the effect.
            modelMaterial.SetEffectParameters(effect);

            // Load the model and let it use the "Simple" effect.
            this.model = this.Content.Load<Model>("Models/Teapot");
            this.model.Meshes[0].MeshParts[0].Effect = effect;

            // Load the "Quad" Effect.
            QuadEffect = this.Content.Load<Effect>("Effects/QuadEffect");
            // Fill the Quad Effect Parameters.
            camera.SetEffectParameters(QuadEffect);
            QuadEffect.Parameters["World"].SetValue(Matrix.CreateScale(10f));
            QuadEffect.Parameters["DiffuseTexture"].SetValue(Content.Load<Texture2D>("Textures/CobblestonesDiffuse"));
            QuadEffect.Parameters["NormalMap"].SetValue(Content.Load<Texture2D>("Normal Maps/CobblestonesNormal"));
            QuadEffect.Parameters["HasNormalMap"].SetValue(true);

            // Load the PostProcesssing effect
            postProcessing = this.Content.Load<Effect>("Effects/PostProcessing");
            postProcessing.Parameters["gamma"].SetValue(1.0f);

            // Setup the quad
            this.setupQuad();

        }

        /// <summary>
        /// Sets up a 2 by 2 quad around the origin.
        /// </summary>
        private void setupQuad()
        {
            float scale = 50.0f;

            // Normal points up
            Vector3 quadNormal = new Vector3(0, 1, 0);

            this.quadVertices = new VertexPositionNormalTexture[4];
            // Top left
            this.quadVertices[0].Position = new Vector3(-10, -1.6f, -10);
            this.quadVertices[0].Normal = quadNormal;
            this.quadVertices[0].TextureCoordinate = new Vector2(0, 0);
            // Top right
            this.quadVertices[1].Position = new Vector3(10, -1.6f, -10);
            this.quadVertices[1].Normal = quadNormal;
            this.quadVertices[1].TextureCoordinate = new Vector2(3, 0);
            // Bottom left
            this.quadVertices[2].Position = new Vector3(-10, -1.6f, 10);
            this.quadVertices[2].Normal = quadNormal;
            this.quadVertices[2].TextureCoordinate = new Vector2(0, 3);
            // Bottom right
            this.quadVertices[3].Position = new Vector3(10, -1.6f, 10);
            this.quadVertices[3].Normal = quadNormal;
            this.quadVertices[3].TextureCoordinate = new Vector2(3, 3);

            this.quadIndices = new short[] { 0, 1, 2, 1, 2, 3 };
            this.quadTransform = Matrix.CreateScale(scale);
        }

        protected override void Update(GameTime gameTime)
        {
            float timeStep = (float)gameTime.ElapsedGameTime.TotalSeconds * 60.0f;

            // Update the window title
            this.Window.Title = "XNA Renderer | FPS: " + this.frameRateCounter.FrameRate;

            base.Update(gameTime);
        }

        protected override void Draw(GameTime gameTime)
        {
            // Clear the screen in a predetermined color and clear the depth buffer
            this.GraphicsDevice.Clear(ClearOptions.Target | ClearOptions.DepthBuffer, Color.DeepSkyBlue, 1.0f, 0);

            // Get the model's only mesh
            ModelMesh mesh = this.model.Meshes[0];
            Effect effect = mesh.Effects[0];
            Matrix World = Matrix.CreateScale(10.0f);

            // Set the effect parameters
            effect.CurrentTechnique = effect.Techniques["Simple"];
            // Matrices for 3D perspective projection
            this.camera.SetEffectParameters(effect);
            effect.Parameters["World"].SetValue(World);
            effect.Parameters["WorldIT"].SetValue(Matrix.Transpose(Matrix.Invert(World)));

            // Create the texture for post-processing.
            DrawToTexture(postRenderTarget, this.model, World);

            // Clear the screen
            GraphicsDevice.Clear(Color.Black);
            // Draw the texture with the post-processing.
            spriteBatch.Begin(SpriteSortMode.Immediate, BlendState.Opaque,
                SamplerState.LinearClamp, DepthStencilState.Default,
                RasterizerState.CullNone, postProcessing);
            spriteBatch.Draw(postRenderTarget, new Rectangle(0, 0, 800, 600), Color.White);
            spriteBatch.End();

            base.Draw(gameTime);
        }

        protected void DrawToTexture(RenderTarget2D renderTarget, Model model, Matrix world)
        {
            // Prepare everything we want to draw
            ModelMesh mesh = model.Meshes[0];
            Effect meshEffect = mesh.Effects[0];
            model.Meshes[0].MeshParts[0].Effect = QuadEffect;

            // Set the render target.
            GraphicsDevice.SetRenderTarget(renderTarget);

            GraphicsDevice.DepthStencilState = new DepthStencilState() { DepthBufferEnable = true  };

            // Draw the scene
            GraphicsDevice.Clear(ClearOptions.Target | ClearOptions.DepthBuffer, Color.DeepSkyBlue, 1.0f, 0);

            // The Quad
            QuadEffect.CurrentTechnique = QuadEffect.Techniques["Technique1"];

            foreach (EffectPass pass in QuadEffect.CurrentTechnique.Passes)
                pass.Apply();

            this.GraphicsDevice.DrawUserIndexedPrimitives(PrimitiveType.TriangleList, quadVertices, 
                0, quadVertices.Length, quadIndices, 0, this.quadIndices.Length / 3);

            model.Meshes[0].MeshParts[0].Effect = meshEffect;
            // The Model
            meshEffect.Parameters["HasTexture"].SetValue(false);
            mesh.Draw();

            // Drop the render target
            GraphicsDevice.SetRenderTarget(null);
        }
    }
}
