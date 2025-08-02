

tcEPZT=IDP.Cruise=="GP16" & (~isnan(IDP.Al_TP_CONC_BOTTLE_nmol_kg_) | ~isnan(IDP.Al_SPT_CONC_PUMP_nmol_kg_));
EPZTbottpump=IDP(tcEPZT,:);

tcNAZT=IDP.Cruise=="GA03" & (~isnan(IDP.Al_TP_CONC_BOTTLE_nmol_kg_) | ~isnan(IDP.Al_SPT_CONC_PUMP_nmol_kg_));
NAZTbottpump=IDP(tcNAZT,:);

tcGN01=IDP.Cruise=="GN01" & (~isnan(IDP.Al_TP_CONC_BOTTLE_nmol_kg_) | ~isnan(IDP.Al_SPT_CONC_PUMP_nmol_kg_));
GN01bottpump=IDP(tcGN01,:);