/* Plugin generated by AMXX-Studio */

#include <amxmodx>
#include <codmod>

new bool:ma_klase[33];

new const nazwa[] = "Szturmowiec";
new const opis[] = "Brak";
new const bronie = 1<<CSW_M4A1;
new const zdrowie = 20;
new const kondycja = -10;
new const inteligencja = 25;
new const wytrzymalosc = 5;

public plugin_init() {
	register_plugin(nazwa, "1.0", "QTM_Peyote");
	
	cod_register_class(nazwa, opis, bronie, zdrowie, kondycja, inteligencja, wytrzymalosc);
}

public cod_class_enabled(id)
	ma_klase[id] = true;

public cod_class_disabled(id)
	ma_klase[id] = false;