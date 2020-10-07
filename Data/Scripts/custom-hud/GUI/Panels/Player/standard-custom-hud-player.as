#include "custom-hud/settings-definitions.as"
#include "custom-hud/GUI/Panels/panel.as"

class StandardCustomHudPlayerPanel : Panel
{
	IMGUI@ guiMain;
	
	IMDivider@ divBottom;
	
	IMImage@ imageHealth;
	IMText@ textHealth;
	
	IMImage@ imageBlood;
	IMText@ textBlood;
	
	IMImage@ imageKOShield;
	IMText@ textKOShield;
	
	IMImage@ imageVelocity;
	IMText@ textVelocity;
	
	int iAmountOfElementsToDisplay = 0;
	
	StandardCustomHudPlayerPanel(IMGUI@ guiMain)
	{
		@this.guiMain = guiMain;
		
		@this.divBottom = IMDivider(DividerOrientation(iPlayerPanelOrientation));
		this.guiMain.getMain().addFloatingElement(this.divBottom, "divBottom", vec2(0.0f), I_MAX_Z_ORDER);
		
		@this.imageHealth = IMImage("Images/custom-hud/health.png");	
		this.imageHealth.setSize(this.imageHealth.getSize() * fPlayerScalingFactor);
		
		@this.textHealth = IMText("100", fsPlayerFont);
		
		
		@this.imageBlood = IMImage("Images/custom-hud/blood.png");
		this.imageBlood.setSize(this.imageBlood.getSize() * fPlayerScalingFactor);
		
		@this.textBlood = IMText("100", fsPlayerFont);
		
		
		@this.imageKOShield = IMImage("Images/custom-hud/koshield.png");
		this.imageKOShield.setSize(this.imageKOShield.getSize() * fPlayerScalingFactor);
		
		@this.textKOShield = IMText("10", fsPlayerFont);
		
		
		@this.imageVelocity = IMImage("Images/custom-hud/velocity.png");
		this.imageVelocity.setSize(this.imageVelocity.getSize() * fPlayerScalingFactor);
		
		@this.textVelocity = IMText("00.00", fsPlayerFont);
		
		// The values set here are supposed to resemble the widest (graphically speaking) values
		// So the values will not later move around and extend the GUI when the values are updated to smaller ones.
		
		// Yeah I know this looks terrible, but I'm too lazy to move four elements into a new structure
		// to iterate somewhat "beautiful" over it.
		for (uint iHudIndex = 0; iHudIndex < aPlayerHudOrder.length(); ++iHudIndex)
		{
			if (aPlayerHudOrder[iHudIndex] == "Health" && bPlayerDisplayHealthPercentage)
			{
				this.divBottom.append(imageHealth);
				this.divBottom.append(textHealth);
				++this.iAmountOfElementsToDisplay;
			}
			else if (aPlayerHudOrder[iHudIndex] == "Blood" && bPlayerDisplayBloodPercentage)
			{
				this.divBottom.append(imageBlood);
				this.divBottom.append(textBlood);
				++this.iAmountOfElementsToDisplay;
			}
			else if (aPlayerHudOrder[iHudIndex] == "KO Shield" && bPlayerDisplayKOShieldAmount)
			{
				this.divBottom.append(imageKOShield);
				this.divBottom.append(textKOShield);
				++this.iAmountOfElementsToDisplay;
			}
			else if (aPlayerHudOrder[iHudIndex] == "Velocity" && bPlayerDisplayVelocity)
			{
				this.divBottom.append(imageVelocity);
				this.divBottom.append(textVelocity);
				++this.iAmountOfElementsToDisplay;
			}
		}
		
		if (this.iAmountOfElementsToDisplay == 0) return;
		
		// Needed so the elements get their respective sizes calculated and assigned.
		this.guiMain.update();
		
		float fMaxWidth = 0.0f;
		
		// A bit more compact rather than checking each appended element individually.
		for (uint iElementIndex = 0; iElementIndex < this.divBottom.getContainers().length; ++iElementIndex)
		{
			// this.divBottom.showBorder(true);
			// this.divBottom.getContainerAt(iElementIndex).getContents().showBorder(true);
			fMaxWidth = max(fMaxWidth, this.divBottom.getContainerAt(iElementIndex).getContents().getSizeX());
		}
		
		// We are setting the minimum size to the widest visible element.
		// The reason for this is that we don't want the text elements to resize when
		// number is too short. The text values should not exit the range in order for this to work.
		this.textHealth.setDefaultSize(vec2(fMaxWidth, textHealth.getSizeY()));
		this.textBlood.setDefaultSize(vec2(fMaxWidth, textBlood.getSizeY()));
		this.textKOShield.setDefaultSize(vec2(fMaxWidth, textKOShield.getSizeY()));
		
		this.textHealth.setSize(this.textHealth.getDefaultSize());
		this.textBlood.setSize(this.textBlood.getDefaultSize());
		this.textKOShield.setSize(this.textKOShield.getDefaultSize());
		
		this.guiMain.update();
		
		this.guiMain.getMain().moveElement(this.divBottom.getName(), CalculatePanelPosition());
		
		this.guiMain.update();
		
		// We are not setting the color if bColorByValue/or transparency is set in the constructor since that would blow it just up more.
		// The code for that is in UpdateInformation anyway so we might aswell live with the miscoloring for one frame on creation! :)
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
		
		if (bPlayerDisplayHealthPercentage)
		{
			this.textHealth.setText(formatFloat(ciPlayer.fCurrentHealth * 100.0f, "l"));
			
			if (bPlayerColorByValue)
			{
				if (ciPlayer.bDead) this.textHealth.setColor(COLOR_DEAD);
				else this.textHealth.setColor(GetHealthbarColor(ciPlayer.fCurrentHealth));
			}
			else
			{
				this.textHealth.setColor(vec4(1.0f));
			}
			
			this.imageHealth.setAlpha(1.0f - fPlayerPanelTransparency);
			this.textHealth.setAlpha(1.0f - fPlayerPanelTransparency);
		}
		
		if (bPlayerDisplayBloodPercentage)
		{
			this.textBlood.setText(formatFloat(ciPlayer.fCurrentBlood * 100.0f, "l"));
		
			if (bPlayerColorByValue)
			{
				if (ciPlayer.bDead) this.textBlood.setColor(COLOR_DEAD);
				else this.textBlood.setColor(GetBloodbarColor(ciPlayer.fCurrentBlood));
			}
			else
			{
				this.textBlood.setColor(vec4(1.0f));
			}
			
			this.imageBlood.setAlpha(1.0f - fPlayerPanelTransparency);
			this.textBlood.setAlpha(1.0f - fPlayerPanelTransparency);
		}
		
		if (bPlayerDisplayKOShieldAmount)
		{
			this.textKOShield.setText(formatInt(ciPlayer.iCurrentKOShield, ""));
		
			if (bPlayerColorByValue)
			{
				if (ciPlayer.bDead) this.textKOShield.setColor(COLOR_DEAD);
				else this.textKOShield.setColor(GetKOShieldbarColor(ciPlayer.iCurrentKOShield, ciPlayer.iMaxKOShield));
			}
			else
			{
				this.textKOShield.setColor(vec4(1.0f));
			}
			
			this.imageKOShield.setAlpha(1.0f - fPlayerPanelTransparency);
			this.textKOShield.setAlpha(1.0f - fPlayerPanelTransparency);
		}
		
		if (bPlayerDisplayVelocity)
		{
			this.textVelocity.setText(formatFloat(length(ciPlayer.moCharacter.velocity), "l", 0, 2));
		
			// Velocity is not colorable by value (since the range is inconsistent)
			// We still check for bPlayerColorByValue because you can enable bColorByValue while being dead
			// and that would result in inconsistent coloring.
			if (bPlayerColorByValue && ciPlayer.bDead) this.textVelocity.setColor(COLOR_DEAD);
			else this.textVelocity.setColor(vec4(1.0f));
				
			this.imageVelocity.setAlpha(1.0f - fPlayerPanelTransparency);
			this.textVelocity.setAlpha(1.0f - fPlayerPanelTransparency);
		}	
	}
	
	void SetVisibility(bool bVisible)
	{
		for (uint iElementIndex = 0; iElementIndex < this.divBottom.getContainers().length(); ++iElementIndex)
			this.divBottom.getContainerAt(iElementIndex).getContents().setVisible(bVisible);
	}
	
	void Reset()
	{
		
	}
	
	void Resize()
	{
		this.guiMain.getMain().moveElement(this.divBottom.getName(), CalculatePanelPosition());
	}
	
	void Destroy()
	{
		this.guiMain.getMain().removeElement(this.divBottom.getName());
	}
	
	vec2 CalculatePanelPosition()
	{
		vec2 posPanel;
		
		// The size of the divBottom is set after adding it and updating the GUI.
		switch (iPlayerHorizontalAlignment)
		{
			case CALeft: posPanel.x = 0.0f; break;
			case CACenter: posPanel.x = (this.guiMain.getMain().getSizeX() - this.divBottom.getSizeX()) / 2.0f; break;
			case CARight: posPanel.x = this.guiMain.getMain().getSizeX() - this.divBottom.getSizeX(); break;
		}
		
		switch (iPlayerVerticalAlignment)
		{
			case CATop: posPanel.y = 0.0f; break;
			case CACenter: posPanel.y = (this.guiMain.getMain().getSizeY() - this.divBottom.getSizeY()) / 2.0f; break;
			case CABottom: posPanel.y = this.guiMain.getMain().getSizeY() - this.divBottom.getSizeY(); break;
		}
		
		return posPanel;
	}
}