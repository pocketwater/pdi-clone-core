USE [PDI_PricingLink];
GO

/*
  PDI_Sites_Clone

  Purpose : Local clone of PDI site (warehouse/branch) master records. Supports
            site key resolution across pricing and dispatch pipelines. Loaded via
            batch pattern (Clone_LoadDtmUtc column). No primary key constraint
            exists on the live table — Site_Key is the natural business key.
  Refresh : dbo.sp_PDI_AllClones_SYNC (registered clone)
*/

IF OBJECT_ID('dbo.PDI_Sites_Clone', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.PDI_Sites_Clone
    (
          Site_Key                                    decimal(15, 0)  NOT NULL
        , Site_ID                                     varchar(15)     NOT NULL
        , Site_Description                            varchar(35)     NOT NULL
        , Site_Address1                               varchar(40)     NULL
        , Site_Address2                               varchar(40)     NULL
        , Site_Address3                               varchar(40)     NULL
        , Site_City                                   varchar(60)     NULL
        , Site_State                                  decimal(15, 0)  NULL
        , Site_Zip                                    char(10)        NULL
        , Site_Phone                                  char(12)        NULL
        , Site_Alt_Phone                              char(12)        NULL
        , Site_Fax                                    char(12)        NULL
        , Site_Modem                                  char(12)        NULL
        , Site_Phone_Formatted                        varchar(20)     NULL
        , Site_Alt_Phone_Formatted                    varchar(20)     NULL
        , Site_Fax_Formatted                          varchar(20)     NULL
        , Site_Modem_Formatted                        varchar(20)     NULL
        , Site_Contact                                varchar(40)     NULL
        , Site_Email_Name                             varchar(40)     NULL
        , Site_Email_Address                          varchar(255)    NULL
        , Site_External_ID                            int             NULL
        , Site_Template                               smallint        NOT NULL
        , Site_Uses_InSite                            smallint        NOT NULL
        , Site_Uses_PD                                smallint        NOT NULL
        , Site_Uses_VU                                smallint        NOT NULL
        , Site_Receives_Downloads                     smallint        NOT NULL
        , Site_Org_Key                                decimal(15, 0)  NULL
        , Site_DelRte_Key                             decimal(15, 0)  NULL
        , Site_DelRte_Stop                            smallint        NULL
        , Site_SPLC_Code                              varchar(10)     NULL
        , Site_SIC_Code                               varchar(5)      NULL
        , Site_Fuel_COGS_Date                         smalldatetime   NOT NULL
        , Site_Used_For_Drop_Ships                    smallint        NOT NULL
        , Site_Deliv_Directions                       text            NULL
        , Site_Def_Fuel_Origin_By                     tinyint         NULL
        , Site_Fuel_Vend_Auths                        tinyint         NOT NULL
        , Site_TrmnlGrp_Key                           decimal(15, 0)  NULL
        , Site_DropShip_Site_Key                      decimal(15, 0)  NULL
        , Site_Pass_On_Min_Freight_Chgs               smallint        NOT NULL
        , Site_Override_Min_Load                      smallint        NOT NULL
        , Site_Override_Min_Load_Amt                  decimal(7, 2)   NULL
        , Site_DispArea_Key                           decimal(15, 0)  NULL
        , Site_Is_Terminal                            smallint        NOT NULL
        , Site_County                                 varchar(40)     NULL
        , Site_Tax_ID                                 varchar(30)     NULL
        , Site_Linked_RMS                             smallint        NOT NULL
        , Site_Exported_FocalPoint                    smallint        NOT NULL
        , Site_TaxSchedCat_Key                        decimal(15, 0)  NULL
        , Host_Key                                    decimal(15, 0)  NULL
        , Site_Invty_COGS_Date                        smalldatetime   NOT NULL
        , Site_Last_Stl_Date                          smalldatetime   NOT NULL
        , Site_Last_StlAccr_Date                      smalldatetime   NOT NULL
        , Site_Last_Comm_Date                         smalldatetime   NOT NULL
        , Site_Last_CommAccr_Date                     smalldatetime   NOT NULL
        , Site_FuelOrdRule_Key                        decimal(15, 0)  NULL
        , Site_Allow_Delivs_After_Hours               smallint        NOT NULL
        , Site_Is_MasterSite                          smallint        NOT NULL
        , Site_MasterSite_Key                         decimal(15, 0)  NULL
        , Site_FPZone_Key                             decimal(15, 0)  NULL
        , Site_TrmnlCtlNo_Key                         decimal(15, 0)  NULL
        , Site_Deliv_TankRd_Method                    tinyint         NOT NULL
        , Site_GPS_Longitude                          decimal(9, 6)   NULL
        , Site_GPS_Latitude                           decimal(9, 6)   NULL
        , Site_Competitor_Radius                      decimal(6, 2)   NULL
        , Site_Competitor_Fuel_Pricing_Alert_Trait_Key decimal(15, 0) NULL
        , Site_GL_Status                              tinyint         NOT NULL
        , Site_Def_Warehouse_Site_Key                 decimal(15, 0)  NULL
        , Site_Incl_In_WhPrcNtc                       smallint        NOT NULL
        , Site_Is_BOLSite                             smallint        NOT NULL
        , Site_Is_Trmnl_Key                           decimal(15, 0)  NULL
        , Site_Last_Royalty_Stl_Date                  smalldatetime   NOT NULL
        , Site_Last_Royalty_StlAccr_Date              smalldatetime   NOT NULL
        , Site_WI_Third_Party_Owned                   smallint        NOT NULL
        , Site_WI_Cust_Key                            decimal(15, 0)  NULL
        , Site_WI_Vend_Key                            decimal(15, 0)  NULL
        , Site_WI_CustLoc_Key                         decimal(15, 0)  NULL
        , Site_TimeZone_ID                            varchar(32)     NULL
        , Site_Allow_Neg_Bulk_Fuel_Invty              smallint        NOT NULL
        , Site_DEP_Dest_Code                          varchar(10)     NULL
        , Site_DestTaxType_TaxSchedCat_key            decimal(15, 0)  NULL
        , ts                                          rowversion      NULL
        , Site_Is_ExxonMobil_Distributor              bit             NOT NULL
        , Site_Distributor_ID                         varchar(30)     NULL
        , Site_Override_Transfer_Pricing              bit             NOT NULL
        , Site_Use_Xfer_Price_Rules_On_Site_Orders    bit             NOT NULL
        , Site_Unit_Basis_For_Site_Orders             tinyint         NOT NULL
        , Site_Transfer_Pricing_Date_Override         tinyint         NOT NULL
        , Site_Transfer_Pricing_Freight_Date_Override tinyint         NOT NULL
        , Site_Order_Notes                            varchar(255)    NULL
        , Site_Delivery_Notes                         varchar(255)    NULL
        , Site_WI_PO_Notes                            varchar(255)    NULL
        , Site_WI_Allow_Origin_For_Buyback_Orders     bit             NOT NULL
        , Site_WI_RequireOnHandInventory              bit             NOT NULL
        , Site_WI_RequireOnHandInventoryOrderStatus   tinyint         NOT NULL
        , Site_WI_ISOnHandInventoryOverride           bit             NOT NULL
        , Site_Enable_Bin_Inventory                   bit             NOT NULL
        , Clone_LoadDtmUtc                            datetime2(3)    NOT NULL
    );
END;
GO
