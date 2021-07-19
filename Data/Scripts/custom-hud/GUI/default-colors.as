// The bar color multipliers
// The max health multiply should darken the colorsCustomColorsPlayerHealth and such
const float F_MAX_HEALTH_MULTIPLY = 0.4f;
const float F_TEMPORARY_MAX_HEALTH_MULTIPLY = 0.6f;
// const float F_CURRENT_HEALTH_MULTIPLY = 1.0f; // Obviously...

const float F_MAX_BLOOD_MULTIPLY = 0.4f;
// const float F_CURRENT_BLOOD_MULTIPLY = 1.0f;

const float F_MAX_KOSHIELD_MULTIPLY = 0.6f;
// const float F_CURRENT_KOSHIELD_MULTIPLY = 1.0f

const vec4 COLOR_DEAD(0.2f, 0.2f, 0.2f, 1.0f);
const vec4 COLOR_CURRENT_DEAD(0.4f, 0.4f, 0.4f, 1.0f);

// Default color gradients (LOW, MID, HIGH)

const array<vec4> COLORS_DEFAULT_HEALTH = {
	vec4(1.0f, 0.0f, 0.0f, 1.0f),
	vec4(1.0f, 1.0f, 0.0f, 1.0f),
	vec4(0.0f, 1.0f, 0.0f, 1.0f)
};

const array<vec4> COLORS_DEFAULT_BLOOD = {
	vec4(0.6f, 0.0f, 0.0f, 1.0f),
	vec4(0.8f, 0.0f, 0.0f, 1.0f),
	vec4(1.0f, 0.0f, 0.0f, 1.0f)
};

const array<vec4> COLORS_DEFAULT_KOSHIELD = {
	vec4(1.0f, 1.0f, 1.0f, 1.0f),
	vec4(0.5f, 0.5f, 1.0f, 1.0f),
	vec4(0.0f, 0.0f, 1.0f, 1.0f)
};

const array<vec4> COLORS_DEFAULT_VELOCITY = {
	vec4(1.0f, 1.0f, 1.0f, 1.0f),
	vec4(1.0f, 1.0f, 0.0f, 1.0f),
	vec4(1.0f, 0.3f, 0.0f, 1.0f)
};

// Used for Health, Blood and Velocity
vec4 GetStatusbarColor(float fStatusValue, vec4& colorLowStatusValue, vec4& colorMediumStatusValue, vec4& colorHighStatusValue)
{
	fStatusValue = max(0.0f, min(1.0f, fStatusValue));

	if (fStatusValue >= 0.5f)
	{
		vec3 colorHigh(colorHighStatusValue.x, colorHighStatusValue.y, colorHighStatusValue.z);
		colorHigh *= min(1.0f, ((fStatusValue - 0.5f) * 2.0f));
		
		vec3 colorMid(colorMediumStatusValue.x, colorMediumStatusValue.y, colorMediumStatusValue.z);
		colorMid *= min(1.0f, (1.0f - (fStatusValue - 0.5f) * 2.0f));
		
		return vec4(colorHigh + colorMid, 1.0f);
	}
	else // (fStatusValue < 0.5f)
	{
		vec3 colorMid(colorMediumStatusValue.x, colorMediumStatusValue.y, colorMediumStatusValue.z);
		colorMid *= min(1.0f, fStatusValue * 2.0f);
		
		vec3 colorLow(colorLowStatusValue.x, colorLowStatusValue.y, colorLowStatusValue.z);
		colorLow *= min(1.0f, 1.0f - fStatusValue * 2.0f);
		
		return vec4(colorMid + colorLow, 1.0f);
	}
}

vec4 GetKOShieldbarColor(int iCurrentKOShield, int iMaxKOShield, vec4& colorLowKOShield, vec4& colorMediumKOShield, vec4& colorHighKOShield)
{
	return GetStatusbarColor(
		(iMaxKOShield == 0) ? 0.0f : float(iCurrentKOShield) / float(iMaxKOShield),
		colorLowKOShield,
		colorMediumKOShield,
		colorHighKOShield
	);
}
