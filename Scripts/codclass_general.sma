/* Plugin generated by AMXX-Studio */

#include <amxmodx>
#include <codmod>
#include <fakemeta>
#include <colorchat>
#include <engine>

#define DMG_BULLET (1<<1)

new bool:ma_klase[33];

new const nazwa[] = "General";
new const opis[] = "Wybucha po smierci zadajac 60(+intelgencja) obrazen, 1/3 szans ze helm odbije pocisk";
new const bronie = 1<<CSW_AK47 | 1<<CSW_HEGRENADE;
new const zdrowie = 25;
new const kondycja = 5;
new const inteligencja = 5;
new const wytrzymalosc = 5;

new sprite_blast, sprite_white;

public plugin_init() 
{
	register_plugin(nazwa, "1.0", "QTM_Peyote");
	
	cod_register_class(nazwa, opis, bronie, zdrowie, kondycja, inteligencja, wytrzymalosc);
	register_event("DeathMsg", "Death", "ade");
	register_forward(FM_TraceLine, "TraceLine");
}

public plugin_precache()
{
	sprite_white = precache_model("sprites/white.spr") ;
	sprite_blast = precache_model("sprites/aexplo.spr");
}

public cod_class_enabled(id)
{
	//ColorChat(id, GREEN, "Klasa stworzona przez =ToRRent='a"); // nie badz swinia, nie usuwaj informacji o tworcy : )
	ma_klase[id] = true;
	return COD_CONTINUE;
}
	
public cod_class_disabled(id)
	ma_klase[id] = false;

public Death()
{
	new id = read_data(2);
	if(ma_klase[id])
		Eksploduj(id);
}

public Eksploduj(id)
{
	new Float:fOrigin[3], iOrigin[3];
	entity_get_vector( id, EV_VEC_origin, fOrigin);
	iOrigin[0] = floatround(fOrigin[0]);
	iOrigin[1] = floatround(fOrigin[1]);
	iOrigin[2] = floatround(fOrigin[2]);
	
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
	
	message_begin( MSG_BROADCAST, SVC_TEMPENTITY, iOrigin );
	write_byte( TE_BEAMCYLINDER );
	write_coord( iOrigin[0] );
	write_coord( iOrigin[1] );
	write_coord( iOrigin[2] );
	write_coord( iOrigin[0] );
	write_coord( iOrigin[1] + 300 );
	write_coord( iOrigin[2] + 300 );
	write_short( sprite_white );
	write_byte( 0 ); // startframe
	write_byte( 0 ); // framerate
	write_byte( 10 ); // life
	write_byte( 10 ); // width
	write_byte( 255 ); // noise
	write_byte( 255 ); // r, g, b
	write_byte( 100 );// r, g, b
	write_byte( 100 ); // r, g, b
	write_byte( 128 ); // brightness
	write_byte( 8 ); // speed
	message_end();
	
	new entlist[33];
	new numfound = find_sphere_class(id, "player", 300.0 , entlist, 32);
	
	for (new i=0; i < numfound; i++)
	{		
		new pid = entlist[i];
		
		if (!is_user_alive(pid) || get_user_team(id) == get_user_team(pid))
			continue;
		cod_inflict_damage(id, pid, 60.0, 0.3);
	}
	return PLUGIN_CONTINUE;
}

public TraceLine(Float:start[3], Float:end[3], conditions, id, trace)
{
	if(random_num(1,3) != 1)
		return FMRES_IGNORED;
		
	if(get_tr2(trace, TR_iHitgroup) != HIT_HEAD)
		return FMRES_IGNORED;
		
	new iHit = get_tr2(trace, TR_pHit);
	
	if(!is_user_connected(iHit))
		return FMRES_IGNORED;

	if(!ma_klase[iHit])
		return FMRES_IGNORED;
		
	set_tr2(trace, TR_iHitgroup, 8);
	
	return FMRES_IGNORED;
}