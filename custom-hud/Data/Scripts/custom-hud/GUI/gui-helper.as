const float F_PI = atan(1.0f) * 4.0f;
const float F_DEG_TO_RAD = F_PI / 180.0f;
const float F_RAD_TO_DEG = 180.0f / F_PI;

// We don't need to calculate the projection matrix over and over again if nothing in it has changed.
// That means the aspectRatio and the FOV stayed the same.
float aspectRatio = float(GetScreenWidth()) / float(GetScreenHeight());
mat4 matProjection = projectionMatrix(VertFOVFromHorz(camera.GetFOV(), aspectRatio), aspectRatio, 0.1f, 1000.0f);

// Big thanks to merlyn from the Wolfire Discord for providing the projection matrix
// and the actual FOV calculation to make this possible!

// I spent a lot of awful lot of time to make the rest work.
float VertFOVFromHorz(float target_horz_fov, float aspect_ratio) {
	float pi = atan(1.0f) * 4.0f;
	
    // Enforce minimum fov on each axis
    float target_horz_radians = target_horz_fov * F_DEG_TO_RAD;
    float horz_unit = tan(target_horz_fov * F_DEG_TO_RAD * 0.5f);
    float vert_unit = horz_unit / aspect_ratio;
    float vert_angle = atan(vert_unit) * 2.0f * F_RAD_TO_DEG;
	
    vert_angle = max(vert_angle, TargetVertFovFromHorz(target_horz_fov));
    return vert_angle;
}

float TargetVertFovFromHorz(float target_horz_fov) {
    return target_horz_fov / (4.0f/3.0f);
}

void RecalculateProjectionMatrix(int iWidth, int iHeight)
{
	aspectRatio = float(iWidth) / float(iHeight);
	matProjection = projectionMatrix(VertFOVFromHorz(camera.GetFOV(), aspectRatio), aspectRatio, 0.1f, 1000.0f);
}

vec3 CalculateScreenCoordinates(IMGUI@ gui, vec3 posTarget)
{
	mat4 matCamRotX; matCamRotX.SetRotationX(camera.GetXRotation() * F_DEG_TO_RAD);
	mat4 matCamRotY; matCamRotY.SetRotationY(camera.GetYRotation() * F_DEG_TO_RAD);
	mat4 matCamTrans; matCamTrans.SetTranslationPart(camera.GetPos());
	
	mat4 matInvCameraSpace;
	matInvCameraSpace = invert(matCamTrans * matCamRotY * matCamRotX);
	matInvCameraSpace[15] = 0.0f;
	
	vec4 posVec4(
		posTarget.x,
		posTarget.y,
		posTarget.z,
		1.0f
	);
	
	vec3 posConverted = matProjection * matInvCameraSpace * posVec4;	
	
	// The 4x4 x 4x1 -> 3x1 multiplication already normalizes the vector automatically for us.
	// Meaning xyz / a (a in this case would be w).	
	
	// Since the clipping space is centered in the middle of the screen as (0/0)
	// and the bottom right corner is specified as (-1/0) we need to multiply y by -1.0f;
	posConverted.x /= posConverted.z;
	posConverted.y /= -posConverted.z;
	
	posConverted.x *= gui.getMain().getSizeX() / 2.0f;
	posConverted.y *= gui.getMain().getSizeY() / 2.0f;
	
	posConverted.x += gui.getMain().getSizeX() / 2.0f;
	posConverted.y += gui.getMain().getSizeY() / 2.0f;
	
	// Why are we returning the z-coordinate when the resulting coordinates should only be 2D?
	// Only the sign of the z-coordinate is relevant since it will tell you if the enemy is in front or behind the camera.
	return vec3(posConverted.x, posConverted.y, posConverted.z);
}

mat4 projectionMatrix(float fovyInDegrees, float aspectRatio, float znear, float zfar)
{
	mat4 matProjection;
	
	float e = 1.0f / tan(fovyInDegrees * ((F_PI/180.0f)) * 0.5f);
	float a = aspectRatio;
	
	float n = znear;
	float epsilon = 0.000001f;
	
	
	matProjection[0] = e/a;
    matProjection[1] = 0.0f;
    matProjection[2] = 0.0f;
    matProjection[3] = 0.0f;

    matProjection[4] = 0.0f;
    matProjection[5] = e;
    matProjection[6] = 0.0f;
    matProjection[7] = 0.0f;

    matProjection[8] = 0.0f;
    matProjection[9] = 0.0f;
    matProjection[10] = epsilon - 1.0f;
    matProjection[11] = -1.0f;

    matProjection[12] = 0.0f;
    matProjection[13] = 0.0f;
    matProjection[14] = (epsilon - 2.0f) * n;
    matProjection[15] = 0.0f;		
	
	return matProjection;
}

// Resizes the GUI to the full game window so the GUI occupies the whole screen.
// This is a rather complicated process to calculate, and is even more confusing
// once you resize the game window since you have to do some extra work.
void ResizeGUIToFullscreen(IMGUI@ guiMain, bool bFromWindowResize = false)
{
	if (bFromWindowResize)
	{
		RecalculateProjectionMatrix(GetScreenWidth(), GetScreenHeight());
	
		// doScrenResize needed otherwise the GUI will displace wrongly
		
		// In order for our free form aspect ratioless gui to function properly
		// we need to reset the displacement and call the doScreenResize function
		// where after we will resize it with out function.
		
		// Watch out that the controls placed with addFloatElement are placed at the exact coordinats.
		// These do not scale with the GUI, so if you place something at 200.0f
		// and resize the GUI to be wider, it will stay at 200.0f, not relative to the screen.
		
		// Placing items relative to oneanother should be done with the IMContainer/IMDivider/...
		// classes. It's enough to just place the parent container relative and assign
		// all the floating elements of the container with absolute coordinates since they will
		// be relative to the parent control.

		guiMain.getMain().setSize(vec2(0.0f));
		guiMain.getMain().setDisplacement(vec2(0.0f));
		
		guiMain.doScreenResize();
	}

	// Secret trademarked resizing routine to size the GUI to the full window
	// rather than letting it stay on 16:9. Don't tell the devs! xD		
	
	float fDisplayRatio = 16.0f / 9.0f;
	float fXResolution, fYResolution;
	float fGUIWidth, fGUIHeight;
			
	if (screenMetrics.getScreenWidth() < screenMetrics.getScreenHeight() * fDisplayRatio)
	{
		fXResolution = screenMetrics.getScreenWidth() / screenMetrics.GUItoScreenXScale;
		fYResolution = fXResolution / fDisplayRatio;
		
		fGUIWidth = fXResolution;
		fGUIHeight = screenMetrics.getScreenHeight() / screenMetrics.GUItoScreenXScale;
		
		guiMain.getMain().setDisplacementY((fYResolution - fGUIHeight) / 2.0f);
		guiMain.getMain().setSize(vec2(fGUIWidth, fGUIHeight));
	}
	else
	{
		fYResolution = screenMetrics.getScreenHeight() / screenMetrics.GUItoScreenYScale;
		fXResolution = fYResolution * fDisplayRatio;
		
		fGUIWidth = screenMetrics.getScreenWidth() / screenMetrics.GUItoScreenYScale;
		fGUIHeight = fYResolution;
		
		guiMain.getMain().setDisplacementX((fXResolution - fGUIWidth) / 2.0f);
		guiMain.getMain().setSize(vec2(fGUIWidth, fGUIHeight));
	}
		
	guiMain.update();	
}