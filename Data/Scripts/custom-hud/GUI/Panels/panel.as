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
	void UpdateInformation(array<CharacterInformation>& ciCharacters);	
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
