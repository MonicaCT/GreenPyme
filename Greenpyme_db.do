********************************************************************************
*** Este dofile crea la base limpia en stata de los proyectos de GreenPyme   ***
*** Autora: Maria Laura Lanzalot 											 ***
*** date: 10/23/2017  														 ***
********************************************************************************
clear all
set more off
*cd "C:\Users\mlanzalot\SharePoint\Yanez Pagans, Patricia - GreenPyme\GreenPyme\dofile"
import excel Data_in\Greenpyme_db_2018.xlsm, sheet("Sheet1") firstrow clear
save Data_out\Greenpyme_db_0.dta, replace

*1) Borro variables que no me sirven
drop SEA_block DEA_block M1_block M2_block  ///
AED_invoice_bolivia AED_banco delete new_sectors

*2) Solo dejo las aprobadas y desaprobadas
*ver que haya solo una observación de la Distribuidora Istmania
br if  (email=="jenny.nunez@istmania.hn")
*Si no esta bien correr lo siguiente
* create identifier to group together observations
gen email1 = word(email,1)

tempfile f
save "`f'"

collapse (lastnm) country_2d-LB_inversion LB_TIR LB_VAN LB_pahorro_hidro_GEI-M1_fecha M1_implement-M1_additionalEE_value M1_nonEE_fneed-M2_additionalEE_value M2_nonEE_fneed-SEA_DEA (first) LB_pahorro LB_pahorro_elect LB_recupera M1_pfecha M1_additionalEE_fneed M2_additionalEE_fneed total_electr_costo total_ninversión total_pahorro total_remsavings, by(email1)
keep if email=="jenny.nunez@istmania.hn"
gen nueva=1
append using "`f'"
drop if email=="jenny.nunez@istmania.hn" & nueva!=1
drop nueva email1

ta status
drop if status=="Duplicate" | status=="Eliminated"
replace status="Approved" if status=="approved" | status=="Approved-exception"
gen approved=1 if status=="Approved" 
replace approved=0 if status=="Not Approved"
label var approved "Aprobada para participar de audits (=1)"

*3) Le pongo las labels
do Do\Greenpyme_labels.do
 
*4) Reemplazo y pongo labels a yes/no questions
label def yesno 1 "Yes" 0 "No"

global dummies audit_before personnel_participate oweekends pproc_steam pproc_cair ///
pproc_emotor pproc_oven pproc_cooling LBD_recommend LBD_info_empresa LBD_metodos_aud ///
LBD_estim_incluye LBD_incluye_ppolit  multinational

foreach var in  $dummies{
replace `var'="1" if `var'=="Yes" | `var'=="yes" | `var'=="YES" | `var'=="si" | `var'=="Sí"
replace `var'="0" if `var'=="No" | `var'=="no" | `var'=="NO"
destring `var', replace
label value `var' yesno
ta `var'
}

global dummies2 LB_estim_incluye LB_incluye_ppolit AES_cuestionario   ///
AED_potencial AED_propuesta AED_informe_CII M2_CII IIC_financing LB_recommend

foreach var in  $dummies2 {
label value `var' yesno
ta `var'
}

replace nonIIC_financing="0" if nonIIC_financing=="0 - but wants to"
replace nonIIC_financing="1" if nonIIC_financing=="Yes - BAC Possibly"
destring nonIIC_financing, replace
label value nonIIC_financing yesno
ta nonIIC_financing

foreach var in  AES_pago_auditor M1_CII M2_CII IIC_sugfinancing LB_informeCII LB_metodos_aud  LB_info_empresa {
replace `var'=1 if `var'>0
label value `var' yesno
ta `var'
}

replace M1_aCII="0" if  strpos(lower(M1_aCII), "not yet") > 0

replace M2_aCII ="1" if  strpos(lower(M2_aCII), "yes") > 0
replace M2_aCII ="0" if  strpos(lower(M2_aCII), "not yet") > 0
replace M2_aCII ="0" if  strpos(lower(M2_aCII), "not known") > 0

foreach var in  AED_interes LBD_informeCII M1_aCII M2_aCII AED_cuestionario {
replace `var'="1" if `var'!="" & `var'!="0"
destring `var', replace
label value `var' yesno
ta `var'
}

*5) Paso las variables que ahora estan en string a numéricas
*Country: corrijo error
ta country country_2d
replace country="Bolivia" if country_2d=="BL"
replace country="Honduras" if country_2d=="HR"
replace country="Ecuador" if country=="Ecuador "
replace country="Nicaragua" if country=="Paraguay"
encode country, generate (country_n)
ta country_n
tab country_n, miss /*4 observaciones que no tienen país*/

*Sector
ta sector
replace sector="Acuicultura y Pesca" if sector=="Aquaculture & fisheries" | sector=="Aquaculture and Fisheries" 
replace sector="Alimentación y Bebidas" if sector=="Food and Beverages" | sector=="Food, Bottling & Beverages" 
replace sector="Construcción, Materiales e Instalaciones" if sector=="Construction, Materials, and Fixtures" | sector=="Utilities & Infrastructure"
replace sector="Distribución y Venta minorista" if sector=="Distribution and Retail" 
replace sector="Educación" if sector=="Education" 
replace sector="Envases y Empaques" if sector=="Containers and Packaging" 
replace sector="Ganadería y Avicultura" if sector=="Livestock & Poultry" 
replace sector="Hostelería y Turismo" if sector=="Hotels and Tourism" | sector=="Tourism & Hotels"
replace sector="Información, Comunicación y Tecnología" if sector=="Information, Communications, and Technology" | sector=="Tech, Comm. & New Economy"
replace sector="Madera, Pulpa y Papel" if sector=="Wood, Pulp & Paper" | sector=="Wood, Pulp, and Paper" 
replace sector="Manufactura en general" if sector=="General Manufacturing" 
replace sector="Petróleo, Gas y Mineria" if sector=="Petróleo, GAs y Mineria" | sector=="Oil and Mining" | sector=="Oil, Gas, and Mining" 
replace sector="Servicios" if sector=="Services" 
replace sector="Productos Agrícolas" if sector=="Agricultural Products" | sector=="Agriculture & Agribusiness"
replace sector="Servicios Financieros" if sector=="Financial Services" | sector=="Capital Markets" | sector=="Agency Lines"
replace sector="Servicios y Suministros Sanitarios" if sector=="Health" 
replace sector="Textiles, Ropa de vestir y Cuero" if sector=="Textiles, Apparel & Leather" | sector=="Textiles, Apparel, and Leather" 
replace sector="Otros" if sector=="Others" 
replace sector="Químicos y Plásticos" if sector=="Chemicals & Plastics" 
replace sector="energia" if sector=="Energy and Power" 
replace sector="Transporte y almacenado" if sector=="Transportation & Warehousing" 
replace sector="Servicios no financieros" if sector=="Non-Financial Services" | sector=="Advisory Services"
replace sector="Plantas de procesamiento industrial" if sector=="Industrial Processing Zones"
replace sector="Servicios y Suministros Sanitarios" if sector=="Health Services and Supplies" 
replace sector="Transporte y almacenado" if sector=="Transporte y Logística" 
*Otros
gen sector_otros=lower(company) if sector=="Otros"
tabsplit sector_otros if sector=="Otros", parse(, " " "(" ")" "?" "+") sort

replace sector="Alimentación y Bebidas" if regexm(sector_otros, "lacteos") == 1 &  sector=="Otros"
replace sector="Servicios" if regexm(sector_otros, "aèrea") == 1 &  sector=="Otros"
replace sector="Servicios" if regexm(sector_otros, "club") == 1 &  sector=="Otros"
replace sector="Servicios" if regexm(sector_otros, "navegaciòn") == 1 &  sector=="Otros"
replace sector="Manufactura en general" if regexm(sector_otros, "pizarrones") == 1 &  sector=="Otros"
replace sector="Manufactura en general" if regexm(sector_otros, "palillos") == 1 &  sector=="Otros"
replace sector="Químicos y Plásticos" if regexm(sector_otros, "asfalto") == 1 &  sector=="Otros"
replace sector="Alimentación y Bebidas" if regexm(sector_otros, "hielo") == 1 &  sector=="Otros"
replace sector="Distribución y Venta minorista" if regexm(sector_otros, "ferretería") == 1 &  sector=="Otros"
replace sector="Productos Agrícolas" if regexm(sector_otros, "agro") == 1 &  sector=="Otros"
replace sector="Distribución y Venta minorista" if regexm(sector_otros, "distribuidora") == 1 &  sector=="Otros"
replace sector="Distribución y Venta minorista" if regexm(sector_otros, "estacion") == 1 &  sector=="Otros"
replace sector="Distribución y Venta minorista" if regexm(sector_otros, "gasolinera") == 1 &  sector=="Otros"
replace sector="Servicios" if regexm(sector_otros, "hospital") == 1 &  sector=="Otros"
replace sector="Químicos y Plásticos" if regexm(sector_otros, "plasticos") == 1 &  sector=="Otros"
replace sector="Manufactura en general" if regexm(sector_otros, "impresores") == 1 &  sector=="Otros"
replace sector="Manufactura en general" if regexm(sector_otros, "maquinarias") == 1 &  sector=="Otros"
replace sector="Servicios" if regexm(sector_otros, "restaurante") == 1 &  sector=="Otros"
replace sector="Distribución y Venta minorista" if regexm(sector_otros, "tienda") == 1 &  sector=="Otros"
replace sector="Distribución y Venta minorista" if regexm(sector_otros, "supermercado") == 1 &  sector=="Otros"
replace sector="Manufactura en general" if regexm(sector_otros, "automotriz") == 1 &  sector=="Otros"
replace sector="Servicios Financieros"  if regexm(sector_otros, "banco") == 1 &  sector=="Otros"
replace sector="Servicios" if regexm(sector_otros, "comidas") == 1 &  sector=="Otros"
replace sector="Servicios" if regexm(sector_otros, "gym") == 1 &  sector=="Otros"
replace sector="Manufactura en general" if regexm(sector_otros, "manufacturing") == 1 &  sector=="Otros"
replace sector="Servicios" if regexm(sector_otros, "panaderia") == 1 &  sector=="Otros"
replace sector="Servicios" if regexm(sector_otros, "pasteleria") == 1 &  sector=="Otros"
replace sector="Químicos y Plásticos" if regexm(sector_otros, "refineria") == 1 &  sector=="Otros"
replace sector="Productos Agrícolas" if regexm(sector_otros, "aceites") == 1 &  sector=="Otros"
replace sector="Distribución y Venta minorista" if regexm(sector_otros, "hipermercados") == 1 &  sector=="Otros"
replace sector="Servicios" if regexm(sector_otros, "panificadora") == 1 &  sector=="Otros"
replace sector="Distribución y Venta minorista" if regexm(sector_otros, "comercial") == 1 &  sector=="Otros"
replace sector="Servicios Financieros"  if regexm(sector_otros, "inversiones") == 1 &  sector=="Otros"
replace sector="Servicios no financieros" if regexm(sector_otros, "camara") == 1 &  sector=="Otros"
replace sector="Distribución y Venta minorista" if regexm(sector_otros, "autoservicios") == 1 &  sector=="Otros"
replace sector="Servicios" if regexm(sector_otros, "servicios") == 1 &  sector=="Otros"
replace sector="Manufactura en general" if regexm(sector_otros, "planta") == 1 &  sector=="Otros"
replace sector="Distribución y Venta minorista" if regexm(sector_otros, "repuestos") == 1 &  sector=="Otros"
replace sector="Servicios" if regexm(sector_otros, "agencia") == 1 &  sector=="Otros"
replace sector="Textiles, Ropa de vestir y Cuero" if regexm(sector_otros, "tenería") == 1 &  sector=="Otros"
replace sector="Químicos y Plásticos" if regexm(sector_otros, "laboratorio") == 1 &  sector=="Otros"
replace sector="Textiles, Ropa de vestir y Cuero" if regexm(sector_otros, "modas") == 1 &  sector=="Otros"
replace sector="Manufactura en general" if regexm(sector_otros, "talleres") == 1 &  sector=="Otros"
replace sector="Servicios" if regexm(sector_otros, "portuaria") == 1 &  sector=="Otros"
replace sector="Distribución y Venta minorista" if regexm(sector_otros, "ventas") == 1 &  sector=="Otros"
replace sector="Productos Agrícolas" if regexm(sector_otros, "agrícola") == 1 &  sector=="Otros"
replace sector="Manufactura en general" if regexm(sector_otros, "alambre") == 1 &  sector=="Otros"
replace sector="Manufactura en general" if regexm(sector_otros, "aluminio") == 1 &  sector=="Otros"
replace sector="Servicios no financieros" if regexm(sector_otros, "aseguradora") == 1 &  sector=="Otros"
replace sector="Ganadería y Avicultura" if regexm(sector_otros, "avicola") == 1 &  sector=="Otros"
replace sector="Alimentación y Bebidas" if regexm(sector_otros, "cafés") == 1 &  sector=="Otros"
replace sector="Químicos y Plásticos" if regexm(sector_otros, "ceramica") == 1 &  sector=="Otros"
replace sector="Distribución y Venta minorista" if regexm(sector_otros, "deposito") == 1 &  sector=="Otros"
replace sector="Servicios" if regexm(sector_otros, "editora") == 1 &  sector=="Otros"
replace sector="Químicos y Plásticos" if regexm(sector_otros, "farmaceutica") == 1 &  sector=="Otros"
replace sector="Madera, Pulpa y Papel" if regexm(sector_otros, "grafica") == 1 &  sector=="Otros" 
replace sector="Servicios" if regexm(sector_otros, "hotelera") == 1 &  sector=="Otros"
replace sector="Madera, Pulpa y Papel" if regexm(sector_otros, "impres") == 1 &  sector=="Otros" 
replace sector="Servicios" if regexm(sector_otros, "infancia") == 1 &  sector=="Otros"
replace sector="Distribución y Venta minorista" if regexm(sector_otros, "maderas") == 1 &  sector=="Otros"
replace sector="Petróleo, Gas y Mineria" if regexm(sector_otros, "marmol") == 1 &  sector=="Otros"

list company if regexm(sector_otros, "marmol") == 1 &  sector=="Otros"

replace sector="Servicios no financieros" if company=="FACIO Y CAÑAS LIMITADA"
replace sector="Servicios" if company=="DIVERTIA, S.A."
replace sector="Servicios no financieros" if company=="Sistemas CR Sisco S.A (AVANTICA TECHNOLOGIES)"
replace sector="Servicios no financieros" if company=="Neon Nieto S.A (aka NEÓN NIETO S.A)"
replace sector="Distribución y Venta minorista" if company=="NOVEM CAR DESIGN S. DE R.L."
replace sector="Alimentación y Bebidas" if company=="LA VAQUITA DE ORIENTE S.A. DE C.V."
replace sector="Alimentación y Bebidas" if company=="Queso Puebla SA de CV"
replace sector="Servicios no financieros" if company=="Transactel El Salvador"
replace sector="Servicios" if company=="AMERICA KARAOKE"
replace sector="Manufactura en general" if company=="HORMIPRET SRL"
replace sector="Servicios no financieros" if company=="EMPACAR S.A"
replace sector="Manufactura en general" if company=="INBOLTECO - INDUSTRIA BOLIVIANA DE TEJAS Y COMPLEMENTOS S.A."
replace sector="Servicios no financieros" if company=="MOTORIZACION ECOLOGICA MOTORECO S.R.L."
replace sector="Manufactura en general" if company=="HORMICRUZ S.R.L "
replace sector="Distribución y Venta minorista" if company=="IMPEXPAP S.A"
replace sector="Manufactura en general" if company=="FABOCE SRL"
replace sector="Distribución y Venta minorista" if company=="AIDISA BOLIVIA S.A. (parte de CIT Bolivia)"
replace sector="Servicios" if company=="E2 energia Eficiente S.A.E.S.P"
replace sector="Servicios" if company=="E.A.A DE SANTA ANA ESP S.A"
replace sector="Servicios no financieros" if company=="Fundación Codesarrollo. SOCYA"
replace sector="Químicos y Plásticos" if company=="TEMPLADO S.A."
replace sector="Manufactura en general" if company=="METALES GYPSUM S.A"
replace sector="Servicios no financieros" if company=="ASK TOTAL SECURITY S.A "
replace sector="Manufactura en general" if company=="Arcelor Mittal "
replace sector="Servicios no financieros" if company=="ASA POSTERS COSTA RICA SA"
replace sector="Servicios no financieros" if company=="Condominio Plaza Roble - Areas comunes"
replace sector="Servicios no financieros" if company=="Condominio Plaza Roble - Edificio pórtico y patio"
replace sector="Servicios no financieros" if company=="Condominio Plaza Roble - Edificios Balcones"
replace sector="Servicios no financieros" if company=="Condominio Plaza Roble - Pórtico"
replace sector="Servicios no financieros" if company=="Condominio Plaza Roble - Tarrazas y casa de máquinas"
replace sector="Servicios no financieros" if company=="Grupo TRIBU NAZCA S.A.  "
replace sector="Servicios no financieros" if company=="GEO Ingenieria"
replace sector="Servicios no financieros" if company=="Corporación Robiisa, aka Robilisa, aka Robisa?"
replace sector="Servicios no financieros" if company=="PHARMERICA DEL SUR S.A  Total Natural"
replace sector="Servicios" if company=="ROMERO FOURNIER"
replace sector="Servicios" if company=="CIECSA INTERNATIONAL CENTER OFCORPO"
replace sector="Alimentación y Bebidas" if company=="Standard Fruit Company de Costa Rica"
replace sector="Alimentación y Bebidas" if company=="Mondaisa S.A."
replace sector="Distribución y Venta minorista" if company=="DISITALI S.A"
replace sector="Servicios no financieros" if company=="TRIBU DDB"
replace sector="Servicios no financieros" if company=="SIESA - Soluciones Industriales Electromecanicas S.A"
replace sector="Servicios no financieros" if company=="Industrias Panorama"
replace sector="Distribución y Venta minorista" if company=="GRUPO GOLLO"
replace sector="Servicios no financieros" if company=="SWISS TRAVEL"
replace sector="Distribución y Venta minorista" if company=="CLIMA IDEAL"
replace sector="Distribución y Venta minorista" if company=="Resoco Costa Rica S.A."
replace sector="Servicios no financieros" if company=="MOVILTECH PREPAGO SOCIEDAD DE RESPONSABILIDAD"
replace sector="Servicios no financieros" if company=="MADISA MANEJO DE DESECHOS INDUSTRIALES S.A."
replace sector="Servicios no financieros" if company=="GLOBAL KEMICAL S.A "
replace sector="Distribución y Venta minorista" if company=="VARIEDADES EL SOL NACIENTE S.A."
replace sector="Servicios no financieros" if company=="De Pe a Pa Mercadeo S.A"
replace sector="Servicios" if company=="AERIS HOLDING COSTA RICA"
replace sector="Servicios no financieros" if company=="Prensa Libre, S.A."
replace sector="Servicios no financieros" if company=="SALA DE TE Y RECEPCIONES LARROSA S.A DE C.V"
replace sector="Servicios no financieros" if company=="CABLE VISION POR SATELITE S.A DE C.V"
replace sector="Servicios no financieros" if company=="Publicaciones del Caribe S.A."
replace sector="Servicios no financieros" if company=="VICEPRESIDENCIA DE LA REPUBLICA"
replace sector="Químicos y Plásticos" if  company=="Tacoplast S.A de C.V. y REASA"
replace sector="Manufactura en general" if company=="INDUSTRIAS FENIX, S.A. DE C.V."
replace sector="Distribución y Venta minorista" if company=="EL BARATILLO (CASA MATRIZ)"
replace sector="Distribución y Venta minorista" if company=="EL BARATILLO (SUCURSAL LA UNION)"
replace sector="Distribución y Venta minorista" if company=="EL BARATILLO (SUCURSAL USULUTAN)"
replace sector="Distribución y Venta minorista" if company=="EL BARATILLO (SUCURSAL El Calvario, SAN MIGUEL)"
replace sector="Distribución y Venta minorista" if company=="EL BARATILLO (SUCURSAL GOTERA)"
replace sector="Distribución y Venta minorista" if company=="EL BARATILLO (SUCURSAL STA ROSA DE LIMA)"
replace sector="Servicios no financieros" if company=="EMPRESARIADO VENTURA S.A. DE C.V"
replace sector="Servicios no financieros" if company=="Transactel El Salvador (Telus)"
replace sector="Servicios" if company=="CHINO TONY EXPRESS"
replace sector="Alimentación y Bebidas" if company=="Escarrasa, de C.V. (San Salvador)"
replace sector="Distribución y Venta minorista" if company=="CELULAR STAR, S.A. DE C.V."
replace sector="Alimentación y Bebidas" if company=="PORCICULTORES UNIDOS SA DE CV"
replace sector="Químicos y Plásticos" if  company=="tacoplast sa de cv"
replace sector="Servicios no financieros" if company=="UPC Group De El Salvador, SA de CV"
replace sector="Distribución y Venta minorista" if company=="Verduglasa S.A. de C.V."
replace sector="Servicios no financieros" if company=="Atento de Guatemala S.A. - Sucursal 2 - ZONA 10 (name chosen from Report 346775)"
replace sector="Servicios no financieros" if company=="Atento de Guatemala S.A. - Sucursal 1 - ZONA 11 (name chosen from Report 346775)"
replace sector="Servicios no financieros" if company=="GARE DE CREACION, S.A."
replace sector="Servicios" if company=="Corporacion AIC, S.A. - Subempresa 2"
replace sector="Servicios" if company=="Corporacion AIC, S.A. - Subempresa 1"
replace sector="Servicios" if company=="Grupo Trefra - Subempresa 1 - TREFRATELLI FONTABELLA"
replace sector="Servicios" if company=="Grupo Trefra - Subempresa 3 - FRISCO GRILL"
replace sector="Servicios" if company=="Grupo TREFRA - Sontres, S.A. - MÉXICO LINDO Y QUÉ RICO (name in capitals is not confirmed, simply chosen by Tyler and Leebong reviewing the final report 346775) aka MeXICO LINDO"
replace sector="Servicios" if company=="TREFRA - Tregua, s.a. , C.C  - PICOLO MIRAFLORES  (name in capitals is not confirmed, simply chosen by Tyler and Leebong reviewing the final report 346775)"
replace sector="Servicios" if company=="Grupo Trefra - Subempresa 4 - TREFRATELLI SAN CRISTOBAL"
replace sector="Servicios" if company=="Grupo Trefra - Subempresa 2 - JKM"
replace sector="Distribución y Venta minorista" if company=="COFAL - Subempresa 6 (CHEVI ZONA 11, MAJADAS from report 346775, name arbitrarily chosen) COFIÃ‘O STAHL Y COMPAÃ‘IA SOCIEDAD ANONIMA"
replace sector="Distribución y Venta minorista" if company=="COFAL - Subempresa 1 (Zona 5 from report 346775, name arbitrarily chosen) Cofiño Stahl y Compañía, S.A."
replace sector="Distribución y Venta minorista" if company=="COFAL - Subempresa 3 REGESA, S.A. (COFAL FIAT ZONA 11, MAJADAS from report 346775, name arbitrarily chosen) Cofiño Stahl"
replace sector="Distribución y Venta minorista" if company=="Acumuladores Iberia S. A."
replace sector="Servicios" if company=="ECO TERMO DE CENTROAMERICA, S.A. - Sala"
replace sector="Manufactura en general" if company=="INDUSTRIA CENTROAMERICANA DE SANITARIOS, S. A."
replace sector="Servicios" if company=="Industrial Don Pan"
replace sector="Servicios" if company=="Empresa de Proteccion y Vigilancia, S.A. (EMPROVISA), aka Empresa de ProtecciÃ³n y Vigilancia, S.A."
replace sector="Químicos y Plásticos" if  company=="PROINCO CONCRETO, BAJO LA REPRESENTACION LEGAL DEL ING RICARDO OROZCO"
replace sector="Químicos y Plásticos" if  company=="PROINCO-PLANTEL EL PORTILLO (Productos Industriales de Construcción, S.A. BAJO LA REPRESENTACION LEGAL DEL ING RICARDO OROZCO, aka PROINCO PLANTEL"
replace sector="Distribución y Venta minorista" if company=="TOYS SOCIEDAD ANONIMA"
replace sector="Químicos y Plásticos" if  company=="J031000004889/ AGRENIC-Triturado"
replace sector="Servicios no financieros" if company=="PRINDECA"
replace sector="Servicios" if company=="INCASA"
replace sector="Servicios" if company=="Estudios Corporativos, SA (VOSTV)"
replace sector="Manufactura en general" if company=="INNOVA S.A"
replace sector="Distribución y Venta minorista" if company=="Santasara SA (aka Centro Plaza de Occidente)"
replace sector="Servicios" if company=="Eficiencia energetica, aka Rectificacion Jhoanillo, aka Rectificacion Johanillo"
replace sector="Servicios" if company=="Reencauchadora Flores S.A."
replace sector="Servicios no financieros" if company=="ATLANTIC PACKAGING CENTRAL AMERICA S. DE R.L."
replace sector="Distribución y Venta minorista" if company=="PARTES ELECTRICAS AUTOMOTRICES S.A."
replace sector="Distribución y Venta minorista" if company=="HCE HONDURAS, S. DE R.L., aka HCE (MYRON)"
replace sector="Alimentación y Bebidas" if company=="BENEFICIO MAYA S. A. de C. V."
replace sector="Servicios" if company=="Fuente de Salud y Juventud S. de R.L"
replace sector="Distribución y Venta minorista" if company=="Parsema Total Lift S. de R.L."
replace sector="Distribución y Venta minorista" if company=="MADE IN CHINA"
replace sector="Servicios no financieros" if company=="Vesta Customs S.A. de C.V."
replace sector="Productos Agrícolas" if company=="Honduras American Tabaco S.A. (American Tobaco)"
replace sector="Madera, Pulpa y Papel" if company=="Cartonera Nacional S.A. (CANASA)"
replace sector="Químicos y Plásticos" if  company=="Vitra S. de R. L (VIDRIOS TRANSFORMADOS S.A de C.V.)"
replace sector="Distribución y Venta minorista" if company=="POLARIS INTERNACIONAL S. DE R.L."
replace sector="Manufactura en general" if company=="CIBASA / FOSFORERA"
replace sector="Distribución y Venta minorista" if company=="Corporacion Mediterraneo"

replace sector="Servicios Financieros" if company=="JUAN EDELFRIDO ROMERO ROMERO LEDEZMA"
replace sector="Servicios Financieros" if company=="JUAN EDELFRIDO ROMERO LEDEZMA"
replace sector="Hostelería y Turismo" if company=="Yakima S.A de C.V"
replace sector="Servicios no financieros" if company=="INSELVE"

replace sector="Servicios, otros" if sector=="Servicios"
replace sector="Servicios, otros" if sector=="Servicios Públicos"
replace sector="Servicios, otros" if sector=="Servicios no financieros"
replace sector="Servicios, otros" if sector=="Servicios y Suministros Sanitarios"
replace sector="Servicios, otros" if company=="European Cleaner S.A"


*Sector agregado
encode sector, generate (sector_n)
ta sector_n
numlabel sector_n , add
ta sector_n, miss /*4 observaciones que no tienen sector*/

gen sector_2 = 1 if sector_n==1 | sector_n==2  | sector_n==8 | sector_n==9 | sector_n==16  
replace sector_2 = 2 if sector_n==3 | sector_n==4 | sector_n==6 | sector_n==7 | sector_n==12 | sector_n==13 | sector_n==14 | sector_n==15 | sector_n==17 | sector_n==20 | sector_n==21
replace sector_2 = 3 if sector_n==5 | sector_n==11 | sector_n==18 | sector_n==19 /*No se incluyó el sector energía22 (2 obser)*/
replace sector_2 = 4 if sector_n==10 

label def sector_2 1 "Agronegocios" 2 "Manufacturas e Industrias"  3 "Servicios, Tecnología y Telecomunicaciones" 4 "Turismo"
label val sector_2 sector_2
numlabel sector_2 , add
ta sector_2, miss
table sector_n, c(max sector_2) miss

gen sector_BID = 1 if sector_n==1 | sector_n==2  | sector_n==8 | sector_n==9 | sector_n==16  
replace sector_BID = 2 if sector_n==4 | sector_n==7 | sector_n==12 | sector_n==13 | sector_n==15 | sector_n==17 | sector_n==20 
replace sector_BID = 3 if sector_n==5 | sector_n==11 | sector_n==18 | sector_n==19 
replace sector_BID = 4 if sector_n==10 
replace sector_BID = 5 if sector_n==3 | sector_n==6 | sector_n==14 | sector_n==21

label def sector_BID 1 "Agronegocios" 2 "Manufacturas e Industrias"  3 "Servicios, Tecnología y Telecomunicaciones" 4 "Turismo" 5 "Infraestructura"
label val sector_BID sector_BID
label var sector_BID "Sector Categorias BID Invest"
numlabel sector_BID , add
ta sector_BID, miss

*date de registracion 
gen registration_1 = date(registration, "MDY") 
gen registration_2 = registration if registration_1==.
replace registration_2= substr(registration_2,1,10)
gen registration_3 = date(registration_2, "DMY") 
format registration_1 %d
format registration_3 %d

gen registration_new=registration_1
replace registration_new=registration_3 if registration_new==.
format registration_new %d

gen registration_year = year(registration_new)
label var registration_year "Año de registro"

drop registration_1 registration_2 registration_3 registration
rename registration_new registration

*date de audit (para esto hice cambios en el excell)
rename LB_auditoria_fecha AES_date

gen AES_date_1 = date(AES_date, "MDY") 
gen AES_date_2 = AES_date if AES_date_1==.

replace AES_date_2= substr(AES_date_2,1,10)
replace AES_date_2="13/01/2014" if AES_date=="ENERO 13, 2014"
replace AES_date_2="16/01/2014" if AES_date=="ENERO 16, 2014"
replace AES_date_2="24/01/2014" if AES_date=="ENERO 24, 2014"
replace AES_date_2="10/02/2014" if AES_date=="FEBRERO 10, 2014"
replace AES_date_2="13/02/2014" if AES_date=="FEBRERO 13, 2014"
replace AES_date_2="17/12/2014" if AES_date=="DICIEMBRE 17, 2014"
replace AES_date_2="19/12/2014" if AES_date=="DICIEMBRE 19, 2014 "
replace AES_date_2="17/12/2013" if AES_date=="DICIEMBRE 17, 2013"
replace AES_date_2="17/04/2017" if AES_date=="03-147-2017"
replace AES_date_2="17/04/2017" if AES_date=="041-17-2017"
replace AES_date_2="10/04/2014" if AES_date=="10 abr"

gen AES_date_3 = date(AES_date_2, "DMY") 
format AES_date_1 %d
format AES_date_3 %d

gen AES_date_new=AES_date_1
replace AES_date_new=AES_date_3 if AES_date_new==.
format AES_date_new %d

gen AES_year = year(AES_date_new)
label var AES_year "Año de la audit sencilla"

drop AES_date_1 AES_date_2 AES_date_3 AES_date
rename AES_date_new AES_date

rename AED_fecha AED_date
gen AED_date_1 = date(AED_date, "MDY") 
gen AED_date_2 = AED_date if AED_date_1==.

replace AED_date_2= substr(AED_date_2,1,10)
gen AED_date_3 = date(AED_date_2, "DMY") 
format AED_date_1 %d
format AED_date_3 %d

gen AED_date_new=AED_date_1
replace AED_date_new=AED_date_3 if AED_date_new==.
format AED_date_new %d

gen AED_year = year(AED_date_new)
label var AED_year "Año de la audit detallada"

drop AED_date_1 AED_date_2 AED_date_3 AED_date
rename AED_date_new AED_date

*Recibió audit
replace LB_thidro_costo="." if LB_thidro_costo=="-" | LB_thidro_costo=="`75" | LB_thidro_costo=="nd"
destring LB_thidro_costo, replace
destring LB_thidro_GEI, replace
egen dato_AES=rownonmiss(AES_date LB_elect_uso LB_elect_costo LB_elect_GEI LB_factor_emision LB_thidro_costo LB_thidro_GEI )

replace LBD_factor_emision="0.292" if LBD_factor_emision=="0.292 " 
destring LBD_factor_emision, replace
replace LBD_thidro_costo="384145" if LBD_thidro_costo=="384145 mpc" 
destring LBD_thidro_costo, replace
destring LBD_thidro_GEI, replace
egen dato_AED=rownonmiss(AED_date LBD_elect_uso LBD_elect_costo LBD_elect_GEI LBD_factor_emision LBD_thidro_costo LBD_thidro_GEI )

gen audit=1 if dato_AES>0 & dato_AED==0
replace audit=2 if dato_AES==0 & dato_AED>0
replace audit=3 if dato_AES>0 & dato_AED>0
replace audit=4 if dato_AES==0 & dato_AED==0
label def audit 1 "Sencilla" 2 "Detallada" 3 "Ambas" 4 "Ninguna"
label val audit audit
label var audit "Tipo de audit recibida"
drop dato_AES dato_AED

*br dato_AES audit AES_date LB_elect_uso LB_elect_costo LB_elect_GEI LB_factor_emision LB_thidro_costo LB_thidro_GEI

gen audit_year=AES_year
replace audit_year=AED_year if audit==2 | audit==3
label var audit_year "Año de la audit realizada (última)"

*Informe IIC Aprobado
gen informe_CII=AES_informe_CII
replace informe_CII=AED_informe_CII if AED_informe_CII!=. & (audit==2 | audit==3)
label var informe_CII "Informe aprobada por CII"

*Activos: las dos variables son iguales
drop assets_1
gen assets=1 if assets_0=="0" | assets_0=="500,000 - 6,000,000" | assets_0=="4000000" | assets_0=="< 500,000" | assets_0=="< US$3,000,000" | assets_0=="< US$6,000,000" | assets_0=="US$3,000,000 - US$7,000,000"
replace assets=2 if assets_0=="6,000,000 - 10,000,000" | assets_0=="US$7,000,000 - US$10,000,000"
replace assets=3 if assets_0=="10,000,000 - 20,000,000" | assets_0=="US$10,000,000 - US$20,000,000" | assets_0=="US$6,000,000 - US$25,000,000"
replace assets=4 if assets_0=="20,000,000 - 35,000,000" | assets_0=="US$25,000,000 - US$35,000,000"
replace assets=5 if assets_0=="> 35,000,000" | assets_0=="> US$35,000,000"
label def assets 1 "US$0 - US$6,000,000" 2 "US$6,000,000 - US$10,000,000" 3 "US$10,000,000 - US$20,000,000" 4 "US$20,000,000 - US$35,000,000" 5 "US$35,000,000 o más"
label value assets assets
drop assets_0
tab assets, miss
br assets audit sector if sector_2==.

*Revenues
drop revenues_1 
gen revenues=1 if revenues_0=="0" | revenues_0=="500,000 - 6,000,000" | revenues_0=="4000000" | revenues_0=="< 500,000" | revenues_0=="< US$3,000,000" | revenues_0=="< US$6,000,000" | revenues_0=="US$3,000,000 - US$7,000,000"
replace revenues=2 if revenues_0=="6,000,000 - 10,000,000" | revenues_0=="US$7,000,000 - US$10,000,000"
replace revenues=3 if revenues_0=="10,000,000 - 20,000,000" | revenues_0=="US$10,000,000 - US$20,000,000" | revenues_0=="US$6,000,000 - US$25,000,000"
replace revenues=4 if revenues_0=="20,000,000 - 35,000,000" | revenues_0=="US$25,000,000 - US$35,000,000"
replace revenues=5 if revenues_0=="> 35,000,000" | revenues_0=="> US$35,000,000"
label value revenues assets

gen revenues_n=0 if revenues_0=="0" 
replace revenues_n=4000000 if revenues_0=="4000000"
replace revenues_n=500000 if revenues_0=="< 500,000" 
replace revenues_n=2750000 if revenues_0=="500,000 - 6,000,000" 
replace revenues_n=1500000 if revenues_0=="< US$3,000,000" 
replace revenues_n=3000000 if revenues_0=="< US$6,000,000" 
replace revenues_n=5000000 if revenues_0=="US$3,000,000 - US$7,000,000"
replace revenues_n=8000000 if revenues_0=="6,000,000 - 10,000,000" 
replace revenues_n=8500000 if revenues_0=="US$7,000,000 - US$10,000,000"
replace revenues_n=15000000 if revenues_0=="10,000,000 - 20,000,000" | revenues_0=="US$10,000,000 - US$20,000,000" 
replace revenues_n=15500000 if revenues_0=="US$6,000,000 - US$25,000,000"
replace revenues_n=27500000 if revenues_0=="20,000,000 - 35,000,000" 
replace revenues_n=30000000 if revenues_0=="US$25,000,000 - US$35,000,000"
replace revenues_n=35000000 if revenues_0=="> 35,000,000" | revenues_0=="> US$35,000,000"

*Age
gen datos_0=registration<td(07jul2015) 
drop datos_0 

gen age=1 if age_1=="Between 0 and 5 years"
replace age=2 if age_1=="Between 5 and 10 years"
replace age=3 if age_1=="Between 10 and 15 years"
replace age=4 if age_1=="Between 15 and 20 years"
replace age=5 if age_1=="Between 20 and 25 years"
replace age=6 if age_1=="More than 25 years"

label def age 1 "0-5" 2 "5-10" 3 "10-15" 4 "15-20" 5 "20-25" 6 ">25" 
label value age age

*Empleados: difieron mucho
replace employees_0="200" if employees_0=="200 en Oficinas Centrales "
replace employees_0="80" if employees_0=="80 PERSONAS EN SANTA CRUZ"
replace employees_0="<150" if employees_0=="< 150"

replace employees_1="2000" if employees_1=="2000 personas"
replace employees_1="3250" if employees_1=="3000-3500"
replace employees_1="45" if employees_1=="45 empleados"
replace employees_1="70" if employees_1=="70 empleados diarios"
replace employees_1="924" if employees_1=="924 empleados / 86 camas / 61% de ocupación en el 2014"
destring employees_1, replace 

gen employees_n=employees_0
replace employees_n="." if employees_n=="> 10" | employees_n=="N/A"
replace employees_n="75" if  employees_n=="<150"
replace employees_n="175" if employees_n=="150-200" 
replace employees_n="225" if employees_n=="200-250" 
replace employees_n="275" if employees_n=="250-300" 
replace employees_n="325" if employees_n=="300-350" 
replace employees_n="375" if employees_n=="350-400" 
replace employees_n="401" if employees_n==">400" 
destring employees_n, replace 
replace employees_n=employees_1 if employees_1<=150 & employees_0=="<150"

gen employees=1 if employees_n<=50
replace employees=2 if employees_n>50 & employees_n<=100 
replace employees=3 if employees_n>100 & employees_n<=150 
replace employees=4 if employees_n>150 & employees_n<=200 
replace employees=5 if employees_n>200 & employees_n<=250 
replace employees=6 if employees_n>250 & employees_n<=300 
replace employees=7 if employees_n>300 & employees_n<=350
replace employees=8 if employees_n>350 & employees_n<=400
replace employees=9 if employees_n>=400 

label def employees 1 "<50" 2 "50-100" 3 "100-150"  4 "150-200" 5 "200-250" 6 "250-300" 7 "300-350" 8 "350-400" 9 ">400" 
label val employees employees
label var employees "Empleados (categorias)"


*6)Merge de las Líneas de Base
tostring LBD_otro_GEI, replace
replace LB_elec_pahorro_GEI="." if LB_elec_pahorro_GEI=="-" | LB_elec_pahorro_GEI=="na"
destring LB_elec_pahorro_GEI, replace
destring LB_preduc_thidro_GEI, replace
replace LBD_pahorro_hidro_GEI="." if LBD_pahorro_hidro_GEI=="-" 
destring LBD_pahorro_hidro_GEI, replace
replace LB_TIR="." if LB_TIR=="-" | LB_TIR=="na"
destring LB_TIR, replace
replace LBD_VAN="5016882" if LBD_VAN=="50.168.82"
destring LBD_VAN, replace
replace LB_elec_pahorro_kwh="." if LB_elec_pahorro_kwh=="-" | LB_elec_pahorro_kwh=="na"
destring LB_elec_pahorro_kwh, replace
replace LBD_elec_pahorro_kwh="." if LBD_elec_pahorro_kwh=="-" | LBD_elec_pahorro_kwh=="na"
destring LBD_elec_pahorro_kwh, replace

*Limpieza de las varaibles en hidrocarburos 
global hidro LB_mhidro_GEI LB_pa_mhidro_GEI LBD_mhidro_GEI LBD_pa_mhidro_GEI M1_hidroc M2_hidroc
foreach var in $hidro {
gen OLD_`var'=`var'
replace `var'="." if `var'=="na" | `var'=="0" | `var'=="na "
replace `var'="Aceite Usado (gal)" if  `var'=="aceite usado-galon" | `var'=="Aceite Usado (como Bunker) - Gal"
replace `var'="Bunker" if  `var'=="bunker" | `var'=="Bunker-gal" | `var'=="B'unker"
replace `var'="Bunker (btu)" if  `var'=="Bunker - BTU" | `var'=="bunker - BTU"
replace `var'="Bunker (gal)" if `var'=="Bunker - Gal"  | `var'=="Bunker-galon" | `var'=="bunker-galon" | `var'=="Bunker-gal" | `var'=="bunker-gallon"
replace `var'="Bunker (lt)" if `var'=="Bunker - litros" | `var'=="bunker-litro" | `var'=="Bunker-litro" | `var'=="Bunker - L" | `var'=="bunker-litr" 
replace `var'="Bunker (lb)" if  `var'=="bunker-lb" 
replace `var'="Biomasa" if  `var'=="biomass" 
replace `var'="Biomasa: Aserrin" if  `var'=="aserrin (biomasa)" 
replace `var'="Biomasa: Madera" if  `var'=="biomasa - madera"  
replace `var'="Biomasa: Pelillo de palma" if  `var'=="biomasa: pelillo de palma" | `var'=="Pelillo de Palma"
replace `var'="Biomasa: Cascabillo de cafe + Diesel" if `var'=="Diesel + cascabillo de caf'e"
replace `var'="Biomasa: Cascarilla de Arroz (kg)" if  `var'=="Cascarilla de Arroz - Kg" 
replace `var'="Carbon (kg)" if `var'=="Carbon - kg" 
replace `var'="Diesel" if `var'=="diesel" | `var'=="Diesel  " | `var'=="Diésel" | `var'=="diésel"
replace `var'="Diesel (gal)" if `var'=="Diesel - Gal" | `var'=="diesel-galon" | `var'=="Diesel (Galones)" | `var'=="Diesel-galon" | `var'=="Disel - Gal" | `var'=="diesel galon" | `var'=="Diesel - gal"
replace `var'="Diesel (lt)" if `var'=="Diesel - L" | `var'=="diesel-litro" | `var'=="Diesel - Liters" | `var'=="Diesel - Litros" | `var'=="diesel - litros"
replace `var'="Diesel (kg)" if `var'=="diesel-kg"
replace `var'="Diesel (btu)" if `var'=="Diesel - BTU (BTU calc 96500/135240*1892.5*12)" | `var'=="Diesel - BTU"
replace `var'="Fuel Oil (gal)" if `var'=="Fuel Oil - Gal" | `var'=="fuel oil-galon"
replace `var'="Fuel Oil" if `var'=="fuel oil" | `var'=="Fuel oil" 
replace `var'="GLP + Diesel" if `var'=="Diesel + GLP" | `var'=="GLP + Diésel" | `var'=="diesel+glp" | `var'=="diesel + LPG" | `var'=="diesel -> LPG"
replace `var'="GLP + Gas Natural" if `var'=="Gas Natural + GLP" | `var'=="GN y GLP" | `var'=="GLP- > GN"
replace `var'="GLP" if `var'=="LPG" | `var'=="GLP "
replace `var'="GLP (kg)" if `var'=="GLP - kg" 
replace `var'="GLP (btu)" if `var'=="LPG - BTU" 
replace `var'="GLP (mcal)" if `var'=="GLP - Mcal" 
replace `var'="GLP (gal)" if `var'=="GLP - gal" | `var'=="GLP-galon" | `var'=="LPG - gal" | `var'=="LPG-galon" | `var'=="LGP-galon" | `var'=="LPG - Gal"
replace `var'="GLP (kwh)" if `var'=="GLP - kWh" 
replace `var'="GLP (mpc)" if `var'=="GLP - mpc" 
replace `var'="GLP (lt)" if `var'=="GLP-litro" | `var'=="LPG (litros)" | `var'=="LPG - L" | `var'=="LPG - Liters" | `var'=="LPG-litro" | `var'=="GLP - Litros" | `var'=="GLP - litros" | `var'=="GLP-liter"
replace `var'="Gas Natural" if `var'=="GN" | `var'=="Gas natural" | `var'=="gas natural" | `var'=="gn" | `var'=="natural gas" | `var'=="Gas Natural " | `var'=="gas natural " | `var'=="gas ntural"
replace `var'="Gas Natural (mpc)" if `var'=="Gas Natural - MPC" | `var'=="Gas Natural - mpc" | `var'=="Gas natural-mpc" | `var'=="gas natural-mpc" | `var'=="natural gas-mpc" | `var'=="GN (mpc)" | `var'=="GN - mpc"
replace `var'="Gas Natural (mcal)" if `var'=="Gas Natural - Mcal" 
replace `var'="Gas Propano" if  `var'=="propane gas" 
replace `var'="Gas Propano (gal)" if `var'=="Gas Propano - Gal" | `var'=="Gas propano - Gal" | `var'=="Propano - gal" | `var'=="Gas propano - gal" | `var'=="gas propano - gal" | `var'=="propane gas-galon" | `var'=="Propano - Gal"
replace `var'="Gasolina (lt)" if  `var'=="Gasolina - L" 
replace `var'="Gasolina (gal)" if  `var'=="Gasolina - Gal" | `var'=="gasoline-galon"
replace `var'="Gasolina" if  `var'=="gasoline" 
replace `var'="Leña" if  `var'=="leña" | `var'=="Leña (biomasa)"
replace `var'="Leña (kg)" if  `var'=="Leña - kg" 
replace `var'="Leña (lb)" if  `var'=="Leña-libras" | `var'=="leña-libras" 
replace `var'="Lubricante" if  `var'=="lubricante"
replace `var'="Kerosene (gal)" if  `var'=="Kerosene - Gal"
replace `var'="Kerosene (lt)" if  `var'=="canfin-litro"
}

label def medida 1 "mpc" 2 "kg" 3 "gal" 4 "lt" 5 "btu" 6 "mcal" 7 "lb" 8 "kwh" 9 "mp" 10 "tn"

global hidro2 LB_mhidro_GEI_uso LBD_mhidro_GEI_uso  LB_pa_mhidro_GEI_uso LBD_pa_mhidro_GEI_uso M1_hidroc_uso M2_hidroc_uso

foreach var in $hidro2 {
gen Z_`var' = `var' 
}
foreach var in $hidro2 {
gen `var'_mpc =  strpos(lower(Z_`var'), " mpc") > 0
replace Z_`var' = subinstr(lower(Z_`var'), " mpc", "", .)

gen `var'_mpc2 =  strpos(lower(Z_`var'), "mpc") > 0
replace Z_`var' = subinstr(lower(Z_`var'), "mpc", "", .)
 
gen `var'_kg2 =  strpos(lower(Z_`var'), " kg") > 0
replace Z_`var' = subinstr(lower(Z_`var'), " kg", "", .)

gen `var'_kg =  strpos(lower(Z_`var'), "kg") > 0
replace Z_`var' = subinstr(lower(Z_`var'), "kg", "", .)

gen `var'_gal3 =  strpos(lower(Z_`var'), " galones") > 0
replace Z_`var' = subinstr(lower(Z_`var'), " galones", "", .)

gen `var'_gal2 =  strpos(lower(Z_`var'), " galon") > 0
replace Z_`var' = subinstr(lower(Z_`var'), " galon", "", .)

gen `var'_gal =  strpos(lower(Z_`var'), " gal") > 0
replace Z_`var' = subinstr(lower(Z_`var'), " gal", "", .)

gen `var'_lt2 =  strpos(lower(Z_`var'), " litros") > 0
replace Z_`var' = subinstr(lower(Z_`var'), " litros", "", .)

gen `var'_lt =  strpos(lower(Z_`var'), " l") > 0
replace Z_`var' = subinstr(lower(Z_`var'), " l", "", .)

gen `var'_btu =  strpos(lower(Z_`var'), " btu") > 0
replace Z_`var' = subinstr(lower(Z_`var'), " btu", "", .)

gen `var'_mcal =  strpos(lower(Z_`var'), " mcal") > 0
replace Z_`var' = subinstr(lower(Z_`var'), " mcal", "", .)

gen `var'_lb =  strpos(lower(Z_`var'), " libras") > 0
replace Z_`var' = subinstr(lower(Z_`var'), " libras", "", .)

gen `var'_kwh =  strpos(lower(Z_`var'), " kwh") > 0
replace Z_`var' = subinstr(lower(Z_`var'), " kwh", "", .)

gen `var'_kwh2 =  strpos(lower(Z_`var'), "kwh") > 0
replace Z_`var' = subinstr(lower(Z_`var'), "kwh", "", .)


gen `var'_mp =  strpos(lower(Z_`var'), " mp") > 0
replace Z_`var' = subinstr(lower(Z_`var'), " mp", "", .)

gen `var'_tn =  strpos(lower(Z_`var'), " tn") > 0
replace Z_`var' = subinstr(lower(Z_`var'), " tn", "", .)

gen `var'_ton =  strpos(lower(Z_`var'), " ton") > 0
replace Z_`var' = subinstr(lower(Z_`var'), " ton", "", .)

gen `var'_tipo=1 if `var'_mpc==1 | `var'_mpc2==1 | `var'_mp==1
replace `var'_tipo=2 if `var'_kg==1 | `var'_kg2==1
replace `var'_tipo=3 if `var'_gal==1 | `var'_gal2==1 | `var'_gal3==1
replace `var'_tipo=4 if `var'_lt==1 | `var'_lt2==1
replace `var'_tipo=5 if `var'_btu==1
replace `var'_tipo=6 if `var'_mcal==1
replace `var'_tipo=7 if `var'_lb==1
replace `var'_tipo=8 if `var'_kwh==1 | `var'_kwh2==1
replace `var'_tipo=10 if `var'_tn==1 | `var'_ton==1
label val `var'_tipo medida
drop `var'_mpc `var'_mpc2 `var'_kg `var'_kg2 `var'_gal `var'_gal2 `var'_gal3 `var'_lt `var'_lt2 `var'_btu `var'_mcal `var'_lb `var'_kwh `var'_kwh2 `var'_mp `var'_tn `var'_ton
}

cap drop notnumeric
gen byte notnumeric = real(Z_LB_mhidro_GEI_uso)==.
ta Z_LB_mhidro_GEI_uso if notnumeric==1

*Arreglo los errores
replace Z_LB_mhidro_GEI_uso="2066.72" if Z_LB_mhidro_GEI_uso==" 2,066.72"
replace LB_mhidro_GEI="GLP" if Z_LB_mhidro_GEI_uso=="11,244 (lgp)"
replace Z_LB_mhidro_GEI_uso="11244" if Z_LB_mhidro_GEI_uso=="11,244 (lgp)"
replace Z_LB_mhidro_GEI_uso="25781" if Z_LB_mhidro_GEI_uso=="25,781"
replace Z_LB_mhidro_GEI_uso="1370.4" if Z_LB_mhidro_GEI_uso=="571/5*12"
replace Z_LB_mhidro_GEI_uso="30874.0519" if LB_mhidro_GEI_uso=="30 874.0519"
replace Z_LB_mhidro_GEI_uso="3412000" if company=="Industria de aceites y grasas Suprema S.A."
replace Z_LB_mhidro_GEI_uso="120000" if Z_LB_mhidro_GEI_uso=="120,000"

/*No sé como arreglar los que son dobles por el momento las dejo missing*/
replace Z_LB_mhidro_GEI_uso="" if Z_LB_mhidro_GEI_uso=="106253 + 3296.39" | Z_LB_mhidro_GEI_uso=="144522.24 k g + 6695.61" 
replace Z_LB_mhidro_GEI_uso="" if Z_LB_mhidro_GEI_uso=="153788 + 19969" | Z_LB_mhidro_GEI_uso=="212 + 17483" 
replace Z_LB_mhidro_GEI_uso="" if Z_LB_mhidro_GEI_uso=="23716 + 16015.04" | Z_LB_mhidro_GEI_uso=="28482.4 + 24000" 
replace Z_LB_mhidro_GEI_uso="" if Z_LB_mhidro_GEI_uso=="36861 + 49137" 
rename LB_mhidro_GEI_uso OLD_LB_mhidro_GEI_uso

cap drop notnumeric
gen byte notnumeric = real(Z_LB_mhidro_GEI_uso)==.
ta Z_LB_mhidro_GEI_uso if notnumeric==1
replace Z_LB_mhidro_GEI_uso="1427719" if Z_LB_mhidro_GEI_uso=="1427719/año" 

destring Z_LB_mhidro_GEI_uso, gen (LB_mhidro_GEI_uso)
drop Z_LB_mhidro_GEI_uso

cap drop notnumeric
gen byte notnumeric = real(Z_LBD_mhidro_GEI_uso)==.
ta Z_LBD_mhidro_GEI_uso if notnumeric==1

replace Z_LBD_mhidro_GEI_uso="" if Z_LBD_mhidro_GEI_uso=="5400 diesel  y 141752"
replace Z_LBD_mhidro_GEI_uso="" if Z_LBD_mhidro_GEI_uso=="na"
replace Z_LBD_mhidro_GEI_uso="874800" if Z_LBD_mhidro_GEI_uso=="874,800"
replace Z_LBD_mhidro_GEI_uso="4263.2" if Z_LBD_mhidro_GEI_uso=="4,263.2"
replace Z_LBD_mhidro_GEI_uso="3412000" if Z_LBD_mhidro_GEI_uso=="3,412,000/año"

replace Z_LBD_mhidro_GEI_uso="263.6" if LB_mhidro_GEI=="263.6"
replace LB_mhidro_GEI="." if LB_mhidro_GEI=="263.6"

replace Z_LBD_mhidro_GEI_uso="" if Z_LBD_mhidro_GEI_uso==" 4/17/1900"
replace Z_LBD_mhidro_GEI_uso="" if Z_LBD_mhidro_GEI_uso=="13000gal/45566gal"

cap drop notnumeric
gen byte notnumeric = real(Z_LBD_mhidro_GEI_uso)==.
ta Z_LBD_mhidro_GEI_uso if notnumeric==1

rename LBD_mhidro_GEI_uso OLD_LBD_mhidro_GEI_uso
destring Z_LBD_mhidro_GEI_uso, gen (LBD_mhidro_GEI_uso)
drop Z_LBD_mhidro_GEI_uso

cap drop notnumeric
gen byte notnumeric = real(Z_LB_pa_mhidro_GEI_uso)==.
ta Z_LB_pa_mhidro_GEI_uso if notnumeric==1

replace Z_LB_pa_mhidro_GEI_uso="4.7" if LB_pa_mhidro_GEI=="4.7"
replace LB_pa_mhidro_GEI="." if LB_pa_mhidro_GEI=="4.7"

replace LB_pa_mhidro_GEI="Diesel" if Z_LB_pa_mhidro_GEI_uso=="diesel" 
replace LB_pa_mhidro_GEI="Gas Natural" if Z_LB_pa_mhidro_GEI_uso=="gn" 

replace Z_LB_pa_mhidro_GEI_uso="" if Z_LB_pa_mhidro_GEI_uso=="a determirse" | Z_LB_pa_mhidro_GEI_uso=="diesel" | Z_LB_pa_mhidro_GEI_uso=="gn" | Z_LB_pa_mhidro_GEI_uso=="mpc" |  Z_LB_pa_mhidro_GEI_uso=="na"
replace Z_LB_pa_mhidro_GEI_uso="508" if Z_LB_pa_mhidro_GEI_uso=="508/ano" 
rename LB_pa_mhidro_GEI_uso OLD_LB_pa_mhidro_GEI_uso
destring Z_LB_pa_mhidro_GEI_uso, gen(LB_pa_mhidro_GEI_uso)
drop Z_LB_pa_mhidro_GEI_uso

cap drop notnumeric
gen byte notnumeric = real(Z_LBD_pa_mhidro_GEI_uso)==.
ta Z_LBD_pa_mhidro_GEI_uso if notnumeric==1

replace Z_LBD_pa_mhidro_GEI_uso="" if Z_LBD_pa_mhidro_GEI_uso=="gn + glp" 
replace Z_LBD_pa_mhidro_GEI_uso="6976.66" if Z_LBD_pa_mhidro_GEI_uso=="6,976.66" 
rename LBD_pa_mhidro_GEI_uso OLD_LBD_pa_mhidro_GEI_uso

cap drop notnumeric
gen byte notnumeric = real(Z_LBD_pa_mhidro_GEI_uso)==.
ta Z_LBD_pa_mhidro_GEI_uso if notnumeric==1

cap drop notnumeric
gen byte notnumeric = real(Z_LBD_pa_mhidro_GEI_uso)==.
ta Z_LBD_pa_mhidro_GEI_uso if notnumeric==1

replace Z_LBD_pa_mhidro_GEI_uso="" if Z_LBD_pa_mhidro_GEI_uso=="ó" 
replace Z_LBD_pa_mhidro_GEI_uso="155048" if Z_LBD_pa_mhidro_GEI_uso=="155048/ano" 

destring Z_LBD_pa_mhidro_GEI_uso, gen(LBD_pa_mhidro_GEI_uso)
drop Z_LBD_pa_mhidro_GEI_uso

cap drop notnumeric
gen byte notnumeric = real(Z_M1_hidroc_uso)==.
ta Z_M1_hidroc_uso if notnumeric==1
rename M1_hidroc_uso OLD_M1_hidroc_uso
destring Z_M1_hidroc_uso, gen(M1_hidroc_uso)
drop Z_M1_hidroc_uso

cap drop notnumeric
gen byte notnumeric = real(Z_M2_hidroc_uso)==.
ta Z_M2_hidroc_uso if notnumeric==1
rename M2_hidroc_uso OLD_M2_hidroc_uso
destring Z_M2_hidroc_uso, gen(M2_hidroc_uso)
drop Z_M2_hidroc_uso

*Convierto las medidas 
global hidro LB_mhidro_GEI LB_pa_mhidro_GEI LBD_mhidro_GEI LBD_pa_mhidro_GEI M1_hidroc M2_hidroc
foreach var in $hidro {

gen `var'_mpc =  strpos(lower(`var'), "mpc") > 0
gen `var'_kg =  strpos(lower(`var'), "kg") > 0
gen `var'_gal =  strpos(lower(`var'), "gal") > 0
gen `var'_lt =  strpos(lower(`var'), "lt") > 0
gen `var'_btu =  strpos(lower(`var'), "btu") > 0
gen `var'_mcal =  strpos(lower(`var'), "mcal") > 0
gen `var'_lb =  strpos(lower(`var'), "lb") > 0
gen `var'_kwh =  strpos(lower(`var'), "kwh") > 0

gen `var'_tipo=1 if `var'_mpc==1 
replace `var'_tipo=2 if `var'_kg==1
replace `var'_tipo=3 if `var'_gal==1 
replace `var'_tipo=4 if `var'_lt==1 
replace `var'_tipo=5 if `var'_btu==1
replace `var'_tipo=6 if `var'_mcal==1
replace `var'_tipo=7 if `var'_lb==1
replace `var'_tipo=8 if `var'_kwh==1 
label val `var'_tipo medida
drop `var'_mpc `var'_kg `var'_gal `var'_lt `var'_btu `var'_mcal `var'_lb `var'_kwh 
}

global hidro LB_mhidro_GEI LB_pa_mhidro_GEI LBD_mhidro_GEI LBD_pa_mhidro_GEI M1_hidroc M2_hidroc
foreach var in $hidro {
gen `var'_medida=`var'_uso_tipo 
replace `var'_medida=`var'_tipo if `var'_medida==.
label val `var'_medida medida
ta `var'_uso_tipo `var'_medida if `var'_uso_tipo!=. & `var'_tipo!=.
}

*Hay una observacion con error
br country_2d status registration company name_f name_l province country LBD_mhidro_GEI LBD_mhidro_GEI_uso ///
OLD_LBD_mhidro_GEI_uso LBD_mhidro_GEI_uso_tipo LBD_mhidro_GEI_uso_tipo if LBD_mhidro_GEI_uso_tipo==2 & LBD_mhidro_GEI_medida==1
       
global hidro LB_mhidro_GEI LB_pa_mhidro_GEI LBD_mhidro_GEI LBD_pa_mhidro_GEI M1_hidroc M2_hidroc
foreach var in $hidro {
drop `var'_uso_tipo `var'_tipo 
}

*Finalmente dejo la medida limpia de tipo de hidrocarburo
global hidro LB_mhidro_GEI LB_pa_mhidro_GEI LBD_mhidro_GEI LBD_pa_mhidro_GEI M1_hidroc M2_hidroc

foreach var in $hidro {
replace `var'="" if `var'=="."
replace `var'="Residuo: Aceite Usado" if  `var'=="Aceite Usado (gal)" 
replace `var'="Bunker" if `var'=="Bunker (btu)" | `var'=="Bunker (gal)" | `var'=="Bunker (lt)" | `var'=="Bunker (lb)" 
replace `var'="Biomasa: Cascarilla de Arroz" if  `var'=="Biomasa: Cascarilla de Arroz (kg)" 
replace `var'="Carbon" if `var'=="Carbon (kg)" 
replace `var'="Diesel" if `var'=="Diesel (gal)" | `var'=="Diesel (lt)" |  `var'=="Diesel (kg)" | `var'=="Diesel (btu)" 
replace `var'="Fuel Oil" if `var'=="Fuel Oil (gal)"
replace `var'="GLP" if `var'=="GLP (kg)" | `var'=="GLP (btu)" | `var'=="GLP (mcal)" | `var'=="GLP (gal)" | `var'=="GLP (kwh)" | `var'=="GLP (mpc)" | `var'=="GLP (lt)" 
replace `var'="Gas Natural" if `var'=="Gas Natural (mpc)" | `var'=="Gas Natural (mcal)" 
replace `var'="Gas Propano" if  `var'=="Gas Propano (gal)" | `var'=="Gas propano (kg)"
replace `var'="Gasolina" if `var'=="Gasolina (lt)" | `var'=="Gasolina (gal)" 
replace `var'="Leña" if `var'=="Leña (kg)" | `var'=="Leña (lb)" 
replace `var'="Kerosene" if  `var'=="Kerosene (gal)" | `var'=="Kerosene (lt)" 


}

*Creo la variable de factor de conversión
*medida 1 "mpc" 2 "kg" 3 "gal" 4 "lt" 5 "btu" 6 "mcal" 7 "lb" 8 "kwh" 10 "tn"


foreach var in $hidro {
gen `var'_fc_kwh=.
replace `var'_fc_kwh=5.84 if `var'=="Carbon" & `var'_medida==2 /*Uso el promedio de la lista */
replace `var'_fc_kwh=11.80 if `var'=="Diesel" & `var'_medida==2
replace `var'_fc_kwh=37.15 if `var'=="Diesel" & `var'_medida==3 
replace `var'_fc_kwh=9.82 if `var'=="Diesel" & `var'_medida==4
replace `var'_fc_kwh=0.00029307107017 if `var'=="Diesel" & `var'_medida==5
replace `var'_fc_kwh=40.97 if `var'=="Fuel Oil" & `var'_medida==3
replace `var'_fc_kwh=202156.97 if `var'=="GLP" & `var'_medida==1 /*Son 7480.52 galones */ 
replace `var'_fc_kwh=12.75 if `var'=="GLP" & `var'_medida==2
replace `var'_fc_kwh=27.02 if `var'=="GLP" & `var'_medida==3
replace `var'_fc_kwh=7.14 if `var'=="GLP" & `var'_medida==4
replace `var'_fc_kwh=0.00029307107017 if `var'=="GLP" & `var'_medida==5
replace `var'_fc_kwh=1.16298 if `var'=="GLP" & `var'_medida==6 /* 1 Mcal = 3,968.254 Btu (0.00029307107017 para pasar a kwh) => 1.162980446 */
replace `var'_fc_kwh=305.81 if `var'=="Gas Natural" & `var'_medida==1 
replace `var'_fc_kwh=1125.10557 if `var'=="Gas Natural" & `var'_medida==6 /* 1 megacaloría 3.67910 millones de pies cúbicos de gas =>   */
replace `var'_fc_kwh=12.83 if `var'=="Gas Propano" & `var'_medida==2
replace `var'_fc_kwh=24.92 if `var'=="Gas Propano" & `var'_medida==3
replace `var'_fc_kwh=35.21 if `var'=="Gasolina" & `var'_medida==3
replace `var'_fc_kwh=9.30 if `var'=="Gasolina" & `var'_medida==4
replace `var'_fc_kwh=36.08 if `var'=="Kerosene" & `var'_medida==3
replace `var'_fc_kwh=9.53 if `var'=="Kerosene" & `var'_medida==4
replace `var'_fc_kwh=3277 if `var'=="Leña" & `var'_medida==10 /*Uso el promedio de la lista */
replace `var'_fc_kwh=3.277 if `var'=="Leña" & `var'_medida==2 /*Uso el promedio de la lista */
replace `var'_fc_kwh=1.49 if `var'=="Leña" & `var'_medida==7 /*Uso el promedio de la lista */
replace `var'_fc_kwh=6.81 if `var'=="Residuo: Aceite Usado" & `var'_medida==3
replace `var'_fc_kwh=3.72 if `var'=="Biomasa: Cascarilla de Arroz" & `var'_medida==2
replace `var'_fc_kwh=3920 if `var'=="Biomasa" & `var'_medida==10
replace `var'_fc_kwh=3.84 if `var'=="Biomasa: Pelillo de palma" & `var'_medida==2 /*Use "Otros residuos forestales"*/ 
replace `var'_fc_kwh=0.00029307107017 if `var'=="unknown - BTU" & `var'_medida==5
replace `var'_fc_kwh=40.97 if `var'=="Bunker" & `var'_medida==3 /*Bunker: Combustible Bunker A equivale a fueloil No. 2, combustible bunker B equivale a fueloil No. 4 o No. 5 y combustible C equivale a fueloil No. 6. */
replace `var'_fc_kwh=10.82 if `var'=="Bunker" & `var'_medida==4
replace `var'_fc_kwh=0.00029307107017 if `var'=="Bunker" & `var'_medida==5
replace `var'_fc_kwh=5.02 if `var'=="Bunker" & `var'_medida==7
replace `var'_fc_kwh=36.90 if `var'=="Lubricante" & `var'_medida==3

replace `var'_fc_kwh=1 if `var'_medida==8
}

foreach var in $hidro {
gen `var'_kwh= `var'_uso *`var'_fc_kwh
}

*Reemplazos de las dobles
replace LB_mhidro_GEI_kwh=259883.2872 if OLD_LB_mhidro_GEI_uso=="212 mpc + 17483 kg" & OLD_LB_mhidro_GEI=="Gas Natural + GLP"
*212 mpc son 305.81*212=37003.01 kwh y 17483 kg de GLP son 17483*12.75=222880.2772 => 259883.2872
replace LB_mhidro_GEI_kwh=5968542.502 if OLD_LB_mhidro_GEI_uso=="153788 gal + 19969" & OLD_LB_mhidro_GEI=="Diesel + GLP" 
*Asumo que son kg, 153788 gal de Diesel son 5713969.703 kwh, 19969 kg se GLP son 254572.7996 kwh => 5968542.502
replace LB_mhidro_GEI_kwh=1995982.968 if OLD_LB_mhidro_GEI_uso=="36861 gal + 49137 kg" & OLD_LB_mhidro_GEI=="Diesel + GLP" 
*36861 gal de Diesel son 1369564.837 kwh, 49137 kg se GLP son 626418.1308 kwh => 1995982.968
replace LB_mhidro_GEI_kwh=2091201.694 if OLD_LB_mhidro_GEI_uso=="144522.24 k g + 6695.61 gal" & LB_mhidro_GEI=="GLP + Diesel" 
*6695.61 gal de Diesel son 248774.3691 kwh,144522.24  kg se GLP son 1842427.324 kwh => 2091201.694
replace LB_mhidro_GEI_kwh=1085330.502 if OLD_LB_mhidro_GEI_uso=="23716 gal + 16015.04" & LB_mhidro_GEI=="GLP + Diesel" 
*23716 gal de Diesel son 881164.3657 kwh, 16015.04 kg se GLP son 204166.1359 kwh => 1085330.502
replace LB_mhidro_GEI_kwh=1254821.371 if OLD_LB_mhidro_GEI_uso=="28482.4 kg + 24000 gal" & LB_mhidro_GEI=="GLP + Diesel" 
*24000 gal de Diesel son 891716.3424 kwh, 28482.4 kg se GLP son 363105.0282 kwh => 1254821.371
replace LB_mhidro_GEI_kwh=1477032.613 if OLD_LB_mhidro_GEI_uso=="106253kg + 3296.39" & LB_mhidro_GEI=="GLP + Diesel" 
*3296.39 gal de Diesel son 122476.8681 kwh, 106253 kg se GLP son 1354555.745 kwh => 1477032.613

replace LB_mhidro_GEI_kwh=2349852.039 if OLD_LB_mhidro_GEI_uso=="13000gal/45566gal" & OLD_LB_mhidro_GEI=="Diesel/Bunker"
*13000 gal de Diesel son 483013.0188 kwh y 45566 gal de Bunker son 1866839.02 kwh

*No sé que medida es "mp"
replace LBD_mhidro_GEI_kwh=1202857.36 if OLD_LBD_mhidro_GEI_uso=="5400 kg diesel  y 141752 kg" & LBD_mhidro_GEI=="Biomasa: Cascabillo de cafe + Diesel" 
*5400 kg de Diesel son 68841.36 kwh, 141752 kg son 1134016  kwh => 1202857.36

**Veo missings
replace LB_mhidro_GEI_uso=. if LB_mhidro_GEI_uso==0

br country_2d  status company  LB_mhidro_GEI  LB_mhidro_GEI_uso LB_mhidro_GEI_medida LB_mhidro_GEI_fc_kwh ///
LB_mhidro_GEI_kwh if LB_mhidro_GEI!="" & LB_mhidro_GEI_uso!=. & LB_mhidro_GEI_kwh==.

br country_2d  status company  LB_pa_mhidro_GEI  LB_pa_mhidro_GEI_uso LB_pa_mhidro_GEI_medida LB_pa_mhidro_GEI_fc_kwh ///
LB_pa_mhidro_GEI_kwh if LB_pa_mhidro_GEI!="" & LB_pa_mhidro_GEI_uso!=. & LB_pa_mhidro_GEI_kwh==.

br country_2d  status company  LBD_mhidro_GEI  LBD_mhidro_GEI_uso LBD_mhidro_GEI_medida LBD_mhidro_GEI_fc_kwh ///
LBD_mhidro_GEI_kwh if LBD_mhidro_GEI!="" & LBD_mhidro_GEI_uso!=. & LBD_mhidro_GEI_kwh==.

br country_2d  status company  LBD_pa_mhidro_GEI  LBD_pa_mhidro_GEI_uso LBD_pa_mhidro_GEI_medida LBD_pa_mhidro_GEI_fc_kwh ///
LBD_pa_mhidro_GEI_kwh if LBD_pa_mhidro_GEI!="" & LBD_pa_mhidro_GEI_uso!=. & LBD_pa_mhidro_GEI_kwh==.

br country_2d  status company  M1_hidroc  M1_hidroc_uso M1_hidroc_medida M1_hidroc_fc_kwh ///
M1_hidroc_kwh if M1_hidroc!="" & M1_hidroc_uso!=. & M1_hidroc_kwh==.

br country_2d  status company  M2_hidroc  M2_hidroc_uso M2_hidroc_medida M2_hidroc_fc_kwh ///
M2_hidroc_kwh if M2_hidroc!="" & M2_hidroc_uso!=. & M2_hidroc_kwh==.

*medida 1 "mpc" 2 "kg" 3 "gal" 4 "lt" 5 "btu" 6 "mcal" 7 "lb" 8 "kwh" 10 "tn"

global hidro LB_mhidro_GEI LB_pa_mhidro_GEI LBD_mhidro_GEI LBD_pa_mhidro_GEI M1_hidroc M2_hidroc
foreach var in $hidro {
replace `var'_fc_kwh=305.81 if `var'=="Gas Natural" & `var'_medida==. 
replace `var'_fc_kwh=3.4 if `var'=="Biomasa: Madera" & `var'_medida==.
replace `var'_fc_kwh=40.97 if `var'=="Bunker" & `var'_medida==.
replace `var'_fc_kwh=37.15 if `var'=="Diesel" & `var'_medida==.
replace `var'_fc_kwh=40.97 if `var'=="Fuel Oil" & `var'_medida==.
replace `var'_fc_kwh=27.02 if `var'=="GLP" & `var'_medida==.
replace `var'_fc_kwh=24.92 if `var'=="Gas Propano" & `var'_medida==.
replace `var'_fc_kwh=35.21 if `var'=="Gasolina" & `var'_medida==.
}

foreach var in $hidro {
capture drop `var'_kwh
gen `var'_kwh= `var'_uso *`var'_fc_kwh
}

*volver a calcular LB_pahorro LB_recupera LB_pahorro_elect LB_pahorro_hidro_GEI 

gen LB_Ahorro_EP=LB_elec_pahorro_usd+LB_pahorro_thidro_GEI
label var LB_Ahorro_EP "Ahorro potencial Economico Proyectado"
drop LB_pahorro

gen LBD_Ahorro_EP=LBD_elec_pahorro_usd+LBD_pahorro_thidro_GEI
label var LBD_Ahorro_EP "Ahorro potencial Economico Proyectado"
drop LBD_pahorro

gen LB_Anios_recupera_P=0 if LB_Ahorro_EP==.
replace LB_Anios_recupera_P=LB_inversion/LB_Ahorro_EP if LB_Ahorro_EP!=.
label var LB_Anios_recupera_P "Periodo de recuperación proyectado (en anios)"
drop LB_recupera

gen LBD_Anios_recupera_P=0 if LB_Ahorro_EP==.
replace LBD_Anios_recupera_P=LB_inversion/LB_Ahorro_EP if LB_Ahorro_EP!=.
label var LBD_Anios_recupera_P "Periodo de recuperacion proyectado (en anios)"
drop LBD_recupera

gen LB_Ahorro_elec_P=0 if LB_elect_uso==.
replace LB_Ahorro_elec_P=LB_elec_pahorro_kwh/LB_elect_uso if LB_elect_uso!=.
label var  LB_Ahorro_elec_P "Ahorro de electricidad proyectado (%)"
drop LB_pahorro_elect

gen LBD_Ahorro_elec_P=0 if LBD_elect_uso==.
replace LBD_Ahorro_elec_P=LBD_elec_pahorro_kwh/LBD_elect_uso if LBD_elect_uso!=.
label var  LBD_Ahorro_elec_P "Ahorro de electricidad proyectado (%)"
drop LBD_pahorro_elect

gen LB_Ahorro_GEI_P=0 if LB_thidro_GEI==.
replace LB_Ahorro_GEI_P=LB_preduc_thidro_GEI/LB_thidro_GEI if LB_thidro_GEI!=.
label var  LB_Ahorro_GEI_P "Ahorro de GEI directo (%)"
drop LB_pahorro_hidro_GEI

gen LBD_Ahorro_GEI_P=0 if LBD_thidro_GEI==.
replace LBD_Ahorro_GEI_P=LBD_preduc_thidro_GEI/LBD_thidro_GEI if LBD_thidro_GEI!=.
label var  LBD_Ahorro_GEI_P "Ahorro de GEI directo (%)"
drop LBD_pahorro_hidro_GEI

 
*Creo la variables LBM: unen las dos lineas de base
global LB informeCII recommend info_empresa metodos_aud elect_uso elect_costo ///
elect_GEI factor_emision mhidro_GEI mhidro_GEI_kwh thidro_costo thidro_GEI otro_GEI ///
elec_pahorro_kwh elec_pahorro_usd elec_pahorro_GEI pfactor_emision pa_mhidro_GEI ///
pa_mhidro_GEI_kwh pahorro_thidro_GEI preduc_thidro_GEI pahorro_otro_GEI ///
inversion Ahorro_EP Anios_recupera_P TIR VAN Ahorro_elec_P Ahorro_GEI_P estim_incluye incluye_ppolit  

foreach var in $LB {
gen LBM_`var'= LB_`var' 
replace LBM_`var'= LBD_`var' if audit==2 | audit==3
}

label var M1_hidroc_kwh "Ahorro del uso de hidrocarburo en kwh"
label var M2_hidroc_kwh "Ahorro del uso de hidrocarburo en kwh"

do Do\Greenpyme_labels2.do

*7)Borro variabkes que javier dijo que no estaban bien
drop M1_motivo_costs M1_motivo_environment M1_motivo_productivity M1_barrera_financing M1_barrera_technical M1_barrera_other M1_quote
drop M2_motivo_costs M2_motivo_environment M2_motivo_productivity M2_barrera_financing M2_barrera_technical M2_barrera_other M2_quote

*8) Creo la variable Adopción (1 si adoptó algunas de las medidas y 0 si no adopto)
replace M2_implement="" if M2_implement=="EZSHARE-241863507-2382"
destring M2_implement, replace

gen adopcion=0 if M1_implement==0 & (M2_implement==0 | M2_implement==. )
replace adopcion=0 if (M1_implement==. & M1_aCII==1) | (M2_implement==. & M2_aCII==1)
replace adopcion=1 if (M1_implement!=. & M1_implement>0) | (M2_implement!=. & M2_implement>0)

order company country_2d approved country_n city province sector_n registration registration_year AES_year AED_year audit ///
assets revenues age employees_n informe_CII LBM_*

*9) Veo las variables de fecha

global fechas AES_entrega_ AED_pago_ M1_ M1_p M1_light_1 M1_compress_1 ///
M1_hidroc_1 M2_ M2_p M2_light_1 M2_AC_1 

foreach var in $fechas {
gen `var'date = date(`var'fecha, "DMY")
label var `var'date `var'fecha
format `var'date %td
drop `var'fecha
}


replace M1_oelec_1fecha="4/1/2015" if M1_oelec_1fecha=="apr 1 2015"
gen M1_oelec_1date = date(M1_oelec_1fecha, "DMY")
label var M1_oelec_1date M1_oelec_1fecha
format M1_oelec_1date %td
drop M1_oelec_1fecha

replace M2_oelec_1fecha="" if M2_oelec_1fecha=="-"
replace M2_oelec_1fecha="" if M2_oelec_1fecha==" 1/17/1900"
replace M2_oelec_1fecha="26/3/2015" if M2_oelec_1fecha==" 3/26/2015"
gen M2_oelec_1date = date(M2_oelec_1fecha, "DMY")
label var M2_oelec_1date M2_oelec_1fecha
format M2_oelec_1date %td
drop M2_oelec_1fecha

global fecha M1_AC M1_hwater M1_eprod M1_electric M2_hwater M2_compress  ///
M2_eprod  M2_electric M2_hidroc 

foreach var in $fecha {
gen `var'_1date = `var'_1fecha 
label var `var'_1date `var'_1fecha
drop `var'_1fecha
}

replace AED_contrato_ffirma="" if AED_contrato_ffirma=="EZSHARE-241863507-2253 " | AED_contrato_ffirma=="EZSHARE-241863507-2254 "
gen AED_contrato_date = date(AED_contrato_ffirma, "DMY")
label var AED_contrato_date AED_contrato_ffirma
format AED_contrato_date %td
drop AED_contrato_ffirma

*10) Limpio otras variables

*Horas trabajadas
gen ohours_c=1 if ohours=="Less than 20 hours"
replace ohours_c=2 if ohours=="Between 20 and 40 hours"
replace ohours_c=3 if ohours=="Between 40 and 60 hours"
replace ohours_c=4 if ohours=="Between 60 and 80 hours"
replace ohours_c=5 if ohours=="More than 80 hours"
drop ohours
rename ohours_c ohours
label define ohours 1 "<20 hs" 2 "20-40 hs" 3 "40-60 hs" 4 "60-80 hs" 5 ">80 hs" 
label var ohours "Facility’s operating hours per week"
label val ohours ohours

*Como conoció greenpyme 
replace  GREENPYME="Banco" if GREENPYME=="Bank"
replace  GREENPYME="Cámara de Comercio e Industria" if GREENPYME=="Chamber of Commerce and Industry"
replace  GREENPYME="Auditor Eficiencia Energética" if GREENPYME=="Energy Efficiency Auditor"
replace  GREENPYME="Taller Eficiencia Energética" if GREENPYME=="Energy Efficiency Workshop"
replace  GREENPYME="Periódico" if GREENPYME=="Newspaper"
replace  GREENPYME="Otros" if GREENPYME=="Other" 
replace  GREENPYME="Otros" if GREENPYME=="other" 

encode GREENPYME, gen (GREENPYME_c)
drop GREENPYME
rename GREENPYME_c GREENPYME

*Superficie
gen surface_mt2=surface

replace surface_mt2 = subinstr(lower(surface_mt2), " metros cuadrados ", "", .)
replace surface_mt2 = subinstr(lower(surface_mt2), " metros cuadrados", "", .)
replace surface_mt2 = subinstr(lower(surface_mt2), " metros cuadroados", "", .)
replace surface_mt2 = subinstr(lower(surface_mt2), " mts cuadrados", "", .)
replace surface_mt2 = subinstr(lower(surface_mt2), "mts cuadrados", "", .)
replace surface_mt2 = subinstr(lower(surface_mt2), " mtrs cuadrados", "", .)
replace surface_mt2 = subinstr(lower(surface_mt2), " m cuadrados", "", .)
replace surface_mt2 = subinstr(lower(surface_mt2), " mts2.", "", .)
replace surface_mt2 = subinstr(lower(surface_mt2), " mts2", "", .)
replace surface_mt2 = subinstr(lower(surface_mt2), " mts2", "", .)
replace surface_mt2 = subinstr(lower(surface_mt2), " mts 2", "", .)
replace surface_mt2 = subinstr(lower(surface_mt2), " mt2", "", .)
replace surface_mt2 = subinstr(lower(surface_mt2), "mt2", "", .)
replace surface_mt2 = subinstr(lower(surface_mt2), " m2", "", .)
replace surface_mt2 = subinstr(lower(surface_mt2), "m2", "", .)
replace surface_mt2 = subinstr(lower(surface_mt2), " m^2 ", "", .)
replace surface_mt2 = subinstr(lower(surface_mt2), "m^2", "", .)
replace surface_mt2 = subinstr(lower(surface_mt2), " (m2)", "", .)
replace surface_mt2 = subinstr(lower(surface_mt2), " aproximadamente", "", .)
replace surface_mt2 = subinstr(lower(surface_mt2), " aprox", "", .)
replace surface_mt2 = subinstr(lower(surface_mt2), "aproximadamente ", "", .)
replace surface_mt2 = subinstr(lower(surface_mt2), "aprox ", "", .)
replace surface_mt2 = subinstr(lower(surface_mt2), "aproximadamente", "", .)

replace surface_mt2 = subinstr(lower(surface_mt2), "aprox. ", "", .)

replace surface_mt2 = subinstr(lower(surface_mt2), " metros ", "", .)
replace surface_mt2 = subinstr(lower(surface_mt2), " metros", "", .)
replace surface_mt2 = subinstr(lower(surface_mt2), " mts ", "", .)
replace surface_mt2 = subinstr(lower(surface_mt2), " mts", "", .)
replace surface_mt2 = subinstr(lower(surface_mt2), "mts", "", .)
replace surface_mt2 = subinstr(lower(surface_mt2), "cuadroados", "", .)
replace surface_mt2 = subinstr(lower(surface_mt2), "estimados", "", .)
replace surface_mt2 = subinstr(lower(surface_mt2), "mas de ", "", .)
replace surface_mt2 = subinstr(lower(surface_mt2), " m²", "", .)

replace surface_mt2 ="" if surface_mt2=="arrendamos" | surface_mt2=="dato por confirmar" | surface_mt2=="empresa no da información"
replace surface_mt2 ="" if surface_mt2=="n/a" | surface_mt2=="n/r" | surface_mt2=="na" | surface_mt2=="nd" | surface_mt2=="no aplica"
replace surface_mt2 ="" if surface_mt2=="no aplica " | surface_mt2=="no disponible" | surface_mt2=="no lo tiene el dato"
replace surface_mt2 ="" if surface_mt2=="no se cuenta con ese registro" | surface_mt2=="no tengo el dato "
replace surface_mt2 ="" if surface_mt2=="no tengo esa informacion a mano " | surface_mt2=="no tiene el dato"
replace surface_mt2 ="" if surface_mt2=="nr" | surface_mt2=="pendiente de confirmar" | surface_mt2=="sin dato preciso"
replace surface_mt2 ="" if surface_mt2=="x" | surface_mt2=="xx"

replace surface_mt2 ="580.00" if surface_mt2=="vivienda  580.00" 
replace surface_mt2 ="1600" if surface_mt2=="800 cada edificio" 
replace surface_mt2 ="10000" if surface_mt2=="10mil" 
replace surface_mt2 ="12000" if surface_mt2=="12,000 m 3" 
replace surface_mt2 ="700" if surface_mt2=="700 (incluye taller de 250)" 
replace surface_mt2 ="150" if surface_mt2=="150 mt" 
replace surface_mt2 ="341" if surface_mt2=="170.5, primera planta y segunda planta igual, haciendo un total de 341." 
replace surface_mt2 ="200" if surface_mt2=="50x40" 
replace surface_mt2 ="757.82" if surface_mt2=="757.82  ()" 
replace surface_mt2 ="10000" if surface_mt2=="10 mil" 
replace surface_mt2 ="360000" if surface_mt2=="900x400" 
replace surface_mt2 ="" if surface_mt2=="3 aÃ±os" 
replace surface_mt2 ="" if surface_mt2=="es un edificio ocupado por varias agencias onu" 
replace surface_mt2 ="6081.58" if surface_mt2=="6081.58 en dos propiedades una horizontal y otra vertical" 
replace surface_mt2 ="1000" if surface_mt2==">1000" 
replace surface_mt2 ="12032" if surface_mt2=="12.032 ()" 
replace surface_mt2 ="8500" if surface_mt2=="la nave principal cuanta con 3,200 y las naves auxiliares tienen 2,640" 
replace surface_mt2 ="850" if surface_mt2=="500 y 350" 
replace surface_mt2 ="2500" if surface_mt2=="2500m" 
replace surface_mt2 ="200" if surface_mt2=="10x20" 
replace surface_mt2 ="3000" if surface_mt2=="una cuadra completa 3000" 
replace surface_mt2 ="22000" if surface_mt2=="más de 16,000 (área techada), más 6000 (área pavimentada)." 
replace surface_mt2 ="" if surface_mt2=="3098kw/h" 
replace surface_mt2 ="420000" if surface_mt2=="420,000 m" 
replace surface_mt2 ="5625" if surface_mt2=="5625 mt.2" 
replace surface_mt2 ="15" if surface_mt2=="15 ()" 
replace surface_mt2 ="" if surface_mt2=="esta información varía por agencia, sucursal." 
replace surface_mt2 ="10000" if surface_mt2=="<10,000" 
replace surface_mt2 ="1000" if surface_mt2=="1000 mt " 
replace surface_mt2 ="1228" if surface_mt2=="1228 (un mil dos cientos veintiocho" 
replace surface_mt2 ="3200" if surface_mt2=="3200esto por confirmar" 
replace surface_mt2 ="3240" if surface_mt2=="3,240         (incluye patio    de secado,    área secadoras, trillas y 5 bodegas)." 
replace surface_mt2 ="25166" if surface_mt2=="25166  se incluyen casas de estudiantes, edificios, calles, parqueos y algunas areas recreativas" 
replace surface_mt2 ="580" if surface_mt2=="  vivienda  580.00" 
replace surface_mt2 ="23000" if surface_mt2=="22,000 - 24,000" 
replace surface_mt2 ="10000" if surface_mt2=="10.000 mtrsimandamente en 2 plantas" 
replace surface_mt2 ="3000" if surface_mt2=="hora unos 3,000, en proyecto 10,000"
replace surface_mt2 ="2940.88" if surface_mt2=="2,94.88"

capture drop notnumeric
gen byte notnumeric = real(surface_mt2)==.
ta surface_mt2 if notnumeric==1

replace surface_mt2 ="9200" if surface_mt2=="9.200,00"
replace surface_mt2 ="2503.27" if surface_mt2=="2.503,27"
replace surface_mt2 ="76862" if surface_mt2=="76.862,00"
replace surface_mt2 ="6988.96" if surface_mt2=="6988,96"


*Relación m2 v2: 1 v2 - 0.6987 m2
replace surface_mt2 ="440.14607" if surface_mt2==" 629.95 v2"
replace surface_mt2 ="838.44" if surface_mt2=="1200 v2"
replace surface_mt2 ="1397.4" if surface_mt2=="2000 v2"


*Relación m2 hectareas: 1 h - 10000 mz
replace surface_mt2 ="2000000" if surface_mt2=="200 hectareas"
replace surface_mt2 ="1500000" if surface_mt2=="150 hectareas de terreno"
replace surface_mt2 ="80000" if surface_mt2=="8 hectarias"


*Relación m2 manzana: 1 manzana - 6988,96 m² 

replace surface_mt2 ="20966.88" if surface_mt2=="3 manzanas"
replace surface_mt2 ="6988,96" if surface_mt2=="manzana"
replace surface_mt2 ="6988,96" if surface_mt2=="todo el campus"

replace surface_mt2 = subinstr(lower(surface_mt2), ",", "", .)
destring surface_mt2, replace

*Veo si tiene dato de monitoreo
replace M1_hwater_costo="" if M1_hwater_costo=="Cambio de 3 motores rebobinados"
destring M1_hwater_costo, replace

replace M1_oelec_costo="" if M1_oelec_costo=="-" | M1_oelec_costo=="nd"
destring M1_oelec_costo, replace

capture drop notnumeric
gen byte notnumeric = real(M1_hidroc_costo)==.
ta M1_hidroc_costo if notnumeric==1

replace M1_electric_costo="" if M1_electric_costo=="í"
replace M1_hidroc_costo="" if M1_hidroc_costo=="-"
destring M1_electric_costo M1_hidroc_costo, replace

foreach var in M1_light_costo M1_hwater_costo M1_compress_costo M1_eprod_costo M1_oelec_costo M1_electric_costo M1_hidroc_costo {
replace `var'=. if `var'==0
}

egen dato_M1=rownonmiss(M1_light_costo M1_hwater_costo M1_compress_costo M1_eprod_costo M1_oelec_costo M1_electric_costo M1_hidroc_costo)
gen monitoreo=(dato_M1>0 & dato_M1!=.)


*Limpio consumo de electricidad cargado antes de la linea de base 
replace elec_kWh="4202484.32" if elec_kWh==" 4,202,484.32  kWh 4,202,484.32  "
replace elec_kWh="1407217" if elec_kWh=="1,407,217 Kwh/año"
replace elec_kWh="1303334" if elec_kWh=="1.303.334"
replace elec_kWh="1512399" if elec_kWh=="1.512.399,00 kW-h/año"
replace elec_kWh="1790000" if elec_kWh=="1.790.000"
replace elec_kWh="120000" if elec_kWh=="10,000 Kwh en promedio mensual"
replace elec_kWh="10999656" if elec_kWh=="10.999.656 "
replace elec_Currency="1007383" if elec_Currency=="." & elec_kWh=="1007383 Dolares anuales"
replace elec_kWh="." if elec_kWh=="1007383 Dolares anuales"
replace elec_kWh="13200" if elec_kWh=="13200 kwh"
replace elec_kWh="137091" if elec_kWh=="137,091 KW/H. (CONSUMO DE ENERO A DICIEMBRE/2011)"
replace elec_kWh="14688" if elec_kWh=="14688 kwh"
replace elec_kWh="150000" if elec_kWh=="150,000 kWh"
replace elec_kWh="15000000" if elec_kWh=="15000000  kwh"
replace elec_Currency="160000" if elec_Currency=="." & elec_kWh=="160 mil dolar"
replace elec_kWh="." if elec_kWh=="160 mil dolar"
replace elec_kWh="165384" if elec_kWh=="165.384"
replace elec_kWh="17842" if elec_kWh=="17.842"
replace elec_kWh="170500" if elec_kWh=="170.500,0 kW-h/año"
replace elec_kWh="17072" if elec_kWh=="17072 kw al año promedio 2013"
replace elec_kWh="2100000" if elec_kWh=="2,100,000.00 en promedio anual"
replace elec_kWh="2397920" if elec_kWh=="2,397,920 promedio anual"
replace elec_kWh="200" if elec_kWh=="200 previsto"
replace elec_kWh="200000000" if elec_kWh=="200.000.000"
replace elec_kWh="20000" if elec_kWh=="20000 KWH al aÃ±o"
replace elec_Currency="22800" if elec_Currency=="." & elec_kWh=="22.800 dolares norteamericanos"
replace elec_kWh="." if elec_kWh=="22.800 dolares norteamericanos"
replace elec_kWh="240000" if elec_kWh=="240,000 kWh"
replace elec_kWh="25793" if elec_kWh=="25,793  kwh  en un aÃ±o"
replace elec_kWh="250000" if elec_kWh=="250,000 kWh"
replace elec_kWh="304320" if elec_kWh=="25360 kwh en promedio mensual"
replace elec_kWh="258000" if elec_kWh=="258,000 kw"
replace elec_kWh="32400" if elec_kWh=="2700 kw/h al mes"
replace elec_kWh="30504" if elec_kWh=="30504 Kw/h"
replace elec_kWh="3138" if elec_kWh=="3138 KW/H"
replace elec_kWh="345" if elec_kWh=="331.9007529 - 361.668075"
replace elec_kWh="420000" if elec_kWh=="35000 KWH Prom Mensual"
replace elec_kWh="4188889" if elec_kWh=="4,188,889 anual"
replace elec_kWh="45000" if elec_kWh=="40,000-50,000"
replace elec_kWh="4000" if elec_kWh=="4000 kwh"
replace elec_kWh="40000" if elec_kWh=="40000 en promedio "
replace elec_kWh="4202484.32" if elec_kWh=="4202484.32 kWh"
replace elec_kWh="425000" if elec_kWh=="425,000 kW/h"
replace elec_kWh="453764" if elec_kWh=="453764 kwh"
replace elec_kWh="494500" if elec_kWh=="494500 kWh por año"
replace elec_kWh="6000000" if elec_kWh=="500,000 promedio mensual"
replace elec_kWh="660000" if elec_kWh=="55,000 kiwh/mes, 660,000 kwh/año"
replace elec_kWh="60000" if elec_kWh=="60000 aprox"
replace elec_kWh="600732" if elec_kWh=="600732 KWH"
replace elec_kWh="602420" if elec_kWh=="602420 kWh"
replace elec_kWh="73632" if elec_kWh=="6136 promedio mensual"
replace elec_kWh="46500" if elec_kWh=="62,000 en 16 meses"
replace elec_kWh="783648" if elec_kWh=="65304 Kwh/mes"
replace elec_kWh="6600000" if elec_kWh=="6600000 (APROX)"
replace elec_kWh="694543" if elec_kWh=="694543 kwh"
replace elec_kWh="70" if elec_kWh=="70.00 kwh"
replace elec_kWh="701340" if elec_kWh=="701340KWH"
replace elec_kWh="748104" if elec_kWh=="748104KWH"
replace elec_kWh="900000" if elec_kWh=="75,000 kWh  mensual"
replace elec_kWh="8500000" if elec_kWh=="8.500.000"
replace elec_kWh="974400" if elec_kWh=="81200 en promedio mensual"
replace elec_kWh="70900" if elec_kWh=="En el aÃ±o 2011 se consumieron 70,900 Kwh. , en promedio mensual 5,900 Kwh."
replace elec_kWh="175000" if elec_kWh=="Aproximadamente 150000 a 200000 KWH"
replace elec_kWh="895456" if elec_kWh=="895 456.00 KWh NOSOTROS TENEMOS TARIFA TNT INDUSTRIAL"
replace elec_kWh="87748" if elec_kWh=="kwh 87,748"
replace elec_kWh="18000000" if elec_kWh=="promedio 1.500.000 mes"
replace elec_kWh="." if elec_kWh=="Lo estamos investigando" | elec_kWh=="N/A" | elec_kWh=="NA" | elec_kWh=="NO TENGO DATOS EXACTOS" 
replace elec_kWh="." if elec_kWh=="NR" | elec_kWh=="X" | elec_kWh=="XX" | elec_kWh=="empresa no da información" 
replace elec_kWh="." if elec_kWh=="kw" | elec_kWh=="kwh bt " | elec_kWh=="n/a" | elec_kWh=="no lo registramos" 
replace elec_kWh="." if elec_kWh=="nr" | elec_kWh=="por determinar" | elec_kWh=="tension media" | elec_kWh=="x" 
replace elec_kWh="." if elec_kWh=="12,120 m2"
replace elec_kWh="." if elec_kWh=="300.000tmt"
replace elec_kWh="96100208" if elec_kWh=="96.100.208"
destring elec_kWh, replace

rename elec_kWh elec_kwh
label var elec_kwh "Electric energy consumption per year in kw/h"

rename elec_Currency elec_usd
label var elec_usd "Electric energy consumption per year in USD"

*Encontrar los nonumericos
cap drop notnumeric
gen byte notnumeric = real(elec_usd)==.
ta elec_usd if notnumeric==1
drop notnumeric

replace elec_usd="22504.03" if elec_usd=="$ 22,504.03 promedio"
replace elec_usd="2422000" if elec_usd=="$2.422.000,00"
replace elec_usd="26400" if elec_usd=="$2200 PROMEDIO MENSUAL"
replace elec_usd="44400" if elec_usd=="$3700/mes"
replace elec_usd="50000" if elec_usd=="$50,000.00 al año"
replace elec_usd="181157" if elec_usd=="\$us. 181.157"
replace elec_usd="1823" if elec_usd=="1,823.00 por mes"
replace elec_usd="102000" if elec_usd=="102,000.00 US$"
replace elec_usd="108000000" if elec_usd=="108 millones"
replace elec_usd="12000000" if elec_usd=="12,ooo.ooo.oo"
replace elec_usd="144000000" if elec_usd=="12.000.000 por mes"
replace elec_usd="15000" if elec_usd=="15000 \$us/año"
replace elec_usd="39000000" if elec_usd=="168&#039;000.000"
replace elec_usd="20000" if elec_usd=="20,000 USD"
replace elec_usd="2400000" if elec_usd=="2400000.00 al aÃ±o 200000.00mensual"
replace elec_usd="24000000" if elec_usd=="24000000.00 al aÃ±o 2000000.00 al mes"
replace elec_usd="3000000" if elec_usd=="250 000 por mes"
replace elec_usd="26857" if elec_usd=="26.857 dolares"
replace elec_usd="300000" if elec_usd=="300 mil dólares"
replace elec_usd="36000" if elec_usd=="3000 dolares mensuales"
replace elec_usd="30000" if elec_usd=="30000 promedio "
replace elec_usd="34500" if elec_usd=="34,500 US$"
replace elec_usd="360000000" if elec_usd=="360000000 al aÃ±o"
replace elec_usd="44000000" if elec_usd=="44.000.000"
replace elec_usd="5713.56" if elec_usd=="5.713,56  dolares norteamericanos"
replace elec_usd="600000000" if elec_usd=="600.000.000.00 al aÃ±o "
replace elec_usd="66000" if elec_usd=="66000 U\$D"
replace elec_usd="700000" if elec_usd=="700 000"
replace elec_usd="79801.18" if elec_usd=="79.801,18 \$us/año"
replace elec_usd="8621" if elec_usd=="8621 dolares norteamericanos"
replace elec_usd="927000000" if elec_usd=="927000000 al aÃ±o "
replace elec_usd="." if elec_usd=="AED directa aprobada iicdocs  473254"
replace elec_usd="135000" if elec_usd=="DE 120,000 A 150,000 DOLARES ANUALES"
replace elec_usd="33774.55" if elec_usd=="US$ 33,774.55"
replace elec_usd="32493" if elec_usd=="USD 32,493"
replace elec_usd="24000" if elec_usd=="USD24000"
replace elec_usd="10396" if elec_usd=="anual $10,396"
replace elec_usd="1000000" if elec_usd=="más de 1000000 por local"
replace elec_usd="1200" if elec_usd=="us1200"
replace elec_usd="24000" if elec_usd=="USD24000"
replace elec_usd="18000" if elec_usd=="us18000"
replace elec_usd="7000" if elec_usd=="us7000"
replace elec_usd="90000" if elec_usd=="us90000"
replace elec_usd="13896.30" if elec_usd=="usd13896.30"
replace elec_usd="800" if elec_usd=="usd800"

replace elec_usd="950" if elec_usd=="$950(energia electrica) $340(gas propano)"
replace elec_usd="4500" if elec_usd=="4500 dolares"
replace elec_usd="10000" if elec_usd=="Diez mil dolares"
replace elec_usd="30000" if elec_usd=="El consumo promedio al mes de U$2,500 al ano seria U$30,000"
replace elec_usd="462000" if elec_usd=="durante los ultimos doce meses se pagaron aproximadamente C$12,000,000 (US$462,000)"

replace elec_usd="." if elec_usd=="N/R" | elec_usd=="NO SE QUE ES ESTO" | elec_usd=="NR" | elec_usd=="No aplica" 
replace elec_usd="." if elec_usd=="No indica " | elec_usd=="No indica no se tiene la informaciÃ³n " | elec_usd=="No tenia el dato" 
replace elec_usd="." if elec_usd=="no aplica " | elec_usd=="no envio informacion" | elec_usd=="no tiene el dato" 
replace elec_usd="." if elec_usd=="nr" | elec_usd=="por definir" | elec_usd=="No tiene el dato " | elec_usd=="no hay datos registrados, se va a levantar informacion en documentos"

*Costa Rica en 2012: ER=502.9
replace elec_usd="1392" if elec_usd=="setecientos mil colones "
replace elec_usd="9818" if elec_usd=="4,937,295.00  (PROMEDIO POR MES 411,000.00 COLONES)"
replace elec_usd="1790" if elec_usd=="900000.00 colones al aÃ±o"
replace elec_usd="318" if elec_usd=="160000 colones "
replace elec_usd="19885" if elec_usd=="10.000.000 Millones de colones al AÃ±o "
replace elec_usd="198846" if elec_usd=="100.000 000 colones"

*Costa Rica en 2015: 534.56577
replace elec_usd="198847" if elec_usd=="45 millones de colones"

*Bolivia 2016: ER=6.91
replace elec_usd="14472" if elec_usd=="Entre 90000 y 100000 Bs"

*Colombia 2013: ER=1868.785327
replace elec_usd="856" if elec_usd=="1600000 COP"

*Guatemala 2012: ER=7.833605417
replace elec_usd="894" if elec_usd=="Q. 7000"
replace elec_usd="554776" if elec_usd=="Q. 4,345,898"
replace elec_usd="51062" if elec_usd=="400,000 quetzales"
replace elec_usd="53615" if elec_usd=="Q 420000.00"
replace elec_usd="3191" if elec_usd=="Q25,000.00"
replace elec_usd="524909" if elec_usd=="Q. 4,111,931.00 Aproximadamente por planta"

*Guatemala 2014: ER=7.732233333
replace elec_usd="155194" if elec_usd=="Q.1,200,000"

*Guatemala 2015: ER=7.654815
replace elec_usd="107775" if elec_usd=="Q.825,000.00"
replace elec_usd="42951" if elec_usd=="Q.328,784.95"
replace elec_usd="9406" if elec_usd=="Q.72,000"
replace elec_usd="177528" if elec_usd=="Q1,358,943.84"

*Honduras 2012: ER=19.50224951
replace elec_usd="30765" if elec_usd=="600000 lempiras anuales"
replace elec_usd="15383" if elec_usd=="300000 LPS"
replace elec_usd="36919" if elec_usd=="60000 lempiras mensuales"
replace elec_usd="98450" if elec_usd=="1920000 lempiras/aÃ±o"
replace elec_usd="205" if elec_usd=="4000 lps"
replace elec_usd="43584" if elec_usd=="850000 lempiras"
replace elec_usd="22151" if elec_usd=="36000 Lempiras/Mes"
replace elec_usd="1538" if elec_usd=="30000 lempiras"
replace elec_usd="3846" if elec_usd=="75000 lps"
replace elec_usd="26902" if elec_usd=="524660.08 LPS"
replace elec_usd="22151" if elec_usd=="432000 lempiras/aÃ±o"
replace elec_usd="43436" if elec_usd=="847100 LPS"
replace elec_usd="1538" if elec_usd=="30000 Lempiras"
replace elec_usd="385" if elec_usd=="7500.00 LPS"
replace elec_usd="46148" if elec_usd=="900000 lempiras/anuales"
replace elec_usd="89220" if elec_usd=="1740000  lempiras anuales."
replace elec_usd="86144" if elec_usd=="140,000 lempiras/mes"
replace elec_usd="33842" if elec_usd=="660000 lempiras anuales"
replace elec_usd="184594" if elec_usd=="3600000 lempiras anuales"

*Honduras 2014: ER=171533.4655
replace elec_usd="285889" if elec_usd=="L.6,000,000.00"
replace elec_usd="116559" if elec_usd=="Lps.203,852.79 en promedio mensual."
replace elec_usd="9530" if elec_usd=="Lps.200,000 aprox"
replace elec_usd="42883" if elec_usd=="900,000 lempiras en promedio "
replace elec_usd="90531" if elec_usd=="1,900,000 lempiras promedio "
replace elec_usd="385950" if elec_usd=="8,100,000 lempiras anuales"

*Nicaragua 2012: ER=
replace elec_usd="10192" if elec_usd=="240 000 cordobas"
replace elec_usd="9173" if elec_usd=="18000 CORDOBAS MENSUALES"
replace elec_usd="595" if elec_usd=="C$ 14.000"
replace elec_usd="255" if elec_usd=="C$ 6,000"
replace elec_usd="42" if elec_usd=="C$1,000.000"
replace elec_usd="23188" if elec_usd=="45,500.00 cordobas mensual"
replace elec_usd="1699" if elec_usd=="40,000.00 cordobas"

*Peru 2012: ER=
replace elec_usd="161511" if elec_usd=="426,000 NUEVOS SOLES"

*Peru 2014: ER=
replace elec_usd="53" if elec_usd==" 150 Nuevos soles"

destring elec_usd, replace

*12) Medidas de monitoreo M1 y M2

*Primero limpio
rename M1_electric_costo OLD_M1_electric_costo
egen M1_electric_costo=rowtotal(M1_light_costo M1_AC_costo M1_hwater_costo M1_compress_costo M1_eprod_costo M1_oelec_costo)
label var  M1_electric_costo "Costo total de inversiones en energia eléctrica"
drop OLD_M1_electric_costo

replace M2_light_costo="" if M2_light_costo=="No proporcionado"
destring M2_light_costo, replace 
replace M2_AC_costo="" if M2_AC_costo=="No proporcionado"
destring M2_AC_costo, replace 

rename M2_electric_costo OLD_M2_electric_costo
egen M2_electric_costo=rowtotal(M2_light_costo M2_AC_costo M2_hwater_costo M2_compress_costo M2_eprod_costo M2_oelec_costo)
label var  M2_electric_costo "Costo total de inversiones en electricidad"
drop OLD_M2_electric_costo

rename M1_electric_kwh_ahorro OLD_M1_electric_kwh_ahorro
egen M1_electric_kwh_ahorro=rowtotal(M1_light_kwh_ahorro M1_AC_kwh_ahorro M1_hwater_kwh_ahorro M1_compress_kwh_ahorro M1_eprod_kwh_ahorro M1_oelec_kwh_ahorro)
label var  M1_electric_kwh_ahorro "Ahorro total en KWH del uso de electricidad"
drop OLD_M1_electric_kwh_ahorro

replace M2_light_kwh_ahorro="" if M2_light_kwh_ahorro=="No proporcionado"
destring M2_light_kwh_ahorro, replace 
replace M2_AC_kwh_ahorro="" if M2_AC_kwh_ahorro=="No proporcionado"
destring M2_AC_kwh_ahorro, replace 

rename M2_electric_kwh_ahorro OLD_M2_electric_kwh_ahorro
egen M2_electric_kwh_ahorro=rowtotal(M2_light_kwh_ahorro M2_AC_kwh_ahorro M2_hwater_kwh_ahorro M2_compress_kwh_ahorro M2_eprod_kwh_ahorro M2_oelec_kwh_ahorro)
label var  M2_electric_kwh_ahorro "Ahorro total en KWH del uso de electricidad"
drop OLD_M2_electric_kwh_ahorro

rename M1_electric_usd_ahorro OLD_M1_electric_usd_ahorro
egen M1_electric_usd_ahorro=rowtotal(M1_light_usd_ahorro M1_AC_usd_ahorro M1_hwater_usd_ahorro M1_compress_usd_ahorro M1_eprod_usd_ahorro M1_oelec_usd_ahorro)
label var  M1_electric_usd_ahorro "Ahorro total en USD del uso de electricidad"
drop OLD_M1_electric_usd_ahorro

replace M2_light_usd_ahorro="" if M2_light_usd_ahorro=="No proporcionado"
destring M2_light_usd_ahorro, replace 
replace M2_AC_usd_ahorro="" if M2_AC_usd_ahorro=="No proporcionado"
destring M2_AC_usd_ahorro, replace 

rename M2_electric_usd_ahorro OLD_M2_electric_usd_ahorro
egen M2_electric_usd_ahorro=rowtotal(M2_light_usd_ahorro M2_AC_usd_ahorro M2_hwater_usd_ahorro M2_compress_usd_ahorro M2_eprod_usd_ahorro M2_oelec_usd_ahorro)
label var  M2_electric_usd_ahorro "Ahorro total en USD del uso de electricidad"
drop OLD_M2_electric_usd_ahorro

rename M1_electric_GEI OLD_M1_electric_GEI
egen M1_electric_GEI=rowtotal(M1_light_GEI M1_AC_GEI M1_hwater_GEI M1_compress_GEI M1_eprod_GEI M1_oelec_GEI)
label var  M1_electric_GEI "Total de GEI de electricidad (indirecta)"
drop OLD_M1_electric_GEI

rename M2_electric_GEI OLD_M2_electric_GEI
egen M2_electric_GEI=rowtotal(M2_light_GEI M2_AC_GEI M2_hwater_GEI M2_compress_GEI M2_eprod_GEI M2_oelec_GEI)
label var  M2_electric_GEI "Total de GEI de electricidad (indirecta)"
drop OLD_M2_electric_GEI

rename M1_additionalEE_fneed M1_additionalEE_fneed_OLD
egen aux_1=rowtotal(LB_inversion LBD_inversion M1_additionalEE_value)
gen M1_additionalEE_fneed=aux_1 - total_costo
replace M1_additionalEE_fneed=0 if M1_additionalEE_fneed<0
drop aux_1 M1_additionalEE_fneed_OLD

rename M2_additionalEE_fneed M2_additionalEE_fneed_OLD
replace M2_additionalEE_value="" if M2_additionalEE_value!="33785" 
destring M2_additionalEE_value, replace
egen aux_1=rowtotal(LB_inversion LBD_inversion M2_additionalEE_value)
gen M2_additionalEE_fneed=aux_1 - total_costo
replace M2_additionalEE_fneed=0 if M2_additionalEE_fneed<0
drop aux_1 M2_additionalEE_fneed_OLD

*Ahorros Totales

*Primero calculo costos totales

*Costos totales
egen M_costo=rowtotal(M1_electric_costo M1_hidroc_costo M2_electric_costo M2_hidroc_costo )
label var M_costo "Costo inversiones"
drop total_costo

egen M_elec_costo=rowtotal(M1_electric_costo  M2_electric_costo  )
label var M_elec_costo "Costo inversiones electricidad"

egen M_hidro_costo=rowtotal( M1_hidroc_costo  M2_hidroc_costo )
label var M_hidro_costo "Costo inversiones hidrocarburos"


*Ahorros USD 
egen M_elec_usd_ahorro=rowtotal(M1_electric_usd_ahorro M2_electric_usd_ahorro )
label var M_elec_usd_ahorro "Ahorro costo electricidad"

egen M_hidro_usd_ahorro=rowtotal( M1_hidroc_ahorro_costo  M2_hidroc_ahorro_costo)
label var M_hidro_usd_ahorro "Ahorro costo hidrocarburos"

egen M_usd_ahorro=rowtotal(M1_electric_usd_ahorro M1_hidroc_ahorro_costo M2_electric_usd_ahorro M2_hidroc_ahorro_costo)
label var M_usd_ahorro "Ahorro costo energia"
drop total_ahorro


*Ahorros KWH 
egen M_elec_kwh_ahorro=rowtotal(M1_electric_kwh_ahorro  M2_electric_kwh_ahorro)
label var M_elec_kwh_ahorro "Ahorro kWh electricidad"

egen M_hidro_kwh_ahorro=rowtotal(M1_hidroc_kwh M2_hidroc_kwh)
label var M_hidro_kwh_ahorro "Ahorro kWh hidrocarburo"
label var M1_hidroc_kwh  "M1 - Ahorro del uso de hidrocarburo en KWH"
label var M2_hidroc_kwh  "M2 - Ahorro del uso de hidrocarburo en KWH"

egen M_kwh_ahorro=rowtotal(M_elec_kwh_ahorro M_hidro_kwh_ahorro)
label var M_kwh_ahorro "Ahorro KWH energia"

*Total de GEI ahorrado
egen M_GEI=rowtotal(M1_electric_GEI M1_GEI M2_electric_GEI M2_GEI)
label var M_GEI "GEI"
drop total_GEI

egen M_elec_GEI=rowtotal(M1_electric_GEI M2_electric_GEI )
label var M_elec_GEI "GEI electricidad"

rename M1_GEI M1_hidro_GEI
rename M2_GEI M2_hidro_GEI

egen M_hidro_GEI=rowtotal(M1_hidro_GEI M2_hidro_GEI)
label var M_hidro_GEI "GEI hidrocarburos"

*Periodo de recuperacion
gen M_recupera=0 if M_usd_ahorro<0 | M_usd_ahorro==. 
replace M_recupera=M_costo/M_usd_ahorro if (M_usd_ahorro>=0 & M_usd_ahorro!=. )
label var M_recupera "Periodo recuperación proyectado (anios)"
drop total_recupera

*Niveles de producción
egen M_produccion=rowtotal(M1_produccion  M2_produccion )
label var M_produccion "Cambio produccion (anual)"

*13) Creo variables de ahorro total comparando con las lineas de base

**************
* EN DOLARES *
**************

*Electricidad
gen Ratio_ahorro_elec_usd=M_elec_usd_ahorro/LBM_elect_costo if LBM_elect_costo!=0 & LBM_elect_costo!=.
label var Ratio_ahorro_elec_usd "Ahorro/Uso electricidad (USD)"

*Hidrocarubros
gen Ratio_ahorro_hidro_usd=M_hidro_usd_ahorro/LBM_thidro_costo if LBM_thidro_costo!=0 & LBM_thidro_costo!=.
label var Ratio_ahorro_hidro_usd "Ahorro/Uso hidrocarburos (USD)"

*Totales
egen LBM_costo = rowtotal(LBM_elect_costo LBM_thidro_costo)
label var LBM_costo "Costo total (USD)"

gen Ratio_ahorro_usd=M_usd_ahorro/LBM_costo if LBM_costo!=0 & LBM_costo!=.
label var Ratio_ahorro_usd "Ahorro/Uso energia (USD)"


**********
* EN KWH *
**********

*Electricidad
gen Ratio_ahorro_elec_kwh=M_elec_kwh_ahorro/LBM_elect_uso if LBM_elect_uso!=0 & LBM_elect_uso!=.
label var Ratio_ahorro_elec_kwh "Ahorro/Uso electricidad (KWH)"

*Hidrocarubros
gen Ratio_ahorro_hidro_kwh=M_hidro_kwh_ahorro/LBM_mhidro_GEI_kwh if LBM_mhidro_GEI_kwh!=0 & LBM_mhidro_GEI_kwh!=.
label var Ratio_ahorro_hidro_kwh "Ahorro/Uso hidrocarburos(KWH)"

*Totales
egen LBM_uso = rowtotal(LBM_elect_uso LBM_mhidro_GEI_kwh)
label var LBM_uso "Costo total (KWH)"

gen Ratio_ahorro_kwh=M_kwh_ahorro/LBM_uso if LBM_uso!=0 & LBM_uso!=.
label var Ratio_ahorro_kwh "Ahorro/Uso energia (KWH)"


**********
* EN GEI *
**********

*Electricidad
gen Ratio_ahorro_elec_GEI=M_elec_GEI/LBM_elect_GEI if LBM_elect_GEI!=0 & LBM_elect_GEI!=.
label var Ratio_ahorro_elec_GEI "Ahorro/Uso GEI electricidad"

*Hidrocarubros
gen Ratio_ahorro_hidro_GEI=M_hidro_GEI/LBM_thidro_GEI if LBM_thidro_GEI!=0 & LBM_thidro_GEI!=.
label var Ratio_ahorro_hidro_GEI "Ahorro/Uso GEI hidrocarburos"

*Totales
egen LBM_GEI = rowtotal(LBM_elect_GEI LBM_thidro_GEI)
label var LBM_GEI "GEI de LB"

gen Ratio_ahorro_GEI=M_GEI/LBM_GEI if LBM_GEI!=0 & LBM_GEI!=.
label var Ratio_ahorro_GEI "Ahorro/Uso GEI"


*Tipo de implementación

egen dato_light=rownonmiss(M1_light_1date M1_light_costo M1_light_kwh_ahorro M1_light_usd_ahorro M1_light_GEI M2_light_1date M2_light_costo M2_light_kwh_ahorro M2_light_usd_ahorro M2_light_GEI)
egen dato_AC=rownonmiss(M1_AC_1date M1_AC_costo M1_AC_kwh_ahorro M1_AC_usd_ahorro M1_AC_GEI M2_AC_1date M2_AC_costo M2_AC_kwh_ahorro M2_AC_usd_ahorro M2_AC_GEI)
egen dato_hwater=rownonmiss(M1_hwater_1date M1_hwater_costo M1_hwater_kwh_ahorro M1_hwater_usd_ahorro M1_hwater_GEI M2_hwater_1date M2_hwater_costo M2_hwater_kwh_ahorro M2_hwater_usd_ahorro M2_hwater_GEI)
egen dato_compress=rownonmiss(M1_compress_1date M1_compress_costo M1_compress_kwh_ahorro M1_compress_usd_ahorro M1_compress_GEI M2_compress_1date M2_compress_costo M2_compress_kwh_ahorro M2_compress_usd_ahorro M2_compress_GEI)
egen dato_eprod=rownonmiss(M1_eprod_1date M1_eprod_costo M1_eprod_kwh_ahorro M1_eprod_usd_ahorro M1_eprod_GEI M2_eprod_1date M2_eprod_costo M2_eprod_kwh_ahorro M2_eprod_usd_ahorro M2_eprod_GEI)
egen dato_oelec=rownonmiss(M1_oelec_1date M1_oelec_costo M1_oelec_kwh_ahorro M1_oelec_usd_ahorro M1_oelec_GEI M2_oelec_1date M2_oelec_costo M2_oelec_kwh_ahorro M2_oelec_usd_ahorro M2_oelec_GEI)
egen dato_hidro=rownonmiss(M1_hidroc_1date M1_hidroc_costo M1_hidroc_uso M1_hidroc_ahorro_costo M1_hidro_GEI M1_otro_GEI M2_hidroc_1date M2_hidroc_costo M2_hidroc_uso M2_hidroc_ahorro_costo M2_hidro_GEI M2_otro_GEI)

gen adop_light=(dato_light>0)
gen adop_AC=(dato_AC>0) 
gen adop_hwater=(dato_hwater>0) 
gen adop_compress=(dato_compress>0) 
gen adop_eprod=(dato_eprod>0)
gen adop_oelec=(dato_oelec>0)
gen adop_hidro=(dato_hidro>0)  

egen adop_q=rowtotal(adop_light adop_AC adop_hwater adop_compress adop_eprod adop_oelec adop_hidro) 
egen adop_elec_q=rowtotal(adop_light adop_AC adop_hwater adop_compress adop_eprod adop_oelec)

*Categorizar "Otros":
gen M1_otros_aux=lower(M1_oelec_medida)
gen M2_otros_aux=lower(M2_oelec_medida)

tabsplit M1_otros_aux , parse(, " " "(" ")" "?" "+") sort
list M1_otros_aux if regexm(M1_otros_aux, "secado") == 1 

gen M1_otros=99 if regexm(M1_otros_aux, "\+") == 1 
replace M1_otros=1 if regexm(M1_otros_aux, "tarifa") == 1 & M1_otros!=99 & M1_otros==.
replace M1_otros=2 if regexm(M1_otros_aux, "agua") == 1 & M1_otros!=99 & M1_otros==.
replace M1_otros=3 if regexm(M1_otros_aux, "secado") == 1 & M1_otros!=99 & M1_otros==.
replace M1_otros=4 if regexm(M1_otros_aux, "capacitores") == 1 & M1_otros!=99 & M1_otros==.
replace M1_otros=5 if regexm(M1_otros_aux, "medidor") == 1 & M1_otros!=99 & M1_otros==.
replace M1_otros=5 if regexm(M1_otros_aux, "hora") == 1 & M1_otros!=99 & M1_otros==.
replace M1_otros=5 if regexm(M1_otros_aux, "medidas") == 1 & M1_otros!=99 & M1_otros==.
replace M1_otros=5 if regexm(M1_otros_aux, "programa") == 1 & M1_otros!=99 & M1_otros==.
replace M1_otros=5 if regexm(M1_otros_aux, "planificación") == 1 & M1_otros!=99 & M1_otros==.
replace M1_otros=5 if regexm(M1_otros_aux, "gestión") == 1 & M1_otros!=99 & M1_otros==.
replace M1_otros=5 if regexm(M1_otros_aux, "apagar") == 1 & M1_otros!=99 & M1_otros==.
replace M1_otros=5 if regexm(M1_otros_aux, "periodo") == 1 & M1_otros!=99 & M1_otros==.
replace M1_otros=5 if regexm(M1_otros_aux, "demanda") == 1 & M1_otros!=99 & M1_otros==.
replace M1_otros=5 if regexm(M1_otros_aux, "manejo") == 1 & M1_otros!=99 & M1_otros==.
replace M1_otros=5 if regexm(M1_otros_aux, "penaliza") == 1 & M1_otros!=99 & M1_otros==.
replace M1_otros=5 if regexm(M1_otros_aux, "consumos") == 1 & M1_otros!=99 & M1_otros==.
replace M1_otros=5 if regexm(M1_otros_aux, "hibernacion") == 1 & M1_otros!=99 & M1_otros==.
replace M1_otros=5 if regexm(M1_otros_aux, "potencia") == 1 & M1_otros!=99 & M1_otros==.
replace M1_otros=6 if regexm(M1_otros_aux, "refriger") == 1 & M1_otros!=99 & M1_otros==.
replace M1_otros=6 if regexm(M1_otros_aux, "fr") == 1 & M1_otros!=99 & M1_otros==.
replace M1_otros=7 if regexm(M1_otros_aux, "sustitucion") == 1 & M1_otros!=99 & M1_otros==.
replace M1_otros=7 if regexm(M1_otros_aux, "cambio") == 1 & M1_otros!=99 & M1_otros==.
replace M1_otros=7 if regexm(M1_otros_aux, "sustituir") == 1 & M1_otros!=99 & M1_otros==.

replace M1_otros=7 if regexm(M1_otros_aux, "sustituir") == 1 & (M1_otros==. | M1_otros==99)
replace M1_otros=5 if regexm(M1_otros_aux, "tableros") == 1 & (M1_otros==. | M1_otros==99)
replace M1_otros=5 if regexm(M1_otros_aux, "gestión") == 1 & (M1_otros==. | M1_otros==99)
replace M1_otros=5 if regexm(M1_otros_aux, "penalización") == 1 & (M1_otros==. | M1_otros==99)
replace M1_otros=5 if regexm(M1_otros_aux, "demanda") == 1 & (M1_otros==. | M1_otros==99)

replace M1_otros=999 if M1_otros==. & M1_otros_aux!=""

replace adop_compress=1 if regexm(M1_otros_aux, "aire comprimido") == 1 & M1_otros!=99
replace adop_light=1 if regexm(M1_otros_aux, "iluminación") == 1 & M1_otros!=99

label define adop_otro 1 "Optimizar Tarifa Contratada" 2 "Agua" 3 "Secado" 4 "Capacitores" 5 "Gestión de energia" 6 "Refrigeracion" 7 "Sustitución de Maquinaria" 99 "Multiple" 999 "No Clasificado"
label val M1_otros adop_otro

tabsplit M2_otros_aux , parse(, " " "(" ")" "?" "+") sort
list M2_otros_aux if regexm(M2_otros_aux, "ahorro") == 1 

gen M2_otros=99 if regexm(M2_otros_aux, "\+") == 1 
replace M2_otros=1 if regexm(M2_otros_aux, "tarifa") == 1 & M2_otros!=99 & M2_otros==.
replace M2_otros=7 if regexm(M2_otros_aux, "sustituci") == 1 
replace M2_otros=1 if regexm(M2_otros_aux, "costo energ") == 1 & M2_otros!=99 & M2_otros==.
replace M2_otros=5 if regexm(M2_otros_aux, "timer") == 1 & M2_otros!=99 & M2_otros==.
replace M2_otros=7 if regexm(M2_otros_aux, "aislamiento") == 1 & M2_otros!=99 & M2_otros==.
replace M2_otros=7 if regexm(M2_otros_aux, "cajas") == 1 & M2_otros!=99 & M2_otros==.
replace M2_otros=5 if regexm(M2_otros_aux, "buenas") == 1 & M2_otros!=99 & M2_otros==.
replace M2_otros=5 if regexm(M2_otros_aux, "consumos") == 1 & M2_otros!=99 & M2_otros==.

replace M2_otros=999 if M2_otros==. & M2_otros_aux!=""
label val M2_otros adop_otro

gen adop_tar_gest=(M1_otros==1 | M2_otros==1 | M1_otros==5 | M2_otros==5)
label var adop_tar_gest "Optimizar gestión de la energia"
gen adop_agua=(M1_otros==2 | M2_otros==2)
label var adop_agua "Manejo del agua" 
gen adop_refrig=(M1_otros==6 | M2_otros==6)
gen adop_reemplazos=(M1_otros==4 | M2_otros==4 | M1_otros==7 | M2_otros==7 | M1_otros==3 | M2_otros==3)
label var adop_reemplazos "Optimización y/o sustitución de maquinarias y equipos" 
gen adop_otros=(M1_otros==99 | M2_otros==99 | M1_otros==999 | M2_otros==999)

*Categorias de tipos de adopción

gen adop_type=0 if adopcion==0
replace adop_type=1 if adop_light==1 & adop_q==1
replace adop_type=2 if adop_AC==1 & adop_q==1
replace adop_type=3 if adop_hwater==1 & adop_q==1
replace adop_type=4 if adop_compress==1 & adop_q==1
replace adop_type=5 if adop_eprod==1 & adop_q==1
replace adop_type=6 if adop_tar_gest==1 & adop_q==1
replace adop_type=7 if adop_agua==1 & adop_q==1
replace adop_type=8 if adop_refrig==1 & adop_q==1
replace adop_type=9 if adop_reemplazos==1 & adop_q==1
replace adop_type=10 if adop_otros==1 & adop_q==1
replace adop_type=11 if adop_hidro==1 & adop_q==1
replace adop_type=12 if adop_q==2
replace adop_type=13 if adop_q==3
replace adop_type=14 if adop_q==4
replace adop_type=15 if adop_q==5
replace adop_type=16 if adop_q==6
label define adop_type 0 "No adoptó" 1 "Iluminación" 2 "Aire Acondicionado" 3 "Calentar Agua" 4 "Compresor" ///
5 "Producción de electricidad" 6 "Optimizar gestión de la energia" 7 "Manejo del agua" 8 "Refrigeración" ///
9 "Optimización y/o sustitución de maquinarias y equipos" 10 "Otras implementaciones electricas" 11 "Hidrocarburos" ///
12 "2 adopciones" 13 "3 adopciones" 14 "4 adopciones" 15 "5 adopciones" 16 "6 adopciones"
label val adop_type adop_type

*13) Otras variables  

gen size = employees
replace size=2 if (employees>1 & employees<6)
replace size=3 if (employees>5)
label define sizel 1 "Small" 2 "Medium" 3 "Large"
label values size sizel

gen hi_country=.
replace  hi_country=1 if (country=="Costa Rica" | country=="Colombia" | country=="Panamá" )
replace  hi_country=0 if (country=="Bolivia" | country=="Ecuador" | country=="El Salvador" ///
| country=="Guatemala" | country=="Honduras"  | country=="Nicaragua"  | country=="Paraguay" )
label define hi_country 1 "High Income" 0 "Low Income"
label values hi_country hi_country
label var hi_country "High income countries"


gen assets_2=assets
replace assets_2=3 if assets>3
label var assets_2 "Assets"

label def assets_2 1 "< US$6,000,000" 2 "US$6,000,000 - US$10,000,000" 3 "> US$10,000,000" 
label value assets_2 assets_2

gen revenues_2=revenues
replace revenues_2=3 if revenues>3
label value revenues_2 assets_2
label var revenues_2 "Revenues"

gen registration_year2 = registration_year
replace registration_year2=2012 if registration_year==2011
label var registration_year2 "Registration year (2011 in 2012)"

gen hours=ohours
recode hours (2=1)
recode hours (3=2)
recode hours (4=3)
recode hours (5=4)
label define hours 1 "<40 hs" 2 "40-60 hs" 3 "60-80 hs" 4 ">80 hs" 
label var hours "Facility’s operating hours per week"
label val hours hours

drop if company=="test" 
drop if company==""
drop if country==""

gen AED=(audit==2 | audit==3) if audit!=.	
label def AED 0 "Sencilla" 1 "Detallada" 
label val AED AED

label def adopcion 0 "No adoptó" 1 "Si adoptó" 
label val adopcion adopcion

gen high_gdp=( country=="Ecuador" | country=="Colombia" | country=="Costa Rica" | country=="Panamá")
label var high_gdp "Países de altos ingresos (en relación a la mediana de la región)"
gen benefi=(country=="El Salvador" | country=="Ecuador" | country=="Colombia" | country=="Costa Rica" | country=="Panamá" | ///
country=="Bolivia"  | country=="Guatemala"  | country=="Honduras"  | country=="Nicaragua" )
label var benefi "Países beneficiados con GreenPyme"

gen andinos=(country=="Bolivia" | country=="Ecuador" | country=="Colombia")


save Data_out\Greenpyme_db.dta, replace

numlabel, re

order country_2d ronda status approved audit informe_CII registration registration_year company name_f name_l position telephone fax email city province country_n ///
sector_n sector_BID market  information_date audit_before audit_bdate personnel_participate efprojects_desired age surface_mt2 employees_n employees ///
elec_kwh elec_usd ngas_consump_m ngas_consump diesel_consump_m diesel_consump coal_consump_m coal_consump lpg_consump_m lpg_consump biom_consump_m biom_consump ///
hours oweekends heating_age cooling_age illumination pproc_steam pproc_steam_c pproc_cair pproc_cair_c pproc_emotor pproc_emotor_c pproc_oven pproc_oven_c ///
pproc_cooling pproc_cooling_c fossil_fuel  fossil_fuel_q fossil_fuel_usd GREENPYME elec_kwh elec_usd multinational web_address revenues_n revenues assets assets_comments ///
LB_* AES_* M1_*  LBD_* M2_* AED_* LBM_* adopcion adop_* M_* Ratio_*

drop LB_* LBD_*
drop ngas_consump_m - fossil_fuel_usd
drop assets_comments assets_comments AES_informe_CII AES_informe_IICDOCS AES_csatisfaccion AES_pago_auditor AES_date AES_entrega_date AES_cuestionario
drop OLD_* total_* dato_*
drop country sector age_0 employees_0  employees_0 revenues_0 age_1 surface employees_1 SEA_DEA sector_otros sector_2 assets_2 revenues_2 registration_year2 ohours
drop AED_propuesta AED_bcomments AED_contrato_w AED_contrato_pdf AED_contrato_firmado AED_pago_cant AED_pago_comprob AED_3m AED_informe_CII AED_informe_IICDOCS ///
AED_csatisfaccion AED_informe_fecha AED_finforme_N AED_informe_3m AED_informe_lfecha AED_finforme_lfecha AED_cuestionario AED_date AED_pago_date AED_contrato_date
drop M1_* M2_*
drop nonIIC_financing IIC_financing IIC_sugfinancing



