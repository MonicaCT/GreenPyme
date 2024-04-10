
*Cambiar el Directorio
cd "D:\GreenPyme_Final\Stata"
************************************************************************
************************LIMPIANDO LOS DATOS*****************************
************************************************************************
doe Do\Greenpyme_db.do
do Do\Greenpyme_descrip.do
*do Do\Greenpyme_reg.do /*Regresiones anteriores*/
************************************************************************
********************************MATCHING********************************
************************************************************************
*+++++++PSOCRE++++++
*Modelos
doed Do\Greenpyme_psm-m1a
doed Do\Greenpyme_psm-m3a
*Evaluación de los modelos

*Mejor sample

*Características del mejor modelo

*+++++++NNMATCH+++++
*Modelos


*Evaluación de los modelos
*Mejor modelo

*Características del mejor modelo

/*Poner un anexo con los resultados del matching por ambos lados*/
*+++++++ELECCIÓN DE LA MUESTRA++++++++++++
/*El modelo mejor de matching que cumple con las caracteristicas xx fue el de xx*/


************************************************************************
*****************************MODELOS DE ADOPCIÓN************************
************************************************************************
*+++++++++Probabilidad de adopción+++++++++++
/*Se estima la probabilidad de adopción de acuerdo a las características de la
empresa y según el tipo de auditoria que tuvo*/
use Results\PSM_CommonSuport\Greenpyme_db_clean-m1,clear
probit adopcion AED i.sector_BID i.after_2013 i.more_10 i.small i.revenues_low i.high_gdp if audit<4 & informe_CII==1
margins, dydx(*) post
outreg2 using Results\Probit_Adopt.xls,  label replace ctitle(Marginal effects) 
************************************************************************
***********************************IMPACTOS*****************************
************************************************************************
*+++++++++Impactos en las variables de interés+++++++++++
*COVARIATES
global covariates i.AED age i.small i.sector_BID i.high_gdp
*******************************************
*Efetos ahorro kwh
*******************************************
*++++Primero el general AHORRO TOTA POR EMPRESA 
*Monitoreo 1
egen M1_costo=rowtotal(M1_light_costo M1_AC_costo M1_compress_costo M1_eprod_costo)
egen M1_kwh_ahorro=rowtotal(M1_light_kwh_ahorro M1_AC_kwh_ahorro M1_compress_kwh_ahorro M1_eprod_kwh_ahorro)
gen lM1_kwh_ahorro=log(M1_kwh_ahorro+((M1_kwh_ahorro^2)+1)^(1/2))
gen lM1_costo=log(M1_costo+((M1_costo^2)+1)^(1/2))
xi: reg lM1_kwh_ahorro lM1_costo $covariates
*Moniteoreo 2
egen M2_costo=rowtotal(M2_light_costo M2_AC_costo M2_compress_costo M2_eprod_costo)
egen M2_kwh_ahorro=rowtotal(M2_light_kwh_ahorro M2_AC_kwh_ahorro M2_compress_kwh_ahorro M2_eprod_kwh_ahorro)
gen lM2_kwh_ahorro=log(M2_kwh_ahorro)
gen lM2_costo=log(M2_costo)
xi: reg lM2_kwh_ahorro lM2_costo $covariates
*Moniteoreo 1 y 2
gen lM_kwh_ahorro=log(M_kwh_ahorro)
gen lM_costo=log(M_costo)
xi: reg lM_kwh_ahorro lM_costo $covariates

*++++++Lo particular según tipo de adopción
global glokwh M1_light_kwh_ahorro M1_AC_kwh_ahorro M1_AC_kwh_ahorro M1_compress_kwh_ahorro M1_hwater_kwh_ahorro ///
M1_eprod_kwh_ahorro M2_light_kwh_ahorro M2_AC_kwh_ahorro M2_AC_kwh_ahorro M2_compress_kwh_ahorro M2_hwater_kwh_ahorro ///
M1_eprod_kwh_ahorro

gen lM1_light_kwh_ahorro=log(M1_light_kwh_ahorro)
gen lM1_AC_kwh_ahorro=log(M1_AC_kwh_ahorro)
gen lM1_compress_kwh_ahorro=log(M1_compress_kwh_ahorro)
gen lM1_hwater_kwh_ahorro=log(M1_hwater_kwh_ahorro)
gen lM1_eprod_kwh_ahorro=log(M1_eprod_kwh_ahorro)
gen lM2_light_kwh_ahorro=log(M2_light_kwh_ahorro)
gen lM2_AC_kwh_ahorro=log(M2_AC_kwh_ahorro)
gen lM2_compress_kwh_ahorro=log(M2_compress_kwh_ahorro)
gen lM2_hwater_kwh_ahorro=log(M2_hwater_kwh_ahorro)
gen lM2_eprod_kwh_ahorro=log(M2_eprod_kwh_ahorro)
*Costos
gen lM1_light_costo=log(M1_light_costo)
gen lM1_AC_costo=log(M1_AC_costo)
gen lM1_compress_costo=log(M1_compress_costo)
gen lM1_hwater_costo=log(M1_hwater_costo)
gen lM1_eprod_costo=log(M1_eprod_costo)
gen lM2_light_costo=log(M2_light_costo)
gen lM2_AC_costo=log(M2_AC_costo)
gen lM2_compress_costo=log(M2_compress_costo)
gen lM2_hwater_costo=log(M2_hwater_costo)
gen lM2_eprod_costo=log(M2_eprod_costo)

*Regresiones

foreach var in $glokwh {
capture gen log_`var'=log(`var'+((`var'^2)+1)^(1/2))
xi: reg log_`var' $covariates  
outreg2 using Results\Kwh_Adopt.xls,  label append ctitle(`var') 
}

xi: reg lM1_light_kwh_ahorro lM1_light_costo $covariates
xi: reg lM1_AC_kwh_ahorro lM1_AC_costo $covariates
xi: reg lM1_compress_kwh_ahorro lM1_compress_costo $covariates
xi: reg lM1_hwater_kwh_ahorro lM1_hwater_costo $covariates /*no hay suficientes observaciones*/
xi: reg lM1_eprod_kwh_ahorro lM1_eprod_costo $covariates if adop_tar_gest==1
xi: reg lM1_eprod_kwh_ahorro lM1_eprod_costo $covariates if adop_agua==1
xi: reg lM1_eprod_kwh_ahorro lM1_eprod_costo $covariates if adop_refrig==1
xi: reg lM1_eprod_kwh_ahorro lM1_eprod_costo $covariates if adop_reemplazos==1
xi: reg lM1_eprod_kwh_ahorro lM1_eprod_costo $covariates if adop_otros==1

xi: reg lM2_light_kwh_ahorro lM2_light_costo $covariates
xi: reg lM2_AC_kwh_ahorro lM2_AC_costo $covariates
xi: reg lM2_compress_kwh_ahorro lM2_compress_costo $covariates /*No hay suficientes obser*/
xi: reg lM2_hwater_kwh_ahorro lM2_hwater_costo $covariates /*no hay suficientes observaciones*/
xi: reg lM2_eprod_kwh_ahorro lM2_eprod_costo $covariates if adop_tar_gest==1
xi: reg lM2_eprod_kwh_ahorro lM2_eprod_costo $covariates if adop_agua==1
xi: reg lM2_eprod_kwh_ahorro lM2_eprod_costo $covariates if adop_refrig==1
xi: reg lM2_eprod_kwh_ahorro lM2_eprod_costo $covariates if adop_reemplazos==1
xi: reg lM2_eprod_kwh_ahorro lM2_eprod_costo $covariates if adop_otros==1

*******************************************
*Efetos ahorro USD
*******************************************
*Primero el general AHORRO TOTA POR EMPRESA 
*Monitoreo 1
egen M1_usd_ahorro=rowtotal(M1_light_usd_ahorro M1_AC_usd_ahorro M1_hwater_usd_ahorro M1_compress_usd_ahorro)
gen lM1_usd_ahorro=log(M1_kwh_ahorro)
xi: reg lM1_usd_ahorro lM1_costo $covariates
*Monitoreo 2
egen M2_usd_ahorro=rowtotal(M2_light_usd_ahorro M2_AC_usd_ahorro M2_hwater_usd_ahorro M2_compress_usd_ahorro)
br M2_usd_ahorro M2_light_kwh_ahorro M2_AC_kwh_ahorro M2_compress_kwh_ahorro M2_eprod_kwh_ahorro
gen lM2_usd_ahorro=log(M2_kwh_ahorro)
xi: reg lM2_usd_ahorro lM2_costo $covariates
*Monitoreo 1 y 2
gen lM_usd_ahorro=log(M_kwh_ahorro)
xi: reg lM_usd_ahorro lM_costo $covariates

*Lo particular según tipo de adopción
gen lM1_light_usd_ahorro=log(M1_light_kwh_ahorro)
gen lM1_AC_usd_ahorro=log(M1_AC_kwh_ahorro)
gen lM1_compress_usd_ahorro=log(M1_compress_kwh_ahorro)
gen lM1_hwater_usd_ahorro=log(M1_hwater_kwh_ahorro)
gen lM1_eprod_usd_ahorro=log(M1_eprod_kwh_ahorro)
gen lM2_light_usd_ahorro=log(M2_light_kwh_ahorro)
gen lM2_AC_usd_ahorro=log(M2_AC_kwh_ahorro)
gen lM2_compress_usd_ahorro=log(M2_compress_kwh_ahorro)
gen lM2_hwater_usd_ahorro=log(M2_hwater_kwh_ahorro)
gen lM2_eprod_usd_ahorro=log(M2_eprod_kwh_ahorro)
*
xi: reg lM1_light_usd_ahorro lM1_light_costo $covariates
xi: reg lM1_AC_usd_ahorro lM1_AC_costo $covariates
xi: reg lM1_compress_usd_ahorro lM1_compress_costo $covariates
xi: reg lM1_hwater_usd_ahorro lM1_hwater_costo $covariates /*no hay suficientes observaciones*/
xi: reg lM1_eprod_usd_ahorro lM1_eprod_costo $covariates if adop_tar_gest==1
xi: reg lM1_eprod_usd_ahorro lM1_eprod_costo $covariates if adop_agua==1
xi: reg lM1_eprod_usd_ahorro lM1_eprod_costo $covariates if adop_refrig==1
xi: reg lM1_eprod_usd_ahorro lM1_eprod_costo $covariates if adop_reemplazos==1
xi: reg lM1_eprod_usd_ahorro lM1_eprod_costo $covariates if adop_otros==1

xi: reg lM2_light_kwh_ahorro lM2_light_costo $covariates
xi: reg lM2_AC_kwh_ahorro lM2_AC_costo $covariates
xi: reg lM2_compress_kwh_ahorro lM2_compress_costo $covariates /*No hay suficientes obser*/
xi: reg lM2_hwater_kwh_ahorro lM2_hwater_costo $covariates /*no hay suficientes observaciones*/
xi: reg lM2_eprod_kwh_ahorro lM2_eprod_costo $covariates if adop_tar_gest==1
xi: reg lM2_eprod_kwh_ahorro lM2_eprod_costo $covariates if adop_agua==1
xi: reg lM2_eprod_kwh_ahorro lM2_eprod_costo $covariates if adop_refrig==1
xi: reg lM2_eprod_kwh_ahorro lM2_eprod_costo $covariates if adop_reemplazos==1
xi: reg lM2_eprod_kwh_ahorro lM2_eprod_costo $covariates if adop_otros==1

*******************************************
*Efetos sobre GEI
*******************************************
*Primero el general AHORRO TOTA POR EMPRESA 
*Monitoreo 1
egen M1_GEI=rowtotal(M1_light_GEI M1_AC_GEI M1_hwater_GEI M1_compress_GEI)
br M1_GEI M1_light_GEI M1_AC_GEI M1_compress_GEI M1_eprod_GEI
gen lM1_GEI=log(M1_GEI)
xi: reg lM1_GEI lM1_costo $covariates
*Monitoreo 1
egen M2_GEI=rowtotal(M2_light_GEI M2_AC_GEI M2_hwater_GEI M2_compress_GEI)
gen lM2_GEI=log(M2_GEI)
xi: reg lM2_GEI lM2_costo $covariates
*Monitoreo 1 y 2
gen lM_GEI=log(M_GEI)
xi: reg lM_GEI lM_costo $covariates

*Lo particular según tipo de adopción
gen lM1_light_GEI=log(M1_light_GEI)
gen lM1_AC_GEI=log(M1_AC_GEI)
gen lM1_compress_GEI=log(M1_compress_GEI)
gen lM1_hwater_GEI=log(M1_hwater_GEI)
gen lM1_eprod_GEI=log(M1_eprod_GEI)
gen lM2_light_GEI=log(M2_light_GEI)
gen lM2_AC_GEI=log(M2_AC_GEI)
gen lM2_compress_GEI=log(M2_compress_GEI)
gen lM2_hwater_GEI=log(M2_hwater_GEI)
gen lM2_eprod_GEI=log(M2_eprod_GEI)
*
xi: reg lM1_light_GEI lM1_light_costo $covariates
xi: reg lM1_AC_GEI lM1_AC_costo $covariates
xi: reg lM1_compress_GEI lM1_compress_costo $covariates
xi: reg lM1_hwater_GEI lM1_hwater_costo $covariates /*no hay suficientes observaciones*/
xi: reg lM1_eprod_GEI lM1_eprod_costo $covariates if adop_tar_gest==1
xi: reg lM1_eprod_GEI lM1_eprod_costo $covariates if adop_agua==1
xi: reg lM1_eprod_GEI lM1_eprod_costo $covariates if adop_refrig==1
xi: reg lM1_eprod_GEI lM1_eprod_costo $covariates if adop_reemplazos==1
xi: reg lM1_eprod_GEI lM1_eprod_costo $covariates if adop_otros==1

xi: reg lM2_light_kwh_ahorro lM2_light_costo $covariates
xi: reg lM2_AC_kwh_ahorro lM2_AC_costo $covariates
xi: reg lM2_compress_kwh_ahorro lM2_compress_costo $covariates /*No hay suficientes obser*/
xi: reg lM2_hwater_kwh_ahorro lM2_hwater_costo $covariates /*no hay suficientes observaciones*/
xi: reg lM2_eprod_kwh_ahorro lM2_eprod_costo $covariates if adop_tar_gest==1
xi: reg lM2_eprod_kwh_ahorro lM2_eprod_costo $covariates if adop_agua==1
xi: reg lM2_eprod_kwh_ahorro lM2_eprod_costo $covariates if adop_refrig==1
xi: reg lM2_eprod_kwh_ahorro lM2_eprod_costo $covariates if adop_reemplazos==1
xi: reg lM2_eprod_kwh_ahorro lM2_eprod_costo $covariates if adop_otros==1

*******************************************
*Efetos en el ratio
*******************************************
*Primero el general AHORRO TOTA POR EMPRESA 
*Monitoreo 1
egen M1_GEI=rowtotal(M1_light_GEI M1_AC_GEI M1_hwater_GEI M1_compress_GEI)
br M1_GEI M1_light_GEI M1_AC_GEI M1_compress_GEI M1_eprod_GEI
gen lM1_GEI=log(M1_GEI)
xi: reg lM1_GEI lM1_costo $covariates
*Monitoreo 2
egen M2_GEI=rowtotal(M2_light_GEI M2_AC_GEI M2_hwater_GEI M2_compress_GEI)
gen lM2_GEI=log(M2_GEI)
xi: reg lM2_GEI lM2_costo $covariates
*Monitoreo 1 y 2
gen lM_GEI=log(M_GEI)
xi: reg lM_GEI lM_costo $covariates

*Lo particular según tipo de adopción
gen lM1_light_GEI=log(M1_light_GEI)
gen lM1_AC_GEI=log(M1_AC_GEI)
gen lM1_compress_GEI=log(M1_compress_GEI)
gen lM1_hwater_GEI=log(M1_hwater_GEI)
gen lM1_eprod_GEI=log(M1_eprod_GEI)
gen lM2_light_GEI=log(M2_light_GEI)
gen lM2_AC_GEI=log(M2_AC_GEI)
gen lM2_compress_GEI=log(M2_compress_GEI)
gen lM2_hwater_GEI=log(M2_hwater_GEI)
gen lM2_eprod_GEI=log(M2_eprod_GEI)
*


xi: reg lM1_light_GEI lM1_light_costo $covariates
xi: reg lM1_AC_GEI lM1_AC_costo $covariates
xi: reg lM1_compress_GEI lM1_compress_costo $covariates
xi: reg lM1_hwater_GEI lM1_hwater_costo $covariates /*no hay suficientes observaciones*/
xi: reg lM1_eprod_GEI lM1_eprod_costo $covariates if adop_tar_gest==1
xi: reg lM1_eprod_GEI lM1_eprod_costo $covariates if adop_agua==1
xi: reg lM1_eprod_GEI lM1_eprod_costo $covariates if adop_refrig==1
xi: reg lM1_eprod_GEI lM1_eprod_costo $covariates if adop_reemplazos==1
xi: reg lM1_eprod_GEI lM1_eprod_costo $covariates if adop_otros==1

xi: reg lM2_light_kwh_ahorro lM2_light_costo $covariates
xi: reg lM2_AC_kwh_ahorro lM2_AC_costo $covariates
xi: reg lM2_compress_kwh_ahorro lM2_compress_costo $covariates /*No hay suficientes obser*/
xi: reg lM2_hwater_kwh_ahorro lM2_hwater_costo $covariates /*no hay suficientes observaciones*/
xi: reg lM2_eprod_kwh_ahorro lM2_eprod_costo $covariates if adop_tar_gest==1
xi: reg lM2_eprod_kwh_ahorro lM2_eprod_costo $covariates if adop_agua==1
xi: reg lM2_eprod_kwh_ahorro lM2_eprod_costo $covariates if adop_refrig==1
xi: reg lM2_eprod_kwh_ahorro lM2_eprod_costo $covariates if adop_reemplazos==1
xi: reg lM2_eprod_kwh_ahorro lM2_eprod_costo $covariates if adop_otros==1



********
*AHORRO COMPARADO CON LA LINEA BASE
*********
xi: reg total_ahorro_LB $covariates
xi: reg total_ahor~I_LB  $covariates
xi: reg total_ahorro_PI $covariates
xi: reg total_ahor~I_PI $covariates










*"Iluminación" M1_light_kwh_ahorro
*"Aire Acondicionado" M1_AC_kwh_ahorro
*"Calentar Agua" M1_hwater_kwh_ahorro
*"Compresor" M1_compress_kwh_ahorro
*"Producción de electricidad" M1_eprod_kwh_ahorro
*"Optimizar gestión de la energia" adop_tar_gest==1 & M1_oelec_medida M1_oelec_usd_ahorro M1_oelec_kwh_ahorro M1_oelec_costo M1_oelec_GEI M1_oelec_1date
*"Manejo del agua" adop_agua ==1
*"Refrigeración" adop_refrig==1
*"Optimización y/o sustitución de maquinarias y equipos" adop_reemplazos==1
*"Otras implementaciones electricas" adop_otros==1
*"Hidrocarburos" adop_hidro==1



global moni_all M_usd_ahorro M_kwh_ahorro M_GEI M_recupera M_produccion Ratio_ahorro_usd Ratio_ahorro_kwh Ratio_ahorro_GEI 
global moni_elec M_elec_costo  M_elec_usd_ahorro   M_elec_kwh_ahorro M_elec_GEI Ratio_ahorro_elec_usd Ratio_ahorro_elec_kwh Ratio_ahorro_elec_GEI
global moni_hidro  M_hidro_costo  M_hidro_usd_ahorro   M_hidro_kwh_ahorro  M_hidro_GEI Ratio_ahorro_hidro_usd Ratio_ahorro_hidro_kwh Ratio_ahorro_hidro_GEI

xi: reg M_costo AED i.sector_BID i.after_2013 i.more_10 i.small i.revenues_low  i.high_gdp  if adopcion!=. 
outreg2 using results\OLS_1_Adopt.xls,  label replace 

foreach var in Ratio_ahorro_elec_usd Ratio_ahorro_hidro_usd Ratio_ahorro_usd Ratio_ahorro_elec_kwh Ratio_ahorro_hidro_kwh ///
Ratio_ahorro_kwh Ratio_ahorro_elec_GEI Ratio_ahorro_hidro_GEI Ratio_ahorro_GEI {
replace `var'=`var'*100
}

keep if adop_q>0

foreach var in $moni_all {
xi: reg `var' AED i.sector_BID i.after_2013 i.more_10 i.small i.revenues_low  i.high_gdp  
outreg2 using results\OLS_1_Adopt.xls,  label append 
}


preserve

keep if ( adop_hidro==0) | (adop_q>1 & adop_hidro==1)

foreach var in $moni_elec {
xi: reg `var' AED i.sector_BID i.after_2013 i.more_10 i.small i.revenues_low  i.high_gdp  
outreg2 using results\OLS_1_Adopt.xls,  label append 
}

restore

preserve

keep if adop_hidro==1

foreach var in $moni_hidro {
xi: reg `var' AED i.sector_BID i.after_2013 i.more_10 i.small i.revenues_low  i.high_gdp  
outreg2 using results\OLS_1_Adopt.xls,  label append  
}

restore

foreach var in Ratio_ahorro_elec_usd Ratio_ahorro_hidro_usd Ratio_ahorro_usd Ratio_ahorro_elec_kwh Ratio_ahorro_hidro_kwh ///
Ratio_ahorro_kwh Ratio_ahorro_elec_GEI Ratio_ahorro_hidro_GEI Ratio_ahorro_GEI {
replace `var'=`var'/100
}


*Controlando por ganancias

xi: reg M_costo AED i.sector_BID i.after_2013 i.more_10 i.small revenues  i.high_gdp  if adopcion!=. 
outreg2 using results\OLS_2_Adopt.xls,  label replace 

foreach var in Ratio_ahorro_elec_usd Ratio_ahorro_hidro_usd Ratio_ahorro_usd Ratio_ahorro_elec_kwh Ratio_ahorro_hidro_kwh ///
Ratio_ahorro_kwh Ratio_ahorro_elec_GEI Ratio_ahorro_hidro_GEI Ratio_ahorro_GEI {
replace `var'=`var'*100
}

keep if adop_q>0

foreach var in $moni_all {
xi: reg `var' AED i.sector_BID i.after_2013 i.more_10 i.small revenues  i.high_gdp  
outreg2 using results\OLS_2_Adopt.xls,  label append 
}


preserve

keep if ( adop_hidro==0) | (adop_q>1 & adop_hidro==1)

foreach var in $moni_elec {
xi: reg `var' AED i.sector_BID i.after_2013 i.more_10 i.small revenues  i.high_gdp  
outreg2 using results\OLS_2_Adopt.xls,  label append 
}

restore

preserve

keep if adop_hidro==1

foreach var in $moni_hidro {
xi: reg `var' AED i.sector_BID i.after_2013 i.more_10 i.small revenues  i.high_gdp  
outreg2 using results\OLS_2_Adopt.xls,  label append  
}

restore

foreach var in Ratio_ahorro_elec_usd Ratio_ahorro_hidro_usd Ratio_ahorro_usd Ratio_ahorro_elec_kwh Ratio_ahorro_hidro_kwh ///
Ratio_ahorro_kwh Ratio_ahorro_elec_GEI Ratio_ahorro_hidro_GEI Ratio_ahorro_GEI {
replace `var'=`var'/100
}


*En logs

capture gen log_M_costo=log(M_costo+((M_costo^2)+1)^(1/2))

xi: reg log_M_costo AED i.sector_BID i.after_2013 i.more_10 i.small i.revenues_low  i.high_gdp  
outreg2 using results\OLS_3_Adopt.xls,  label replace ctitle(M_costo) 

global moni_all2 M_usd_ahorro M_kwh_ahorro M_GEI M_recupera M_produccion 

global moni_elec2 M_elec_costo  M_elec_usd_ahorro   M_elec_kwh_ahorro M_elec_GEI 

global moni_hidro2  M_hidro_costo  M_hidro_usd_ahorro   M_hidro_kwh_ahorro  M_hidro_GEI 


foreach var in $moni_all2 {
capture gen log_`var'=log(`var'+((`var'^2)+1)^(1/2))

xi: reg log_`var' AED i.sector_BID i.after_2013 i.more_10 i.small i.revenues_low  i.high_gdp  
outreg2 using results\OLS_3_Adopt.xls,  label append ctitle(`var') 
}

preserve

keep if ( adop_hidro==0) | (adop_q>1 & adop_hidro==1)

foreach var in $moni_elec2 {
xi: reg `var' AED i.sector_BID i.after_2013 i.more_10 i.small i.revenues_low  i.high_gdp  
outreg2 using results\OLS_3_Adopt.xls,  label append 
}

restore

preserve

keep if adop_hidro==1

foreach var in $moni_hidro2 {
xi: reg `var' AED i.sector_BID i.after_2013 i.more_10 i.small i.revenues_low  i.high_gdp  
outreg2 using results\OLS_3_Adopt.xls,  label append  
}

restore




*Efectos fijos

*Diferencias en diferencias









