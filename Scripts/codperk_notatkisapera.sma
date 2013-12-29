/* Plugin generated by AMXX-Studio */

#include <amxmodx>
#include <engine>
#include <codmod>
#include <acg>

#define MAX 20
new const nazwa[] = "Notatki Sapera";
new const opis[] = "Masz 3 miny co spawn";

new ilosc_min_gracza[MAX + 1];

new sprite_blast;

new const model[] = "models/QTM_CodMod/mine.mdl"

public plugin_init()
 {
	register_plugin(nazwa, "1.0", "QTM_Peyote");
	
	cod_register_perk(nazwa, opis);
	
	register_event("ResetHUD", "ResetHUD", "abe");
	register_touch("mine", "*" , "DotykMiny");
}

public plugin_precache()
{
	sprite_blast = precache_model("sprites/dexplo.spr");
	precache_model(model);
}

public cod_perk_enabled(id)
{
	COD_MSG_SKILL_D;
	show_hudmessage(id, "Aby polozyc na mapie mine ^nuzyj komendy useperk lub radio3");
	ilosc_min_gracza[id] = 3;
	return COD_CONTINUE;
}

public cod_perk_disabled(id)
{
	ilosc_min_gracza[id] = 0;
	acg_removedrawnimage(id, 3, 3)
}
	
public cod_perk_used(id)
{		
	if (!ilosc_min_gracza[id])
	{
		client_print(id, print_center, "Do dyspozycji masz tylko 3 miny na spawn !");
		return PLUGIN_CONTINUE;
	}
	
	ilosc_min_gracza[id]--;
	
	new Float:origin[3];
	entity_get_vector(id, EV_VEC_origin, origin);
		
	new ent = create_entity("info_target");
	entity_set_string(ent ,EV_SZ_classname, "mine");
	entity_set_edict(ent ,EV_ENT_owner, id);
	entity_set_int(ent, EV_INT_movetype, MOVETYPE_TOSS);
	entity_set_origin(ent, origin);
	entity_set_int(ent, EV_INT_solid, SOLID_BBOX);
	
	entity_set_model(ent, model);
	entity_set_size(ent,Float:{-16.0,-16.0,0.0},Float:{16.0,16.0,2.0});
	
	drop_to_floor(ent);
	
	set_rendering(ent,kRenderFxNone, 0,0,0, kRenderTransTexture,60);
	
	ShowAmmo(id);
	
	return PLUGIN_CONTINUE;
}


public DotykMiny(ent, id)
{
	if(!is_valid_ent(ent))
		return;
		
	new attacker = entity_get_edict(ent, EV_ENT_owner);
	if (get_user_team(attacker) != get_user_team(id))
	{
		new Float:fOrigin[3];
		entity_get_vector( ent, EV_VEC_origin, fOrigin);
	
		new iOrigin[3];
		for(new i=0;i<3;i++)
			iOrigin[i] = floatround(fOrigin[i]);
		
		message_begin(MSG_BROADCAST,SVC_TEMPENTITY, iOrigin);
		write_byte(TE_EXPLOSION);
		write_coord(iOrigin[0]);
		write_coord(iOrigin[1]);
		write_coord(iOrigin[2]);
		write_short(sprite_blast);
		write_byte(32); 
		write_byte(20); 
		write_byte(0);
		message_end();
		
		new entlist[33];
		new numfound = find_sphere_class(ent,"player", 90.0 ,entlist, 32);
		
		for (new i=0; i < numfound; i++)
		{		
			new pid = entlist[i];
			
			if (!is_user_alive(pid) || get_user_team(attacker) == get_user_team(pid))
				continue;
				
			cod_inflict_damage(attacker, pid, 80.0, 1.0, ent, (1<<24));
			COD_MSG_NEWS_N;
			show_hudmessage(pid, "Wlazles na mine !^nPatrz pod nogi");
		}
		remove_entity(ent);
	}
}	

public ResetHUD(id)
{
	ShowAmmo(id);
	ilosc_min_gracza[id] = 3;
}

public NowaRunda()
{
	new ent = find_ent_by_class(-1, "mine");
	while(ent > 0) 
	{
		remove_entity(ent);
		ent = find_ent_by_class(ent, "mine");	
	}
}

public client_disconnect(id)
{
	new ent = find_ent_by_class(0, "mine");
	while(ent > 0)
	{
		if(entity_get_edict(id, EV_ENT_owner) == id)
			remove_entity(ent);
		ent = find_ent_by_class(ent, "mine");
	}
}


ShowAmmo(id)
{ 
	if(acg_userstatus(id))
	{
		acg_removedrawnimage(id, 3, 3)
		new ammo[51] 
		formatex(ammo, 50, "Liczba min: %i/3",ilosc_min_gracza[id])
		acg_drawtext(id, ammo, 10, 255, 100, -0.1, -1.0, 0.9, 0, 1)
	}
} 
/*ShowAmmo(id)
{ 
    new ammo[51] 
    formatex(ammo, 50, "Liczba min: %i/3",ilosc_min_gracza[id])

    message_begin(MSG_ONE, get_user_msgid("StatusText"), {0,0,0}, id) 
    write_byte(0) 
    write_string(ammo) 
    message_end() 
}*/