#include "custom-hud/GUI/default-colors.as"

const string S_MOD_ID = "custom-hud";
const string S_MOD_NAME = "Custom HUD";
const string S_MOD_VERSION = "2.2.0";

const string S_SETTINGS_PREFIX = S_MOD_ID + "-";

const vec2 SIZE_SETTINGS_GUI(630.0f, 450.0f);

bool bShowSettings = false;

SettingsTab stSelectedTab = StGeneralSettings;

enum SettingsTab
{
	StGeneralSettings,
	StPlayerInformation,
	StEnemyInformation,
	StCustomColors,
	StAboutAndHelp
};

enum PlayerHudStyles
{
	PhsStandardCustomHud,
	PhsStatusbars
};

const array<string> A_PLAYER_PANEL_STYLES = {
	"Standard Custom HUD style",
	"Statusbars style"
};

const array<string> A_FONTS = {
	"Arial",
	"Arialbd",
	"Cella",
	"edosz",
	"Inconsolata",
	"Lato-Regular",
	"OpenSans-Regular",
	"OptimusPrinceps",
	"Underdog-Regular"
};

// ===== General Settings =====
bool bEnableCustomHud = true;
bool bShowPlayerPanel = true;
bool bShowEnemyPanel = true;
bool bShowDuringDialogues = false;

bool bShowTooltipsInTheSettingsWindow = true;
// ============================

// ===== Player Information Settings =====
const float F_PLAYER_BASE_FONT_SIZE = 128.0f;

const TextureAssetRef TEXTURE_HEALTH = LoadTexture("Data/Images/custom-hud/health.png");
const TextureAssetRef TEXTURE_BLOOD = LoadTexture("Data/Images/custom-hud/blood.png");
const TextureAssetRef TEXTURE_KOSHIELD = LoadTexture("Data/Images/custom-hud/koshield.png");
const TextureAssetRef TEXTURE_VELOCITY = LoadTexture("Data/Images/custom-hud/velocity.png");

int iPlayerPanelStyle = 0;

bool bPlayerDisplayHealthPercentage = true;
bool bPlayerDisplayBloodPercentage = true;
bool bPlayerDisplayKOShieldAmount = true;
bool bPlayerDisplayVelocity = true;

int iPlayerSelectedHudOrderIndex = 0;

float fPlayerScalingFactor = 1.0f;
int iPlayerHorizontalAlignment = CACenter;
int iPlayerVerticalAlignment = CABottom;
int iPlayerPanelOrientation = DOHorizontal;
int iPlayerFont = 3;
bool bPlayerFontShadow = true;

FontSetup fsPlayerFont("edosz", int(F_PLAYER_BASE_FONT_SIZE * fPlayerScalingFactor), vec4(1.0f), bPlayerFontShadow);

float fPlayerPanelTransparency = 0.0f;

array<string> aPlayerHudOrder = { "Health", "Blood", "KO Shield", "Velocity" };
// =======================================

// ===== Enemy Information Settings ======
bool bEnemyDisplayHealthPercentage = true;
bool bEnemyDisplayBloodPercentage = true;
bool bEnemyDisplayKOShieldAmount = true;

bool bEnemyScaleWithDistanceToPlayer = true;
bool bEnemyShowEnemyPanelStyleAlsoOnPlayer = false;
bool bEnemyShowEnemyPanelsForDeadEnemies = true;
bool bEnemyShowEnemyPanelsAlsoForAllies = true;
bool bEnemyShowEnemyPanelsOnlyWithinCertainRangeOfEnemies = false;
bool bEnemyShowEnemyPanelsOnlyOnVisibleContact = false;

int iEnemySelectedHudOrderIndex = 0;

float fEnemyBaseScalingFactor = 1.0f;

float fEnemyPanelTransparency = 0.0f;

array<string> aEnemyHudOrder = { "Health", "Blood", "KO Shield" };
// =======================================

// ===== Custom Colors =====
bool bCustomColorsUseStaticColorForPlayerInsteadOfColorGradient = false;
bool bCustomColorsUseStaticColorForEnemyInsteadOfColorGradient = false;

array<vec4> colorsCustomColorsHealthPlayer = COLORS_DEFAULT_HEALTH;
array<vec4> colorsCustomColorsHealthEnemy = COLORS_DEFAULT_HEALTH;

array<vec4> colorsCustomColorsBloodPlayer = COLORS_DEFAULT_BLOOD;
array<vec4> colorsCustomColorsBloodEnemy = COLORS_DEFAULT_BLOOD;

array<vec4> colorsCustomColorsKOShieldPlayer = COLORS_DEFAULT_KOSHIELD;
array<vec4> colorsCustomColorsKOShieldEnemy = COLORS_DEFAULT_KOSHIELD;

array<vec4> colorsCustomColorsVelocityPlayer = COLORS_DEFAULT_VELOCITY;
// ======================
