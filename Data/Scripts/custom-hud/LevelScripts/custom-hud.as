#include "custom-hud/character-info.as"

#include "custom-hud/settings-definitions.as"
#include "custom-hud/settings.as"

#include "custom-hud/GUI/hud-panels.as"
#include "custom-hud/GUI/gui-helper.as"

IMGUI@ guiHUD = CreateIMGUI();

Panel@ panelPlayer;
Panel@ panelEnemy;

int iPlayerID = -1;

float fFOV = camera.GetFOV();

// If you edit the script while having it loaded Overgrowth will try to update it on the fly.
// However, you might lose some references in classes and to save the game from crashing we are
// basically just reloading the whole HUD if the script reloads.
//
// This way we can hot-edit/live-edit the script without reloading the whole level!
// Very useful for development.
void PostScriptReload()
{
	panelPlayer.Destroy();
	panelEnemy.Destroy();
	
	iPlayerID = -1;
	
	Init("");
}

void Init(string level_name)
{
	LoadSettings();
	
	guiHUD.clear();
	guiHUD.setup();
	
	ResizeGUIToFullscreen(guiHUD);
		
	switch (iPlayerPanelStyle)
	{
		case PhsStandardCustomHUD: @panelPlayer = StandardCustomHudPlayerPanel(guiHUD); break;
		case PhsStatusbars: @panelPlayer = StatusbarsPlayerPanel(guiHUD); break;
	}
	
	@panelEnemy = StandardCustomHudEnemyPanel(guiHUD);
}

void Update(int is_paused)
{	
	// Is CTRL+H pressed for the settings window? Save settings if window is closed.
	if ((GetInputDown(0, "lctrl") || GetInputDown(0, "rctrl")) && GetInputPressed(0, "h"))
	{
		bShowSettings = !bShowSettings;
		if (!bShowSettings) SaveSettings();
	}
	
	if (!bShowDuringDialogues && level.DialogueCameraControl()) return;

	// If the mod is disabled, do not execute the rest of the Update code
	// since we only need the part that brings us into the Custom HUD settings above.
	if (!bEnableCustomHUD) return;
	
	// Check if the player ID is valid, if not get a new one.
	if (iPlayerID == -1 || !ObjectExists(iPlayerID) || ReadObjectFromID(iPlayerID).GetType() != _movement_object || !ReadCharacterID(iPlayerID).controlled || ReadCharacterID(iPlayerID).controller_id != 0)
	{
		// So we need to check for one criteria if we don't find any.
		iPlayerID = -1;
		
		// Since our player ID is invalid, we don't need to display the hud.
		panelPlayer.SetVisibility(false);
		panelEnemy.SetVisibility(false);
		
		array<int> aCharacters;
		GetCharacters(aCharacters);
		
		for (uint iCharacterIndex = 0; iCharacterIndex < aCharacters.length(); ++iCharacterIndex)
		{
			if (ReadCharacterID(aCharacters[iCharacterIndex]).controlled)
			{
				iPlayerID = aCharacters[iCharacterIndex];
				
				if (bShowPlayerPanel) panelPlayer.SetVisibility(true);
				if (bShowEnemyPanel) panelEnemy.SetVisibility(true);
				
				break;
			}
		}
	}
	
	// If our player ID is valid, create an array with the wrapper class CharacterInformation and send it to the panels!
	if (iPlayerID != -1)
	{
		// Kind of unnecessary since changing the fov is so rare but
		// checking for the change or even recalculating the matrix every iteration
		// is not impacting the performance at all --- we might keep it for convenience.
		if (camera.GetFOV() != fFOV)
		{
			fFOV = camera.GetFOV();
			RecalculateProjectionMatrix(GetScreenWidth(), GetScreenHeight());
		}
		
		array<CharacterInformation> aCharacterInformations(GetNumCharacters());
		
		for (int iCharacterIndex = 0; iCharacterIndex < GetNumCharacters(); ++iCharacterIndex)
			aCharacterInformations[iCharacterIndex] = CharacterInformation(ReadCharacter(iCharacterIndex));
			
		if (bShowPlayerPanel) panelPlayer.UpdateInformation(aCharacterInformations);
		if (bShowEnemyPanel) panelEnemy.UpdateInformation(aCharacterInformations);
	}
	
	guiHUD.update();
}

void DrawGUI()
{	
	if (bShowSettings) DisplaySettingsGUI();
	
	if (!bShowDuringDialogues && level.DialogueCameraControl()) return;
	
	// Same reason as in Update()
	if (!bEnableCustomHUD) return;
	
	guiHUD.render();
}

void ReceiveMessage(string message)
{
	if (message == "post_reset")
	{
		panelPlayer.Reset();
		panelEnemy.Reset();
		
		iPlayerID = -1;
	}
}

void SetWindowDimensions(int width, int height)
{
	// Includes recalculations for the 3D to 2D conversion aswell. (RecalculateProjectionMatrix)
	ResizeGUIToFullscreen(guiHUD, true);
	
	panelPlayer.Resize();
	panelEnemy.Resize();
}

bool HasFocus()
{
	return bShowSettings;
}