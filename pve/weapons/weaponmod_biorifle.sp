#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <emitsoundany>
#include <smlib>

#include <custom_weapon_mod.inc>

#define ROLEPLAY
#if defined ROLEPLAY
#include <colors_csgo>
#include <roleplay>
#endif

char g_szFullName[PLATFORM_MAX_PATH] =	"Pistolet bioniques";
char g_szName[PLATFORM_MAX_PATH] 	 =	"biorifle";
char g_szReplace[PLATFORM_MAX_PATH]  =	"weapon_negev";

char g_szVModel[PLATFORM_MAX_PATH] =	"models/weapons/tsx/bio_rifle/v_bio_rifle.mdl";
char g_szWModel[PLATFORM_MAX_PATH] =	"models/weapons/tsx/bio_rifle/w_bio_rifle.mdl";
char g_szTModel[PLATFORM_MAX_PATH] =	"models/weapons/tsx/bio_rifle/biomass.mdl";

char g_szMaterials[][PLATFORM_MAX_PATH] = {
	"materials/models/weapons/tsx/bio_rifle/BioRifleGlass0.vmt",
	"materials/models/weapons/tsx/bio_rifle/BioRifleGlass0.vtf",
	"materials/models/weapons/tsx/bio_rifle/BioRifleTex0.vmt",
	"materials/models/weapons/tsx/bio_rifle/BioRifleTex0.vtf",
	"materials/models/weapons/tsx/bio_rifle/BioRifleTex1.vmt",
	"materials/models/weapons/tsx/bio_rifle/BioRifleTex1.vtf",
	"materials/models/weapons/tsx/bio_rifle/BioRifleTex2.vmt",
	"materials/models/weapons/tsx/bio_rifle/BioRifleTex2.vtf",
	"materials/models/weapons/tsx/bio_rifle/BioRifleTex3.vmt",
	"materials/models/weapons/tsx/bio_rifle/BioRifleTex3.vtf",
	"materials/models/weapons/tsx/bio_rifle/BioRifleTex4.vmt",
	"materials/models/weapons/tsx/bio_rifle/BioRifleTex4.vtf",
	"materials/models/weapons/tsx/bio_rifle/BRInnerGoo.vmt",
	"materials/models/weapons/tsx/bio_rifle/BRInnerGoo.vtf",
	"materials/models/weapons/tsx/bio_rifle/BRInnerGoo1.vmt",
	"materials/models/weapons/tsx/bio_rifle/BRInnerGoo1.vtf",
	"materials/models/weapons/tsx/bio_rifle/BRInnerGoo2.vmt",
	"materials/models/weapons/tsx/bio_rifle/BRInnerGoo2.vtf",
	"materials/models/weapons/tsx/bio_rifle/BRInnerGoo3.vmt",
	"materials/models/weapons/tsx/bio_rifle/BRInnerGoo3.vtf",
	"materials/models/weapons/tsx/bio_rifle/BRInnerGoo4.vmt",
	"materials/models/weapons/tsx/bio_rifle/BRInnerGoo4.vtf",
};
char g_szSounds[][PLATFORM_MAX_PATH] = {
		
};

#define MAX_WMODE	5
char g_szColors[MAX_WMODE][32] = {
	"0 200 0",
	"0 0 200",
	"200 0 0",
	"200 100 200",
	"200 200 0"
};

int g_iWeaponMode[MAX_ENTITIES];
float g_fWeaponStart[MAX_ENTITIES];
public void OnPluginStart() {
	RegServerCmd("sm_cwm_reload", Cmd_PluginReloadSelf);
}
public void OnAllPluginsLoaded() {
	int id = CWM_Create(g_szFullName, g_szName, g_szReplace, g_szVModel, g_szWModel);
	
	CWM_SetInt(id, WSI_AttackType,		view_as<int>(WSA_LockAndLoad));
	CWM_SetInt(id, WSI_ReloadType,		view_as<int>(WSR_Automatic));
	CWM_SetInt(id, WSI_AttackDamage, 	0);
	CWM_SetInt(id, WSI_AttackBullet, 	1);
	CWM_SetInt(id, WSI_MaxBullet, 		10);
	CWM_SetInt(id, WSI_MaxAmmunition, 	20);
	
	CWM_SetFloat(id, WSF_Speed,			240.0);
	CWM_SetFloat(id, WSF_ReloadSpeed,	0.0);
	CWM_SetFloat(id, WSF_AttackSpeed,	0.5);
	CWM_SetFloat(id, WSF_AttackRange,	RANGE_MELEE * 4.0);
	CWM_SetFloat(id, WSF_Spread, 		0.0);
	
	CWM_AddAnimation(id, WAA_Idle, 		0, 119, 60);
	CWM_AddAnimation(id, WAA_Draw, 		1,	29, 30);
	CWM_AddAnimation(id, WAA_Attack, 	3,  59, 30);
	CWM_AddAnimation(id, WAA_AttackPost,2,  19, 60);
	
	CWM_RegHook(id, WSH_Draw,			OnDraw);
	CWM_RegHook(id, WSH_Attack,			OnAttack);
	CWM_RegHook(id, WSH_AttackPost,		OnAttackPost);
	CWM_RegHook(id, WSH_Attack2,		OnAttack2);
	CWM_RegHook(id, WSH_Idle,			OnIdle);
}
public void OnDraw(int client, int entity) {
	CWM_RunAnimation(entity, WAA_Draw);
}
public void OnIdle(int client, int entity) {
	CWM_RunAnimation(entity, WAA_Idle);
}
public Action OnAttack(int client, int entity) {
	CWM_RunAnimation(entity, WAA_Attack);
	g_fWeaponStart[entity] = GetGameTime();
	return Plugin_Continue;
}

public Action OnAttackPost(int client, int entity) {
	CWM_RunAnimation(entity, WAA_AttackPost);
	float pc = (GetGameTime() - g_fWeaponStart[entity]) * (30 / 60.0);
	if( pc > 1.0 )
		pc = 1.0;
	
	float scale = 0.5 + Pow(pc, 2.0);
	
	int ent = CWM_ShootProjectile(client, entity, g_szTModel, "blob", 3.0, 800.0, OnProjectileHit);
	SetEntityGravity(ent, 0.5);
	SetEntPropFloat(ent, Prop_Send, "m_flElasticity", 0.2);
	SetEntPropFloat(ent, Prop_Send, "m_flModelScale", scale);
	SetEntProp(ent, Prop_Send, "m_nSkin", g_iWeaponMode[entity]);
	SetEntProp(ent, Prop_Send, "m_nSequence", 3);
	
	SetEntityRenderMode(ent, RENDER_TRANSTEXTURE);
	SetEntityRenderColor(ent, 255, 255, 255, 200);
	
	g_iWeaponMode[ent] = g_iWeaponMode[entity];
}
public Action OnProjectileHit(int client, int wpnid, int entity, int target) {
	return Plugin_Handled;
}
public Action OnAttack2(int client, int entity) {
	g_iWeaponMode[entity] = (g_iWeaponMode[entity] + 1) % MAX_WMODE;
	CWM_SetEntityInt(entity, WSI_Skin, g_iWeaponMode[entity]);
	CWM_RefreshHUD(client, entity);
	
	return Plugin_Handled;
}

public void OnMapStart() {

	AddModelToDownloadsTable(g_szVModel);
	AddModelToDownloadsTable(g_szWModel);
	AddModelToDownloadsTable(g_szTModel);
	
	for (int i = 0; i < sizeof(g_szSounds); i++) {
		AddSoundToDownloadsTable(g_szSounds[i]);
		PrecacheSoundAny(g_szSounds[i]);
	}
	for (int i = 0; i < sizeof(g_szMaterials); i++) {
		AddFileToDownloadsTable(g_szMaterials[i]);
	}
}
