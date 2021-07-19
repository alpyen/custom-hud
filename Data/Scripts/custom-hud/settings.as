#include "custom-hud/settings-definitions.as"

// Executes the code for generating the Custom HUD settings.
// Sorting this out to a dedicated function will not make the level script clutter up.
void DisplaySettingsGUI()
{
	ImGui_PushStyleColor(ImGuiCol_TitleBg, HexColor("#CC8500"));
	ImGui_PushStyleColor(ImGuiCol_TitleBgActive, HexColor("#FFA500"));
	
	ImGui_SetNextWindowSize(SIZE_SETTINGS_GUI, ImGuiSetCond_Always);
	ImGui_SetNextWindowPos((screenMetrics.screenSize - SIZE_SETTINGS_GUI) / 2.0f, ImGuiSetCond_FirstUseEver);
	
	bool bOldShowSettings = bShowSettings;
	
	ImGui_Begin(S_MOD_NAME + " " + S_MOD_VERSION + " - Settings", bShowSettings, ImGuiWindowFlags_NoResize | ImGuiWindowFlags_NoCollapse);	
		// This SaveSettings() call is just for the GUI being closed with the X button on the top right,
		// rather than the hotkey (that SaveSettings() is being called directly in the custom-hud.as script.
		
		// I know that this can be consolidated directly into the ImGui_Begin with a simple if and
		// a !bShowSettings afterwards but writing it down explicitly illustrates what's going on better.
		if (bOldShowSettings && !bShowSettings) SaveSettings();
		
		if (ImGui_TabButton("General Settings", stSelectedTab == StGeneralSettings)) stSelectedTab = StGeneralSettings;
		ImGui_SameLine();
		
		if (ImGui_TabButton("Player Information", stSelectedTab == StPlayerInformation)) stSelectedTab = StPlayerInformation;
		ImGui_SameLine();
		
		if (ImGui_TabButton("Enemy Information", stSelectedTab == StEnemyInformation)) stSelectedTab = StEnemyInformation;
		ImGui_SameLine();
		
		if (ImGui_TabButton("Custom Colors", stSelectedTab == StCustomColors)) stSelectedTab = StCustomColors;
		ImGui_SameLine();
		
		if (ImGui_TabButton("About & Help", stSelectedTab == StAboutAndHelp)) stSelectedTab = StAboutAndHelp;
		
		ImGui_Separator();
		
		ImGui_Indent();	
			ImGui_NewLine();
			
			switch (stSelectedTab)
			{
				case StGeneralSettings: ImGui_CustomHudGeneralSettings(); break;
				case StPlayerInformation: ImGui_CustomHudPlayerSettings(); break;
				case StEnemyInformation: ImGui_CustomHudEnemySettings(); break;
				case StCustomColors: ImGui_CustomHudCustomColorSettings(); break;
				case StAboutAndHelp: ImGui_CustomHudAboutAndHelp(); break;
			}	
		ImGui_Unindent();	
	ImGui_End();
	
	ImGui_PopStyleColor(2);
}

void ImGui_CustomHudGeneralSettings()
{
	ImGui_Checkbox(" Enable " + S_MOD_NAME, bEnableCustomHud);
	ImGui_SetTooltipOnHover("This will enable the Custom HUD mod with a simple switch,\nso you don't need to turn on/off the mod every time you want to use it.");
	
	ImGui_NewLine();
	
	ImGui_Indent();
		if (!bEnableCustomHud) ImGui_PushDisableControls();
		
		if (ImGui_Checkbox(" Show player panel", bShowPlayerPanel)) panelPlayer.SetVisibility(bShowPlayerPanel);
		if (ImGui_Checkbox(" Show enemy panel", bShowEnemyPanel)) panelEnemy.SetVisibility(bShowEnemyPanel);
		ImGui_Checkbox(" Show during dialogues", bShowDuringDialogues);
		ImGui_SetTooltipOnHover("Custom HUD is normally hidden during dialogues since it's not needed there.\nHowever some levels will hook into the DialogueCameraControl function and cause the hud to not show up.\n\nIf that is the case, enable this option to have the hud show at all times.\nPlease note however that the hud is still deactivate if the editor mode is active!");
		
		if (!bEnableCustomHud) ImGui_PopDisableControls();
	ImGui_Unindent();
	
	ImGui_NewLine();
	ImGui_NewLine();
	
	ImGui_Checkbox(" Show tooltips in the settings window", bShowTooltipsInTheSettingsWindow);
	ImGui_SetTooltipOnHover("Tooltips are little text boxes containing detailed information\nabout the setting you're currently hovering the mouse over.\n\nYou are currently reading one! :)\n\nUnlike other tooltips the tooltip for this option will always stay on.", true);
	
	ImGui_NewLine();
	ImGui_NewLine();
	
	ImGui_TextColored(HexColor("#DD4400"), "##### WARNING - PLEASE READ:");
	ImGui_TextWrapped("Overgrowth 1.4 has a bug that prevents it from disposing old fonts.\n\nUnfortunetaly there is no way around it so if the game crashes with the error message \"Too many cached text atlases\" simply restart the game and tweak the font bit by bit and keep saving it by closing and opening the settings window.\n\nThe game can only crash if you are messing with font settings.\nIt will not crash while playing.\n\nHopefully this will be fixed in Overgrowth 1.5 so I can remove this message!");
}

void ImGui_CustomHudPlayerSettings()
{
	bool bRebuildPlayerPanel = false;
				
	ImGui_Text("HUD Player Panel Style:");
	ImGui_NewLine();
	ImGui_Indent(); 
		int iOldPlayerPanelStyle = iPlayerPanelStyle;
		if (ImGui_Combo(" ", iPlayerPanelStyle, A_PLAYER_PANEL_STYLES))
		{
			if (iOldPlayerPanelStyle != iPlayerPanelStyle) bRebuildPlayerPanel = true;
		}
		ImGui_SetTooltipOnHover("The Panel style decides the overall look of how the player information is presented.\nThere are a variety of options you can choose from.");
	ImGui_Unindent();

	ImGui_NewLine(); ImGui_Separator();
	ImGui_NewLine();
	
	if (ImGui_Checkbox(" Display Health percentage", bPlayerDisplayHealthPercentage)) bRebuildPlayerPanel = true;
	ImGui_SameLine(240.0f); ImGui_Image(TEXTURE_HEALTH, vec2(19.0f, 19.0f));
	ImGui_SameLine(); ImGui_TextColored(HexColor("#00FF00"), "100");

	if (ImGui_Checkbox(" Display Blood percentage", bPlayerDisplayBloodPercentage)) bRebuildPlayerPanel = true;
	ImGui_SameLine(240.0f); ImGui_Image(TEXTURE_BLOOD, vec2(19.0f, 19.0f));
	ImGui_SameLine(); ImGui_TextColored(HexColor("#DD0000"), "100");

	if (ImGui_Checkbox(" Display KO Shield amount", bPlayerDisplayKOShieldAmount)) bRebuildPlayerPanel = true;
	ImGui_SameLine(240.0f); ImGui_Image(TEXTURE_KOSHIELD, vec2(19.0f, 19.0f));
	ImGui_SameLine(); ImGui_TextColored(HexColor("#0000FF"), "10");

	if (ImGui_Checkbox(" Display Velocity", bPlayerDisplayVelocity)) bRebuildPlayerPanel = true;
	ImGui_SameLine(240.0f); ImGui_Image(TEXTURE_VELOCITY, vec2(19.0f, 19.0f));
	ImGui_SameLine(); ImGui_TextColored(HexColor("#FFFFFF"), "7.95");

	ImGui_NewLine();
	ImGui_NewLine();

	// Attention, this is just a crude workaround for Overgrowth 1.4
	// 
	// There is currently no way of deleting cached fonts generated by FontSetup
	// so if we generate too many the game crashes with a message that too many have been cached.
	// 
	// To combat this, I used a ImGui_InputFloat rather than ImGui_SliderFloat because
	// the slider would force the GUI to rebuild at each new slider position.
	// 			
	// This just makes a difference in the ease of use, since you now have to insert the number		
	// directly rather than having it slide around and see the difference immediately.
	// 
	// This will hopefully be fixed with Overgrowth 1.5 and I'll reenable the slider then.
	//
	// This also means that the game will still crash when you apply too many changes
	// without restarting the level to reload the fonts.
	// However, doing this by accident is kind of impossible since you need many many changes! :)
	//
	// That is also the reason why we set the font only when an option modifies it and not 
	// when bRebuildPlayerPanel == true further down.
	// This will not be needed once we have a for the issue stated above.
	ImGui_Text("Scaling Factor:       "); ImGui_SameLine();
	//if (ImGui_SliderFloat(" ", fPlayerScalingFactor, 0.1f, 2.0f, "%.2fx")) bRebuildPlayerPanel = true;
	float fOldPlayerScalingFactor = fPlayerScalingFactor;
	if (ImGui_InputFloat("  ", fPlayerScalingFactor, 0.1f, 0.2f, 2))
	{
		bool bRebuildFont = false;
	
		if (fPlayerScalingFactor < 0.1f)
		{
			fPlayerScalingFactor = 0.1f;
			
			// This case grabs when the old value is not the lower limit but the player
			// enters a number directly undercutting the lower limit, since the old font
			// is a different size, we need to update it. If we had clicked on "-" while being
			// on the lower limit, the font size would still be the same.
			// Once we have a fix for the error described above we can simply remove this.
			if (fOldPlayerScalingFactor != 0.1f)
			{				
				bRebuildFont = true;
				bRebuildPlayerPanel = true;
			}
		}
		else if (fPlayerScalingFactor > 2.0f)
		{
			fPlayerScalingFactor = 2.0f;
			
			// This case is analog to the one described above.
			if (fOldPlayerScalingFactor != 2.0f)
			{
				bRebuildFont = true;
				bRebuildPlayerPanel = true;
			}
		}
		else
		{
			bRebuildFont = true;
			bRebuildPlayerPanel = true;
		}
		
		if (bRebuildFont)
		{
			fsPlayerFont = FontSetup(A_FONTS[iPlayerFont], int(F_PLAYER_BASE_FONT_SIZE * fPlayerScalingFactor), vec4(1.0f), bPlayerFontShadow);
		}
	}
	ImGui_SetTooltipOnHover("Scales the player panel's size by this factor making it smaller or larger.\nValues have to lye within the limits 0.1 and 2.0.\n\nNOTE: This element will be a slider for easier use when the game receives an update\nsince there is a bug preventing this from being a slider right now.");

	ImGui_Text("Horizontal Alignment: "); ImGui_SameLine();

	int iOldPlayerHorizontalAlignment = iPlayerHorizontalAlignment;
	if (ImGui_Combo("   ", iPlayerHorizontalAlignment, array<string> = { "Left", "Center", "Right" }))
	{
		if (iOldPlayerHorizontalAlignment != iPlayerHorizontalAlignment) bRebuildPlayerPanel = true;
	} ImGui_SetTooltipOnHover("Aligns the player panel horizontally on the screen.");

	ImGui_Text("Vertical Alignment:   "); ImGui_SameLine();

	int iOldPlayerVerticalAlignment = iPlayerVerticalAlignment;
	if (ImGui_Combo("    ", iPlayerVerticalAlignment, array<string> = { "Top", "Center", "Bottom" }))
	{
		if (iOldPlayerVerticalAlignment != iPlayerVerticalAlignment) bRebuildPlayerPanel = true;
	} ImGui_SetTooltipOnHover("Aligns the player panel vertically on the screen.");

	ImGui_Text("Panel Orientation:    "); ImGui_SameLine();

	int iOldPlayerPanelOrientation = iPlayerPanelOrientation;
	if (ImGui_Combo("     ", iPlayerPanelOrientation, array<string> = { "Vertical", "Horizontal" }))
	{
		if (iOldPlayerPanelOrientation != iPlayerPanelOrientation) bRebuildPlayerPanel = true;
	} ImGui_SetTooltipOnHover("Determines the player panel's orientation whether the hud elements\nshould be layed out next to each other (horizontally) or on top of each other (vertically).\n\nThis option will affect the overall player panel style differently.");

	ImGui_Text("Font:                 ");
	ImGui_SameLine();

	int iOldPlayerFont = iPlayerFont;
	ImGui_PushItemWidth(336.0f);
	if (ImGui_Combo("", iPlayerFont, A_FONTS))
	{
		if (iOldPlayerFont != iPlayerFont)
		{
			fsPlayerFont = FontSetup(A_FONTS[iPlayerFont], int(F_PLAYER_BASE_FONT_SIZE * fPlayerScalingFactor), vec4(1.0f), bPlayerFontShadow);
			bRebuildPlayerPanel = true;
		}
	}
	ImGui_PopItemWidth();
	
	ImGui_SameLine();
	if (ImGui_Checkbox("Shadow", bPlayerFontShadow))
	{
		fsPlayerFont = FontSetup(A_FONTS[iPlayerFont], int(F_PLAYER_BASE_FONT_SIZE * fPlayerScalingFactor), vec4(1.0f), bPlayerFontShadow);
		bRebuildPlayerPanel = true;
	}
	
	ImGui_Text("Panel Transparency:   "); ImGui_SameLine();
	if (ImGui_SliderFloat("      ", fPlayerPanelTransparency, 0.00f, 1.0f, int(fPlayerPanelTransparency * 100.0f) + "%%"))
	{
		if (fPlayerPanelTransparency < 0.0f) fPlayerPanelTransparency = 0.0f;
		else if (fPlayerPanelTransparency > 1.0f) fPlayerPanelTransparency = 1.0f;
	}
	
	ImGui_SetCursorPos(vec2(344.0f, 169.0f));
	ImGui_Text("HUD Order:");
	ImGui_SetCursorPosX(354.0f);
	ImGui_PushItemWidth(100.0f);
	ImGui_ListBox("", iPlayerSelectedHudOrderIndex, aPlayerHudOrder, 5);
	ImGui_SetTooltipOnHover("The order of the hud elements presented in the player panel.\nDeactivated elements will not be drawn and thus will not affect the order.\n\nChange the order with the 'Move Up' and 'Move Down' button on the right.");
	ImGui_SameLine();

	if (iPlayerSelectedHudOrderIndex == 0) ImGui_ButtonDisabled("Move Up");
	else if (ImGui_Button("Move Up"))
	{
		string sTmp = aPlayerHudOrder[iPlayerSelectedHudOrderIndex - 1];
		aPlayerHudOrder[iPlayerSelectedHudOrderIndex - 1] = aPlayerHudOrder[iPlayerSelectedHudOrderIndex];
		aPlayerHudOrder[iPlayerSelectedHudOrderIndex] = sTmp;
		
		--iPlayerSelectedHudOrderIndex;
		
		bRebuildPlayerPanel = true;
	}

	ImGui_SetCursorPos(vec2(462.0f, 209.0f));

	if (iPlayerSelectedHudOrderIndex == int(aPlayerHudOrder.length() - 1)) ImGui_ButtonDisabled("Move Down");
	else if (ImGui_Button("Move Down"))
	{
		string sTmp = aPlayerHudOrder[iPlayerSelectedHudOrderIndex + 1];
		aPlayerHudOrder[iPlayerSelectedHudOrderIndex + 1] = aPlayerHudOrder[iPlayerSelectedHudOrderIndex];
		aPlayerHudOrder[iPlayerSelectedHudOrderIndex] = sTmp;
		
		++iPlayerSelectedHudOrderIndex;
		
		bRebuildPlayerPanel = true;
	}

	ImGui_PopItemWidth();

	if (bRebuildPlayerPanel)
	{
		// See panel.as for why we use a dedicated function instead of using the destructor.
		panelPlayer.Destroy();
		
		switch (iPlayerPanelStyle)
		{
			case PhsStandardCustomHud: @panelPlayer = StandardCustomHudPlayerPanel(guiHud); break;
			case PhsStatusbars: @panelPlayer = StatusbarsPlayerPanel(guiHud); break;
		}
	}
}

void ImGui_CustomHudEnemySettings()
{
	bool bRebuildEnemyPanel = false;
	
	ImGui_Text("HUD Enemy Panel Configuration:");
	
	ImGui_NewLine();
	
	if (ImGui_Checkbox(" Display Health percentage", bEnemyDisplayHealthPercentage)) bRebuildEnemyPanel = true;
	ImGui_SameLine(240.0f); ImGui_Image(TEXTURE_HEALTH, vec2(19.0f, 19.0f));
	ImGui_SameLine(); ImGui_TextColored(HexColor("#00FF00"), "100");
	
	if (ImGui_Checkbox(" Display Blood percentage", bEnemyDisplayBloodPercentage)) bRebuildEnemyPanel = true;
	ImGui_SameLine(240.0f); ImGui_Image(TEXTURE_BLOOD, vec2(19.0f, 19.0f));
	ImGui_SameLine(); ImGui_TextColored(HexColor("#DD0000"), "100");
	
	if (ImGui_Checkbox(" Display KO Shield amount", bEnemyDisplayKOShieldAmount)) bRebuildEnemyPanel = true;
	ImGui_SameLine(240.0f); ImGui_Image(TEXTURE_KOSHIELD, vec2(19.0f, 19.0f));
	ImGui_SameLine(); ImGui_TextColored(HexColor("#0000FF"), "10");
	
	ImGui_NewLine();
	
	ImGui_Checkbox(" Scale with distance to player", bEnemyScaleWithDistanceToPlayer);
	ImGui_SetTooltipOnHover("The size of the enemy panels will vary with the distance to the enemy.\nIf the enemy is further away, the panel will appear smaller until it disappears at some point.");
	
	ImGui_Checkbox(" Show enemy panel style also on player", bEnemyShowEnemyPanelStyleAlsoOnPlayer);
	
	ImGui_Checkbox(" Show enemy panels for dead enemies", bEnemyShowEnemyPanelsForDeadEnemies);
	
	ImGui_Checkbox(" Show enemy panels also for allies", bEnemyShowEnemyPanelsAlsoForAllies);
	
	ImGui_Checkbox(" Show enemy panels only within certain range of enemies", bEnemyShowEnemyPanelsOnlyWithinCertainRangeOfEnemies);
	
	ImGui_Checkbox(" Show enemy panels only on visible contact", bEnemyShowEnemyPanelsOnlyOnVisibleContact);
	ImGui_SetTooltipOnHover("Display enemy information only if the line of sight towards the enemy is not blocked.\nDisable for pseudo-wallhack. (You might aswell disable the option above too then.)");
	
	ImGui_NewLine();
	
	ImGui_Text("Base Scaling Factor:  "); ImGui_SameLine();
	if (ImGui_SliderFloat(" ", fEnemyBaseScalingFactor, 0.1f, 2.0f, int(fEnemyBaseScalingFactor * 100.0f) + "%%"))
	{
		if (fEnemyBaseScalingFactor < 0.1f) fEnemyBaseScalingFactor = 0.1f;
		else if (fEnemyBaseScalingFactor > 2.0f) fEnemyBaseScalingFactor = 2.0f;
	}
	ImGui_SetTooltipOnHover("Scales the enemy panels' size by this base factor making it smaller or larger.\nValues have to lye within the limits 0.1 and 2.0.\n\nNOTE: This element will be a slider for easier use when the game receives an update\nsince there is a bug preventing this from being a slider right now.");
	
	ImGui_Text("Panel Transparency:   "); ImGui_SameLine();
	if (ImGui_SliderFloat("      ", fEnemyPanelTransparency, 0.00f, 1.0f, int(fEnemyPanelTransparency * 100.0f) + "%%"))
	{
		if (fEnemyPanelTransparency < 0.0f) fEnemyPanelTransparency = 0.0f;
		else if (fEnemyPanelTransparency > 2.0f) fEnemyPanelTransparency = 2.0f;
	}
	
	ImGui_SetCursorPos(vec2(344.0f, 108.0f));
	ImGui_Text("HUD Order:");
	ImGui_SetCursorPosX(354.0f);
	ImGui_PushItemWidth(100.0f);
	ImGui_ListBox("", iEnemySelectedHudOrderIndex, aEnemyHudOrder, 5);
	ImGui_SetTooltipOnHover("The order of the hud elements presented in the enemy panels.\nDeactivated elements will not be drawn and thus will not affect the order.\n\nChange the order with the 'Move Up' and 'Move Down' button on the right.");
	ImGui_SameLine();

	if (iEnemySelectedHudOrderIndex == 0) ImGui_ButtonDisabled("Move Up");
	else if (ImGui_Button("Move Up"))
	{
		string sTmp = aEnemyHudOrder[iEnemySelectedHudOrderIndex - 1];
		aEnemyHudOrder[iEnemySelectedHudOrderIndex - 1] = aEnemyHudOrder[iEnemySelectedHudOrderIndex];
		aEnemyHudOrder[iEnemySelectedHudOrderIndex] = sTmp;
		
		--iEnemySelectedHudOrderIndex;
		
		bRebuildEnemyPanel = true;
	}

	ImGui_SetCursorPos(vec2(462.0f, 148.0f));

	if (iEnemySelectedHudOrderIndex == int(aEnemyHudOrder.length() - 1)) ImGui_ButtonDisabled("Move Down");
	else if (ImGui_Button("Move Down"))
	{
		string sTmp = aEnemyHudOrder[iEnemySelectedHudOrderIndex + 1];
		aEnemyHudOrder[iEnemySelectedHudOrderIndex + 1] = aEnemyHudOrder[iEnemySelectedHudOrderIndex];
		aEnemyHudOrder[iEnemySelectedHudOrderIndex] = sTmp;
		
		++iEnemySelectedHudOrderIndex;
		
		bRebuildEnemyPanel = true;
	}

	if (bRebuildEnemyPanel)
	{	
		panelEnemy.Destroy();
		@panelEnemy = StandardCustomHudEnemyPanel(guiHud);
	}

	ImGui_PopItemWidth();
}

void ImGui_CustomHudCustomColorSettings()
{
	const int I_CUSTOM_COLORS_COLOR_EDIT_FLAG = ImGuiColorEditFlags_NoInputs | ImGuiColorEditFlags_NoAlpha | ImGuiColorEditFlags_NoLabel;

	ImGui_Checkbox(" Use static color for player (only high color) instead of color gradient", bCustomColorsUseStaticColorForPlayerInsteadOfColorGradient);
	ImGui_Checkbox(" Use static color for enemy (only high color) instead of color gradient", bCustomColorsUseStaticColorForEnemyInsteadOfColorGradient);
	// ImGui_NewLine();
	
	ImGui_Text("Health:");		
	ImGui_Indent();
		
		ImGui_AlignTextToFramePadding();
		ImGui_Text("Player - Low (0%), Medium (50%), High (100%):     ");
		ImGui_SameLine();
		
		ImGui_ColorEdit4("Player Health Low (0%)", colorsCustomColorsHealthPlayer[0], I_CUSTOM_COLORS_COLOR_EDIT_FLAG);
		ImGui_SameLine();
		ImGui_ColorEdit4("Player Health Medium (50%)", colorsCustomColorsHealthPlayer[1], I_CUSTOM_COLORS_COLOR_EDIT_FLAG);
		ImGui_SameLine();
		ImGui_ColorEdit4("Player Health High (100%)", colorsCustomColorsHealthPlayer[2], I_CUSTOM_COLORS_COLOR_EDIT_FLAG);
		
		ImGui_AlignTextToFramePadding();
		ImGui_Text("Enemy  - Low (0%), Medium (50%), High (100%):     ");
		ImGui_SameLine();
		
		ImGui_ColorEdit4("Enemy Health Low (0%)", colorsCustomColorsHealthEnemy[0], I_CUSTOM_COLORS_COLOR_EDIT_FLAG);
		ImGui_SameLine();
		ImGui_ColorEdit4("Enemy Health Medium (50%)", colorsCustomColorsHealthEnemy[1], I_CUSTOM_COLORS_COLOR_EDIT_FLAG);
		ImGui_SameLine();
		ImGui_ColorEdit4("Enemy Health High (100%)", colorsCustomColorsHealthEnemy[2], I_CUSTOM_COLORS_COLOR_EDIT_FLAG);
		ImGui_SameLine();
		if (ImGui_Button("Player Health")) colorsCustomColorsHealthEnemy = colorsCustomColorsHealthPlayer;
		ImGui_SetTooltipOnHover("Copies the Player Health colors onto the enemy ones.");
		
	ImGui_Unindent();
	ImGui_NewLine();
	
	ImGui_Text("Blood:");		
	ImGui_Indent();
		
		ImGui_AlignTextToFramePadding();
		ImGui_Text("Player - Low (0%), Medium (50%), High (100%):     ");
		ImGui_SameLine();
		
		ImGui_ColorEdit4("Player Blood Low (0%)", colorsCustomColorsBloodPlayer[0], I_CUSTOM_COLORS_COLOR_EDIT_FLAG);
		ImGui_SameLine();
		ImGui_ColorEdit4("Player Blood Medium (50%)", colorsCustomColorsBloodPlayer[1], I_CUSTOM_COLORS_COLOR_EDIT_FLAG);
		ImGui_SameLine();
		ImGui_ColorEdit4("Player Blood High (100%)", colorsCustomColorsBloodPlayer[2], I_CUSTOM_COLORS_COLOR_EDIT_FLAG);
		
		ImGui_AlignTextToFramePadding();
		ImGui_Text("Enemy  - Low (0%), Medium (50%), High (100%):     ");
		ImGui_SameLine();
		
		ImGui_ColorEdit4("Enemy Blood Low (0%)", colorsCustomColorsBloodEnemy[0], I_CUSTOM_COLORS_COLOR_EDIT_FLAG);
		ImGui_SameLine();
		ImGui_ColorEdit4("Enemy Blood Medium (50%)", colorsCustomColorsBloodEnemy[1], I_CUSTOM_COLORS_COLOR_EDIT_FLAG);
		ImGui_SameLine();
		ImGui_ColorEdit4("Enemy Blood High (100%)", colorsCustomColorsBloodEnemy[2], I_CUSTOM_COLORS_COLOR_EDIT_FLAG);
		ImGui_SameLine();
		if (ImGui_Button("Player Blood")) colorsCustomColorsBloodEnemy = colorsCustomColorsBloodPlayer;
		ImGui_SetTooltipOnHover("Copies the Player Blood colors onto the enemy ones.");
		
	ImGui_Unindent();
	ImGui_NewLine();
	
	ImGui_Text("KO Shield:");		
	ImGui_Indent();
		
		ImGui_AlignTextToFramePadding();
		ImGui_Text("Player - Low (0%), Medium (50%), High (100%):     ");
		ImGui_SameLine();
		
		ImGui_ColorEdit4("Player KO Shield Low (0%)", colorsCustomColorsKOShieldPlayer[0], I_CUSTOM_COLORS_COLOR_EDIT_FLAG);
		ImGui_SameLine();
		ImGui_ColorEdit4("Player KO Shield Medium (50%)", colorsCustomColorsKOShieldPlayer[1], I_CUSTOM_COLORS_COLOR_EDIT_FLAG);
		ImGui_SameLine();
		ImGui_ColorEdit4("Player KO Shield High (100%)", colorsCustomColorsKOShieldPlayer[2], I_CUSTOM_COLORS_COLOR_EDIT_FLAG);
		
		ImGui_AlignTextToFramePadding();
		ImGui_Text("Enemy  - Low (0%), Medium (50%), High (100%):     ");
		ImGui_SameLine();
		
		ImGui_ColorEdit4("Enemy KO Shield Low (0%)", colorsCustomColorsKOShieldEnemy[0], I_CUSTOM_COLORS_COLOR_EDIT_FLAG);
		ImGui_SameLine();
		ImGui_ColorEdit4("Enemy KO Shield Medium (50%)", colorsCustomColorsKOShieldEnemy[1], I_CUSTOM_COLORS_COLOR_EDIT_FLAG);
		ImGui_SameLine();
		ImGui_ColorEdit4("Enemy KO Shield High (100%)", colorsCustomColorsKOShieldEnemy[2], I_CUSTOM_COLORS_COLOR_EDIT_FLAG);
		ImGui_SameLine();
		if (ImGui_Button("Player KO Shield")) colorsCustomColorsKOShieldEnemy = colorsCustomColorsKOShieldPlayer;
		ImGui_SetTooltipOnHover("Copies the Player KO Shield colors onto the enemy ones.");
		
	ImGui_Unindent();
	ImGui_NewLine();
	
	ImGui_Text("Velocity:");		
	ImGui_Indent();
		
		ImGui_AlignTextToFramePadding();
		ImGui_Text("Player - Low (0u/s), Medium (5u/s), High (20u/s): ");
		ImGui_SameLine();
		
		ImGui_ColorEdit4("Player Velocity Low (0u/s)", colorsCustomColorsVelocityPlayer[0], I_CUSTOM_COLORS_COLOR_EDIT_FLAG);
		ImGui_SameLine();
		ImGui_ColorEdit4("Player Velocity Medium (5u/s)", colorsCustomColorsVelocityPlayer[1], I_CUSTOM_COLORS_COLOR_EDIT_FLAG);
		ImGui_SameLine();
		ImGui_ColorEdit4("Player Velocity High (20u/s)", colorsCustomColorsVelocityPlayer[2], I_CUSTOM_COLORS_COLOR_EDIT_FLAG);
		
	ImGui_Unindent();
	ImGui_NewLine();
	
	if (ImGui_Button("Reset all colors to default")) {
		colorsCustomColorsHealthPlayer = COLORS_DEFAULT_HEALTH;
		colorsCustomColorsHealthEnemy = COLORS_DEFAULT_HEALTH;
		
		colorsCustomColorsBloodPlayer = COLORS_DEFAULT_BLOOD;
		colorsCustomColorsBloodEnemy = COLORS_DEFAULT_BLOOD;
		
		colorsCustomColorsKOShieldPlayer = COLORS_DEFAULT_KOSHIELD;
		colorsCustomColorsKOShieldEnemy = COLORS_DEFAULT_KOSHIELD;
		
		colorsCustomColorsVelocityPlayer = COLORS_DEFAULT_VELOCITY;
	}
}

void ImGui_CustomHudAboutAndHelp()
{
	ImGui_NewLine();
	ImGui_TextColored(HexColor("#FFFF09"), S_MOD_NAME + " " + S_MOD_VERSION);
	ImGui_SameLine();
	ImGui_Text("mod made by");
	ImGui_SameLine();
	ImGui_TextColored(HexColor("#F1C40F"), "alpines (Steam: _Ins4ne_)");

	ImGui_NewLine();

	ImGui_Text("Hover over the controls (checkboxes, etc...) to find a short\nexplanation on what the setting does!");

	ImGui_NewLine();

	ImGui_TextWrapped(
		"Do you have feedback you want to share with me?\n"
		"\n"
		"Visit the workshop page and leave your suggestions in the comments\n"
		"...or open up a topic in the mod forum\n"
		"...or directly message me on the Wolfire Discord!\n"
		"\n"
		"\n"
		"If you have two minutes, consider leaving a like/favorite on the mod page!\n"
		"\n"
		"Thank you! :)"
	);

	ImGui_NewLine();

	array<ModID>@ aMods = GetActiveModSids();
	int iModIndex = 0;

	for (uint iIndex = 0; iIndex < aMods.length(); ++iIndex)
	{	
		if (ModGetID(aMods[iIndex]) == S_MOD_ID)
		{
			iModIndex = iIndex;
			break;
		}
	}

	if (ImGui_Button("Open Steam Workshop Page")) OpenModWorkshopPage(aMods[iModIndex]);
}

bool ImGui_TabButton(const string &in sLabel, bool bSelected)
{
	if (bSelected) ImGui_PushStyleColor(ImGuiCol_Button, ImGui_GetStyleColorVec4(ImGuiCol_ButtonHovered));
	
	bool bReturn = ImGui_Button(sLabel);	
	
	if (bSelected) ImGui_PopStyleColor();
	
	return bReturn;
}

bool ImGui_ButtonDisabled(const string& in sLabel)
{
	ImGui_PushStyleVar(ImGuiStyleVar_Enabled, false);	
	ImGui_PushStyleColor(ImGuiCol_Button, vec4(0.43f, 0.43f, 0.43f, 0.39f));

	bool bReturn = ImGui_Button(sLabel);
	
	ImGui_PopStyleVar();
	ImGui_PopStyleColor();
	
	return bReturn;
}

void ImGui_SetTooltipOnHover(const string &in sLabel, bool bForceTooltipOnHover = false)
{
	if ((bShowTooltipsInTheSettingsWindow || bForceTooltipOnHover) && ImGui_IsItemHovered()) ImGui_SetTooltip(sLabel);
}

void SaveSettings()
{
	// General Settings
	SetConfigValueBool(S_SETTINGS_PREFIX + "bEnableCustomHud", bEnableCustomHud);
	SetConfigValueBool(S_SETTINGS_PREFIX + "bShowPlayerPanel", bShowPlayerPanel);
	SetConfigValueBool(S_SETTINGS_PREFIX + "bShowEnemyPanel", bShowEnemyPanel);
	SetConfigValueBool(S_SETTINGS_PREFIX + "bShowDuringDialogues", bShowDuringDialogues);
	
	SetConfigValueBool(S_SETTINGS_PREFIX + "bShowTooltipsInTheSettingsWindow", bShowTooltipsInTheSettingsWindow);
	
	
	// Player Information
	SetConfigValueInt(S_SETTINGS_PREFIX + "iPlayerPanelStyle", iPlayerPanelStyle);
	SetConfigValueBool(S_SETTINGS_PREFIX + "bPlayerDisplayHealthPercentage", bPlayerDisplayHealthPercentage);
	SetConfigValueBool(S_SETTINGS_PREFIX + "bPlayerDisplayBloodPercentage", bPlayerDisplayBloodPercentage);
	SetConfigValueBool(S_SETTINGS_PREFIX + "bPlayerDisplayKOShieldAmount", bPlayerDisplayKOShieldAmount);
	SetConfigValueBool(S_SETTINGS_PREFIX + "bPlayerDisplayVelocity", bPlayerDisplayVelocity);
		
	SetConfigValueFloat(S_SETTINGS_PREFIX + "fPlayerScalingFactor", fPlayerScalingFactor);
	SetConfigValueInt(S_SETTINGS_PREFIX + "iPlayerHorizontalAlignment", iPlayerHorizontalAlignment);
	SetConfigValueInt(S_SETTINGS_PREFIX + "iPlayerVerticalAlignment", iPlayerVerticalAlignment);
	SetConfigValueInt(S_SETTINGS_PREFIX + "iPlayerPanelOrientation", iPlayerPanelOrientation);
	SetConfigValueInt(S_SETTINGS_PREFIX + "iPlayerFont", iPlayerFont);
	SetConfigValueBool(S_SETTINGS_PREFIX + "bPlayerFontShadow", bPlayerFontShadow);
	SetConfigValueFloat(S_SETTINGS_PREFIX + "fPlayerPanelTransparency", fPlayerPanelTransparency);
	
	SetConfigValueString(S_SETTINGS_PREFIX + "sPlayerHudOrder", join(aPlayerHudOrder, "|"));
	
	
	// Enemy Information
	SetConfigValueBool(S_SETTINGS_PREFIX + "bEnemyDisplayHealthPercentage", bEnemyDisplayHealthPercentage);
	SetConfigValueBool(S_SETTINGS_PREFIX + "bEnemyDisplayBloodPercentage", bEnemyDisplayBloodPercentage);
	SetConfigValueBool(S_SETTINGS_PREFIX + "bEnemyDisplayKOShieldAmount", bEnemyDisplayKOShieldAmount);
	
	SetConfigValueBool(S_SETTINGS_PREFIX + "bEnemyScaleWithDistanceToPlayer", bEnemyScaleWithDistanceToPlayer);	
	SetConfigValueBool(S_SETTINGS_PREFIX + "bEnemyShowEnemyPanelStyleAlsoOnPlayer", bEnemyShowEnemyPanelStyleAlsoOnPlayer);
	SetConfigValueBool(S_SETTINGS_PREFIX + "bEnemyShowEnemyPanelsForDeadEnemies", bEnemyShowEnemyPanelsForDeadEnemies);
	SetConfigValueBool(S_SETTINGS_PREFIX + "bEnemyShowEnemyPanelsAlsoForAllies", bEnemyShowEnemyPanelsAlsoForAllies);
	SetConfigValueBool(S_SETTINGS_PREFIX + "bEnemyShowEnemyPanelsOnlyWithinCertainRangeOfEnemies", bEnemyShowEnemyPanelsOnlyWithinCertainRangeOfEnemies);
	SetConfigValueBool(S_SETTINGS_PREFIX + "bEnemyShowEnemyPanelsOnlyOnVisibleContact", bEnemyShowEnemyPanelsOnlyOnVisibleContact);
	
	SetConfigValueFloat(S_SETTINGS_PREFIX + "fEnemyBaseScalingFactor", fEnemyBaseScalingFactor);
	SetConfigValueFloat(S_SETTINGS_PREFIX + "fEnemyPanelTransparency", fEnemyPanelTransparency);
	
	SetConfigValueString(S_SETTINGS_PREFIX + "sEnemyHudOrder", join(aEnemyHudOrder, "|"));
	
	
	// Custom Colors	
	SetConfigValueBool(S_SETTINGS_PREFIX + "bCustomColorsUseStaticColorForPlayerInsteadOfColorGradient", bCustomColorsUseStaticColorForPlayerInsteadOfColorGradient);
	SetConfigValueBool(S_SETTINGS_PREFIX + "bCustomColorsUseStaticColorForEnemyInsteadOfColorGradient", bCustomColorsUseStaticColorForEnemyInsteadOfColorGradient);
	
	SetConfigValueArrayVec4(S_SETTINGS_PREFIX + "colorsCustomColorsHealthPlayer", colorsCustomColorsHealthPlayer);
	SetConfigValueArrayVec4(S_SETTINGS_PREFIX + "colorsCustomColorsHealthEnemy", colorsCustomColorsHealthEnemy);
	
	SetConfigValueArrayVec4(S_SETTINGS_PREFIX + "colorsCustomColorsBloodPlayer", colorsCustomColorsBloodPlayer);
	SetConfigValueArrayVec4(S_SETTINGS_PREFIX + "colorsCustomColorsBloodEnemy", colorsCustomColorsBloodEnemy);
	
	SetConfigValueArrayVec4(S_SETTINGS_PREFIX + "colorsCustomColorsKOShieldPlayer", colorsCustomColorsKOShieldPlayer);
	SetConfigValueArrayVec4(S_SETTINGS_PREFIX + "colorsCustomColorsKOShieldEnemy", colorsCustomColorsKOShieldEnemy);
	
	SetConfigValueArrayVec4(S_SETTINGS_PREFIX + "colorsCustomColorsVelocityPlayer", colorsCustomColorsVelocityPlayer);
	
	SaveConfig();
}

// The LoadSettings function implements error checking so tampering with the config file
// will not result in the mod breaking!
void LoadSettings()
{
	// These config functions wrap the original ones and add limit enforcing so defective values
	// caused by the user manually editing the config file have no effect!
	// Since we are setting the defaults on declaration we simply ignore it for the booleans.
	
	// General Settings
	GetConfigValueBoolIfKeyExists("bEnableCustomHud", bEnableCustomHud);
	GetConfigValueBoolIfKeyExists("bShowPlayerPanel", bShowPlayerPanel);
	GetConfigValueBoolIfKeyExists("bShowEnemyPanel", bShowEnemyPanel);
	GetConfigValueBoolIfKeyExists("bShowDuringDialogues", bShowDuringDialogues);
	
	GetConfigValueBoolIfKeyExists("bShowTooltipsInTheSettingsWindow", bShowTooltipsInTheSettingsWindow);
	
	
	// Player Information
	GetConfigValueIntIfKeyExists("iPlayerPanelStyle", iPlayerPanelStyle, 0, int(A_PLAYER_PANEL_STYLES.length() - 1), 0);
	
	GetConfigValueBoolIfKeyExists("bPlayerDisplayHealthPercentage", bPlayerDisplayHealthPercentage);
	GetConfigValueBoolIfKeyExists("bPlayerDisplayBloodPercentage", bPlayerDisplayBloodPercentage);
	GetConfigValueBoolIfKeyExists("bPlayerDisplayKOShieldAmount", bPlayerDisplayKOShieldAmount);
	GetConfigValueBoolIfKeyExists("bPlayerDisplayVelocity", bPlayerDisplayVelocity);
	
	GetConfigValueFloatIfKeyExists("fPlayerScalingFactor", fPlayerScalingFactor, 0.1f, 2.0f, 1.0f);
	GetConfigValueIntIfKeyExists("iPlayerHorizontalAlignment", iPlayerHorizontalAlignment, CALeft, CARight, CACenter);
	GetConfigValueIntIfKeyExists("iPlayerVerticalAlignment", iPlayerVerticalAlignment, CATop, CABottom, CACenter);
	GetConfigValueIntIfKeyExists("iPlayerPanelOrientation", iPlayerPanelOrientation, DOVertical, DOHorizontal, DOHorizontal);
	GetConfigValueIntIfKeyExists("iPlayerFont", iPlayerFont, 0, int(A_FONTS.length() - 1), 0);
	GetConfigValueBoolIfKeyExists("bPlayerFontShadow", bPlayerFontShadow);
	GetConfigValueFloatIfKeyExists("fPlayerPanelTransparency", fPlayerPanelTransparency, 0.0f, 1.0f, 0.0f);
	
	fsPlayerFont = FontSetup(A_FONTS[iPlayerFont], int(F_PLAYER_BASE_FONT_SIZE * fPlayerScalingFactor), vec4(1.0f), bPlayerFontShadow);
	
	// This routine is special and can not be really generalized for strings, so we do this explicitly here.
	if (ConfigHasKey(S_SETTINGS_PREFIX + "sPlayerHudOrder"))
	{
		string sPlayerHudOrder = GetConfigValueString(S_SETTINGS_PREFIX + "sPlayerHudOrder");
		aPlayerHudOrder = sPlayerHudOrder.split("|");
		
		bool bValidHudOrder = true;
		
		for (uint iHudIndex = 0; iHudIndex < aPlayerHudOrder.length(); ++iHudIndex)
		{
			if (aPlayerHudOrder[iHudIndex] != "Health" && aPlayerHudOrder[iHudIndex] != "Blood" && aPlayerHudOrder[iHudIndex] != "KO Shield" && aPlayerHudOrder[iHudIndex] != "Velocity")
			{
				bValidHudOrder = false;
				break;
			}
		}
		
		if (aPlayerHudOrder.length() != 4) bValidHudOrder = false;
		
		if (!bValidHudOrder) aPlayerHudOrder = { "Health", "Blood", "KO Shield", "Velocity" };
	}
	
	
	// Enemy Information
	GetConfigValueBoolIfKeyExists("bEnemyDisplayHealthPercentage", bEnemyDisplayHealthPercentage);
	GetConfigValueBoolIfKeyExists("bEnemyDisplayBloodPercentage", bEnemyDisplayBloodPercentage);
	GetConfigValueBoolIfKeyExists("bEnemyDisplayKOShieldAmount", bEnemyDisplayKOShieldAmount);
	
	GetConfigValueBoolIfKeyExists("bEnemyScaleWithDistanceToPlayer", bEnemyScaleWithDistanceToPlayer);	
	GetConfigValueBoolIfKeyExists("bEnemyShowEnemyPanelStyleAlsoOnPlayer", bEnemyShowEnemyPanelStyleAlsoOnPlayer);	
	GetConfigValueBoolIfKeyExists("bEnemyShowEnemyPanelsForDeadEnemies", bEnemyShowEnemyPanelsForDeadEnemies);
	GetConfigValueBoolIfKeyExists("bEnemyShowEnemyPanelsAlsoForAllies", bEnemyShowEnemyPanelsAlsoForAllies);
	GetConfigValueBoolIfKeyExists("bEnemyShowEnemyPanelsOnlyWithinCertainRangeOfEnemies", bEnemyShowEnemyPanelsOnlyWithinCertainRangeOfEnemies);
	GetConfigValueBoolIfKeyExists("bEnemyShowEnemyPanelsOnlyOnVisibleContact", bEnemyShowEnemyPanelsOnlyOnVisibleContact);
	
	GetConfigValueFloatIfKeyExists("fEnemyBaseScalingFactor", fEnemyBaseScalingFactor, 0.1f, 2.0f, 1.0f);
	GetConfigValueFloatIfKeyExists("fEnemyPanelTransparency", fEnemyPanelTransparency, 0.0f, 1.0f, 0.0f);
	
	if (ConfigHasKey(S_SETTINGS_PREFIX + "sEnemyHudOrder"))
	{
		string sEnemyHudOrder = GetConfigValueString(S_SETTINGS_PREFIX + "sEnemyHudOrder");
		aEnemyHudOrder = sEnemyHudOrder.split("|");
		
		bool bValidHudOrder = true;
		
		for (uint iHudIndex = 0; iHudIndex < aEnemyHudOrder.length(); ++iHudIndex)
		{
			if (aEnemyHudOrder[iHudIndex] != "Health" && aEnemyHudOrder[iHudIndex] != "Blood" && aEnemyHudOrder[iHudIndex] != "KO Shield")
			{
				bValidHudOrder = false;
				break;
			}
		}
		
		if (aEnemyHudOrder.length() != 3) bValidHudOrder = false;
		
		if (!bValidHudOrder) aEnemyHudOrder = { "Health", "Blood", "KO Shield" };
	}
	
	
	// Custom Colors
	GetConfigValueBoolIfKeyExists("bCustomColorsUseStaticColorForPlayerInsteadOfColorGradient", bCustomColorsUseStaticColorForPlayerInsteadOfColorGradient);
	GetConfigValueBoolIfKeyExists("bCustomColorsUseStaticColorForEnemyInsteadOfColorGradient", bCustomColorsUseStaticColorForEnemyInsteadOfColorGradient);
	
	GetConfigValueArrayVec4IfKeyExists("colorsCustomColorsHealthPlayer", colorsCustomColorsHealthPlayer, vec4(0.0f, 0.0f, 0.0f, 1.0f), vec4(1.0f, 1.0f, 1.0f, 1.0f), COLORS_DEFAULT_HEALTH);
	GetConfigValueArrayVec4IfKeyExists("colorsCustomColorsHealthEnemy", colorsCustomColorsHealthEnemy, vec4(0.0f, 0.0f, 0.0f, 1.0f), vec4(1.0f, 1.0f, 1.0f, 1.0f), COLORS_DEFAULT_HEALTH);
	
	GetConfigValueArrayVec4IfKeyExists("colorsCustomColorsBloodPlayer", colorsCustomColorsBloodPlayer, vec4(0.0f, 0.0f, 0.0f, 1.0f), vec4(1.0f, 1.0f, 1.0f, 1.0f), COLORS_DEFAULT_BLOOD);
	GetConfigValueArrayVec4IfKeyExists("colorsCustomColorsBloodEnemy", colorsCustomColorsBloodEnemy, vec4(0.0f, 0.0f, 0.0f, 1.0f), vec4(1.0f, 1.0f, 1.0f, 1.0f), COLORS_DEFAULT_BLOOD);
	
	GetConfigValueArrayVec4IfKeyExists("colorsCustomColorsKOShieldPlayer", colorsCustomColorsKOShieldPlayer, vec4(0.0f, 0.0f, 0.0f, 1.0f), vec4(1.0f, 1.0f, 1.0f, 1.0f), COLORS_DEFAULT_KOSHIELD);
	GetConfigValueArrayVec4IfKeyExists("colorsCustomColorsKOShieldEnemy", colorsCustomColorsKOShieldEnemy, vec4(0.0f, 0.0f, 0.0f, 1.0f), vec4(1.0f, 1.0f, 1.0f, 1.0f), COLORS_DEFAULT_KOSHIELD);
	
	GetConfigValueArrayVec4IfKeyExists("colorsCustomColorsVelocityPlayer", colorsCustomColorsVelocityPlayer, vec4(0.0f, 0.0f, 0.0f, 1.0f), vec4(1.0f, 1.0f, 1.0f, 1.0f), COLORS_DEFAULT_VELOCITY);
}

void GetConfigValueBoolIfKeyExists(string sKey, bool& bVar)
{
	if (ConfigHasKey(S_SETTINGS_PREFIX + sKey)) bVar = GetConfigValueBool(S_SETTINGS_PREFIX + sKey);
}

void GetConfigValueIntIfKeyExists(string sKey, int& iVar, int iLowerLimit, int iUpperLimit, int iDefaultOnError)
{
	if (ConfigHasKey(S_SETTINGS_PREFIX + sKey))
	{
		iVar = GetConfigValueInt(S_SETTINGS_PREFIX + sKey);
		if (iVar < iLowerLimit || iVar > iUpperLimit) iVar = iDefaultOnError;
	}
}

void GetConfigValueFloatIfKeyExists(string sKey, float& iVar, float iLowerLimit, float iUpperLimit, float iDefaultOnError)
{
	if (ConfigHasKey(S_SETTINGS_PREFIX + sKey))
	{
		iVar = GetConfigValueFloat(S_SETTINGS_PREFIX + sKey);
		if (iVar < iLowerLimit || iVar > iUpperLimit) iVar = iDefaultOnError;
	}
}

void SetConfigValueArrayVec4(string sKey, array<vec4> aVecs)
{
	string sValue = "";
	
	for (uint i = 0; i < aVecs.length(); ++i)
	{
		sValue += __indexReadVec4(aVecs[i], 0) + "," + __indexReadVec4(aVecs[i], 1) + "," + __indexReadVec4(aVecs[i], 2) + "," + __indexReadVec4(aVecs[i], 3);
		if (i < aVecs.length() - 1) sValue += ";";
	}
	
	SetConfigValueString(sKey, sValue);
}

void GetConfigValueArrayVec4IfKeyExists(string sKey, array<vec4>& aVecs, vec4 vecLowerLimit, vec4 vecUpperLimit, array<vec4> aDefaultsOnError)
{	
	if (ConfigHasKey(S_SETTINGS_PREFIX + sKey))
	{
		string sVar = GetConfigValueString(S_SETTINGS_PREFIX + sKey);
		
		array<string> aSplitVar = sVar.split(";");
		
		if (aSplitVar.length() != aVecs.length())
		{
			// Malicious config.txt detected.
			for (uint i = 0; i < aVecs.length(); ++i)
			{
				aVecs[i] = aDefaultsOnError[i];
			}
			
			return;
		}
		
		// Check if it's three dimensional, non empty and within limits.
		// The vector will be defaulted if one condition is not satisfied.
		
		for (uint i = 0; i < aSplitVar.length(); ++i)
		{
			array<string> aSplitVec = aSplitVar[i].split(",");
			
			if (aSplitVec.length() != 4)
			{
				aVecs[i] = aDefaultsOnError[i];
				continue;
			}
			
			vec4 vecTemporary;
			
			for (uint j = 0; j < aSplitVec.length(); ++j)
			{
				// Using parseFloat instead of atof will cause the game to crash or behave weirdly.
				float fCurrentValue = atof(aSplitVec[j]);
			
				if (aSplitVec[j] == "" || fCurrentValue < __indexReadVec4(vecLowerLimit, j) || fCurrentValue > __indexReadVec4(vecUpperLimit, j))
				{
					vecTemporary = aDefaultsOnError[i];
					break;
				}

				__indexWriteVec4(vecTemporary, j, fCurrentValue);
			}
			
			aVecs[i] = vecTemporary;
		}
	}
}


// Will be removed when there's an indexing operator for vec4.
void __indexWriteVec4(vec4& vec, int index, float value)
{
	if (index == 0) vec.x = value;
	else if (index == 1) vec.y = value;
	else if (index == 2) vec.z = value;
	else if (index == 3) vec.a = value;
}

float __indexReadVec4(vec4 vec, int index)
{
	if (index == 0) return vec.x;
	else if (index == 1) return vec.y;
	else if (index == 2) return vec.z;
	else if (index == 3) return vec.a;
	
	return 99e99f;
}

void ImGui_PushDisableControls()
{
	vec4 colorDisabled = vec4(0.5f, 0.5f, 0.5f, 1.0f);
	
	ImGui_PushStyleVar(ImGuiStyleVar_Enabled, false);
	ImGui_PushStyleColor(ImGuiCol_CheckMark, colorDisabled);
	ImGui_PushStyleColor(ImGuiCol_Text, colorDisabled);
}

void ImGui_PopDisableControls()
{
	ImGui_PopStyleColor(2);
	ImGui_PopStyleVar();
}