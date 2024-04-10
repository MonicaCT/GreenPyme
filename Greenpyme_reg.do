********************************************************************************
*** Este dofile crea las estimaciones de Greenpyme y descriptivas en         ***
*** el soporte comun                                                         ***
*** Autora: Maria Laura Lanzalot 											 ***
*** date: 06/14/2019  														 ***
********************************************************************************
clear all
set more off
*cd "C:\Users\MLANZALOT\Inter-American Development Bank Group\Yanez Pagans, Patricia - GreenPyme\GreenPyme\dofile"
cd "C:\Users\Asus\Documents\IDBinvest\GreenPymes\Dataset and do-files"
use data\Greenpyme_db_clean.dta, clear

/******************************************************************************/
/*  			Propensity score matching: Common Support                     */ 
/******************************************************************************/
/* Run Logit*/
logit AED i.sector_BID i.after_2013 i.age i.size i.revenues  i.high_gdp  

/* Predicted probability */
capture drop p
predict p if e(sample), pr

/* Define overlap using the max(min PS) and min(max PS) rule */
/*				
summ p if AED==0, d
local min0=r(min)
local max0=r(max)

summ p if AED==1, d
local min1=r(min)
local max1=r(max)
local min=max(`min0',`min1')
local max=min(`max0',`max1')

capture drop sample_overlap
gen sample_overlap=(p>=`min' & p<=`max')
noi tab sample_overlap AED, m
				
bihist p, by(AED)
gr export "..\graphs\common_support\PS_overlap_sample.png", replace
bihist p if sample_overlap ==1, by(AED)
gr export "..\graphs\common_support\PS_overlap_sample_2.png", replace

keep if sample_overlap ==1
*/
/* Define overlap: over ADE=1 p(10) and under ADE=1 p(90)  */

kdensity p if AED==1, addplot(kdensity p if AED==0)
sum p if AED==1, d
gen p10=r(p10)
sum p if AED==1, d
gen p90=r(p90)
gen sample_overlap =1 if p>p10 & p<p90

keep if sample_overlap==1
kdensity p if AED==1, addplot(kdensity p if AED==0)


/******************************************************************************/
/*  					Descriptivas diferencia de medias                    */ 
/******************************************************************************/

**Diferencuas entre rechazados y aceptados **
foreach var in s_1 s_2 s_3 s_4 s_5 y_1 y_2 y_3 y_4 y_5 y_6 y_7 y_8  more_10 small revenues_low high_gdp andinos {
replace `var'=`var'*100
}

** Diferencia sencilla y detallada **
estpost ttest s_1 s_2 s_3 s_4 s_5 y_1 y_2 y_3 y_4 y_5 y_6 y_7 y_8 more_10 small revenues_low high_gdp andinos if audit<4 & informe_CII==1, by(AED)
esttab using results\ttest_AED.rtf, noobs cells("mu_1(fmt(1)) mu_2(fmt(1))  b(star fmt(1))") star(* 0.1 ** .05 *** 0.01) ///
collabels("Sencilla" "Detallada" "Diferencia" ) width(0.8\hsize) replace 

foreach var in s_1 s_2 s_3 s_4 s_5 y_1 y_2 y_3 y_4 y_5 y_6 y_7 y_8  more_10 small revenues_low high_gdp andinos {
replace `var'=`var'/100
}


/******************************************************************************/
/*  						Regresiones adopción  			                  */ 
/******************************************************************************/
Greenpyme_db_clean-m1
probit adopcion AED i.sector_BID i.after_2013 i.more_10 i.small i.revenues_low i.high_gdp if audit<4 & informe_CII==1
margins, dydx(*) post
outreg2 using results\Probit_Adopt.xls,  label replace ctitle(Marginal effects) 

/******************************************************************************/
/*  						Regresiones efectos  			                  */ 
/******************************************************************************/


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


