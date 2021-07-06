#include "custom-hud/character-info.as"
#include "custom-hud/GUI/default-colors.as"


// Hud elements that are not supposed to be overlapped by others should start at this z position.
// Keep in mind that mixing elements with the max-z order is still possible, this is mainly
// to avoid the enemy panel being on top of the player panel.
const int I_MAX_Z_ORDER = 1000000;

// Individual player and enemy panel classes implement this interface so we can generailze
// the access to the panels a bit. Keeping it nice and clean.
interface Panel
{
	void UpdateInformation(array<CharacterInformation> ciCharacters);	
	void SetVisibility(bool bVisible);
	
	void Reset(); // Called when the message post_reset is received.
	void Resize(); // Called when SetWindowDimensions is called.
	
	// I wanted to use the destructor of the respective classes to clean up the created GUI elements
	// but since Angelscript does not call the destructor immediately after setting a class variable
	// to null we have to outsource it to a dedicated function.
	// 
	// If you assign a new instance to the same variable the destructor is called after the new
	// instance is created, which makes sense (since it calculates the value on the right, and then
	// assigns it to the variable calling the destructor) but is not usable for us since we need
	// to clean up beforehand.
	void Destroy();
}

// Maybe add another parameter for max health, blood and ko shield?
// Currently the max is 1 which requires the ko shield to be normalized first.

vec4 GetHealthbarColor(float fHealth)
{
	if (fHealth <= 0.0f) return vec4(1.0f, 0.0f, 0.0f, 1.0f);
	if (fHealth >= 0.5f) return vec4((1.0f - fHealth) * 2.0f, 1.0f, 0.0f, 1.0f);
	return vec4(1.0f, fHealth * 2.0f, 0.0f, 1.0);
}

vec4 GetBloodbarColor(float fBlood)
{
	return vec4(1.0f - (0.4f - 0.4f * fBlood), 0.0f, 0.0f, 1.0f); 
}

vec4 GetKOShieldbarColor(int iCurrentKOShield, int iMaxKOShield)
{
	if (iMaxKOShield == 0) return vec4(1.0f);
	else return vec4(1.0f - (float(iCurrentKOShield) / float(iMaxKOShield)), 1.0f - (float(iCurrentKOShield) / float(iMaxKOShield)), 1.0f, 1.0f);
}