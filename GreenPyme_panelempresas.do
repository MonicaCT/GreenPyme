
use Results\PSM_CommonSuport\Greenpyme_db_clean-m1,clear
*+++++++++++++++++++++EFECTOS FIJOS
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

*Definiendo el global para los modelos
global glopaelec electric_usd_ahorro electric_kwh_ahorro electric_GEI
global glopahidro hidroc_ahorro_costo hidroc_kwh hidro_GEI
global glopatotal total_usd_ahorro total_kwh_ahorro total_GEI 
*Logaritmos de los costos de inversion
gen log_electric_costo=log(electric_costo+((electric_costo^2)+1)^(1/2))
gen log_hidroc_costo=log(hidroc_costo+((hidroc_costo^2)+1)^(1/2))
gen log_total_costo=log(total_costo +((total_costo^2)+1)^(1/2))

global covariates i.AED age s_1 s_2 s_3 s_4 s_5 small##sector_BID i.high_gdp

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
gen log_`var'=log(`var'+((`var'^2)+1)^(1/2))
xtreg  log_`var' log_total_costo $covariates if comsup==1 & audit<4 & informe_CII==1, fe  
outreg2 using Results\both_fe.xls,  label append ctitle(`var') 
}

*+++++++++++++++++++++DIFERENCIAS EN DIFERENCIAS
gen time =  yearmonitereo==1
*Interaccion variable
gen did=time*AED
reg log_electric_usd_ahorro time##AED log_electric_costo $covariates if comsup==1 & audit<4 & informe_CII==1, r
reg log_electric_kwh_ahorro time##AED log_electric_costo $covariates if comsup==1 & audit<4 & informe_CII==1, r
reg log_electric_GEI time##AED log_electric_costo $covariates if comsup==1 & audit<4 & informe_CII==1, r
*
reg log_hidroc_ahorro_costo time##AED log_hidroc_costo $covariates if comsup==1 & audit<4 & informe_CII==1, r
reg log_hidroc_kwh time##AED log_hidroc_costo $covariates if comsup==1 & audit<4 & informe_CII==1, r
reg log_hidro_GEI time##AED log_hidroc_costo $covariates if comsup==1 & audit<4 & informe_CII==1, r
*
reg log_total_usd_ahorro time##AED log_total_costo $covariates if comsup==1 & audit<4 & informe_CII==1, r
reg log_total_kwh_ahorro time##AED log_total_costo $covariates if comsup==1 & audit<4 & informe_CII==1, r
reg log_total_GEI time##AED log_total_costo $covariates if comsup==1 & audit<4 & informe_CII==1, r

*ssc install diff
diff log_electric_usd_ahorro if comsup==1 & audit<4 & informe_CII==1, t(AED) p(time)
diff log_electric_kwh_ahorro if comsup==1 & audit<4 & informe_CII==1, t(AED) p(time)
diff log_electric_GEI if comsup==1 & audit<4 & informe_CII==1, t(AED) p(time)

diff log_hidroc_ahorro_costo if comsup==1 & audit<4 & informe_CII==1, t(AED) p(time)
diff log_hidroc_kwh if comsup==1 & audit<4 & informe_CII==1, t(AED) p(time)
diff log_hidro_GEI if comsup==1 & audit<4 & informe_CII==1, t(AED) p(time)

diff log_total_usd_ahorro if comsup==1 & audit<4 & informe_CII==1, t(AED) p(time)
diff log_total_kwh_ahorro if comsup==1 & audit<4 & informe_CII==1, t(AED) p(time)
diff log_total_GEI if comsup==1 & audit<4 & informe_CII==1, t(AED) p(time)









