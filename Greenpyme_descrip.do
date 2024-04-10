********************************************************************************
*** Este dofile crea tablas descriptivas de los proyectos de GreenPyme       ***
*** Autora: Maria Laura Lanzalot 											 ***
*** date: 10/23/2017  														 ***
********************************************************************************
clear all
set more off
*Abriendo los datos
use Data_out\Greenpyme_db.dta, clear
des LBM_informeCII AES_informe_CII AED_informe_CII  M1_aCII M2_aCII
gen M_aCII=M1_aCII
replace M_aCII=M2_aCII if M_aCII==.
label var M_aCII "M - seguimiento aprobado por CII"

drop if adop_q>0 & M_aCII==. & registration_year==2018

drop AED informe_CII

gen informe_CII=(AES_informe_CII==1 | AED_informe_CII==1)
label var informe_CII "Informe aprobada por CII" 

gen AED=0 if informe_CII==1
replace AED=1 if AED_informe_CII==1 & informe_CII==1
label var AED "Auditoria Detallada"

rename audit audit_drop

gen audit=1 if AES_informe_CII==1 & AED_informe_CII!=1
replace audit=2 if AES_informe_CII!=1 & AED_informe_CII==1
replace audit=3 if AES_informe_CII==1 & AED_informe_CII==1
replace audit=4 if AES_informe_CII==0 & AED_informe_CII==0
label def audit 1 "Sencilla" 2 "Detallada" 3 "Ambas" 4 "Ninguna", replace
label val audit audit
label var audit "Tipo de audit recibida"

replace M_aCII=1 if adopcion!=.

*Implementó
replace M1_implement=0 if (M1_implement==. & M1_aCII==1)
replace M2_implement=0 if (M2_implement==. & M2_aCII==1)

egen M_implement=rowtotal(M1_implement M2_implement)
label var M_implement "M - Implementaciones (#)"

ta M_implement adop_q

*NO USAR adop_q

gen more_10=(age>2)
replace more_10=. if age==.

gen small=(size==1)

gen revenues_low=(revenues==1)
replace revenues_low=. if revenues==.

ta registration_year, g(y_)
ta sector_BID, g(s_)

*drop hi_country

drop if benefi==0


replace M1_aCII=0 if company=="Sociedad Bolivana de Cemento S.A. SOBOCE S.A. (Viacha) - audited by KEMCO”." 
tab M1_aCII audit if  informe_CII==1 ,   m

replace informe_CII=0 if informe_CII!=1 

gen aprob_inf=.
replace aprob_inf=0 if informe_CII!=1 & approved==1
replace aprob_inf=1 if informe_CII==1 & approved==1

gen after_2013=(registration_year>2013)

gen case_id = _n

export excel using "Data_out\DB_Greenpyme_clean_06_18.xlsx", firstrow(varlabels) replace

save Data_out\Greenpyme_db_clean.dta, replace

****************************************************************
*************     Tabulaciones simples      ********************
****************************************************************

*	Número de Firmas por país
ta country, m
ta country if approved!=. , m
ta country if approved==0 , m
ta country if approved==1 , m
ta country if informe_CII==1 , m

*	Número de Firmas por sector_3
ta sector_n if audit<4 & informe_CII==1 , m
ta sector_BID if audit<4 & informe_CII==1 , m

ta sector_BID if approved!=. , m

*	Número de Firmas por sector_3 y país
ta sector_BID country if audit<4 & informe_CII==1 & ///
(country=="Bolivia" | country=="El Salvador" | country=="Costa Rica" | country=="Honduras" | country=="Guatemala" | country=="Nicaragua") ///
,    m   

ta sector_BID if audit<4 & informe_CII==1 & ///
(country=="Bolivia" | country=="El Salvador" | country=="Costa Rica" | country=="Honduras" | country=="Guatemala" | country=="Nicaragua") ///
,    m   


*	Si generamos una variable que tome el valor de 1 si recibió auditoría sencilla, 2 auditoría completa y 3 ambas, tabular cuántas firmas tenemos en cada grupo
ta audit if informe_CII==1 , m

*	Número de Firmas por año de antigüedad o desde que inició el negocio
ta age audit if  audit<4 & informe_CII==1 , m

*	Número de Firmas por número de empleados
ta employees audit if  audit<4 & informe_CII==1 , m

*	Número de Firmas por año de inscripción al programa
ta registration_year if informe_CII==1 , m
ta registration_year if approved!=. , m

ta registration_year if approved==0, m
ta registration_year if approved==1 , m

ta registration_year audit if  audit<4 & informe_CII==1 , m


****************************************************************
***************    Cruces (con porcentaje)    ******************
****************************************************************

*   Monitoreo y auditoria 


*	País por tipo de audit
tab country audit if audit<4 & informe_CII==1 ,   m

tab country audit if audit<4 & informe_CII==1 , nofreq row  m

*	sector_3 por tipo de audit 
tab sector_BID audit if audit<4 & informe_CII==1 , nofreq col  m

tab sector_BID audit if audit<4 & informe_CII==1 , m

*	Número de Firmas por antigüedad y por tipo de auditoría 
ta age audit if  audit<4 & informe_CII==1 , nofreq col  m
ta age audit if  audit<4 & informe_CII==1 , nofreq row  m

*	Número de Firmas por número de empleados y por tipo de auditoría 
ta employees audit if  audit<4 & informe_CII==1, nofreq col  m
ta employees audit if  audit<4 & informe_CII==1, nofreq row  m

*	Año de inscripción al programa por tipo de auditoría 

tab registration_year audit if audit<4 & approved==1 , nofreq col  m
tab registration_year audit if audit<4 & informe_CII==1 , nofreq col  m

tab registration_year audit if audit<4 & approved==1 , nofreq row  m
tab registration_year audit if audit<4 & informe_CII==1 , nofreq row  m

*	Si generamos una variable de adopción (1 si adoptó algunas de las medidas y 0 si no adopto) podríamos cruzar adopción con tipo de auditoría

tab adopcion audit if audit<4 & approved==1 , nofreq col  m
tab adopcion audit if audit<4 & informe_CII==1 , nofreq col  m


****************************************************************
************    Cruces por tipo de adopcion    *****************
****************************************************************

*Cantidad de adopciones
tab M_implement audit if adopcion!=.   ,  m
tab M_implement audit if  adopcion!=.  , nofreq col  m
tab M_implement audit if  adopcion!=.  , nofreq row  m

*	Adopción por país

tab country adopcion if  adopcion!=. , nofreq col  m
tab country adopcion if  adopcion!=. ,    m

tab country adopcion if  adopcion!=.  , nofreq row  m


*	Adopción por sector_3

tab sector_BID adopcion if  adopcion!=. , nofreq col  m
tab sector_BID adopcion if  adopcion!=. ,    m

tab sector_BID adopcion if  adopcion!=. , nofreq row  m

*	Adopción por edad

tab age adopcion if  adopcion!=. , nofreq col  m
tab age adopcion if  adopcion!=. ,   m
tab age adopcion if  adopcion!=. , nofreq row  m

*	Adopción por tamanio

tab employees adopcion if  adopcion!=. , nofreq col  m
tab employees adopcion if  adopcion!=. ,   m
tab employees adopcion if  adopcion!=. , nofreq row  m

*Proporcion de adopciones

foreach var in adop_light adop_AC adop_hwater adop_compress adop_eprod adop_tar_gest adop_agua  ///
 adop_refrig adop_reemplazos adop_otros adop_hidro {
replace `var'=`var'*100
}

 tabstat adop_light adop_AC adop_hwater adop_compress adop_eprod adop_tar_gest adop_agua  ///
 adop_refrig adop_reemplazos adop_otros adop_hidro if adopcion==1, stat(mean) columns(statistics) save
 mat T = r(StatTotal)' // the prime is for transposing the matrix
putexcel set Data_out\Tables\Tipos_adop.xls, replace // remember to specify the full path
putexcel A1 = matrix(T), names 
  
  *Por tipo de auditoria
 numlabel audit, re
 tabstat adop_light adop_AC adop_hwater adop_compress adop_eprod adop_tar_gest adop_agua   ///
 adop_refrig adop_reemplazos adop_otros adop_hidro if adopcion==1, stat(mean) by(audit) save
  mat T = r(Stat1)\r(Stat2)\r(Stat3)\r(StatTotal) // the prime is for transposing the matrix
  matrix rownames T = "`r(name1)'" "`r(name2)'" "`r(name3)'" "Total"
putexcel set Data_out\Tables\Tipos_adop_audit.xls, replace // remember to specify the full path
putexcel A1 = matrix(T), names 
 
  
 *Por sector
 numlabel sector_BID, re
 tabstat adop_light adop_AC adop_hwater adop_compress adop_eprod adop_tar_gest adop_agua  ///
 adop_refrig adop_reemplazos adop_otros adop_hidro if adopcion==1, stat(mean) by(sector_BID) save
  mat T = r(Stat1)\r(Stat2)\r(Stat3)\r(Stat4)\r(StatTotal) // the prime is for transposing the matrix
  matrix rownames T = "`r(name1)'" "`r(name2)'" "Servicios, tecno. Y comun." "`r(name4)'" "Total"
putexcel set Data_out\Tables\Tipos_adop_sector.xls, replace // remember to specify the full path
putexcel A1 = matrix(T), names 

  *Por país
 tabstat adop_light adop_AC adop_hwater adop_compress adop_eprod adop_tar_gest adop_agua  ///
 adop_refrig adop_reemplazos adop_otros adop_hidro if adopcion==1, stat(mean) by(country) columns(statistics) save
  mat T = r(Stat1)\r(Stat2)\r(Stat3)\r(Stat4)\r(Stat5)\r(Stat6)\r(Stat7)\r(StatTotal) // the prime is for transposing the matrix
  matrix rownames T = "`r(name1)'" "`r(name2)'" "`r(name3)'" "`r(name4)'" "`r(name5)'" "`r(name6)'" "`r(name7)'" "Total"
putexcel set Data_out\Tables\Tipos_adop_pais.xls, replace // remember to specify the full path
putexcel A1 = matrix(T), names 

   *Por edad
 tabstat adop_light adop_AC adop_hwater adop_compress adop_eprod adop_tar_gest adop_agua  ///
 adop_refrig adop_reemplazos adop_otros adop_hidro if adopcion==1, stat(mean) by(age) columns(statistics) save
   mat T = r(Stat1)\r(Stat2)\r(Stat3)\r(Stat4)\r(Stat5)\r(StatTotal) // the prime is for transposing the matrix
  matrix rownames T = "`r(name1)'" "`r(name2)'" "`r(name3)'" "`r(name4)'" "`r(name5)'" "Total"
putexcel set Data_out\Tables\Tipos_adop_edad.xls, replace // remember to specify the full path
putexcel A1 = matrix(T), names 
 
    *Por tamanio
 tabstat adop_light adop_AC adop_hwater adop_compress adop_eprod adop_tar_gest adop_agua  ///
 adop_refrig adop_reemplazos adop_otros adop_hidro if adopcion==1, stat(mean) by(employees) columns(statistics) save
  mat T = r(Stat1)\r(Stat2)\r(Stat3)\r(Stat4)\r(Stat5)\r(Stat6)\r(Stat7)\r(Stat8)\r(Stat9)\r(StatTotal) // the prime is for transposing the matrix
  matrix rownames T = "`r(name1)'" "`r(name2)'" "`r(name3)'" "`r(name4)'" "`r(name5)'" "`r(name6)'" "`r(name7)'" "`r(name8)'" "`r(name9)'" "Total"
putexcel set Data_out\Tables\Tipos_adop_tamanio.xls, replace // remember to specify the full path
putexcel A1 = matrix(T), names 

foreach var in adop_light adop_AC adop_hwater adop_compress adop_eprod adop_tar_gest adop_agua  ///
 adop_refrig adop_reemplazos adop_otros adop_hidro {
replace `var'=`var'/100
}

****************************************************************
************         Diferencia de medias         **************
****************************************************************


global ahorro LBM_elec_pahorro_kwh LBM_elec_pahorro_usd LBM_elec_pahorro_GEI ///
LBM_pa_mhidro_GEI_kwh LBM_pahorro_thidro_GEI LBM_preduc_thidro_GEI  ///
LBM_inversion LBM_Ahorro_EP LBM_Anios_recupera_P LBM_TIR LBM_VAN LBM_Ahorro_elec_P ///
LBM_Ahorro_GEI_P LBM_costo LBM_uso LBM_GEI


foreach var in  $ahorro  {
capture drop `var'_2
capture drop `var'_3
gen `var'_2=`var'/employees_n
gen `var'_3=`var'/revenues_n
}


sum LBM_elec_pahorro_kwh LBM_elec_pahorro_usd LBM_elec_pahorro_GEI LBM_pa_mhidro_GEI_kwh ///
 LBM_pahorro_thidro_GEI LBM_preduc_thidro_GEI  LBM_inversion ///
 LBM_Ahorro_EP LBM_Anios_recupera_P LBM_TIR LBM_VAN LBM_Ahorro_elec_P LBM_Ahorro_GEI_P ///
 LBM_costo LBM_uso LBM_GEI if audit<4 & informe_CII==1

estpost ttest LBM_costo LBM_uso LBM_GEI LBM_elec_pahorro_kwh LBM_elec_pahorro_usd LBM_elec_pahorro_GEI LBM_pa_mhidro_GEI_kwh ///
 LBM_pahorro_thidro_GEI LBM_preduc_thidro_GEI  LBM_inversion LBM_Ahorro_EP LBM_VAN  if adopcion!=. & informe_CII==1, by(adopcion)
esttab using Data_out\Tables\LB_ttest_1.rtf, noobs cells("mu_1(fmt(0)) mu_2(fmt(0))  b(star fmt(0))") star(* 0.1 ** .05 *** 0.01) ///
collabels("No adopto" "Adopto" "Diferencia" ) width(0.8\hsize) replace 


foreach var in LBM_Ahorro_elec_P LBM_Ahorro_GEI_P {
replace `var'=`var'*100
}

estpost ttest  LBM_Anios_recupera_P LBM_TIR LBM_Ahorro_elec_P LBM_Ahorro_GEI_P if adopcion!=. & informe_CII==1, by(adopcion)
esttab using Data_out\Tables\LB_ttest_1.rtf, noobs cells("mu_1(fmt(2)) mu_2(fmt(2))  b(star fmt(2))") star(* 0.1 ** .05 *** 0.01) ///
collabels("No adopto" "Adopto" "Diferencia" ) width(0.8\hsize) append 


foreach var in LBM_Ahorro_elec_P LBM_Ahorro_GEI_P {
replace `var'=`var'/100
}
	
estpost ttest LBM_costo_2 LBM_uso_2 LBM_GEI_2 LBM_elec_pahorro_kwh_2 LBM_elec_pahorro_usd_2 LBM_elec_pahorro_GEI_2 LBM_pa_mhidro_GEI_kwh_2 ///
LBM_pahorro_thidro_GEI_2 LBM_preduc_thidro_GEI_2  LBM_inversion_2 LBM_Ahorro_EP_2 LBM_VAN_2 if adopcion!=. & informe_CII==1, by(adopcion)
esttab using Data_out\Tables\LB_ttest_2.rtf, noobs cells("mu_1(fmt(0)) mu_2(fmt(0))  b(star fmt(0))") star(* 0.1 ** .05 *** 0.01) ///
collabels("No adopto" "Adopto" "Diferencia" ) width(0.8\hsize) replace 
	
estpost ttest LBM_costo_3 LBM_uso_3 LBM_GEI_3 LBM_elec_pahorro_kwh_3 LBM_elec_pahorro_usd_3 LBM_elec_pahorro_GEI_3 LBM_pa_mhidro_GEI_kwh_3 ///
LBM_pahorro_thidro_GEI_3 LBM_preduc_thidro_GEI_3  LBM_inversion_3 LBM_Ahorro_EP_3 LBM_VAN_3 if adopcion!=. &  informe_CII==1, by(adopcion)
esttab using Data_out\Tables\LB_ttest_3.rtf, noobs cells("mu_1(fmt(4)) mu_2(fmt(4))  b(star fmt(4))") star(* 0.1 ** .05 *** 0.01) ///
collabels("No adopto" "Adopto" "Diferencia" ) width(0.8\hsize) replace 
	

estpost ttest LBM_costo LBM_uso LBM_GEI LBM_elec_pahorro_kwh LBM_elec_pahorro_usd LBM_elec_pahorro_GEI LBM_pa_mhidro_GEI_kwh ///
 LBM_pahorro_thidro_GEI LBM_preduc_thidro_GEI  LBM_inversion LBM_Ahorro_EP LBM_VAN if audit<4 & informe_CII==1, by(AED )
esttab using Data_out\Tables\LB_ttest_AED_1.rtf, noobs cells("mu_1(fmt(0)) mu_2(fmt(0))  b(star fmt(0))") star(* 0.1 ** .05 *** 0.01) ///
collabels("Sencilla" "Detallada" "Diferencia" ) width(0.8\hsize) replace 


foreach var in LBM_Ahorro_elec_P LBM_Ahorro_GEI_P {
replace `var'=`var'*100
}

estpost ttest  LBM_Anios_recupera_P LBM_TIR LBM_Ahorro_elec_P LBM_Ahorro_GEI_P  if audit<4 & informe_CII==1, by(AED )
esttab using Data_out\Tables\LB_ttest_AED_1.rtf, noobs cells("mu_1(fmt(2)) mu_2(fmt(2))  b(star fmt(2))") star(* 0.1 ** .05 *** 0.01) ///
collabels("Sencilla" "Detallada" "Diferencia" ) width(0.8\hsize) append 

foreach var in LBM_Ahorro_elec_P LBM_Ahorro_GEI_P {
replace `var'=`var'/100
}
	
estpost ttest LBM_costo_2 LBM_uso_2 LBM_GEI_2 LBM_elec_pahorro_kwh_2 LBM_elec_pahorro_usd_2 LBM_elec_pahorro_GEI_2 LBM_pa_mhidro_GEI_kwh_2 ///
LBM_pahorro_thidro_GEI_2 LBM_preduc_thidro_GEI_2  LBM_inversion_2 LBM_Ahorro_EP_2 ///
LBM_Anios_recupera_P_2 LBM_TIR_2 LBM_VAN_2 LBM_Ahorro_elec_P_2 LBM_Ahorro_GEI_P_2 if audit<4 & informe_CII==1, by(AED )
esttab using Data_out\Tables\LB_ttest_AED_2.rtf, noobs cells("mu_1(fmt(0)) mu_2(fmt(0))  b(star fmt(0))") star(* 0.1 ** .05 *** 0.01) ///
collabels("Sencilla" "Detallada" "Diferencia" ) width(0.8\hsize) replace 
	
estpost ttest LBM_costo_3 LBM_uso_3 LBM_GEI_3 LBM_elec_pahorro_kwh_3 LBM_elec_pahorro_usd_3 LBM_elec_pahorro_GEI_3 LBM_pa_mhidro_GEI_kwh_3 ///
LBM_pahorro_thidro_GEI_3 LBM_preduc_thidro_GEI_3  LBM_inversion_3 LBM_Ahorro_EP_3 LBM_VAN_3 if audit<4 & informe_CII==1, by(AED )
esttab using Data_out\Tables\LB_ttest_AED_3.rtf, noobs cells("mu_1(fmt(4)) mu_2(fmt(4))  b(star fmt(4))") star(* 0.1 ** .05 *** 0.01) ///
collabels("Sencilla" "Detallada" "Diferencia" ) width(0.8\hsize) replace 

global monitoreo M_costo M_elec_costo M_hidro_costo M_elec_usd_ahorro M_hidro_usd_ahorro M_usd_ahorro M_elec_kwh_ahorro ///
M_hidro_kwh_ahorro M_kwh_ahorro M_GEI M_elec_GEI M_hidro_GEI M_recupera M_produccion Ratio_ahorro_elec_usd ///
Ratio_ahorro_hidro_usd Ratio_ahorro_usd Ratio_ahorro_elec_kwh Ratio_ahorro_hidro_kwh Ratio_ahorro_kwh ///
Ratio_ahorro_elec_GEI Ratio_ahorro_hidro_GEI Ratio_ahorro_GEI

foreach var in  $monitoreo  {
capture drop `var'_2
capture drop `var'_3
gen `var'_2=`var'/employees_n
gen `var'_3=`var'/revenues_n
}

foreach var in Ratio_ahorro_elec_usd Ratio_ahorro_hidro_usd Ratio_ahorro_usd Ratio_ahorro_elec_kwh Ratio_ahorro_hidro_kwh ///
Ratio_ahorro_kwh Ratio_ahorro_elec_GEI Ratio_ahorro_hidro_GEI Ratio_ahorro_GEI {
replace `var'=`var'*100
}

estpost sum M_costo M_elec_costo M_hidro_costo M_elec_usd_ahorro M_hidro_usd_ahorro M_usd_ahorro M_elec_kwh_ahorro M_hidro_kwh_ahorro ///
M_kwh_ahorro M_GEI M_elec_GEI M_hidro_GEI M_recupera M_produccion if adopcion==1 , d
esttab using Data_out\Tables\M_descrip.rtf, noobs cells("mean(fmt(0)) p50(fmt(0))  min(fmt(0)) max(fmt(0)) count(fmt(0))")  ///
collabels("Promedio" "Mediana" "Min" "Max" "Obs" ) width(0.8\hsize) replace 

estpost sum Ratio_ahorro_elec_usd Ratio_ahorro_hidro_usd Ratio_ahorro_usd ///
Ratio_ahorro_elec_kwh Ratio_ahorro_hidro_kwh Ratio_ahorro_kwh Ratio_ahorro_elec_GEI Ratio_ahorro_hidro_GEI Ratio_ahorro_GEI if adopcion==1 , d
esttab using Data_out\Tables\M_descrip.rtf, noobs cells("mean(fmt(1)) p50(fmt(1))  min(fmt(1)) max(fmt(1)) count(fmt(1))")  ///
collabels("Promedio" "Mediana" "Min" "Max" "Obs" ) width(0.8\hsize) append 


estpost ttest M_costo M_elec_costo M_hidro_costo M_elec_usd_ahorro M_hidro_usd_ahorro M_usd_ahorro M_elec_kwh_ahorro M_hidro_kwh_ahorro ///
M_kwh_ahorro M_GEI M_elec_GEI M_hidro_GEI M_recupera if adopcion!=. & informe_CII==1, by(AED )
esttab using Data_out\Tables\M_ttest_AED_1.rtf, noobs cells("mu_1(fmt(0)) mu_2(fmt(0))  b(star fmt(0))") star(* 0.1 ** .05 *** 0.01) ///
collabels("Sencilla" "Detallada" "Diferencia" ) width(0.8\hsize) replace 

estpost ttest M_produccion Ratio_ahorro_elec_usd Ratio_ahorro_hidro_usd Ratio_ahorro_usd Ratio_ahorro_elec_kwh Ratio_ahorro_hidro_kwh ///
Ratio_ahorro_kwh Ratio_ahorro_elec_GEI Ratio_ahorro_hidro_GEI Ratio_ahorro_GEI if adopcion!=. & informe_CII==1, by(AED )
esttab using Data_out\Tables\M_ttest_AED_1.rtf, noobs cells("mu_1(fmt(2)) mu_2(fmt(2))  b(star fmt(2))") star(* 0.1 ** .05 *** 0.01) ///
collabels("Sencilla" "Detallada" "Diferencia" ) width(0.8\hsize) append 
	
foreach var in Ratio_ahorro_elec_usd Ratio_ahorro_hidro_usd Ratio_ahorro_usd Ratio_ahorro_elec_kwh Ratio_ahorro_hidro_kwh ///
Ratio_ahorro_kwh Ratio_ahorro_elec_GEI Ratio_ahorro_hidro_GEI Ratio_ahorro_GEI {
replace `var'=`var'/100
}

estpost ttest M_costo_2 M_elec_costo_2 M_hidro_costo_2 M_elec_usd_ahorro_2 M_hidro_usd_ahorro_2 M_usd_ahorro_2 M_elec_kwh_ahorro_2 M_hidro_kwh_ahorro_2 ///
M_kwh_ahorro_2 M_GEI_2 M_elec_GEI_2 M_hidro_GEI_2 M_recupera_2 M_produccion_2 if adopcion!=. & informe_CII==1, by(AED )
esttab using Data_out\Tables\M_ttest_AED_2.rtf, noobs cells("mu_1(fmt(4)) mu_2(fmt(4))  b(star fmt(4))") star(* 0.1 ** .05 *** 0.01) ///
collabels("Sencilla" "Detallada" "Diferencia" ) width(0.8\hsize) replace 
	
estpost ttest M_costo_3 M_elec_costo_3 M_hidro_costo_3 M_elec_usd_ahorro_3 M_hidro_usd_ahorro_3 M_usd_ahorro_3 M_elec_kwh_ahorro_3 M_hidro_kwh_ahorro_3 ///
M_kwh_ahorro_3 M_GEI_3 M_elec_GEI_3 M_hidro_GEI_3 M_recupera_3 M_produccion_3 if adopcion!=. & informe_CII==1, by(AED )
esttab using Data_out\Tables\M_ttest_AED_3.rtf, noobs cells("mu_1(fmt(4)) mu_2(fmt(4))  b(star fmt(4))") star(* 0.1 ** .05 *** 0.01) ///
collabels("Sencilla" "Detallada" "Diferencia" ) width(0.8\hsize) replace 


**Diferencuas entre rechazados y aceptados **
foreach var in s_1 s_2 s_3 s_4 s_5 y_1 y_2 y_3 y_4 y_5 y_6 y_7 y_8  more_10 small revenues_low high_gdp andinos {
replace `var'=`var'*100
}

estpost ttest s_1 s_2 s_3 s_4 s_5 y_1 y_2 y_3 y_4 y_5 y_6 y_7 y_8  more_10 small revenues_low high_gdp andinos if benefi==1, by(approved)
esttab using Data_out\Tables\ttest_rech_acep.csv, noobs cells("mu_1(fmt(1)) mu_2(fmt(1))  b(star fmt(1))") star(* 0.1 ** .05 *** 0.01) ///
collabels("Rechazadas" "Aceptadas" "Diferencia" ) width(0.8\hsize) replace 

** Diferencia aceptado y aprobado **

estpost ttest s_1 s_2 s_3 s_4 s_5 y_1 y_2 y_3 y_4 y_5 y_6 y_7 y_8 more_10 small revenues_low high_gdp andinos if aprob_inf!=., by(aprob_inf)
esttab using Data_out\Tables\ttest_acep_apro.rtf, noobs cells("mu_1(fmt(1)) mu_2(fmt(1))  b(star fmt(1))") star(* 0.1 ** .05 *** 0.01) ///
collabels("Aceptadas" "Aprobadas" "Diferencia" ) width(0.8\hsize) replace 

** Diferencia sencilla y detallada **
estpost ttest s_1 s_2 s_3 s_4 s_5 y_1 y_2 y_3 y_4 y_5 y_6 y_7 y_8 more_10 small revenues_low high_gdp andinos if audit<4 & informe_CII==1, by(AED)
esttab using Data_out\Tables\ttest_AED.rtf, noobs cells("mu_1(fmt(1)) mu_2(fmt(1))  b(star fmt(1))") star(* 0.1 ** .05 *** 0.01) ///
collabels("Sencilla" "Detallada" "Diferencia" ) width(0.8\hsize) replace 

foreach var in s_1 s_2 s_3 s_4 s_5 y_1 y_2 y_3 y_4 y_5 y_6 y_7 y_8  more_10 small revenues_low high_gdp andinos {
replace `var'=`var'/100
}

***************************
***    Histogramas 		***
***************************

*Histograma de tiempo para recuperar la inversion 
sum M_recupera if adopcion!=.  & M_recupera<50, d
hist M_recupera if adopcion!=.  & M_recupera<50
graph export Data_out\Graphs\M_recupera.png, replace

label val AED AED

sum M_recupera if adopcion!=. & M_recupera<50 & AED==0, d
sum M_recupera if adopcion!=. & M_recupera<50 & AED==1, d 
histogram M_recupera if M_recupera<50 &  M_aCII==1, by(AED, note("")) width(1) 
graph export Data_out\Graphs\M_recupera_AED.png, replace


sum LBM_Anios_recupera_P if adopcion!=. , d
hist LBM_Anios_recupera_P if adopcion!=. 
graph export Data_out\Graphs\LBM_Anios_recupera_P.png, replace

sum LBM_Anios_recupera_P if adopcion!=. & AED==0, d
sum LBM_Anios_recupera_P if adopcion!=. & AED==1, d 

histogram LBM_Anios_recupera_P , by(AED, note("")) width(1) 
graph export Data_out\Graphs\LBM_Anios_recupera_P_AED.png, replace

histogram LBM_Anios_recupera_P if audit<4 & informe_CII==1, by(adopcion, note("")) width(1) 
graph export Data_out\Graphs\LBM_Anios_recupera_P_adop.png, replace

sum LBM_Anios_recupera_P if audit<4 & informe_CII==1 & adopcion==0 , d
sum LBM_Anios_recupera_P if audit<4 & informe_CII==1 & adopcion==1 , d 

*******************************************
***    Distribuciones de densidad 		***
*******************************************
set scheme s1color 
twoway (kdensity M_costo) (kdensity M_costo if AED==0) (kdensity M_costo if AED==1) if M_costo>0, ///
title("Investments (USD)") legend(label(1 "All") label(2 "Simple") label(3 "Detailed") rows(1) )  ///
xtitle("Investments") ytitle("K-Density")
graph export Data_out\Graphs\M_costo.png, replace

twoway (kdensity M_elec_costo) (kdensity M_elec_costo if AED==0) (kdensity M_elec_costo if AED==1) if M_elec_costo>0, ///
title("Investments in Energy (USD)") legend(label(1 "All") label(2 "Simple") label(3 "Detailed") rows(1) )  ///
xtitle("Investments") ytitle("K-Density")
graph export Data_out\Graphs\M_elec_costo.png, replace

twoway (kdensity M_hidro_costo) (kdensity M_hidro_costo if AED==0) (kdensity M_hidro_costo if AED==1) if M_hidro_costo>0, ///
title("Investments in Hydrocarbons (USD)") legend(label(1 "All") label(2 "Simple") label(3 "Detailed") rows(1) )  ///
xtitle("Investments") ytitle("K-Density")
graph export Data_out\Graphs\M_hidro_costo.png, replace

*Ahorro
twoway (kdensity M_usd_ahorro) (kdensity M_usd_ahorro if AED==0) (kdensity M_usd_ahorro if AED==1) if M_usd_ahorro>0, ///
title("Savings (USD)") legend(label(1 "All") label(2 "Simple") label(3 "Detailed") rows(1) )  ///
xtitle("Savings") ytitle("K-Density")
graph export Data_out\Graphs\M_usd_ahorro.png, replace

twoway (kdensity M_elec_usd_ahorro) (kdensity M_elec_usd_ahorro if AED==0) (kdensity M_elec_usd_ahorro if AED==1) if M_elec_usd_ahorro>0, ///
title("Savings in Energy (USD)") legend(label(1 "All") label(2 "Simple") label(3 "Detailed") rows(1) )  ///
xtitle("Savings") ytitle("K-Density")
graph export Data_out\Graphs\M_elec_usd_ahorro.png, replace

twoway (kdensity M_hidro_usd_ahorro) (kdensity M_hidro_usd_ahorro if AED==0) (kdensity M_hidro_usd_ahorro if AED==1) if M_hidro_usd_ahorro>0, ///
title("Savings in Hydrocarbons (USD)") legend(label(1 "All") label(2 "Simple") label(3 "Detailed") rows(1) )  ///
xtitle("Savings") ytitle("K-Density")
graph export Data_out\Graphs\M_hidro_usd_ahorro.png, replace

 
*Ahorro en KWH
twoway (kdensity M_kwh_ahorro) (kdensity M_kwh_ahorro if AED==0) (kdensity M_kwh_ahorro if AED==1) if M_kwh_ahorro>0, ///
title("Savings (KWH)") legend(label(1 "All") label(2 "Simple") label(3 "Detailed") rows(1) )  ///
xtitle("Savings") ytitle("K-Density")
graph export Data_out\Graphs\M_kwh_ahorro.png, replace

twoway (kdensity M_elec_kwh_ahorro) (kdensity M_elec_kwh_ahorro if AED==0) (kdensity M_elec_kwh_ahorro if AED==1) if M_elec_kwh_ahorro>0, ///
title("Savings in Energy (KWH)") legend(label(1 "All") label(2 "Simple") label(3 "Detailed") rows(1) )  ///
xtitle("Savings") ytitle("K-Density")
graph export Data_out\Graphs\M_elec_kwh_ahorro.png, replace

twoway (kdensity M_hidro_kwh_ahorro) (kdensity M_hidro_kwh_ahorro if AED==0) (kdensity M_hidro_kwh_ahorro if AED==1) if M_hidro_kwh_ahorro>0, ///
title("Savings in Hydrocarbons (KWH)") legend(label(1 "All") label(2 "Simple") label(3 "Detailed") rows(1) )  ///
xtitle("Savings") ytitle("K-Density")
graph export Data_out\Graphs\M_hidro_kwh_ahorro.png, replace
   

*GEI
twoway (kdensity M_GEI) (kdensity M_GEI if AED==0) (kdensity M_GEI if AED==1) if M_GEI>0, ///
title("GEI") legend(label(1 "All") label(2 "Simple") label(3 "Detailed") rows(1) )  ///
xtitle("GEI") ytitle("K-Density")
graph export Data_out\Graphs\M_GEI.png, replace

twoway (kdensity M_elec_GEI) (kdensity M_elec_GEI if AED==0) (kdensity M_elec_GEI if AED==1) if M_elec_GEI>0, ///
title("GEI in Energy (USD)") legend(label(1 "All") label(2 "Simple") label(3 "Detailed") rows(1) )  ///
xtitle("GEI") ytitle("K-Density")
graph export Data_out\Graphs\M_elec_GEI.png, replace

twoway (kdensity M_hidro_GEI) (kdensity M_hidro_GEI if AED==0) (kdensity M_hidro_GEI if AED==1) if M_hidro_GEI>0, ///
title("GEI in Hydrocarbons (USD)") legend(label(1 "All") label(2 "Simple") label(3 "Detailed") rows(1) )  ///
xtitle("GEI") ytitle("K-Density")
graph export Data_out\Graphs\M_hidro_GEI.png, replace

  
log close
