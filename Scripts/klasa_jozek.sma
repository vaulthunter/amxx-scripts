/* Plugin generated by AMXX-Studio */

#include <amxmodx>
#include <amxmisc>
#include <hamsandwich>
#include <fakemeta>
#include <fakemeta_util>
#include <engine>
#include <xs>
#include <torreinc>
#include <acg>

#define TIME_SHOT 3.0
#define RANGE 250.0
#define DAMAGE 75.0

#define MAX 20

#define write_coord_f(%0)  ( engfunc( EngFunc_WriteCoord, %0 ) )

new const v_model[] 	= 	"models/v_palec.mdl";
new const iWeapon	= 	CSW_KNIFE;
new const szWeapon[]	= 	"weapon_knife";

new Float:fShot[MAX + 1];

new gmsgShake

new gLaserSprite;
new bool:ma_klase[MAX + 1];

new const nazwa[] = "Jozek";
new const nazwa_kodowa[] = "Excel";
new const opis[] = "Moze stawiac co spawn replike, ktora odbija obrazenia, Razi pradem zamiast noza";
new const grawitacja = 0;
new const zdrowie = 15;
new const kondycja = 0;
new const inteligencja = 0;
new const wytrzymalosc = 10;
new const przeladowanie = 0;
new const regeneracja = 5;

new ilosc_kukiel[MAX + 1];

new sprite_blast;
new mapname[32];

public plugin_init() 
{	
	register_plugin(nazwa, "1.0", "QTM_Peyote & DarkGL (ToRRent Edit)");
	
	cod_register_class(nazwa, opis, grawitacja, zdrowie, kondycja, inteligencja, wytrzymalosc, przeladowanie, regeneracja, nazwa_kodowa);
	RegisterHam(Ham_TakeDamage, "info_target", "TakeDamage");
	RegisterHam(Ham_Spawn, "player", "Spawn", 1);
	
	register_event("HLTV", "NowaRunda", "a", "1=0", "2=0");
	register_event("DeathMsg", "DeathEvent", "a");
	
	RegisterHam(Ham_Item_Deploy,szWeapon,"fwDeploy",1)
	
	register_forward(FM_PlayerPreThink, "PlayerPreThink")
	register_forward(FM_UpdateClientData, "UpdateClientData_Post", 1)
	
	gmsgShake = get_user_msgid("ScreenShake");
	
	get_mapname(mapname, 31)
}

public plugin_precache()
{
	sprite_blast = precache_model("sprites/dexplo.spr");
	precache_model(v_model)
	gLaserSprite = precache_model("sprites/laserbeam.spr")
	//precache_sound("palec_zeusa/thunder.wav")
}

public client_connect(id){
	fShot[id] = get_gametime();
}

public cod_class_enabled(id)
{
	if(equali(mapname, "gg_", 3) || equali(mapname, "aim_", 4) || equali(mapname, "fun_", 4) || equali(mapname, "awp_", 4))
	{
		return COD_CONTINUE;
	}
	else
	{
		acg_drawtext(id, 0.04, 0.69, "Aby postawic replike na mapie, wcisnij USE (domyslnie E)^nAby pierdolnac piorunem, wyciagnij noz", 0, 212, 255, 255, 0.0, 2.5, 4.5, 0, TS_NONE, 0, 1, 11)
	}
	//COD_MSG_SKILL_D;
	//show_hudmessage(id, "Aby postawic replike na mapie, wcisnij USE (domyslnie E)^nAby pierdolnac piorunem, wyciagnij noz");
	ma_klase[id] = true;
	//fm_give_item(id, szWeapon);
	Spawn(id);
	
	return COD_CONTINUE;
}

public cod_class_disabled(id)
{
	ma_klase[id] = false;
}

public cod_class_skill_used(id)
{
	if(equali(mapname, "gg_", 3) || equali(mapname, "aim_", 4) || equali(mapname, "fun_", 4) || equali(mapname, "awp_", 4))
	{
		client_print(id, print_center, "Umiejetnosci klas nie sa dostepne w tym trybie gry !");
	}
	else
	{
		if(ilosc_kukiel[id] < 1)
		{
			client_print(id, print_center, "Do dyspozycji masz tylko 1 replke na spawn !");
			return;
		}
	
		new Float:OriginGracza[3], Float:OriginKukly[3], Float:VBA[3];
		entity_get_vector(id, EV_VEC_origin, OriginGracza);
		VelocityByAim(id, 50, VBA);
	
		VBA[2] = 0.0;
	
		for(new i=0; i < 3; i++)
			OriginKukly[i] = OriginGracza[i]+VBA[i];
		
		if(get_distance_f(OriginKukly, OriginGracza) < 30.0)
		{
			client_print(id, print_center, "Musisz postawic replike dalej !");
			return;
		}
		new iTarget, iBody;
		if(get_user_aiming(id, iTarget, iBody, 65))
		{
			client_print(id, print_center, "Nie mozesz postawic repliki na graczu !");
			return;
		}
	
		new model[55], Float:AngleKukly[3],
	
		SekwencjaKukly = entity_get_int(id, EV_INT_gaitsequence);
		SekwencjaKukly = SekwencjaKukly == 3 || SekwencjaKukly == 4? 1: SekwencjaKukly;
	
		entity_get_string(id, EV_SZ_model, model, 54);
		entity_get_vector(id, EV_VEC_angles, AngleKukly);
	
		AngleKukly[0] = 0.0;
	
		new ent = create_entity("info_target");
	
		entity_set_string(ent, EV_SZ_classname, "Kukla");
		entity_set_model(ent, model);
		entity_set_edict(ent ,EV_ENT_owner, id);
		entity_set_vector(ent, EV_VEC_origin, OriginKukly);
		entity_set_vector(ent, EV_VEC_angles, AngleKukly);
		entity_set_vector(ent, EV_VEC_v_angle, AngleKukly);
		entity_set_int(ent, EV_INT_sequence, SekwencjaKukly);
		entity_set_int(ent, EV_INT_solid, SOLID_BBOX);
		entity_set_float(ent, EV_FL_health, 60.0);
		entity_set_float(ent, EV_FL_takedamage, DAMAGE_YES);
		entity_set_size(ent, Float:{-16.0,-16.0, -36.0}, Float:{16.0,16.0, 40.0});
		entity_set_int(ent, EV_INT_iuser1, id);
	
		ilosc_kukiel[id]--;
	}
}

public TakeDamage(this, idinflictor, idattacker, Float:damage, damagebits)
{
	if(!is_user_alive(idattacker))
		return HAM_IGNORED;
		
	new classname[MAX + 1];
	entity_get_string(this, EV_SZ_classname, classname, charsmax(classname));
	
	if(!equal(classname, "Kukla")) 
		return HAM_IGNORED;
	
	new owner = entity_get_int(this, EV_INT_iuser1);
	
	if(get_user_team(owner) == get_user_team(idattacker))
		return HAM_SUPERCEDE;
		
	cod_inflict_damage(owner, idattacker, damage*0.2, 0.3, this, damagebits);
	
	new Float:fOrigin[3], iOrigin[3];
	
	entity_get_vector(this, EV_VEC_origin, fOrigin);
	
	FVecIVec(fOrigin, iOrigin);
	
	if(damage > entity_get_float(this, EV_FL_health))
	{
		new entlist[MAX + 1];
		new numfound = find_sphere_class(this, "player", 150.0, entlist, MAX);
			
		for (new i=0; i < numfound; i++)
		{		
			new pid = entlist[i];
				
			if (!is_user_alive(pid) || get_user_team(owner) == get_user_team(pid))
				continue;
			cod_inflict_damage(owner, pid, 60.0, 0.3, this, (1<<24));
			set_hudmessage(255, 255, 255, -1.0, -1.00, 2, 6.0, 0.4, 0.00, 0.39, -1)
			ShowSyncHudMsg(owner, CreateHudSyncObj(), "X")	
		}
			
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
	}
	
	return HAM_IGNORED;
}

public fwDeploy(wpn){
	if(equali(mapname, "gg_", 3) || equali(mapname, "aim_", 4) || equali(mapname, "fun_", 4) || equali(mapname, "awp_", 4))
		return ;
		
	static iOwner;
	iOwner = pev(wpn,pev_owner);
	
	if(!is_user_alive(iOwner) || !ma_klase[iOwner])
		return ;
	
	set_pev(iOwner,pev_viewmodel2,v_model)
	
	setWeaponAnim(iOwner,5);
	
}

public PlayerPreThink( id )
{
	if(equali(mapname, "gg_", 3) || equali(mapname, "aim_", 4) || equali(mapname, "fun_", 4) || equali(mapname, "awp_", 4))
		return FMRES_IGNORED;

	if( !is_user_alive(id) || get_user_weapon(id) != iWeapon || !ma_klase[id])
		return FMRES_IGNORED;
	
	new buttons = pev(id,pev_button);
	new oldbuttons = pev(id,pev_oldbuttons)
	
	if(buttons & IN_ATTACK && !(oldbuttons & IN_ATTACK) && fShot[id] <= get_gametime()){
		
		fShot[id] = get_gametime() + TIME_SHOT;
		
		new Float:fOrigin[3],Float:fView[3],Float:fAngles[3]
		
		pev(id,pev_origin,fOrigin)
		pev(id,pev_view_ofs,fView);
		
		xs_vec_add(fOrigin,fView,fOrigin);
		
		pev(id,pev_v_angle,fAngles);
		angle_vector(fAngles,ANGLEVECTOR_FORWARD,fAngles);
		
		xs_vec_mul_scalar(fAngles,999.0,fAngles);
		
		xs_vec_add(fOrigin,fAngles,fAngles);
		
		new ptr = create_tr2()
		
		engfunc(EngFunc_TraceLine,fOrigin,fAngles,DONT_IGNORE_MONSTERS,id,ptr)
		
		new Float:fEnd[3];
		get_tr2(ptr,TR_vecEndPos,fEnd)
		
		new pHit = get_tr2(ptr,TR_pHit)
		
		free_tr2(ptr);
		
		message_begin( MSG_BROADCAST, SVC_TEMPENTITY );
		write_byte (TE_BEAMENTPOINT)
		write_short(id | 0x1000)
		/*write_byte( TE_BEAMPOINTS  )
		write_coord_f( fOrigin[0] );
		write_coord_f( fOrigin[1] );
		write_coord_f( fOrigin[2] );*/
		write_coord_f( fEnd[0] );
		write_coord_f( fEnd[1] );
		write_coord_f( fEnd[2] );
		write_short( gLaserSprite );
		write_byte( 255 );    //Start frame 0 
		write_byte( 255 );    //Frame rate 0
		write_byte( 3 );    //Life 10
		write_byte( 10);    //Width 20
		write_byte( 30);    //noise 300
		write_byte( 0 );    //R
		write_byte( 127 );    //G
		write_byte( 255 );    //B
		write_byte( 255 );    //brightness 200
		write_byte( 5 );    //Scroll 30
		message_end();        //End
		
		setWeaponAnim(id,random_num(1,3));
		
		message_begin(MSG_ONE, gmsgShake, {0,0,0}, id)
		write_short(255<< 14 ) //ammount 
		write_short((1<<12)) //lasts this long 
		write_short(255<< 14) //frequency 
		message_end() 
		
		//emit_sound(id,CHAN_VOICE,"palec_zeusa/thunder.wav",VOL_NORM, ATTN_NORM, 0, PITCH_NORM)
		
		if(is_user_alive(pHit) && get_user_team(pHit) != get_user_team(id)){
			
			message_begin(MSG_ONE, gmsgShake, {0,0,0}, pHit)
			write_short(255<< 14 ) //ammount 
			write_short((1<<12)) //lasts this long 
			write_short(255<< 14) //frequency 
			message_end() 
			
			new bool:bAttacked[MAX + 1];
			
			bAttacked[pHit] = true;
			
			cod_inflict_damage(id,pHit,DAMAGE,1.0)
			set_hudmessage(255, 255, 255, -1.0, -1.00, 2, 6.0, 0.4, 0.00, 0.39, -1)
			show_hudmessage(id, "X")	
			Display_Fade(pHit,(1<<12),(1<<12),0x0000,0,127,255,200);
			
			new Array:iFinded = ArrayCreate(1,1);
			ArrayPushCell(iFinded,pHit);
			
			new iPos = 0;
			
			while(ArraySize(iFinded) > iPos){
				new Float:fOriginTmp[3];
				pev(ArrayGetCell(iFinded,iPos),pev_origin,fOriginTmp);
				
				new iEnt = -1
				
				while((iEnt = find_ent_in_sphere(iEnt,fOriginTmp,RANGE)) != 0){
					if(is_user_alive(iEnt) && get_user_team(iEnt) != get_user_team(id) && !bAttacked[iEnt]){
						bAttacked[iEnt] = true;
						
						ArrayPushCell(iFinded,iEnt);
						
						cod_inflict_damage(id,iEnt,DAMAGE,1.0)
						set_hudmessage(255, 255, 255, -1.0, -1.00, 2, 6.0, 0.4, 0.00, 0.39, -1)
						show_hudmessage(id, "X")
						Display_Fade(iEnt,(1<<12),(1<<12),0x0000,0,127,255,200);
						
						message_begin( MSG_BROADCAST, SVC_TEMPENTITY );
						write_byte(TE_BEAMENTS)
						write_short(ArrayGetCell(iFinded,iPos))
						write_short(iEnt)
						write_short( gLaserSprite );
						write_byte( 255 );    //Start frame 0 
						write_byte( 255 );    //Frame rate 0
						write_byte( 3 );    //Life 10
						write_byte( 10);    //Width 20
						write_byte( 30);    //noise 300
						write_byte( 0 );    //R
						write_byte( 127 );    //G
						write_byte( 255 );    //B
						write_byte( 255 );    //brightness 200
						write_byte( 5 );    //Scroll 30
						message_end();        //End
						
						message_begin(MSG_ONE, gmsgShake, {0,0,0}, iEnt)
						write_short(255<< 14 ) //ammount 
						write_short((1<<12)) //lasts this long 
						write_short(255<< 14) //frequency 
						message_end() 
					}
				}
				iPos++;
			}
			
			ArrayDestroy(iFinded)
		}
	}
	
	buttons = buttons & ~IN_ATTACK;
	buttons = buttons & ~IN_ATTACK2;
	
	set_pev( id, pev_button, buttons );
	
	return FMRES_HANDLED;
}

public UpdateClientData_Post( id, sendweapons, cd_handle )
{
	
	if ( !is_user_alive(id) || get_user_weapon(id) != iWeapon || !ma_klase[id])
		return FMRES_IGNORED;
	
	set_cd(cd_handle, CD_flNextAttack, halflife_time() + 0.001 );
	return FMRES_HANDLED;
}

stock setWeaponAnim(id, anim) {
	set_pev(id, pev_weaponanim, anim)
	
	message_begin(MSG_ONE, SVC_WEAPONANIM, {0, 0, 0}, id)
	write_byte(anim)
	write_byte(pev(id, pev_body))
	message_end()
} 

stock Display_Fade(id,duration,holdtime,fadetype,red,green,blue,alpha)
{
	if(!is_user_alive(id)){
		return ;
	}
	message_begin( MSG_ONE, get_user_msgid("ScreenFade"),{0,0,0},id );
	write_short( duration );        // Duration of fadeout
	write_short( holdtime );        // Hold time of color
	write_short( fadetype );        // Fade type
	write_byte ( red );             // Red
	write_byte ( green );           // Green
	write_byte ( blue );            // Blue
	write_byte ( alpha );   // Alpha
	message_end();
}

public Spawn(id)
{
	if(!is_user_alive(id) || !ma_klase[id])
		return HAM_IGNORED;
	
	//fm_give_item(id,szWeapon);
	ilosc_kukiel[id] = 1;
	
	return HAM_IGNORED;
}

public DeathEvent()
{
	new vid = read_data(2);
	set_task(5.0, "Usun", vid);
}

public Usun(id)
{
	new ent	    
	while((ent = fm_find_ent_by_owner(ent, "Kukla", id)) != 0)
		remove_entity(ent)
}

public NowaRunda()
	remove_entity_name("Kukla");

public client_disconnect(id)
{
	new ent	    
	while((ent = fm_find_ent_by_owner(ent, "Kukla", id)) != 0)
		remove_entity(ent)
}