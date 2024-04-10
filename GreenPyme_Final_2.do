

*Cambiar el Directorio
cd "D:\GreenPyme_Final\Stata"
set scheme s1color
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
do Do\Greenpyme_psm-m1a
do Do\Greenpyme_psm-m3a

*+++++++NNMATCH+++++
*Modelos
do Do\Greenpyme_nnmatch-m1-d4
do Do\Greenpyme_nnmatch-m2-d4

************************************************************************
******************************FORMATO PANEL*****************************
************************************************************************
use Results\PSM_CommonSuport\Greenpyme_db_clean-m1,clear

*Cambios en los totales
**************
*Electricidad
**************
gen M_elec_usd_ahorrop=M1_electric_usd_ahorro 
replace M_elec_usd_ahorrop=M_elec_usd_ahorro/2 if (M1_electric_usd_ahorro==0 | M2_electric_usd_ahorro==0)
replace M_elec_usd_ahorrop=M_elec_usd_ahorro/2 if M2_electric_usd_ahorro==0
*
gen M_elec_kwh_ahorrop=M1_electric_kwh_ahorro
replace M_elec_kwh_ahorrop=M2_electric_kwh_ahorro if M1_electric_kwh_ahorro==0
replace M_elec_kwh_ahorrop=M_elec_kwh_ahorro/2 if M1_electric_kwh_ahorro!=0 & M2_electric_kwh_ahorro!=0 
*
gen M_elec_GEIp=M1_electric_GEI
replace M_elec_GEIp=M2_electric_GEI if M1_electric_GEI==0
replace M_elec_GEIp=M_GEI/2 if M1_electric_GEI!=0 & M2_electric_GEI!=0 
*
gen M_elec_costop=M1_electric_costo
replace M_elec_costop=M2_electric_costo if M1_electric_costo==0
replace M_elec_costop=M_elec_costo/2 if M1_electric_costo!=0 & M2_electric_costo!=0 

***************
*Hidrocarburos
***************
gen M_hidro_usd_ahorrop=M1_hidroc_ahorro_costo
replace M_hidro_usd_ahorrop=M_hidro_usd_ahorro/2 if (M1_hidroc_ahorro_costo==0 | M2_hidroc_ahorro_costo==0)
replace M_hidro_usd_ahorrop=M_hidro_usd_ahorro/2 if M2_hidroc_ahorro_costo==0
*
gen M_hidro_kwh_ahorrop=M1_hidroc_kwh
replace M_hidro_kwh_ahorrop=M2_hidroc_kwh if M1_hidroc_kwh==0
replace M_hidro_kwh_ahorrop=M_hidro_kwh_ahorro/2 if M1_hidroc_kwh!=0 & M2_hidroc_kwh!=0 
*
gen M_hidro_GEIp=M1_hidro_GEI
replace M_hidro_GEIp=M2_hidro_GEI if M1_hidro_GEI==0
replace M_hidro_GEIp=M_GEI/2 if M1_hidro_GEI!=0 & M2_hidro_GEI!=0 
*
gen M_hidro_costop=M1_hidroc_costo
replace M_hidro_costop=M2_hidroc_costo if M1_hidroc_costo==0
replace M_hidro_costop=M_hidro_costo/2 if M1_hidroc_costo!=0 & M2_hidroc_costo!=0 

***************
*Totales
***************
egen M_usd_ahorrop=rowtotal(M_hidro_usd_ahorrop M_elec_usd_ahorrop)
egen M_kwh_ahorrop=rowtotal(M_hidro_kwh_ahorrop M_elec_kwh_ahorrop)
egen M_GEIp=rowtotal(M_hidro_GEIp M_elec_GEIp)
egen M_costop=rowtotal(M_hidro_costop M_elec_costop)

*Formato PANEL
gen electric_usd_ahorroM1=M1_electric_usd_ahorro
gen electric_usd_ahorroM2=M2_electric_usd_ahorro
gen electric_kwh_ahorroM1=M1_electric_kwh_ahorro
gen electric_kwh_ahorroM2=M2_electric_kwh_ahorro
gen electric_GEIM1=M1_electric_GEI
gen electric_GEIM2=M2_electric_GEI
gen electric_costoM1=M1_electric_costo
gen electric_costoM2=M2_electric_costo

gen hidroc_ahorro_costoM1=M1_hidroc_ahorro_costo
gen hidroc_ahorro_costoM2=M2_hidroc_ahorro_costo
gen hidroc_kwhM1=M1_hidroc_kwh
gen hidroc_kwhM2=M2_hidroc_kwh
gen hidro_GEIM1=M1_hidro_GEI
gen hidro_GEIM2=M2_hidro_GEI
gen hidroc_costoM1=M1_hidroc_costo
gen hidroc_costoM2=M2_hidroc_costo

egen total_usd_ahorroM1=rowtotal(M1_electric_usd_ahorro M1_hidroc_ahorro_costo)
egen total_usd_ahorroM2=rowtotal(M2_electric_usd_ahorro M2_hidroc_ahorro_costo)
egen total_kwh_ahorroM1=rowtotal(M1_electric_kwh_ahorro M1_hidroc_kwh)
egen total_kwh_ahorroM2=rowtotal(M2_electric_kwh_ahorro M2_hidroc_kwh)
egen total_GEIM1=rowtotal(M1_electric_GEI M1_hidro_GEI)
egen total_GEIM2=rowtotal(M2_electric_GEI M2_hidro_GEI)
egen total_costoM1=rowtotal(M1_electric_costo M1_hidroc_costo)
egen total_costoM2=rowtotal(M2_electric_costo M2_hidroc_costo)

*Reshape los datos
gen idempresa=_n
reshape long electric_usd_ahorro  electric_kwh_ahorro  electric_GEI ///
electric_costo hidroc_ahorro_costo hidroc_kwh hidro_GEI  hidroc_costo ///
total_usd_ahorro total_kwh_ahorro total_GEI total_costo ///
, i(idempresa) j(j) string

*Datos de panel
destring j, replace
encode j, gen(yearmonitereo)
*Definiendo datos de panel
xtset yearmonitereo idempresa

save Results\PSM_CommonSuport\Greenpyme_db_clean-m1_panel.dta, replace

************************************************************************
*****************************MODELOS DE ADOPCIÓN************************
************************************************************************
*+++++++++Probabilidad de adopción+++++++++++
/*Se estima la probabilidad de adopción de acuerdo a las características de la
empresa y según el tipo de auditoria que tuvo*/
use Results\PSM_CommonSuport\Greenpyme_db_clean-m1_panel,clear
probit adopcion i.AED i.age s_1 s_2 s_3 s_4 s_5 small revenues_n employees_n ///
if yearmonitereo==1 & comsup==1 & audit<4 & informe_CII==1
margins , dydx(AED age s_1 s_2 s_3 s_4 s_5 small revenues_n employees_n) atmeans
outreg2 using Results\Probit_Adopt.xls,  label replace ctitle(Marginal effects) 

************************************************************************
***********************************IMPACTOS*****************************
************************************************************************
*+++++++++Impactos en las variables de interés+++++++++++
*COVARIATES
global covariates i.AED i.age s_1 s_2 s_3 s_4 s_5 small i.high_gdp revenues_n employees_n
*******************************************
*+++++++++++++MINIMOS CUADRADOS ORDINARIOS
*Definiendo el global para los modelos
global glopaelec electric_usd_ahorro electric_kwh_ahorro electric_GEI
global glopahidro hidroc_ahorro_costo hidroc_kwh hidro_GEI
global glopatotal total_usd_ahorro total_kwh_ahorro total_GEI 
*Logaritmos de los costos de inversion
gen log_electric_costo=log(electric_costo+((electric_costo^2)+1)^(1/2))
gen log_hidroc_costo=log(hidroc_costo+((hidroc_costo^2)+1)^(1/2))
gen log_total_costo=log(total_costo +((total_costo^2)+1)^(1/2))

foreach var in $glopaelec {
*capture gen log_`var'=log(`var'+((`var'^2)+1)^(1/2))
gen log_`var'=log(`var'+((`var'^2)+1)^(1/2))
xi: reg log_`var' log_electric_costo $covariates  
outreg2 using Results\elec_ols.xls,  label append ctitle(`var') 
}
foreach var in $glopahidro {
*capture gen log_`var'=log(`var'+((`var'^2)+1)^(1/2))
gen log_`var'=log(`var'+((`var'^2)+1)^(1/2))
xi: reg log_`var' log_hidroc_costo $covariates  
outreg2 using Results\hidro_ols.xls,  label append ctitle(`var') 
}
foreach var in $glopatotal {
*capture gen log_`var'=log(`var'+((`var'^2)+1)^(1/2))
gen log_`var'=log(`var'+((`var'^2)+1)^(1/2))
xi: reg log_`var' log_total_costo $covariates  
outreg2 using Results\both_ols.xls,  label append ctitle(`var') 
}

*+++++++++++++++++++++EFECTOS FIJOS
*COVARIATES
*global covariates i.AED age s_1 s_2 s_3 s_4 s_5 i.small##AED i.high_gdp
global covariates i.AED i.age s_1 s_2 s_3 s_4 s_5 small i.high_gdp revenues_n employees_n

foreach var in $glopaelec {
*gen log_`var'=log(`var'+((`var'^2)+1)^(1/2))
xtreg log_`var' log_electric_costo $covariates if comsup==1 & audit<4 & informe_CII==1, fe 
outreg2 using Results\elec_fe.xls,  label append ctitle(`var') 
}
foreach var in $glopahidro {
*gen log_`var'=log(`var'+((`var'^2)+1)^(1/2))
xtreg  log_`var' log_hidroc_costo $covariates if comsup==1 & audit<4 & informe_CII==1, fe  
outreg2 using Results\hidro_fe.xls,  label append ctitle(`var') 
}
foreach var in $glopatotal {
*gen log_`var'=log(`var'+((`var'^2)+1)^(1/2))
xtreg  log_`var' log_total_costo $covariates if comsup==1 & audit<4 & informe_CII==1, fe  
outreg2 using Results\both_fe.xls,  label append ctitle(`var') 
}

*+++++++++++++++++++++DIFERENCIAS EN DIFERENCIAS
gen time =  yearmonitereo==1
*Interaccion variable
gen did=time*AED

foreach var in $glopaelec {
*gen log_`var'=log(`var'+((`var'^2)+1)^(1/2))
xtreg  log_`var' time##AED log_electric_costo $covariates if comsup==1 & audit<4 & informe_CII==1 ,fe
outreg2 using Results\elec_dd.xls,  label append ctitle(`var') 
}
foreach var in $glopahidro {
*gen log_`var'=log(`var'+((`var'^2)+1)^(1/2))
xtreg  log_`var' time##AED log_hidroc_costo $covariates if comsup==1 & audit<4 & informe_CII==1 , fe
outreg2 using Results\hidro_dd.xls,  label append ctitle(`var') 
}
foreach var in $glopatotal {
*gen log_`var'=log(`var'+((`var'^2)+1)^(1/2))
xtreg  log_`var' time##AED log_total_costo $covariates if comsup==1 & audit<4 & informe_CII==1 ,fe
outreg2 using Results\both_dd.xls,  label append ctitle(`var') 
}


save Results\PSM_CommonSuport\Greenpyme_db_clean-m1_final,replace













