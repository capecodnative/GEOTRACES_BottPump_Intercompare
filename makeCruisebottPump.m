tcGP16=IDP.Cruise=="GP16" & (~isnan(IDP.Al_TP_CONC_BOTTLE_nmol_kg_) | ~isnan(IDP.Al_SPT_CONC_PUMP_nmol_kg_));
GP16bottpump=IDP(tcGP16,:);

tcGA01=IDP.Cruise=="GA01" & (~isnan(IDP.Al_TP_CONC_BOTTLE_nmol_kg_) | ~isnan(IDP.Al_SPT_CONC_PUMP_nmol_kg_));
GA01bottpump=IDP(tcGA01,:);

tcGA03=IDP.Cruise=="GA03" & (~isnan(IDP.Al_TP_CONC_BOTTLE_nmol_kg_) | ~isnan(IDP.Al_SPT_CONC_PUMP_nmol_kg_));
GA03bottpump=IDP(tcGA03,:);

tcGN01=IDP.Cruise=="GN01" & (~isnan(IDP.Al_TP_CONC_BOTTLE_nmol_kg_) | ~isnan(IDP.Al_SPT_CONC_PUMP_nmol_kg_));
GN01bottpump=IDP(tcGN01,:);

clear tcGP16 tcGA03 tcGN01 tcGA01