Team Members:
	Timo Bleeker - 5527864
	Quinten Leidekker - 4245547
	Matthijs Platenburg - 4260953

Division of labor:
	We met regularly on skype to work together on the practical.
	One of us would do the typing, and the other would notify him of typos. *insert laughter*
	But seriously, we switched out the person who typed every meeting.
	So everybody shared in the labor.
	One of our member went on holiday to Colombia in the retake week, but he compensated for this by working harder in the beginning.

Cool Code Comments:
	We chose to implement each shading technique in a separate method within the simple.fx file.
	Our reason for this choice is readability of the code and the ability to easily toggle whether or not we use each shading method.
	We added an extra effect file named QuadEffect, because we hit the limit of 64 instruction slots with the 2.0 shader.

	Lambertian Shading: 
		We chose to use a Point Light located at (50, 50, 50). 
		We implemented this in a separate method in the simple.fx file, named DiffuseShading().

	Blinn-Phong Shading:
		We chose to use the Blinn optimization of Phong shading.
		The shading is implemented in a separate method in the simple.fx file, named SpecularShading().
		
	The Quad:
		The Quad uses a separate effect file for sampling its texture, this file is named QuadEffect.fx.
		We thought our code would be better readable this way.
	
Bonus Assignments:
	
		We implemented gamma correction in a separate effect file named PostProcessing.fx
		
		- We changed the camera to rotate around the teapot and the Quad. 
			To stop it from rotating just comment out the line in update() starting with camera.Eye =..
		
		- We also changed the light source to rotate around the teapot and the Quad. 
			To stop it from rotating just comment out the line in update() starting with modelEffect.Parameters["..
	
	