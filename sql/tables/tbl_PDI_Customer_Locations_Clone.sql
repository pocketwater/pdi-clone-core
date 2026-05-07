USE [PDI_PricingLink];
GO

/*
  PDI_Customer_Locations_Clone

  Purpose : Local clone of PDI customer delivery locations. All columns stored
            as varchar(100) to preserve raw PDI values without type coercion.
  Refresh : dbo.sp_PDI_AllClones_SYNC (registered clone)
*/

IF OBJECT_ID('dbo.PDI_Customer_Locations_Clone', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.PDI_Customer_Locations_Clone
    (
          CustLoc_Key                              varchar(100)  NOT NULL
        , Cust_ID                                  varchar(100)  NULL
        , Cust_Description                         varchar(100)  NULL
        , CustLoc_Type                             varchar(100)  NULL
        , CustLoc_Cust_Key                         varchar(100)  NULL
        , CustLoc_ID                               varchar(100)  NULL
        , CustLoc_Description                      varchar(100)  NULL
        , CustLoc_Address_1                        varchar(100)  NULL
        , CustLoc_Address_2                        varchar(100)  NULL
        , CustLoc_Address_3                        varchar(100)  NULL
        , CustLoc_City                             varchar(100)  NULL
        , CustLoc_State_Key                        varchar(100)  NULL
        , CustLoc_Postal_Code                      varchar(100)  NULL
        , CustLoc_Phone                            varchar(100)  NULL
        , CustLoc_FAX                              varchar(100)  NULL
        , CustLoc_Modem                            varchar(100)  NULL
        , CustLoc_Speed_Dial                       varchar(100)  NULL
        , CustLoc_Phone_Formatted                  varchar(100)  NULL
        , CustLoc_Fax_Formatted                    varchar(100)  NULL
        , CustLoc_Modem_Formatted                  varchar(100)  NULL
        , CustLoc_Tax_ID                           varchar(100)  NULL
        , CustLoc_Contact                          varchar(100)  NULL
        , CustLoc_Active                           varchar(100)  NULL
        , CustLoc_DelRte_Key                       varchar(100)  NULL
        , CustLoc_DelRte_Stop                      varchar(100)  NULL
        , CustLoc_SPLC_Code                        varchar(100)  NULL
        , CustLoc_FI_Invc_Deliv_Method             varchar(100)  NULL
        , CustLoc_WI_Invc_Deliv_Method             varchar(100)  NULL
        , CustLoc_NI_Invc_Deliv_Method             varchar(100)  NULL
        , CustLoc_EMail                            varchar(100)  NULL
        , CustLoc_Deliv_Directions                 varchar(100)  NULL
        , CustLoc_Def_Fuel_Orig_By                 varchar(100)  NULL
        , CustLoc_Define_Fuel_Tanks                varchar(100)  NULL
        , CustLoc_Fuel_Vend_Auths                  varchar(100)  NULL
        , CustLoc_DropShip_Site_Key                varchar(100)  NULL
        , CustLoc_DispArea_Key                     varchar(100)  NULL
        , CustLoc_County                           varchar(100)  NULL
        , CustLoc_FaxPrefix                        varchar(100)  NULL
        , CustLoc_TaxSchedCat_Key                  varchar(100)  NULL
        , CustLoc_Pass_On_Min_Frt_Chgs             varchar(100)  NULL
        , CustLoc_Override_Min_Load                varchar(100)  NULL
        , CustLoc_Override_Min_Load_Amt            varchar(100)  NULL
        , CustLoc_PrcNtcRule_Key                   varchar(100)  NULL
        , CustLoc_PrcNtc_Deliv_Method              varchar(100)  NULL
        , CustLoc_PrcNtc_MsgGrp_Key                varchar(100)  NULL
        , CustLoc_FPZone_Key                       varchar(100)  NULL
        , CustLoc_Use_PrcNtc_Price                 varchar(100)  NULL
        , CustLoc_Latitude                         varchar(100)  NULL
        , CustLoc_Longitude                        varchar(100)  NULL
        , CustLoc_WhPrcNtc_Incl_Loc                varchar(100)  NULL
        , CustLoc_WhPrcNtc_Deliv_Method            varchar(100)  NULL
        , CustLoc_NatlAcct_ID                      varchar(100)  NULL
        , CustLoc_NatlAcct_Location_ID             varchar(100)  NULL
        , CustLoc_DEP_Dest_Code                    varchar(100)  NULL
        , CustLoc_DestTaxType_TaxSchedCat_Key      varchar(100)  NULL
        , CustLoc_BF_BillGrp_Key                   varchar(100)  NULL
        , CustLoc_Wh_BillGrp_Key                   varchar(100)  NULL
        , CustLoc_NI_BillGrp_Key                   varchar(100)  NULL
        , CustLoc_PrefWH_Site_Key                  varchar(100)  NULL
        , CustLoc_Auth_All_Warehouses              varchar(100)  NULL
        , CustLoc_Override_WhAuth                  varchar(100)  NULL
        , CustLoc_Ownership_TransferAt_WH_Orders   varchar(100)  NULL
        , CustLoc_Ownership_TransferAt_BF_Orders   varchar(100)  NULL
        , CustLoc_PriceDate_Basis_Override         varchar(100)  NULL
        , CustLoc_FreightDate_Basis_Override       varchar(100)  NULL
        , CustLoc_Use_PriceDate_Override           varchar(100)  NULL
        , CustLoc_Use_FreightDate_Override         varchar(100)  NULL
        , CustLoc_DDRegion_Key                     varchar(100)  NULL
        , CustLoc_Fuel_DelRte_Key                  varchar(100)  NULL
        , CustLoc_TrmnlCtlNo_Key                   varchar(100)  NULL
        , CustLoc_Order_Notes                      varchar(100)  NULL
        , CustLoc_Delivery_Notes                   varchar(100)  NULL
        , Sync_Dtm                                 datetime2(3)  NOT NULL
        , CONSTRAINT PK_PDI_Customer_Locations_Clone
            PRIMARY KEY CLUSTERED (CustLoc_Key)
    );
END;
GO
