tcGP16=IDP.Cruise=="GP16" & (~isnan(IDP.Al_TP_CONC_BOTTLE_nmol_kg_) | ~isnan(IDP.Al_SPT_CONC_PUMP_nmol_kg_));
GP16bottpump=IDP(tcGP16,:);

tcGA01=IDP.Cruise=="GA01" & (~isnan(IDP.Al_TP_CONC_BOTTLE_nmol_kg_) | ~isnan(IDP.Al_SPT_CONC_PUMP_nmol_kg_));
GA01bottpump=IDP(tcGA01,:);

tcGA03e=IDP.Operator_sCruiseName_METAVAR_INDEXED_TEXT=="KN199" & (~isnan(IDP.Al_TP_CONC_BOTTLE_nmol_kg_) | ~isnan(IDP.Al_SPT_CONC_PUMP_nmol_kg_));
GA03ebottpump=IDP(tcGA03e,:);

tcGA03w=IDP.Operator_sCruiseName_METAVAR_INDEXED_TEXT=="KN204" & (~isnan(IDP.Al_TP_CONC_BOTTLE_nmol_kg_) | ~isnan(IDP.Al_SPT_CONC_PUMP_nmol_kg_));
GA03wbottpump=IDP(tcGA03w,:);

tcGN01=IDP.Cruise=="GN01" & (~isnan(IDP.Al_TP_CONC_BOTTLE_nmol_kg_) | ~isnan(IDP.Al_SPT_CONC_PUMP_nmol_kg_));
GN01bottpump=IDP(tcGN01,:);

clear tcGP16 tcGA03 tcGN01 tcGA01