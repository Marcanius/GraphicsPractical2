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
        private Effect modelEffect;
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

            // Initialize the camera, located at (0,50,100), and looking at the origin.
            this.camera = new Camera(new Vector3(0, 50, 100), new Vector3(0, 0, 0), new Vector3(0, 1, 0));

            // Make the cursor visible on screen.
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

            // Load the "Simple" effect.
            modelEffect = this.Content.Load<Effect>("Effects/Simple");

            // Filling modelMaterial's parameters.
            modelMaterial.NormalColoring = false;
            modelMaterial.ProceduralColoring = false;

            modelMaterial.DiffuseColor = Color.Red;
            modelMaterial.DiffuseIntensity = 1f;
            modelMaterial.LightPosition = new Vector3(50, 50, 50);

            modelMaterial.AmbientIntensity = 0.2f;
            modelMaterial.AmbientColor = Color.Red;

            modelMaterial.SpecularColor = Color.White;
            modelMaterial.SpecularIntensity = 2.0f;
            modelMaterial.SpecularPower = 25.0f;

            // Flushing the modelMaterial to the effect.
            modelMaterial.SetEffectParameters(modelEffect);

            // Load the model and let it use the "Simple" effect.
            this.model = this.Content.Load<Model>("Models/Teapot");
            this.model.Meshes[0].MeshParts[0].Effect = modelEffect;

            // Setup the quad
            this.setupQuad();

            // Load the "Quad" Effect.
            QuadEffect = this.Content.Load<Effect>("Effects/QuadEffect");
            // Load the texture for the quad.
            cobblestone = Content.Load<Texture2D>("Textures/CobblestonesDiffuse");

            // Fill the Quad Effect Parameters.
            camera.SetEffectParameters(QuadEffect);
            QuadEffect.Parameters["World"].SetValue(this.quadTransform);
            QuadEffect.Parameters["DiffuseTexture"].SetValue(Content.Load<Texture2D>("Textures/CobblestonesDiffuse"));
            QuadEffect.Parameters["NormalMap"].SetValue(Content.Load<Texture2D>("Normal Maps/CobblestonesNormal"));
            QuadEffect.Parameters["HasNormalMap"].SetValue(true);

            // Load the PostProcesssing effect, and fill its parameter.
            postProcessing = this.Content.Load<Effect>("Effects/PostProcessing");
            postProcessing.Parameters["gamma"].SetValue(1.0f);
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
            this.quadVertices[0].Position = new Vector3(-1, 0, -1);
            this.quadVertices[0].Normal = quadNormal;
            this.quadVertices[0].TextureCoordinate = new Vector2(0, 0);
            // Top right
            this.quadVertices[1].Position = new Vector3(1, 0, -1);
            this.quadVertices[1].Normal = quadNormal;
            this.quadVertices[1].TextureCoordinate = new Vector2(3, 0);
            // Bottom left
            this.quadVertices[2].Position = new Vector3(-1, 0, 1);
            this.quadVertices[2].Normal = quadNormal;
            this.quadVertices[2].TextureCoordinate = new Vector2(0, 3);
            // Bottom right
            this.quadVertices[3].Position = new Vector3(1, 0, 1);
            this.quadVertices[3].Normal = quadNormal;
            this.quadVertices[3].TextureCoordinate = new Vector2(3, 3);

            this.quadIndices = new short[] { 0, 1, 2, 1, 2, 3 };
            this.quadTransform = Matrix.CreateScale(scale);
        }

        protected override void Update(GameTime gameTime)
        {
            float timeStep = (float)gameTime.ElapsedGameTime.TotalSeconds * 60.0f;

            // Let the camera rotate around the teapot.
            camera.Eye = new Vector3(
                                    (float)(-Math.Cos(((float)gameTime.TotalGameTime.TotalMilliseconds / 8000) * 2 * Math.PI) * 100),
                                    50,
                                    (float)(Math.Sin(((float)gameTime.TotalGameTime.TotalMilliseconds / 8000) * 2 * Math.PI) * 100)
                                    );

            // Let the lightSource rotate around the teapot.
            modelEffect.Parameters["LightPosition"].SetValue(new Vector3(
                                    (float)(Math.Cos(((float)gameTime.TotalGameTime.TotalMilliseconds / 8000) * 2 * Math.PI) * 50),
                                    50,
                                    (float)(Math.Sin(((float)gameTime.TotalGameTime.TotalMilliseconds / 8000) * 2 * Math.PI) * 50))
                                    );

            // Update the window title
            this.Window.Title = "XNA Renderer | FPS: " + this.frameRateCounter.FrameRate;

            base.Update(gameTime);
        }

        protected override void Draw(GameTime gameTime)
        {
            // Get the model's only mesh
            ModelMesh mesh = this.model.Meshes[0];
            Effect effect = mesh.Effects[0];

            // Creating the world Matrix for the effect.
            Matrix World = Matrix.CreateScale(10.0f) * Matrix.CreateTranslation(0.0f, 15f, 0.0f);

            // Set the effect parameters
            effect.CurrentTechnique = effect.Techniques["Simple"];
            // Matrices for 3D perspective projection; View, Projection and World.
            this.camera.SetEffectParameters(effect);
            effect.Parameters["World"].SetValue(World);
            effect.Parameters["WorldIT"].SetValue(Matrix.Transpose(Matrix.Invert(World)));

            // Create the texture for post-processing.
            DrawToTexture(postRenderTarget, this.model, World);

            // Clear the screen
            GraphicsDevice.Clear(Color.Black);
            // Draw the texture with the post-processing effect applied.
            spriteBatch.Begin(SpriteSortMode.Immediate, BlendState.Opaque,
                SamplerState.LinearClamp, DepthStencilState.Default,
                RasterizerState.CullNone, postProcessing);
            spriteBatch.Draw(postRenderTarget, new Rectangle(0, 0, 800, 600), Color.White);
            spriteBatch.End();

            base.Draw(gameTime);
        }

        protected void DrawToTexture(RenderTarget2D renderTarget, Model model, Matrix world)
        {
            // Set the effect to the QuadEffect.
            ModelMesh mesh = model.Meshes[0];
            Effect meshEffect = mesh.Effects[0];
            model.Meshes[0].MeshParts[0].Effect = QuadEffect;

            // Set the render target.
            GraphicsDevice.SetRenderTarget(renderTarget);

            // Make sure we cannot see through the teapot, it would ruin the immersion created by the amazing graphics.
            GraphicsDevice.DepthStencilState = new DepthStencilState() { DepthBufferEnable = true };

            // Draw the scene
            GraphicsDevice.Clear(ClearOptions.Target | ClearOptions.DepthBuffer, Color.DeepSkyBlue, 1.0f, 0);

            // Prepare The Quad
            QuadEffect.CurrentTechnique = QuadEffect.Techniques["Technique1"];
            camera.SetEffectParameters(QuadEffect);
            foreach (EffectPass pass in QuadEffect.CurrentTechnique.Passes)
                pass.Apply();
            // Draw the Quad.
            this.GraphicsDevice.DrawUserIndexedPrimitives(PrimitiveType.TriangleList, quadVertices,
                0, quadVertices.Length, quadIndices, 0, this.quadIndices.Length / 3);

            // Prepare the Model.
            model.Meshes[0].MeshParts[0].Effect = meshEffect;
            // Draw the model.
            mesh.Draw();

            // Drop the render target
            GraphicsDevice.SetRenderTarget(null);
        }
    }
}
