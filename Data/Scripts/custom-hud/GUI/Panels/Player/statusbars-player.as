#include "custom-hud/settings-definitions.as"
#include "custom-hud/GUI/Panels/panel.as"

class StatusbarsPlayerPanel : Panel
{
	float fBackgroundWidth = 600.0f * fPlayerScalingFactor;
	float fBorderLeftRight = 10.0f * fPlayerScalingFactor;
	float fBorderTopDown = 10.0f * fPlayerScalingFactor;

	float fBarWidth = fBackgroundWidth - 2.0f * fBorderLeftRight;
	float fBarHeight = 40.0f * fPlayerScalingFactor;
	
	float fPanelHorizontalOffset = 100.0f - 100.0f * (fPlayerScalingFactor / 2.0f);
	float fPanelVerticalOffset = 100.0f - 100.0f * (fPlayerScalingFactor / 2.0f);

	FontSetup fsGuiFont;

	IMGUI@ guiMain;

	IMContainer@ containerPanel;

	IMImage@ imageBackground;


	IMImage@ imageHealthbarMax;
	IMImage@ imageHealthbarTemporaryMax;
	IMImage@ imageHealthbarCurrent;
	
	IMImage@ imageHealth;
	IMText@ textHealth;
	
	
	IMImage@ imageBloodbarMax;
	IMImage@ imageBloodbarCurrent;
	
	IMImage@ imageBlood;
	IMText@ textBlood;
	
	
	IMImage@ imageKOShieldbarMax;
	IMImage@ imageKOShieldbarCurrent;
	
	IMImage@ imageKOShield;
	IMText@ textKOShield;
	
	vec2 posBaseHealth;
	vec2 posBaseBlood;
	vec2 posBaseKOShield;
	
	int iAmountOfElementsToDisplay;

	StatusbarsPlayerPanel(IMGUI@ guiMain)
	{
		this.fsGuiFont = FontSetup(fsPlayerFont.fontName, int(fBarHeight), fsPlayerFont.color, fsPlayerFont.shadowed);
		
		@this.guiMain = guiMain;
		
		this.iAmountOfElementsToDisplay = 0;
		if (bPlayerDisplayHealthPercentage) ++this.iAmountOfElementsToDisplay;
		if (bPlayerDisplayBloodPercentage) ++this.iAmountOfElementsToDisplay;
		if (bPlayerDisplayKOShieldAmount) ++this.iAmountOfElementsToDisplay;
		
		vec2 sizePanel(fBackgroundWidth, this.iAmountOfElementsToDisplay * fBarHeight + (this.iAmountOfElementsToDisplay + 1) * fBorderTopDown);
		if (iPlayerPanelOrientation == DOVertical) sizePanel = vec2(sizePanel.y, sizePanel.x);
		
		@this.containerPanel = IMContainer();
		this.containerPanel.setSize(sizePanel);
		this.guiMain.getMain().addFloatingElement(this.containerPanel, "containerPanel", vec2(0.0f), I_MAX_Z_ORDER);
		
		// We exit here so we don't add the margins (the background) and since we check for
		// the same condition in UpdateElements, it's OK.
		if (this.iAmountOfElementsToDisplay == 0) return;
		
		@this.imageBackground = IMImage("Textures/UI/whiteblock.tga");
		this.imageBackground.setSize(sizePanel);
		this.imageBackground.setColor(vec4(0.0f, 0.0f, 0.0f, 1.0f));
		this.containerPanel.addFloatingElement(this.imageBackground, "imageBackground", vec2(0.0f), I_MAX_Z_ORDER + 1);
		
		int iSkippedIndices = 0;
		
		for (uint iHudElementIndex = 0; iHudElementIndex < aPlayerHudOrder.length(); ++iHudElementIndex)
		{
			vec2 posBar(fBorderLeftRight, (iHudElementIndex - iSkippedIndices + 1) * fBorderTopDown + (iHudElementIndex - iSkippedIndices) * fBarHeight);
			
			if (aPlayerHudOrder[iHudElementIndex] == "Health" && bPlayerDisplayHealthPercentage)
			{
				this.posBaseHealth = posBar;
				
				@this.imageHealthbarMax = IMImage("Textures/UI/whiteblock.tga");
				@this.imageHealthbarTemporaryMax = IMImage("Textures/UI/whiteblock.tga");
				@this.imageHealthbarCurrent = IMImage("Textures/UI/whiteblock.tga");
				@this.imageHealth = IMImage("Images/custom-hud/health.png");
				@this.textHealth = IMText("100", this.fsGuiFont);
				
				this.imageHealth.setSize(vec2(fBarHeight, fBarHeight));
				
				this.containerPanel.addFloatingElement(this.imageHealthbarMax, "imageHealthbarMax", posBar, I_MAX_Z_ORDER + 2);
				this.containerPanel.addFloatingElement(this.imageHealthbarTemporaryMax, "imageHealthbarTemporaryMax", posBar, I_MAX_Z_ORDER + 3);
				this.containerPanel.addFloatingElement(this.imageHealthbarCurrent, "imageHealthbarCurrent", posBar, I_MAX_Z_ORDER + 4);
				
				vec2 posHealth(posBar);
				if (iPlayerPanelOrientation == DOVertical) posHealth = vec2(posHealth.y, fBarWidth - posHealth.x - 2.0f * fBorderLeftRight);
				
				this.containerPanel.addFloatingElement(this.imageHealth, "imageHealth", posHealth, I_MAX_Z_ORDER + 5);
				
				if (iPlayerPanelOrientation == DOHorizontal)
				{
					// The text value will not fit nicely into the vertical orientation so we leave it out.
					this.containerPanel.addFloatingElement(this.textHealth, "textHealth", posBar + vec2(this.imageHealth.getSizeX() + fBorderLeftRight, 0.0f), I_MAX_Z_ORDER + 6);
				}
			}
			else if (aPlayerHudOrder[iHudElementIndex] == "Blood" && bPlayerDisplayBloodPercentage)
			{
				this.posBaseBlood = posBar;
				
				@this.imageBloodbarMax = IMImage("Textures/UI/whiteblock.tga");
				@this.imageBloodbarCurrent = IMImage("Textures/UI/whiteblock.tga");
				@this.imageBlood = IMImage("Images/custom-hud/blood.png");
				@this.textBlood = IMText("100", this.fsGuiFont);
				
				this.imageBlood.setSize(vec2(fBarHeight, fBarHeight));
				
				this.containerPanel.addFloatingElement(this.imageBloodbarMax, "imageBloodbarMax", posBar, I_MAX_Z_ORDER + 2);
				this.containerPanel.addFloatingElement(this.imageBloodbarCurrent, "imageBloodbarCurrent", posBar, I_MAX_Z_ORDER + 3);			

				vec2 posBlood(posBar);
				if (iPlayerPanelOrientation == DOVertical) posBlood = vec2(posBlood.y, fBarWidth - posBlood.x - 2.0f * fBorderLeftRight);
				this.containerPanel.addFloatingElement(this.imageBlood, "imageBlood", posBlood, I_MAX_Z_ORDER + 4);
				
				if(iPlayerPanelOrientation == DOHorizontal)
				{
					this.containerPanel.addFloatingElement(this.textBlood, "textBlood", posBar + vec2(this.imageBlood.getSizeX() + fBorderLeftRight, 0.0f), I_MAX_Z_ORDER + 4);
				}
			}
			else if (aPlayerHudOrder[iHudElementIndex] == "KO Shield" && bPlayerDisplayKOShieldAmount)
			{
				this.posBaseKOShield = posBar;
				
				@this.imageKOShieldbarMax = IMImage("Textures/UI/whiteblock.tga");
				@this.imageKOShieldbarCurrent = IMImage("Textures/UI/whiteblock.tga");
				@this.imageKOShield = IMImage("Images/custom-hud/koshield.png");	
				@this.textKOShield = IMText("100", this.fsGuiFont);
				
				this.imageKOShield.setSize(vec2(fBarHeight, fBarHeight));
				
				this.containerPanel.addFloatingElement(this.imageKOShieldbarMax, "imageKOShieldbarMax", posBar, I_MAX_Z_ORDER + 2);				
				this.containerPanel.addFloatingElement(this.imageKOShieldbarCurrent, "imageKOShieldbarCurrent", posBar, I_MAX_Z_ORDER + 3);
				
				vec2 posKOShield(posBar);
				if (iPlayerPanelOrientation == DOVertical) posKOShield = vec2(posKOShield.y, fBarWidth - posKOShield.x - 2.0f * fBorderLeftRight);
				this.containerPanel.addFloatingElement(this.imageKOShield, "imageKOShield", posKOShield, I_MAX_Z_ORDER + 4);
				
				if (iPlayerPanelOrientation == DOHorizontal)
				{
					this.containerPanel.addFloatingElement(this.textKOShield, "textKOShield", posBar + vec2(this.imageKOShield.getSizeX() + fBorderLeftRight, 0.0f), I_MAX_Z_ORDER + 4);
				}
			}
			else
			{
				++iSkippedIndices;
			}
		}
		
		this.guiMain.getMain().moveElement(this.containerPanel.getName(), CalculatePanelPosition());
	}	
	
	void UpdateInformation(array<CharacterInformation> ciCharacters)
	{
		if (this.iAmountOfElementsToDisplay == 0) return;
	
		CharacterInformation ciPlayer;
			
		for (uint iCharacterIndex = 0; iCharacterIndex < ciCharacters.length(); ++iCharacterIndex)
		{
			if (ciCharacters[iCharacterIndex].moCharacter.controlled && ciCharacters[iCharacterIndex].moCharacter.controller_id == 0)
			{
				ciPlayer = ciCharacters[iCharacterIndex];
				break;
			}
		}
		
		this.imageBackground.setAlpha(1.0f - fPlayerPanelTransparency);
		
		if (bPlayerDisplayHealthPercentage)
		{
			this.MoveAndResizeBar(this.imageHealthbarMax, posBaseHealth, ciPlayer.fTemporaryMaxHealth, 1.0f);
			this.MoveAndResizeBar(this.imageHealthbarTemporaryMax, posBaseHealth, ciPlayer.fCurrentHealth, ciPlayer.fTemporaryMaxHealth);
			this.MoveAndResizeBar(this.imageHealthbarCurrent, posBaseHealth, 0.0f, ciPlayer.fCurrentHealth);
			
			// We should check to see what orientation we have since we are not adding the text values on the vertical position
			// but that clutters up the code and saves almost no performance.
			this.textHealth.setText(formatFloat(ciPlayer.fCurrentHealth * 100.0f, "l"));
			
			if (bPlayerColorByValue)
			{
				if (ciPlayer.bDead)
				{
					this.imageHealthbarMax.setColor(COLOR_DEAD);
					this.imageHealthbarTemporaryMax.setColor(COLOR_DEAD);
					this.imageHealthbarCurrent.setColor(COLOR_CURRENT_DEAD);
				}
				else
				{
					this.imageHealthbarMax.setColor(COLOR_MAX_HEALTH);
					this.imageHealthbarTemporaryMax.setColor(COLOR_TEMPORARY_MAX_HEALTH);
					this.imageHealthbarCurrent.setColor(GetHealthbarColor(ciPlayer.fCurrentHealth));					
				}
			}
			else
			{
				this.imageHealthbarMax.setColor(COLOR_MAX_HEALTH);
				this.imageHealthbarTemporaryMax.setColor(COLOR_TEMPORARY_MAX_HEALTH);
				this.imageHealthbarCurrent.setColor(COLOR_CURRENT_HEALTH);
			}
			
			this.imageHealthbarMax.setAlpha(1.0f - fPlayerPanelTransparency);
			this.imageHealthbarTemporaryMax.setAlpha(1.0f - fPlayerPanelTransparency);
			this.imageHealthbarCurrent.setAlpha(1.0f - fPlayerPanelTransparency);
			this.imageHealth.setAlpha(1.0f - fPlayerPanelTransparency);
			this.textHealth.setAlpha(1.0f - fPlayerPanelTransparency);
		}
		
		if (bPlayerDisplayBloodPercentage)
		{
			this.MoveAndResizeBar(this.imageBloodbarMax, posBaseBlood, ciPlayer.fCurrentBlood, 1.0f);
			this.MoveAndResizeBar(this.imageBloodbarCurrent, posBaseBlood, 0.0f, ciPlayer.fCurrentBlood);
		
			this.textBlood.setText(formatFloat(ciPlayer.fCurrentBlood * 100.0f, "l"));
			
			if (bPlayerColorByValue)
			{
				if (ciPlayer.bDead)
				{
					this.imageBloodbarMax.setColor(COLOR_DEAD);
					this.imageBloodbarCurrent.setColor(COLOR_CURRENT_DEAD);
				}
				else
				{
					this.imageBloodbarMax.setColor(COLOR_MAX_BLOOD);
					this.imageBloodbarCurrent.setColor(GetBloodbarColor(ciPlayer.fCurrentBlood));					
				}
			}
			else
			{
				this.imageBloodbarMax.setColor(COLOR_MAX_BLOOD);
				this.imageBloodbarCurrent.setColor(COLOR_CURRENT_BLOOD);
			}
			
			this.imageBloodbarMax.setAlpha(1.0f - fPlayerPanelTransparency);
			this.imageBloodbarCurrent.setAlpha(1.0f - fPlayerPanelTransparency);
			this.imageBlood.setAlpha(1.0f - fPlayerPanelTransparency);
			this.textBlood.setAlpha(1.0f - fPlayerPanelTransparency);
		}
		
		if (bPlayerDisplayKOShieldAmount)
		{
			float fKOShieldbarWidth = 0.0f;
			if (ciPlayer.iMaxKOShield > 0) fKOShieldbarWidth = float(ciPlayer.iCurrentKOShield) / float(ciPlayer.iMaxKOShield);
			
			this.MoveAndResizeBar(this.imageKOShieldbarMax, posBaseKOShield, fKOShieldbarWidth, 1.0f);
			this.MoveAndResizeBar(this.imageKOShieldbarCurrent, posBaseKOShield, 0.0f, fKOShieldbarWidth);
			
			this.textKOShield.setText(formatFloat(ciPlayer.iCurrentKOShield, "l"));
			
			if (bPlayerColorByValue)
			{
				if (ciPlayer.bDead)
				{
					this.imageKOShieldbarMax.setColor(COLOR_DEAD);
					this.imageKOShieldbarCurrent.setColor(COLOR_CURRENT_DEAD);
				}
				else
				{
					this.imageKOShieldbarMax.setColor(COLOR_MAX_KOSHIELD);
					this.imageKOShieldbarCurrent.setColor(GetKOShieldbarColor(ciPlayer.iCurrentKOShield, ciPlayer.iMaxKOShield));					
				}
			}
			else
			{
				this.imageKOShieldbarMax.setColor(COLOR_MAX_KOSHIELD);
				this.imageKOShieldbarCurrent.setColor(COLOR_CURRENT_KOSHIELD);
			}
			
			this.imageKOShieldbarMax.setAlpha(1.0f - fPlayerPanelTransparency);
			this.imageKOShieldbarCurrent.setAlpha(1.0f - fPlayerPanelTransparency);
			this.imageKOShield.setAlpha(1.0f - fPlayerPanelTransparency);
			this.textKOShield.setAlpha(1.0f - fPlayerPanelTransparency);
		}
	}
	
	void MoveAndResizeBar(IMImage@ imageBar, vec2 posBase, float fPercentageBegin, float fPercentageEnd)
	{	
		vec2 sizeBar((fPercentageEnd - fPercentageBegin) * fBarWidth, fBarHeight);
		vec2 posBar(posBase.x + fPercentageBegin * fBarWidth, posBase.y);
		
		if (iPlayerPanelOrientation == DOVertical)
		{
			sizeBar = vec2(sizeBar.y, sizeBar.x);
			posBar = vec2(posBar.y, posBase.x + (1.0f - fPercentageBegin) * fBarWidth - sizeBar.y);
		}
		
		imageBar.setSize(sizeBar);
		this.containerPanel.moveElement(imageBar.getName(), posBar);
	}
	
	void SetVisibility(bool bVisible)
	{
		this.containerPanel.setVisible(bVisible);
		
		for (uint iElementIndex = 0; iElementIndex < this.containerPanel.getFloatingContents().length(); ++iElementIndex)
			this.containerPanel.getFloatingContents()[iElementIndex].setVisible(bVisible);
	}
	
	void Reset()
	{
		
	}
	
	void Resize()
	{
		this.guiMain.getMain().moveElement(this.containerPanel.getName(), CalculatePanelPosition());
	}
	
	void Destroy()
	{
		this.guiMain.getMain().removeElement(this.containerPanel.getName());
	}
	
	vec2 CalculatePanelPosition()
	{
		vec2 posPanel;
		
		// The size of the divBottom is set after adding it and updating the GUI.
		switch (iPlayerHorizontalAlignment)
		{
			case CALeft: posPanel.x = fPanelHorizontalOffset; break;
			case CACenter: posPanel.x = (this.guiMain.getMain().getSizeX() - this.containerPanel.getSizeX()) / 2.0f; break;
			case CARight: posPanel.x = this.guiMain.getMain().getSizeX() - this.containerPanel.getSizeX() - fPanelHorizontalOffset; break;
		}
		
		switch (iPlayerVerticalAlignment)
		{
			case CATop: posPanel.y = fPanelVerticalOffset; break;
			case CACenter: posPanel.y = (this.guiMain.getMain().getSizeY() - this.containerPanel.getSizeY()) / 2.0f; break;
			case CABottom: posPanel.y = this.guiMain.getMain().getSizeY() - this.containerPanel.getSizeY() - fPanelVerticalOffset; break;
		}
		
		return posPanel;
	}
}