// A wrapper class so we can read out information like health and blood without having to
// execute code each time we want to read it.
// We might aswell do it once, and let the hud panels read out the class attributes.
class CharacterInformation
{
	int iCharacterID;
	bool bDead;

	float fCurrentHealth;
	float fTemporaryMaxHealth;
	float fMaxHealth; 
	
	float fCurrentBlood;
	float fMaxBlood; 
	
	int iCurrentKOShield;
	int iMaxKOShield;
	
	MovementObject@ moCharacter;
	
	CharacterInformation() { }
	
	CharacterInformation(MovementObject@ moCharacter)
	{
		// Theoretically this is kinda of unnecessary since we have the moCharacter in the class,
		// but since this ID is being used very frequently, we can avoid calling GetID and simply read out the integer.
		this.iCharacterID = moCharacter.GetID();
	
		int iPlayerKnockedOut = moCharacter.GetIntVar("knocked_out");
		this.bDead = iPlayerKnockedOut == _dead || iPlayerKnockedOut == _unconscious;
		
		this.fCurrentHealth = moCharacter.GetFloatVar("temp_health");
		if (this.fCurrentHealth < 0.0f) this.fCurrentHealth = 0.0f;
		
		this.fTemporaryMaxHealth = moCharacter.GetFloatVar("permanent_health");
		if (this.fTemporaryMaxHealth < 0.0f) this.fTemporaryMaxHealth = 0.0f;
		
		this.fMaxHealth = 1.0f; // Magic Number in aschar.as, might need fix in future revisions!
		
		this.fCurrentBlood = moCharacter.GetFloatVar("blood_health");
		if (this.fCurrentBlood < 0.0f) this.fCurrentBlood = 0.0f;
		
		this.fMaxBlood = 1.0f; // See fMaxHealth above
		
		this.iCurrentKOShield = moCharacter.GetIntVar("ko_shield");
		this.iMaxKOShield = moCharacter.GetIntVar("max_ko_shield");
		
		@this.moCharacter = moCharacter;
	}
}