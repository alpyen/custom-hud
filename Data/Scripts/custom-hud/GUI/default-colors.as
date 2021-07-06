const vec4 COLOR_MAX_HEALTH(0.0f, 0.4f, 0.0f, 1.0f);
const vec4 COLOR_TEMPORARY_MAX_HEALTH(0.0f, 0.6f, 0.0f, 1.0f);
const vec4 COLOR_CURRENT_HEALTH(0.0f, 1.0f, 0.0f, 1.0f);

const vec4 COLOR_MAX_BLOOD(0.4f, 0.0f, 0.0f, 1.0f);
const vec4 COLOR_CURRENT_BLOOD(1.0f, 0.0f, 0.0f, 1.0f);

const vec4 COLOR_MAX_KOSHIELD(0.0f, 0.0f, 0.6f, 1.0f);
const vec4 COLOR_CURRENT_KOSHIELD(0.0f, 0.0f, 1.0f, 1.0f);

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