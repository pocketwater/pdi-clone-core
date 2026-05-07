USE [PDI_PricingLink];
GO

/*
  PDI_Order_Details_Fuel_Clone

  Purpose : Local windowed clone of PDI fuel delivery line items.
            Enables pipeline matching (advisory view, handoff match) to resolve
            product and quantity without linked-server reads at query time.

            Window: Order_Details_Fuel rows where OrdFuel_Ord_Key maps to an
            order with Ord_Act_Deliv_DateTime within the last 90 days
            (controlled by sp_PDI_Order_Details_Fuel_Clone_SYNC).

  Source  : [PDI-SQL-01].PDICompany_2386_01.dbo.Order_Details_Fuel
  Refresh : dbo.sp_PDI_Order_Details_Fuel_Clone_SYNC (called by sp_PDI_AllClones_SYNC)

  Key join paths:
    OrdFuel_Ord_Key      -> dbo.PDI_Orders_Clone.Ord_Key       (order header)
    OrdFuel_Ord_Prod_Key -> dbo.PDI_Products_Clone.Prod_Key    (product master)

  Note: ts (rowversion) column is excluded — internal to source, no meaning in clone.
*/

IF OBJECT_ID('dbo.PDI_Order_Details_Fuel_Clone', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.PDI_Order_Details_Fuel_Clone
    (
          OrdFuel_Key                              decimal(15, 0)   NOT NULL
        , OrdFuel_Ord_Key                          decimal(15, 0)   NOT NULL
        , OrdFuel_Site_Key                         decimal(15, 0)   NULL
        , OrdFuel_Ord_Prod_Key                     decimal(15, 0)   NOT NULL
        , OrdFuel_Prch_Prod_Key                    decimal(15, 0)   NULL
        , OrdFuel_ProdBlnd_Key                     decimal(15, 0)   NULL
        , OrdFuel_Order_Qty                        decimal(12, 2)   NOT NULL
        , OrdFuel_Deliv_Gross_Qty                  decimal(12, 2)   NOT NULL
        , OrdFuel_Deliv_Net_Qty                    decimal(12, 2)   NOT NULL
        , OrdFuel_Invoice_Qty                      decimal(12, 2)   NOT NULL
        , OrdFuel_Def_Origin_Type                  tinyint          NOT NULL
        , OrdFuel_Def_Vend_Key                     decimal(15, 0)   NULL
        , OrdFuel_Def_Trmnl_Key                    decimal(15, 0)   NULL
        , OrdFuel_Def_Site_Key                     decimal(15, 0)   NULL
        , OrdFuel_Def_Tank_No                      smallint         NULL
        , OrdFuel_Dest_Tank_No                     smallint         NULL
        , OrdFuel_Based_On_Units                   tinyint          NOT NULL
        , OrdFuel_Frt_Based_On_Units               tinyint          NOT NULL
        , OrdFuel_Unit_Cost                        decimal(15, 7)   NOT NULL
        , OrdFuel_Unit_Cost_AfterRecon             decimal(15, 7)   NOT NULL
        , OrdFuel_Unit_Price                       decimal(15, 7)   NOT NULL
        , OrdFuel_Unit_Discount                    decimal(15, 7)   NOT NULL
        , OrdFuel_Post_As_Discount                 smallint         NOT NULL
        , OrdFuel_Disc_On_Invoice                  smallint         NOT NULL
        , OrdFuel_Disc_TranCode_Key                decimal(15, 0)   NULL
        , OrdFuel_Disc_CstDscRule_Key              decimal(15, 0)   NULL
        , OrdFuel_Frt_Unit_Price                   decimal(15, 7)   NOT NULL
        , OrdFuel_Frt_Total_Price                  decimal(12, 2)   NOT NULL
        , OrdFuel_Frt_Override                     smallint         NOT NULL
        , OrdFuel_Total_Unit_Price                 decimal(15, 7)   NOT NULL
        , OrdFuel_Quoted_Price                     smallint         NOT NULL
        , OrdFuel_Calc_Total_Unit_Price            decimal(15, 7)   NOT NULL
        , OrdFuel_Price_Incl_Taxes                 smallint         NOT NULL
        , OrdFuel_Price_Incl_Freight               smallint         NOT NULL
        , OrdFuel_Sys_Unit_Price                   decimal(15, 7)   NOT NULL
        , OrdFuel_Sys_Unit_Discount                decimal(15, 7)   NOT NULL
        , OrdFuel_PriceChg_User_Key                decimal(15, 0)   NULL
        , OrdFuel_Price_Locked                     tinyint          NOT NULL
        , OrdFuel_FuelDel_Key                      decimal(15, 0)   NULL
        , OrdFuel_FuelDelProd_Key                  decimal(15, 0)   NULL
        , OrdFuel_Tax_In_Inv                       decimal(15, 7)   NULL
        , OrdFuel_Posted_Dest_Tank_No              smallint         NULL
        , OrdFuel_Orig_Key                         decimal(15, 0)   NULL
        , OrdFuel_Frt_In_Inventory                 smallint         NOT NULL
        , OrdFuel_Frt_PL_In_Inventory              smallint         NOT NULL
        , OrdFuel_Frt_PL_Amt                       decimal(12, 2)   NOT NULL
        , OrdFuel_Frt_PL_In_Inv_Amt               decimal(12, 2)   NOT NULL
        , OrdFuel_Notes                            varchar(255)     NULL
        , OrdFuel_Use_Percent_Full                 smallint         NOT NULL
        , OrdFuel_Percent_Full                     decimal(6, 2)    NOT NULL
        , OrdFuel_Frt_Total_Surcharge              decimal(12, 2)   NOT NULL
        , OrdFuel_PricingRule_Key                  decimal(15, 0)   NULL
        , OrdFuel_PricingRule_Multiples_Found      smallint         NOT NULL
        , OrdFuel_Margin_Exception                 smallint         NOT NULL
        , OrdFuel_ODFuelPrcRule_Key                decimal(15, 0)   NULL
        , OrdFuel_ODFuelDscRule_Key                decimal(15, 0)   NULL
        , OrdFuel_FrtOvd_Actual_Per_Unit           decimal(15, 7)   NULL
        , OrdFuel_FrtOvd_Surchg_Pct               decimal(19, 7)   NULL
        , OrdFuel_FrtOvd_Surchg_Pct_Basis         decimal(15, 7)   NULL
        , OrdFuel_FrtOvd_Surchg_Per_Unit           decimal(15, 7)   NULL
        , OrdFuel_FrtOvd_Other_Per_Unit            decimal(15, 7)   NULL
        , OrdFuel_Quoted_Price_Amount              decimal(15, 7)   NOT NULL
        , OrdFuel_CustFuelCont_Key                 decimal(15, 0)   NULL
        , OrdFuel_CustFuelContDtl_Key              decimal(15, 0)   NULL
        , OrdFuel_CustFuelCont_Override            smallint         NOT NULL
        , OrdFuel_LastPosted_CustFuelContDtl_Key   decimal(15, 0)   NULL
        , OrdFuel_LastPosted_CustFuelCont_Qty      decimal(12, 2)   NOT NULL
        , OrdFuel_LastPosted_Date                  smalldatetime    NULL
        , OrdFuel_CustFuelCont_UserNotified        smallint         NOT NULL
        , OrdFuel_DestEquip_Key                    decimal(15, 0)   NULL
        , OrdFuel_Use_Beg_Percent_Full             smallint         NOT NULL
        , OrdFuel_Beg_Percent_Full                 decimal(6, 2)    NOT NULL
        , OrdFuel_Is_Short_Fill                    bit              NULL
        , OrdFuel_LastPosted_ODFuelPrcRule_Key     decimal(15, 0)   NULL
        , OrdFuel_DestEqDate_Key                   decimal(15, 0)   NULL
        , OrdFuel_Total_Unit_Price_Unrounded       decimal(15, 7)   NOT NULL
        , OrdFuel_ARTerms_Key                      decimal(15, 0)   NULL
        , OrdFuel_Frt_Qty                          decimal(12, 2)   NULL
        , OrdFuel_Total_Addl_Fees                  decimal(12, 2)   NOT NULL
        , OrdFuel_Calculated_Frt_Based_On_Units    tinyint          NULL
        -- Clone metadata (last two columns by convention)
        , Clone_LoadDtmUtc                         datetime2(3)     NOT NULL
        , Clone_LoadBatchId                        uniqueidentifier NOT NULL
        , CONSTRAINT PK_PDI_Order_Details_Fuel_Clone
            PRIMARY KEY CLUSTERED (OrdFuel_Key)
    );

    CREATE NONCLUSTERED INDEX IX_PDI_Order_Details_Fuel_Clone_OrdKey
        ON dbo.PDI_Order_Details_Fuel_Clone (OrdFuel_Ord_Key)
        INCLUDE (OrdFuel_Ord_Prod_Key, OrdFuel_Deliv_Net_Qty);
END;
GO
