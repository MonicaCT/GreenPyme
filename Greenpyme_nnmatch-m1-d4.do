********************************************************************************
*** Este dofile crea las estimaciones de Greenpyme y descriptivas en         ***
*** el soporte comun usando el comando nnmatch                                                        ***
*** Autora: Maria Laura Lanzalot 											 ***
*** date: 02/2020  														 ***
********************************************************************************
clear all
set more off
*cd "C:\Users\MLANZALOT\Inter-American Development Bank Group\Yanez Pagans, Patricia - GreenPyme\GreenPyme"
cd "C:\Users\Asus\Documents\IDBinvest\GreenPymes\Dataset and do-files"
use data\Greenpyme_db_clean.dta, clear

********************************************************************************
/*Paso 1: Define número de vecinos para el nnmatch
********************************************************************************/
global nmat 4
********************************************************************************
/*Paso 2: Numera los modelos de acuerdo al número de variables que se 
consideran para el matching exacto
*******************************************************************************/
global model 4
********************************************************************************
/*Paso 3: Para matching solo muestra rural (primero se filtra quitando 
comunidades a menos de 3 km de pavimentados)
*******************************************************************************/
*Model 1
********
rename sector_BID sBID
rename after_2013 a2013
rename employees_n menplo
rename revenues_n reve
rename high_gdp hgdp
global cv_m1 sBID a2013 age menplo reve hgdp /*continuas*/
nnmatch n AED $cv_m1, tc(att) metric(maha) m($nmat) keep(matches) replace

********************************************************************************
*Paso 4: Extrae de la base de datos de match lo necesario para pasarlo a la base original
*******************************************************************************/
use "matches", clear
rename n_0 n_control
rename n_1 n_tratado_1
keep n n_control dist n_tratado_1
sort n dist
by n: gen match=_n
reshape wide n_control dist, i(n n_tratado_1) j(match)
save "aux1", replace

use data\Greenpyme_db_clean.dta, clear
merge 1:1 n using "aux1"
tab _merge
drop _merge
sort n
save data\Greenpyme_db_clean2, replace

********************************************************************************
/*Paso 5: Generamos el número de veces que aparecen como controles y 
distancia a cada tratado
*******************************************************************************/
use "aux1", clear
forvalues i=1(1)$nmat {
*forvalues i=1(1)1 {
bysort n_control`i': gen veces_control`i'=_N 
collapse (min) dist`i' (max) veces_control`i', by(n_control`i')
rename n_control`i' n
sort n
merge n using data\Greenpyme_db_clean2
tab _merge
drop if _merge==1
drop _merge
sort n
rename n n_treated
}

save data\Greenpyme_db_clean3, replace

********************************************************************************
*Paso 6: Marca las observaciones de control que son buenos matches **/
********************************************************************************
* Utilizando 1 vecino más cercano
*gen control_matched = [treated==0 & (dist1~=.)]
* Utilizandos 2 vecinos más cercanos
*gen control_matched = [treated==0 & (dist1~=. | dist2~=.)]
* Utilizando 4 vecinos más cercanos
gen control_matched = [AED==0 & (dist1~=. | dist2~=. | dist3~=. | dist4~=.)]
* Utilizando 5 vecinos más cercanos
*gen control_matched = [n_tratado==0 & (dist1~=. | dist2~=. | dist3~=. | dist4~=. | dist5~=.)]
*gen control_matched = [AED==0 & (dist1!=. | dist2!=. | dist3!=. | dist4!=. | dist5!=.)]

********************************************************************************
*Paso 7: Balance before matching */
********************************************************************************
*rename sector_BID sBID
*rename after_2013 a2013
*rename employees_n menplo
*rename revenues_n reve
*rename high_gdp hgdp
*drop if country=="Colombia" | country=="Panamá"
global cv_m1 s_1 s_2 s_3 s_4 s_5 y_1 y_2 y_3 y_4 y_5 y_6 y_7 y_8 more_10 small revenues_low high_gdp andinos if audit<4 & informe_CII==1
estpost ttest $cv_m1, by(AED)
estout using nnmatch_model1b_$model.out, cells("mu_2(fmt(3) label(Mean Treated)) mu_1(fmt(3) label(Mean Control)) b(fmt(3) label(Difference)star)") label replace 

********************************************************************************
*Paso 8: Muestra valida después del matching (tratados y mejores controles) **/
********************************************************************************
gen matched_sample = 1 if AED==1 | control_match==1
tab matched_sample AED
save data\Greenpyme_db_clean3, replace
tab AED, m

/***********************************************************
*Paso 9: Cuenta el número de comunidades que hay en cada tramo 
el numero de empresas que hay en cada pais**
**********************************************************
bysort country_n: gen n_com1 = _N
tab country_n if  AED==0 & inlist(mc_orden_bd_multicriterio,149,46,42,138,20), m
tab matched_sample treated if inlist(mc_orden_bd_multicriterio,149,46,42,138,20, 10)

********************************* Identificando caminos *********************************************
* Total de 79 comunidades de control antes del match en estos tramos
* 149 - Condega - Lim. Mcpal. Condega/Pueblo
* 46 - San Ramón - Empalme El Jobo - Empalme..
* 42 -  Estelí - Escuela Miraflores 
* 138 - Sn. Fco. Del Norte - Lim. Dptal. Chin.. 
* 20 - Tramo El Jicaro la mía
*****************************************************************************************************/
****************************************************
/*Paso 10: Bota a los controles que no son buenos matches **
****************************************************/
table matched_sample AED control_matched
drop if AED==0 & control_match!=1

* Vemos cuantas de las comunidades quedan en cada tramos para escoger los tramos
* Comparamos los tramos que salen como mejores controles respecto al analisis
* de pixeles, mantenemos aquellos que son comunes al primer analisis publicado en TDRs

*tab country_n if  matched_sample==1 & AED==0 & inlist(mc_orden_bd_multicriterio,149,46,42,138,20), m
tab country_n AED
tab country_n AED, m
tab country_n if  matched_sample==1 & AED==0, m
*tab ot_nombredeltramo if  matched_sample==1 & AED==0, m

* Podríamos priorizar a aquellos tramos que tienen más comunidades que son buenos controles (no es necesario)
bysort country_n: gen n_com = _N if matched_sample==1 & AED==0
tab n_com
*tab country_n if  matched_sample==1 & treated==0 & inlist(mc_orden_bd_multicriterio,149,46,42,138,20) & n_com>10, m
tab country_n if matched_sample==1 & AED==0 & n_com>10

*******************************************************************************
** Comando para después seleccionar a los tramos de control ya seleccionados **
*******************************************************************************
*global if_select "if (mc_orden_bd_multicriterio==149 | mc_orden_bd_multicriterio==20 | mc_orden_bd_multicriterio==42 | mc_orden_bd_multicriterio==138 | mc_orden_bd_multicriterio==10 | mc_orden_bd_multicriterio==46)"
*global if_select "if (matched_sample==1"
/* Contamos el número de viviendas en todos los tramos para ver si tendríamos suficiente muestra
quietly bysort treated: egen sumavivtramos1=total(inide_viv_ocup) $if_select
quietly sum sumavivtramos1 if treated==0
local treat0=`r(mean)'
quietly sum sumavivtramos1 if treated==1
local treat1=`r(mean)'
************************************************************************************
* Visualizamos en un mapa donde están ubicados los tramos de tratamiento y control *
************************************************************************************
*spmap treated $if_select  using "coord_inide_latlong.dta", ndocolor(white) id(id)  clm(unique) fcolor(BuRd)  ///
*line(data("coord_multicriterio_final_wf.dta") color(gs5) size(medium)) name(g1, replace)  legc ///
*title("Matching - Vecinos mas cercanos", size(*0.8)) note("Numero viviendas en 5 tramos control= `treat0'" "Numero viviendas en tratamiento=`treat1'") 
*graph save "map_nmatch1_$model", replace
*/

**************************************
*Test de diferencias de medias (after matching)
**************************************
estpost ttest $cv_m1, by(AED)
estout using nnmatch_m1after_d4_$model.out, cells("mu_2(fmt(3) label(Mean Treated)) mu_1(fmt(3) label(Mean Control)) b(fmt(3) label(Difference)star)") label replace 
tab country_n AED
save nmatch1_5.dta, replace 
/*********************************************************************************************
*Paso 11: Distintas opciones para seguir filtrando los controles si es necesario cortar su número **
*********************************************************************************************
* No fue necesario en nuestro caso *
** Seleccionando por el numero de veces que aparecen como control **
** Uno puede priorizar aquellos que aparecen más veces como buenos controles **
** Por ejemplo, por lo menos 3 veces **
egen suma_seleccion=rowtotal(veces_control*) if AED==0
*tab ot_nombredeltramo if matched_sample==1 & AED==0 & inlist(mc_orden_bd_multicriterio,149,46,42,138,20) & suma_seleccion>3, m
tab country_n if matched_sample==1 & AED==0 & suma_seleccion>3

** Por ejemplo, por lo menos 2 veces **
*tab country_n if matched_sample==1 & treated==0 & inlist(mc_orden_bd_multicriterio,149,46,42,138,20) & suma_seleccion>2, m
tab country_n if matched_sample==1 & AED==0 & suma_seleccion>2

** Seleccionando por la distancia en el matching **
** Por ejemplo, quitando arriba del percentil 75 de la distancia del primer match s
egen min_distancia_$model =rowmin(dist1 dist2 dist3 dist4 dist5)
egen mean_distancia_$model = rowmean(dist1 dist2 dist3 dist4 dist5)
_pctile min_distancia_$model if AED==0, p(75)
dis "p75____" `r(r1)'
gen recorte=(min_distancia_$model <=`r(r1)')
*table AED recorte $if_select
table AED recorte
*bys AED recorte: egen sumaviviendas=total(inide_viv_ocup)
tab AED recorte, sum(sumaviviendas) nost
bys treated recorte: egen sumavivtramos=total(inide_viv_ocup) $if_select
qui sum sumavivtramos if treated==0 & recorte==1
local treat0=`r(mean)'
qui sum sumavivtramos if treated==1 & recorte==1
local treat1=`r(mean)'
tab treated recorte, sum(sumavivtramos) nost
drop sumavivtramos*
*
*log close
*keep $if_select
gen match_$model =1
sort n_treated
save "match$model", replace
tab AED

preserve
keep if AED==1 | (AED==0 & match_5==1)
* Nos quedamos sólo con la muestra de interés */
*keep $if_select
*drop if treated==0 & urban==1 
*drop if treated==1 & urban==1

******************************************
/*COHORTE 1: Entre el percentil 10 y 90*/
******************************************
** Por ejemplo, quitando arriba del percentil 75 de la distancia del primer match s
use nmatch1_5.dta, clear
egen min_distancia_$model =rowmin(dist1 dist2 dist3 dist4)
egen mean_distancia_$model = rowmean(dist1 dist2 dist3 dist4)
_pctile min_distancia_$model if AED==0, p(10)
dis "p10____" `r(r1)'
_pctile min_distancia_$model if AED==0, p(90)
dis "p90____" `r(r1)'
gen recorte=(min_distancia_$model >=`r(r1)')
replace recorte=(min_distancia_$model <=`r(r1)')

*table AED recorte $if_select
table AED recorte
drop if recorte==0
** Pruebas de balance después del matching **
estpost ttest $cv_m1, by(AED)
estout using nnmatch_m1_c1-4_$model.out, cells("mu_2(fmt(3) label(Mean Treated)) mu_1(fmt(3) label(Mean Control)) b(fmt(3) label(Difference)star)") label replace 
*Cantidad de paises
*tab country_n AED

******************************************
/*COHORTE 2: Entre el percentil 5 y 95*/
******************************************
** Por ejemplo, quitando arriba del percentil 75 de la distancia del primer match s
use nmatch1_5.dta, clear
egen min_distancia_$model =rowmin(dist1 dist2 dist3 dist4)
egen mean_distancia_$model = rowmean(dist1 dist2 dist3 dist4)
_pctile min_distancia_$model if AED==0, p(5)
dis "p5____" `r(r1)'
_pctile min_distancia_$model if AED==0, p(95)
dis "p95____" `r(r1)'
gen recorte=(min_distancia_$model >=`r(r1)')
replace recorte=(min_distancia_$model <=`r(r1)')

*table AED recorte $if_select
table AED recorte
drop if recorte==0
** Pruebas de balance después del matching **
estpost ttest $cv_m1, by(AED)
estout using nnmatch_m1_c2-4_$model.out, cells("mu_2(fmt(3) label(Mean Treated)) mu_1(fmt(3) label(Mean Control)) b(fmt(3) label(Difference)star)") label replace 
*Cantidad de paises
*tab country_n AED




