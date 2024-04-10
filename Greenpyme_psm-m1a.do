*************************************
*Propensity matching score
**************************************
use Data_out\Greenpyme_db_clean.dta, clear
**Definiendo las covariables
global cv_m1 sector_BID after_2013 age employees_n revenues_n high_gdp /*continuas*/
*********
*Modelo 1
*********
set scheme s1color
**************************************
*Test de diferencias de medias (before)
**************************************
estpost ttest $cv_m1, by(AED)
estout using Results\PSM_CommonSuport\m1_before.txt, cells("mu_2(fmt(3) label(Mean Treated)) mu_1(fmt(3) label(Mean Control)) b(fmt(3) label(Difference)star)") label replace 
**********************************
*Matching application
**********************************
pscore AED $cv_m1 if audit<4, pscore(aed) blockid(aedid) comsup level(0.001)
drop if audit>4
save Results\PSM_CommonSuport\Greenpyme_db_clean-m1.dta, replace
/*Las diferencias entre AED==1 y AED==0 no tienen que ser significativas porque 
estamos tratando de comparar entre individuos similares*/
**************************************
*Analizando common suport
**************************************
use Results\PSM_CommonSuport\Greenpyme_db_clean-m1.dta, clear
keep if comsup==1
*Graphs
kdensity aed if AED==1, addplot(kdensity aed if AED==0) scheme()
graph export Results\PSM_CommonSuport\m1_before.png, replace
*tables
global cv_m2 s_1 s_2 s_3 s_4 s_5 y_1 y_2 y_3 y_4 y_5 y_6 y_7 y_8 more_10 small revenues_low high_gdp andinos if audit<4 & informe_CII==1
estpost ttest $cv_m2, by(AED)
estout using Results\PSM_CommonSuport\m1_before.txt, cells("mu_2(fmt(3) label(Mean Treated)) mu_1(fmt(3) label(Mean Control)) b(fmt(3) label(Difference)star)") label replace 

**************************************
/*COHORTE 1: Entre el percentil 10 y 90*/
**************************************
use Results\PSM_CommonSuport\Greenpyme_db_clean-m1.dta, clear
sum aed if AED==1, d /*0.034-0.688*/
gen aed10=r(p10)
sum aed if AED==1, d
gen aed90=r(p90)
gen sample_overlap =1 if aed>aed10 & aed<aed90
keep if sample_overlap==1
*Kdensity
kdensity aed if AED==1, addplot(kdensity aed if AED==0)
graph export Results\PSM_CommonSuport\m1_after.png, replace
*Test de diferencias de medias (after cohorte)
global cv_m2 s_1 s_2 s_3 s_4 s_5 y_1 y_2 y_3 y_4 y_5 y_6 y_7 y_8 more_10 small revenues_low high_gdp andinos if audit<4 & informe_CII==1
estpost ttest $cv_m2, by(AED)
estout using Results\PSM_CommonSuport\m1_after.txt, cells("mu_2(fmt(3) label(Mean Treated)) mu_1(fmt(3) label(Mean Control)) b(fmt(3) label(Difference)star)") label replace 

