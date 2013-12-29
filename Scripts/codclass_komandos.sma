/* Plugin generated by AMXX-Studio */

#include <amxmodx>
#include <engine>
#include <codmod>
#include <hamsandwich>

#define DMG_BULLET (1<<1)

new bool:ma_klase[33];

new const nazwa[] = "Komandos";
new const opis[] = "150 procent obrazen z deagl'a, 1/2 szans na natychmiastowe zabicie z noza(PPM)";
new const bronie = 1<<CSW_DEAGLE | 1<<CSW_HEGRENADE;
new const zdrowie = 20;
new const kondycja = 35;
new const inteligencja = 0;
new const wytrzymalosc = -15;

public plugin_init() 
{
	register_plugin(nazwa, "1.0", "QTM_Peyote");
	
	cod_register_class(nazwa, opis, bronie, zdrowie, kondycja, inteligencja, wytrzymalosc);
	
	RegisterHam(Ham_TakeDamage, "player", "TakeDamage");
	register_event("CurWeapon", "CurWeapon", "be", "1=1");
}

public cod_class_enabled(id)
	ma_klase[id] = true;
	
public cod_class_disabled(id)
	ma_klase[id] = false;
	
public plugin_precache()
{
        precache_model("models/QTM_Codmod/v_deagle.mdl");
}	

public TakeDamage(this, idinflictor, idattacker, Float:damage, damagebits)
{
	if(!is_user_connected(idattacker) || !ma_klase[idattacker])
		return HAM_IGNORED;
		
	new weapon = get_user_weapon(idattacker);
	
	if(weapon == CSW_DEAGLE && damagebits & DMG_BULLET)
		cod_inflict_damage(idattacker, this, damage*0.5, 0.0, idinflictor, damagebits);
		
	if(weapon == CSW_KNIFE && damagebits & DMG_BULLET && damage > 17.0 && random_num(1,2) == 1)
		cod_inflict_damage(idattacker, this, float(get_user_health(this))-damage+10.0, 0.0, idinflictor, damagebits);
		
	return HAM_IGNORED;
}

public CurWeapon(id)
{
	new weapon = read_data(2);

	if(ma_klase[id] && weapon == CSW_DEAGLE)
	{
		entity_set_string(id, EV_SZ_viewmodel, "models/QTM_Codmod/v_deagle.mdl")
	}
	if(cod_get_user_class(id) == cod_get_classid("Komandos"))
	{
		if(weapon == CSW_USP || weapon == CSW_GLOCK18)
		{
			//engclient_cmd(id, "drop")
			cod_take_weapon(id, weapon)
		}
	}
}