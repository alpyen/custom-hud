#include "custom-hud/settings-definitions.as"
#include "custom-hud/GUI/default-colors.as"
#include "custom-hud/GUI/Panels/panel.as"

class StandardCustomHudEnemyPanel : Panel
{
	IMGUI@ guiMain;
	
	// This array holds a wrapper for the enemy panel elements and its order is the same as
	// it is passed with the ciCharacters parameter on UpdateInformation.
	
	// If characters are removed or added the panels assigned character will be overwritten
	// and the old character will receive a new panel depending on where the new character was inserted in the array from the game.
	array<StandardCustomHudEnemyPanelElement@> aEnemyPanels;
	
	StandardCustomHudEnemyPanel(IMGUI@ guiMain)
	{
		@this.guiMain = guiMain;
	}
	
	void UpdateInformation(array<CharacterInformation>& ciCharacters)
	{
		if (this.aEnemyPanels.length() != ciCharacters.length()) this.aEnemyPanels.resize(ciCharacters.length());
	
		for (uint iCharacterIndex = 0; iCharacterIndex < ciCharacters.length(); ++iCharacterIndex)
		{		
			CharacterInformation ciCharacter = ciCharacters[iCharacterIndex];
			
			if (this.aEnemyPanels[iCharacterIndex] is null)
			{
				@this.aEnemyPanels[iCharacterIndex] = StandardCustomHudEnemyPanelElement(this.guiMain, ciCharacter.iCharacterID, iCharacterIndex, ciCharacter.moCharacter.controlled);
			}
			else if (ciCharacter.iCharacterID != this.aEnemyPanels[iCharacterIndex].iCharacterID)
			{
				this.aEnemyPanels[iCharacterIndex].SetCharacterID(ciCharacter.iCharacterID, ciCharacter.moCharacter.controlled);
			}
			
			StandardCustomHudEnemyPanelElement@ panelEnemy = this.aEnemyPanels[iCharacterIndex];
			
			// Check the enemy panels should not be displayed when certain settings are set.			
			if (!bEnemyShowEnemyPanelsAlsoForAllies && iPlayerID != ciCharacter.iCharacterID && ReadCharacterID(iPlayerID).OnSameTeam(ciCharacter.moCharacter))
			{
				if (panelEnemy.bVisible) panelEnemy.SetVisibility(false);
				continue;
			}
			
			if (!bEnemyShowEnemyPanelStyleAlsoOnPlayer && ciCharacter.moCharacter.controlled)
			{
				if (panelEnemy.bVisible) panelEnemy.SetVisibility(false);
				continue;
			}
			
			if (!ReadObjectFromID(ciCharacter.iCharacterID).GetEnabled())
			{
				if (panelEnemy.bVisible) panelEnemy.SetVisibility(false);
				continue;
			}
			
			if (!bEnemyShowEnemyPanelsForDeadEnemies && ciCharacter.bDead)
			{
				if (panelEnemy.bVisible) panelEnemy.SetVisibility(false);
				continue;
			}
			
			if ((bEnemyScaleWithDistanceToPlayer || bEnemyShowEnemyPanelsOnlyWithinCertainRangeOfEnemies) && distance(camera.GetPos(), ciCharacter.moCharacter.position) >= 15.0f)
			{
				if (panelEnemy.bVisible) panelEnemy.SetVisibility(false);
				continue;
			}
			
			if (bEnemyShowEnemyPanelsOnlyOnVisibleContact && col.GetRayCollision(ReadCharacterID(iPlayerID).position, ciCharacter.moCharacter.position) != ciCharacter.moCharacter.position)
			{
				if (panelEnemy.bVisible) panelEnemy.SetVisibility(false);
				continue;
			}
			
			// Necessary for enemies that got revived and also necessary
			// if panels need to be reactivated again because they have been disabled
			// by the conditions above.
			if (!panelEnemy.bVisible && !ciCharacter.bDead)
			{
				panelEnemy.SetVisibility(true);
			}
			
			vec3 posScreenPosition = CalculateScreenCoordinates(this.guiMain, ciCharacter.moCharacter.position + vec3(0.0f, 1.25f, 0.0f));
			if (posScreenPosition.z < 0.0f) // Means it is behind the camera, so we don't need to draw it.
			{
				if (panelEnemy.bVisible) panelEnemy.SetVisibility(false);
				continue;
			}
			else if (!panelEnemy.bVisible) panelEnemy.SetVisibility(true);
						
			// We export the actual value assignment (health, blood, ...) into the container class
			// because otherwise this loop would look very dirty.
			
			// The built-in base scaling factor because I designed the GUI without actual scaling
			// so we just multiply the size by an initial factor.
			float fScalingFactor = 1.3f;
			
			if (bEnemyScaleWithDistanceToPlayer)
			{
				fScalingFactor = 1.5f - 0.1f * distance(camera.GetPos(), ciCharacter.moCharacter.position);
				
				if (fScalingFactor < 0.0f) fScalingFactor = 0.0f;
			}
			
			panelEnemy.UpdateElements(ciCharacter, fEnemyBaseScalingFactor * fScalingFactor);
			
			this.guiMain.getMain().moveElement(panelEnemy.containerElement.getName(), vec2(posScreenPosition.x, posScreenPosition.y) - panelEnemy.containerElement.getSize() / 2.0f);
		}
	}
	
	void SetVisibility(bool bVisible)
	{		
		for (uint iEnemyPanelIndex = 0; iEnemyPanelIndex < this.aEnemyPanels.length(); ++iEnemyPanelIndex)
			this.aEnemyPanels[iEnemyPanelIndex].SetVisibility(bVisible);
	}
	
	void Reset()
	{
		this.aEnemyPanels.resize(0);
	}
	
	void Resize()
	{
		
	}
	
	void Destroy()
	{
		this.aEnemyPanels.resize(0);
	}
}

class StandardCustomHudEnemyPanelElement
{
	float fBackgroundWidth = 200.0f;
	float fBorderLeftRight = 5.0f;
	float fBorderTopDown = 5.0f;

	float fBarWidth = fBackgroundWidth - 2.0f * fBorderLeftRight;
	float fBarHeight = 10.0f;

	IMGUI@ guiMain;

	bool bVisible;
	int iCharacterID;
	int iPanelIndex;
	bool bCharacterControlled;
	
	vec2 sizePanel;
	
	IMContainer@ containerElement;
	IMImage@ imageBackground;
	
	IMImage@ imageHealthbarMax;
	IMImage@ imageHealthbarTemporaryMax;
	IMImage@ imageHealthbarCurrent;
	
	IMImage@ imageBloodbarMax;
	IMImage@ imageBloodbarCurrent;
	
	IMImage@ imageKOShieldbarMax;
	IMImage@ imageKOShieldbarCurrent;
	
	vec2 posBaseHealth;
	vec2 posBaseBlood;
	vec2 posBaseKOShield;
	
	int iAmountOfElementsToDisplay;
	
	// We can use the destructor here since resizing an array with classes will immediately call
	// the destructors in our case rather than using an explicit method in the panel classes.
	~StandardCustomHudEnemyPanelElement()
	{
		this.guiMain.getMain().removeElement(this.containerElement.getName());
	}
	
	StandardCustomHudEnemyPanelElement(IMGUI@ guiMain, int iCharacterID, int iPanelIndex, bool bCharacterControlled)
	{
		@this.guiMain = guiMain;
		
		this.bVisible = true;
		this.iCharacterID = iCharacterID;
		this.iPanelIndex = iPanelIndex;
		this.bCharacterControlled = bCharacterControlled;
		
		int iBaseZOrder = this.iPanelIndex * 10 + (bCharacterControlled ? 1000 : 0);
		
		this.iAmountOfElementsToDisplay = 0;
		if (bEnemyDisplayHealthPercentage) ++this.iAmountOfElementsToDisplay;
		if (bEnemyDisplayBloodPercentage) ++this.iAmountOfElementsToDisplay;
		if (bEnemyDisplayKOShieldAmount) ++this.iAmountOfElementsToDisplay;
		
		@this.containerElement = IMContainer();
		this.containerElement.setName("containerElement_" + this.iPanelIndex);
		this.containerElement.setSize(sizePanel);
		
		this.guiMain.getMain().addFloatingElement(this.containerElement, this.containerElement.getName(), vec2(0.0f), iBaseZOrder);
				
		// We exit here so we don't add the margins (the background) and since we check for
		// the same condition in UpdateElements, it's OK.
		if (this.iAmountOfElementsToDisplay == 0) return;
		
		sizePanel = vec2(fBackgroundWidth, this.iAmountOfElementsToDisplay * fBarHeight + (this.iAmountOfElementsToDisplay + 1) * fBorderTopDown);
		
		@this.imageBackground = IMImage("Textures/UI/whiteblock.tga");
		this.imageBackground.setColor(vec4(0.0f, 0.0f, 0.0f, 1.0f - fEnemyPanelTransparency));
		this.imageBackground.setSize(sizePanel);
		
		this.containerElement.addFloatingElement(this.imageBackground, "imageBackground", vec2(0.0f), iBaseZOrder + 1);
		
		int iSkippedIndices = 0;
		
		for (uint iHudElementIndex = 0; iHudElementIndex < aEnemyHudOrder.length(); ++iHudElementIndex)
		{
			vec2 posBar(fBorderLeftRight, (iHudElementIndex - iSkippedIndices + 1) * fBorderTopDown + (iHudElementIndex - iSkippedIndices) * fBarHeight);
			
			if (aEnemyHudOrder[iHudElementIndex] == "Health" && bEnemyDisplayHealthPercentage)
			{
				this.posBaseHealth = posBar;
				
				vec4 colorMaxHealth(
					F_MAX_HEALTH_MULTIPLY * colorsCustomColorsHealthEnemy[2].x,
					F_MAX_HEALTH_MULTIPLY * colorsCustomColorsHealthEnemy[2].y,
					F_MAX_HEALTH_MULTIPLY * colorsCustomColorsHealthEnemy[2].z,
					1.0f
				);
				
				vec4 colorTemporaryMaxHealth(
					F_TEMPORARY_MAX_HEALTH_MULTIPLY * colorsCustomColorsHealthEnemy[2].x,
					F_TEMPORARY_MAX_HEALTH_MULTIPLY * colorsCustomColorsHealthEnemy[2].y,
					F_TEMPORARY_MAX_HEALTH_MULTIPLY * colorsCustomColorsHealthEnemy[2].z,
					1.0f
				);
				
				@this.imageHealthbarMax = IMImage("Textures/UI/whiteblock.tga");
				@this.imageHealthbarTemporaryMax = IMImage("Textures/UI/whiteblock.tga");
				@this.imageHealthbarCurrent = IMImage("Textures/UI/whiteblock.tga");
		
				this.imageHealthbarMax.setSize(vec2(fBarWidth, fBarHeight));
				this.imageHealthbarTemporaryMax.setSize(vec2(fBarWidth, fBarHeight));
				this.imageHealthbarCurrent.setSize(vec2(fBarWidth, fBarHeight));
				
				this.imageHealthbarMax.setColor(colorMaxHealth);
				this.imageHealthbarTemporaryMax.setColor(colorTemporaryMaxHealth);
				this.imageHealthbarCurrent.setColor(colorsCustomColorsHealthEnemy[2]);
				
				this.imageHealthbarMax.setAlpha(1.0f - fEnemyPanelTransparency);
				this.imageHealthbarTemporaryMax.setAlpha(1.0f - fEnemyPanelTransparency);
				this.imageHealthbarCurrent.setAlpha(1.0f - fEnemyPanelTransparency);
				
				this.containerElement.addFloatingElement(this.imageHealthbarMax, "imageHealthbarMax", posBar, iBaseZOrder + 2);
				this.containerElement.addFloatingElement(this.imageHealthbarTemporaryMax, "imageHealthbarTemporaryMax", posBar, iBaseZOrder + 3);
				this.containerElement.addFloatingElement(this.imageHealthbarCurrent, "imageHealthbarCurrent", posBar, iBaseZOrder + 4);
			}
			else if (aEnemyHudOrder[iHudElementIndex] == "Blood" && bEnemyDisplayBloodPercentage)
			{
				this.posBaseBlood = posBar;
				
				vec4 colorMaxBlood(
					F_MAX_BLOOD_MULTIPLY * colorsCustomColorsBloodEnemy[2].x,
					F_MAX_BLOOD_MULTIPLY * colorsCustomColorsBloodEnemy[2].y,
					F_MAX_BLOOD_MULTIPLY * colorsCustomColorsBloodEnemy[2].z,
					1.0f
				);
				
				@this.imageBloodbarMax = IMImage("Textures/UI/whiteblock.tga");
				@this.imageBloodbarCurrent = IMImage("Textures/UI/whiteblock.tga");
				
				this.imageBloodbarMax.setSize(vec2(fBarWidth, fBarHeight));
				this.imageBloodbarCurrent.setSize(vec2(fBarWidth, fBarHeight));
				
				this.imageBloodbarMax.setColor(colorMaxBlood);
				this.imageBloodbarCurrent.setColor(colorsCustomColorsBloodEnemy[2]);
				
				this.imageBloodbarMax.setAlpha(1.0f - fEnemyPanelTransparency);
				this.imageBloodbarCurrent.setAlpha(1.0f - fEnemyPanelTransparency);
				
				this.containerElement.addFloatingElement(this.imageBloodbarMax, "imageBloodbarMax", posBar, iBaseZOrder + 2);
				this.containerElement.addFloatingElement(this.imageBloodbarCurrent, "imageBloodbarCurrent", posBar, iBaseZOrder + 3);
			}
			else if (aEnemyHudOrder[iHudElementIndex] == "KO Shield" && bEnemyDisplayKOShieldAmount)
			{
				this.posBaseKOShield = posBar;
				
				vec4 colorMaxKOShield(
					F_MAX_KOSHIELD_MULTIPLY * colorsCustomColorsKOShieldEnemy[2].x,
					F_MAX_KOSHIELD_MULTIPLY * colorsCustomColorsKOShieldEnemy[2].y,
					F_MAX_KOSHIELD_MULTIPLY * colorsCustomColorsKOShieldEnemy[2].z,
					1.0f
				);
					
				@this.imageKOShieldbarMax = IMImage("Textures/UI/whiteblock.tga");
				@this.imageKOShieldbarCurrent = IMImage("Textures/UI/whiteblock.tga");
				
				this.imageKOShieldbarMax.setSize(vec2(fBarWidth, fBarHeight));
				this.imageKOShieldbarCurrent.setSize(vec2(fBarWidth, fBarHeight));
				
				this.imageKOShieldbarMax.setColor(colorMaxKOShield);
				this.imageKOShieldbarCurrent.setColor(colorsCustomColorsKOShieldEnemy[2]);
				
				this.imageKOShieldbarMax.setAlpha(1.0f - fEnemyPanelTransparency);
				this.imageKOShieldbarCurrent.setAlpha(1.0f - fEnemyPanelTransparency);
				
				this.containerElement.addFloatingElement(this.imageKOShieldbarMax, "imageKOShieldbarMax", posBar, iBaseZOrder + 2);
				this.containerElement.addFloatingElement(this.imageKOShieldbarCurrent, "imageKOShieldbarCurrent", posBar, iBaseZOrder + 3);
			}
			else
			{
				++iSkippedIndices;
			}
		}
		
		this.SetVisibility(false);
	}
	
	void UpdateElements(CharacterInformation& ciCharacter, float fScalingFactor)
	{
		if (this.iAmountOfElementsToDisplay == 0) return;
		
		this.containerElement.setSize(sizePanel * fScalingFactor);
		this.imageBackground.setSize(sizePanel * fScalingFactor);	
		
		this.imageBackground.setAlpha(1.0f - fEnemyPanelTransparency);
		
		if (bEnemyDisplayHealthPercentage)
		{
			this.MoveAndResizeBar(this.imageHealthbarMax, posBaseHealth, ciCharacter.fTemporaryMaxHealth, 1.0f, fScalingFactor);
			this.MoveAndResizeBar(this.imageHealthbarTemporaryMax, posBaseHealth, ciCharacter.fCurrentHealth, ciCharacter.fTemporaryMaxHealth, fScalingFactor);
			this.MoveAndResizeBar(this.imageHealthbarCurrent, posBaseHealth, 0.0f, ciCharacter.fCurrentHealth, fScalingFactor);
			
			if (bCustomColorsUseStaticColorForEnemyInsteadOfColorGradient)
			{
				vec4 colorMaxHealth(
					F_MAX_HEALTH_MULTIPLY * colorsCustomColorsHealthEnemy[2].x,
					F_MAX_HEALTH_MULTIPLY * colorsCustomColorsHealthEnemy[2].y,
					F_MAX_HEALTH_MULTIPLY * colorsCustomColorsHealthEnemy[2].z,
					1.0f
				);
				
				vec4 colorTemporaryMaxHealth(
					F_TEMPORARY_MAX_HEALTH_MULTIPLY * colorsCustomColorsHealthEnemy[2].x,
					F_TEMPORARY_MAX_HEALTH_MULTIPLY * colorsCustomColorsHealthEnemy[2].y,
					F_TEMPORARY_MAX_HEALTH_MULTIPLY * colorsCustomColorsHealthEnemy[2].z,
					1.0f
				);
			
				this.imageHealthbarMax.setColor(colorMaxHealth);
				this.imageHealthbarTemporaryMax.setColor(colorTemporaryMaxHealth);
				this.imageHealthbarCurrent.setColor(colorsCustomColorsHealthEnemy[2]);
			}
			else
			{
				if (ciCharacter.bDead)
				{
					this.imageHealthbarMax.setColor(COLOR_DEAD);
					this.imageHealthbarTemporaryMax.setColor(COLOR_DEAD);
					this.imageHealthbarCurrent.setColor(COLOR_CURRENT_DEAD);
				}
				else
				{
					vec4 colorMaxHealth(
						F_MAX_HEALTH_MULTIPLY * colorsCustomColorsHealthEnemy[2].x,
						F_MAX_HEALTH_MULTIPLY * colorsCustomColorsHealthEnemy[2].y,
						F_MAX_HEALTH_MULTIPLY * colorsCustomColorsHealthEnemy[2].z,
						1.0f
					);
					
					vec4 colorTemporaryMaxHealth(
						F_TEMPORARY_MAX_HEALTH_MULTIPLY * colorsCustomColorsHealthEnemy[2].x,
						F_TEMPORARY_MAX_HEALTH_MULTIPLY * colorsCustomColorsHealthEnemy[2].y,
						F_TEMPORARY_MAX_HEALTH_MULTIPLY * colorsCustomColorsHealthEnemy[2].z,
						1.0f
					);
				
					this.imageHealthbarMax.setColor(colorMaxHealth);
					this.imageHealthbarTemporaryMax.setColor(colorTemporaryMaxHealth);
					this.imageHealthbarCurrent.setColor(
						GetStatusbarColor(
							ciCharacter.fCurrentHealth,
							colorsCustomColorsHealthEnemy[0],
							colorsCustomColorsHealthEnemy[1],
							colorsCustomColorsHealthEnemy[2]
						)
					);
				}
			}
			
			this.imageHealthbarMax.setAlpha(1.0f - fEnemyPanelTransparency);
			this.imageHealthbarTemporaryMax.setAlpha(1.0f - fEnemyPanelTransparency);
			this.imageHealthbarCurrent.setAlpha(1.0f - fEnemyPanelTransparency);
		}
		
		if (bEnemyDisplayBloodPercentage)
		{
			this.MoveAndResizeBar(this.imageBloodbarMax, posBaseBlood, ciCharacter.fCurrentBlood, 1.0f, fScalingFactor);
			this.MoveAndResizeBar(this.imageBloodbarCurrent, posBaseBlood, 0.0f, ciCharacter.fCurrentBlood, fScalingFactor);
			
			if (bCustomColorsUseStaticColorForEnemyInsteadOfColorGradient)
			{
				vec4 colorMaxBlood(
					F_MAX_BLOOD_MULTIPLY * colorsCustomColorsBloodEnemy[2].x,
					F_MAX_BLOOD_MULTIPLY * colorsCustomColorsBloodEnemy[2].y,
					F_MAX_BLOOD_MULTIPLY * colorsCustomColorsBloodEnemy[2].z,
					1.0f
				);
			
				this.imageBloodbarMax.setColor(colorMaxBlood);
				this.imageBloodbarCurrent.setColor(colorsCustomColorsBloodEnemy[2]);
			}
			else
			{
				if (ciCharacter.bDead)
				{
					this.imageBloodbarMax.setColor(COLOR_DEAD);
					this.imageBloodbarCurrent.setColor(COLOR_CURRENT_DEAD);
				}
				else
				{
					vec4 colorMaxBlood(
						F_MAX_BLOOD_MULTIPLY * colorsCustomColorsBloodEnemy[2].x,
						F_MAX_BLOOD_MULTIPLY * colorsCustomColorsBloodEnemy[2].y,
						F_MAX_BLOOD_MULTIPLY * colorsCustomColorsBloodEnemy[2].z,
						1.0f
					);
				
					this.imageBloodbarMax.setColor(colorMaxBlood);
					this.imageBloodbarCurrent.setColor(
						GetStatusbarColor(
							ciCharacter.fCurrentBlood,
							colorsCustomColorsBloodEnemy[0],
							colorsCustomColorsBloodEnemy[1],
							colorsCustomColorsBloodEnemy[2]
						)
					);
				}
			}
			
			this.imageBloodbarMax.setAlpha(1.0f - fEnemyPanelTransparency);
			this.imageBloodbarCurrent.setAlpha(1.0f - fEnemyPanelTransparency);
		}
		
		if(bEnemyDisplayKOShieldAmount)
		{
			float fKOShieldbarWidth = 0.0f;
			if (ciCharacter.iMaxKOShield > 0) fKOShieldbarWidth = float(ciCharacter.iCurrentKOShield) / float(ciCharacter.iMaxKOShield);
			
			this.MoveAndResizeBar(this.imageKOShieldbarMax, posBaseKOShield, fKOShieldbarWidth, 1.0f, fScalingFactor);
			this.MoveAndResizeBar(this.imageKOShieldbarCurrent, posBaseKOShield, 0.0f, fKOShieldbarWidth, fScalingFactor);
			
			if (bCustomColorsUseStaticColorForEnemyInsteadOfColorGradient)
			{
				vec4 colorMaxKOShield(
					F_MAX_KOSHIELD_MULTIPLY * colorsCustomColorsKOShieldEnemy[2].x,
					F_MAX_KOSHIELD_MULTIPLY * colorsCustomColorsKOShieldEnemy[2].y,
					F_MAX_KOSHIELD_MULTIPLY * colorsCustomColorsKOShieldEnemy[2].z,
					1.0f
				);
			
				this.imageKOShieldbarMax.setColor(colorMaxKOShield);
				this.imageKOShieldbarCurrent.setColor(colorsCustomColorsKOShieldEnemy[2]);
			}
			else
			{
				if (ciCharacter.bDead)
				{
					this.imageKOShieldbarMax.setColor(COLOR_DEAD);
					this.imageKOShieldbarCurrent.setColor(COLOR_CURRENT_DEAD);
				}
				else
				{
					vec4 colorMaxKOShield(
						F_MAX_KOSHIELD_MULTIPLY * colorsCustomColorsKOShieldEnemy[2].x,
						F_MAX_KOSHIELD_MULTIPLY * colorsCustomColorsKOShieldEnemy[2].y,
						F_MAX_KOSHIELD_MULTIPLY * colorsCustomColorsKOShieldEnemy[2].z,
						1.0f
					);
				
					this.imageKOShieldbarMax.setColor(colorMaxKOShield);
					this.imageKOShieldbarCurrent.setColor(
						GetKOShieldbarColor(
							ciCharacter.iCurrentKOShield,
							ciCharacter.iMaxKOShield,
							colorsCustomColorsKOShieldEnemy[0],
							colorsCustomColorsKOShieldEnemy[1],
							colorsCustomColorsKOShieldEnemy[2]
						)
					);
				}
			}
			
			this.imageKOShieldbarMax.setAlpha(1.0f - fEnemyPanelTransparency);
			this.imageKOShieldbarCurrent.setAlpha(1.0f - fEnemyPanelTransparency);
		}
	}
	
	// The fScalingFactor here is separate since the scaling factor live updates without recreating the panels.
	void MoveAndResizeBar(IMImage@ imageBar, vec2 posBase, float fPercentageBegin, float fPercentageEnd, float fScalingFactor)
	{	
		vec2 sizeBar((fPercentageEnd - fPercentageBegin) * fBarWidth, fBarHeight);
		vec2 posBar(posBase.x + fPercentageBegin * fBarWidth, posBase.y);
				
		imageBar.setSize(sizeBar * fScalingFactor);
		this.containerElement.moveElement(imageBar.getName(), posBar * fScalingFactor);
	}
	
	void SetVisibility(bool bVisible)
	{
		this.bVisible = bVisible;
		
		this.containerElement.setVisible(bVisible);
		
		for (uint iElementIndex = 0; iElementIndex < this.containerElement.getFloatingContents().length(); ++iElementIndex)
			this.containerElement.getFloatingContents()[iElementIndex].setVisible(bVisible);
	}
	
	void SetCharacterID(int iCharacterID, bool bCharacterControlled)
	{
		this.iCharacterID = iCharacterID;
		this.bCharacterControlled = bCharacterControlled;
		
		int iBaseZOrder = this.iPanelIndex * 10 + (bCharacterControlled ? 1000 : 0);
		
		this.containerElement.setZOrdering(iBaseZOrder);
		this.imageBackground.setZOrdering(iBaseZOrder + 1);
		
		if (bEnemyDisplayHealthPercentage)
		{
			this.imageHealthbarMax.setZOrdering(iBaseZOrder + 2);
			this.imageHealthbarTemporaryMax.setZOrdering(iBaseZOrder + 3);
			this.imageHealthbarCurrent.setZOrdering(iBaseZOrder + 4);
		}
		
		if (bEnemyDisplayBloodPercentage)
		{
			this.imageBloodbarMax.setZOrdering(iBaseZOrder + 2);
			this.imageBloodbarCurrent.setZOrdering(iBaseZOrder + 3);
		}
		
		if (bEnemyDisplayKOShieldAmount)
		{
			this.imageKOShieldbarMax.setZOrdering(iBaseZOrder + 2);
			this.imageKOShieldbarCurrent.setZOrdering(iBaseZOrder + 3);
		}
	}
}