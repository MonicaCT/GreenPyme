
*******************************************
*************Gráficos adicionales***********
********************************************
*Boxplot de las variables de interes por tipo de adopción
**************
use Results\PSM_CommonSuport\Greenpyme_db_clean-m1,clear
set scheme s1color
*Label variables
label variable log_M_elec_usd_ahorrop "Ahorro electricidad USD"
label variable log_M_elec_kwh_ahorrop "Ahorro electricidad kwh"
label variable log_M_elec_GEIp "Reducción GEI, electricidad"
label variable log_M_elec_costop "Costo inversión electricidad"
label variable log_M_hidro_usd_ahorrop "Ahorro electricidad USD"
label variable log_M_hidro_kwh_ahorrop "Ahorro electricidad kwh"
label variable log_M_hidro_GEIp "Reducción GEI, electricidad"
label variable log_M_hidro_costop "Costo inversión electricidad"
label variable log_M_usd_ahorrop "Ahorro electricidad total, USD"
label variable log_M_kwh_ahorrop "Ahorro electricidad total, kwh"
label variable log_M_GEIp "Reducción GEI total"
label variable log_M_costop "Costo de inversión total"
label define aed 1 "Detallada" 0 "Sencilla"
label values AED aed
*Box plot electricidad total (ambos monitoreo)
graph box log_M_elec_usd_ahorrop, over(adop_type) by(AED) horizontal
graph box log_M_elec_kwh_ahorrop, over(adop_type) by(AED) horizontal
graph box log_M_elec_GEIp, over(adop_type) by(AED) horizontal
graph box log_M_elec_costop, over(adop_type) by(AED) horizontal
*Box plot hidrocarburos total (ambos monitoreo)
graph box log_M_hidro_usd_ahorrop, over(adop_type) by(AED) horizontal
graph box log_M_hidro_kwh_ahorrop, over(adop_type) by(AED) horizontal
graph box log_M_hidro_GEIp if log_M_hidro_GEIp>0, over(adop_type) by(AED) horizontal
graph box log_M_hidro_costop, over(adop_type) by(AED) horizontal
*Box plot total (ambos monitoreo)
graph box log_M_usd_ahorrop, over(adop_type) by(AED) horizontal
graph box log_M_kwh_ahorrop if log_M_kwh_ahorrop>0, over(adop_type) by(AED) horizontal
graph box log_M_GEIp, over(adop_type) by(AED) horizontal
graph box log_M_costop, over(adop_type) by(AED) horizontal


*Gráficos de dispersion para segunda pregunta
**************
aaplot log_M_elec_usd_ahorrop log_M_elec_GEIp  
aaplot log_M_elec_costop log_M_elec_GEIp  
*
aaplot log_M_hidro_usd_ahorrop log_M_hidro_GEIp  
aaplot log_M_hidro_costop log_M_hidro_GEIp  
*Detallada-total
aaplot log_M_usd_ahorrop log_M_GEIp if AED==1
aaplot log_M_costop log_M_GEIp   if AED==1
*Sencilla-total
aaplot log_M_usd_ahorrop log_M_GEIp   if AED==0
aaplot log_M_costop log_M_GEIp   if AED==0
*Ambas-total
aaplot log_M_usd_ahorrop log_M_GEIp
aaplot log_M_costop log_M_GEIp
*Ambas-total (AED)
aaplot log_M_usd_ahorrop log_M_GEIp if AED==1
aaplot log_M_costop log_M_GEIp





*++++Ratios respecto a la linea base en USD
*Electricidad
gen M1Ratio_ahorro_elec_usd=(M1_electric_costo/LBM_elect_costo)*100 if LBM_elect_costo!=0 & LBM_elect_costo!=.
label var M1Ratio_ahorro_elec_usd "M1 Ahorro/Uso electricidad (USD)"
gen M2Ratio_ahorro_elec_usd=(M2_electric_costo/LBM_elect_costo)*100 if LBM_elect_costo!=0 & LBM_elect_costo!=.
label var M2Ratio_ahorro_elec_usd "M2 Ahorro/Uso electricidad (USD)"
*Hidrocarburos
gen M1Ratio_ahorro_hidro_usd=(M1_hidroc_ahorro_costo/LBM_thidro_costo)*100 if LBM_thidro_costo!=0 & LBM_thidro_costo!=.
label var Ratio_ahorro_hidro_usd "M1 Ahorro/Uso hidrocarburos (USD)"
gen M2Ratio_ahorro_hidro_usd=(M2_hidroc_ahorro_costo/LBM_thidro_costo)*100 if LBM_thidro_costo!=0 & LBM_thidro_costo!=.
label var Ratio_ahorro_hidro_usd "M2 Ahorro/Uso hidrocarburos (USD)"
*Totales
gen M1Ratio_ahorro_usd=M1_usd_ahorro/LBM_costo if LBM_costo!=0 & LBM_costo!=.
label var Ratio_ahorro_usd "M1 Ahorro/Uso energia (USD)"
gen M2Ratio_ahorro_usd=M2_usd_ahorro/LBM_costo if LBM_costo!=0 & LBM_costo!=.
label var Ratio_ahorro_usd "M2 Ahorro/Uso energia (USD)"


*Relacion iempo de recuperacion de la inversion y el ahorro en electricidad
LBM_Anios_rec~P LB_Anios_recu~P LBD_Anios_rec~P M_recupera

aaplot LB_Anios_recupera_P log_M_elec_costo if log_M_elec_costo!=0 & LB_Anios_recupera_P!=0 & AED==0
aaplot LBD_Anios_recupera_P log_M_elec_costo if log_M_elec_costo!=0 & LBD_Anios_recupera_P!=0 & AED==1








