*+++++++++++++++++++++EFECTOS FIJOS
gen AESD_year=AED_year
replace AESD_year=AES_year if AED_year==.
replace AESD_year=2014 if AESD_year==1900
replace AESD_year=2014 if AESD_year==214
gen id=_n
xtset AESD_year id

foreach var in $gloelec {
xtreg log_`var' log_M_elec_costop $covariates  ,fe
outreg2 using Results\elec.xls,  label append ctitle(`var') 
}
foreach var in $glohidro {
xtreg log_`var' log_M_hidro_costop $covariates  ,fe
outreg2 using Results\hidro.xls,  label append ctitle(`var') 
}
foreach var in $globoth {
xtreg log_`var' log_M_costop $covariates  ,fe
outreg2 using Results\both.xls,  label append ctitle(`var') 
}


*++++++++++++++++++++DIFERENCIAS EN DIFERENCIAS
*Diferencia entre monitoreo 1 y monitoreo 2
*br registration_~r registration_~2 AES_year AED_year AESD_year M_*
drop time
gen time =  (AESD_year>2013) & !missing(AESD_year)
*Interaccion variable
gen did=time*AED
reg log_M_elec_usd_ahorrop time AED did $covariates, r
reg log_M_elec_usd_ahorrop time##AED, r
*ssc install diff
diff log_M_elec_usd_ahorrop log_M_elec_kwh_ahorrop if comsup==1, t(AED) p(time)

