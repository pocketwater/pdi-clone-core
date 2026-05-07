USE [PDI_PricingLink];
GO

/*
  sp_PDI_Order_Details_Fuel_Clone_SYNC

  Purpose : Windowed full-reload sync of dbo.PDI_Order_Details_Fuel_Clone from
            [PDI-SQL-01].PDICompany_2386_01.dbo.Order_Details_Fuel.

            Scope: only OrdFuel rows where OrdFuel_Ord_Key >= the minimum
            Ord_Key present in PDI_Orders_Clone with an actual delivery date
            within the last @WindowDays days. This bounds the clone to a
            rolling delivery window and keeps the table small.

            PDI_Orders_Clone must be current before calling this proc
            (sp_PDI_Orders_SYNC runs first in sp_PDI_AllClones_SYNC).

  Called by : dbo.sp_PDI_AllClones_SYNC (after Orders step)
  Frequency : Each AllClones_SYNC run

  Parameters:
    @Debug      bit  = 0   — 1 emits diagnostic SELECTs
    @WindowDays int  = 90  — rolling lookback window (days from today UTC)
*/

CREATE OR ALTER PROCEDURE dbo.sp_PDI_Order_Details_Fuel_Clone_SYNC
      @Debug      bit = 0
    , @WindowDays int = 90
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE
          @Rows      int             = 0
        , @MinOrdKey decimal(15, 0)  = 0
        , @BatchId   uniqueidentifier = NEWID()
        , @LoadDtm   datetime2(3)    = SYSUTCDATETIME();

    BEGIN TRY

        /* Derive the rolling window lower-bound from the local Orders clone.
           Using MIN(Ord_Key) on filtered rows avoids a cross-server subquery. */
        SELECT @MinOrdKey = ISNULL(MIN(Ord_Key), 0)
        FROM dbo.PDI_Orders_Clone
        WHERE Ord_Act_Deliv_DateTime >= DATEADD(day, -@WindowDays, @LoadDtm);

        IF @Debug = 1
            SELECT
                  Msg        = N'Starting sync: dbo.PDI_Order_Details_Fuel_Clone'
                , MinOrdKey  = @MinOrdKey
                , WindowDays = @WindowDays
                , UtcDtm     = @LoadDtm;

        TRUNCATE TABLE dbo.PDI_Order_Details_Fuel_Clone;

        INSERT dbo.PDI_Order_Details_Fuel_Clone
        (
              OrdFuel_Key
            , OrdFuel_Ord_Key
            , OrdFuel_Site_Key
            , OrdFuel_Ord_Prod_Key
            , OrdFuel_Prch_Prod_Key
            , OrdFuel_ProdBlnd_Key
            , OrdFuel_Order_Qty
            , OrdFuel_Deliv_Gross_Qty
            , OrdFuel_Deliv_Net_Qty
            , OrdFuel_Invoice_Qty
            , OrdFuel_Def_Origin_Type
            , OrdFuel_Def_Vend_Key
            , OrdFuel_Def_Trmnl_Key
            , OrdFuel_Def_Site_Key
            , OrdFuel_Def_Tank_No
            , OrdFuel_Dest_Tank_No
            , OrdFuel_Based_On_Units
            , OrdFuel_Frt_Based_On_Units
            , OrdFuel_Unit_Cost
            , OrdFuel_Unit_Cost_AfterRecon
            , OrdFuel_Unit_Price
            , OrdFuel_Unit_Discount
            , OrdFuel_Post_As_Discount
            , OrdFuel_Disc_On_Invoice
            , OrdFuel_Disc_TranCode_Key
            , OrdFuel_Disc_CstDscRule_Key
            , OrdFuel_Frt_Unit_Price
            , OrdFuel_Frt_Total_Price
            , OrdFuel_Frt_Override
            , OrdFuel_Total_Unit_Price
            , OrdFuel_Quoted_Price
            , OrdFuel_Calc_Total_Unit_Price
            , OrdFuel_Price_Incl_Taxes
            , OrdFuel_Price_Incl_Freight
            , OrdFuel_Sys_Unit_Price
            , OrdFuel_Sys_Unit_Discount
            , OrdFuel_PriceChg_User_Key
            , OrdFuel_Price_Locked
            , OrdFuel_FuelDel_Key
            , OrdFuel_FuelDelProd_Key
            , OrdFuel_Tax_In_Inv
            , OrdFuel_Posted_Dest_Tank_No
            , OrdFuel_Orig_Key
            , OrdFuel_Frt_In_Inventory
            , OrdFuel_Frt_PL_In_Inventory
            , OrdFuel_Frt_PL_Amt
            , OrdFuel_Frt_PL_In_Inv_Amt
            , OrdFuel_Notes
            , OrdFuel_Use_Percent_Full
            , OrdFuel_Percent_Full
            , OrdFuel_Frt_Total_Surcharge
            , OrdFuel_PricingRule_Key
            , OrdFuel_PricingRule_Multiples_Found
            , OrdFuel_Margin_Exception
            , OrdFuel_ODFuelPrcRule_Key
            , OrdFuel_ODFuelDscRule_Key
            , OrdFuel_FrtOvd_Actual_Per_Unit
            , OrdFuel_FrtOvd_Surchg_Pct
            , OrdFuel_FrtOvd_Surchg_Pct_Basis
            , OrdFuel_FrtOvd_Surchg_Per_Unit
            , OrdFuel_FrtOvd_Other_Per_Unit
            , OrdFuel_Quoted_Price_Amount
            , OrdFuel_CustFuelCont_Key
            , OrdFuel_CustFuelContDtl_Key
            , OrdFuel_CustFuelCont_Override
            , OrdFuel_LastPosted_CustFuelContDtl_Key
            , OrdFuel_LastPosted_CustFuelCont_Qty
            , OrdFuel_LastPosted_Date
            , OrdFuel_CustFuelCont_UserNotified
            , OrdFuel_DestEquip_Key
            , OrdFuel_Use_Beg_Percent_Full
            , OrdFuel_Beg_Percent_Full
            , OrdFuel_Is_Short_Fill
            , OrdFuel_LastPosted_ODFuelPrcRule_Key
            , OrdFuel_DestEqDate_Key
            , OrdFuel_Total_Unit_Price_Unrounded
            , OrdFuel_ARTerms_Key
            , OrdFuel_Frt_Qty
            , OrdFuel_Total_Addl_Fees
            , OrdFuel_Calculated_Frt_Based_On_Units
            , Clone_LoadDtmUtc
            , Clone_LoadBatchId
        )
        SELECT
              F.OrdFuel_Key
            , F.OrdFuel_Ord_Key
            , F.OrdFuel_Site_Key
            , F.OrdFuel_Ord_Prod_Key
            , F.OrdFuel_Prch_Prod_Key
            , F.OrdFuel_ProdBlnd_Key
            , F.OrdFuel_Order_Qty
            , F.OrdFuel_Deliv_Gross_Qty
            , F.OrdFuel_Deliv_Net_Qty
            , F.OrdFuel_Invoice_Qty
            , F.OrdFuel_Def_Origin_Type
            , F.OrdFuel_Def_Vend_Key
            , F.OrdFuel_Def_Trmnl_Key
            , F.OrdFuel_Def_Site_Key
            , F.OrdFuel_Def_Tank_No
            , F.OrdFuel_Dest_Tank_No
            , F.OrdFuel_Based_On_Units
            , F.OrdFuel_Frt_Based_On_Units
            , F.OrdFuel_Unit_Cost
            , F.OrdFuel_Unit_Cost_AfterRecon
            , F.OrdFuel_Unit_Price
            , F.OrdFuel_Unit_Discount
            , F.OrdFuel_Post_As_Discount
            , F.OrdFuel_Disc_On_Invoice
            , F.OrdFuel_Disc_TranCode_Key
            , F.OrdFuel_Disc_CstDscRule_Key
            , F.OrdFuel_Frt_Unit_Price
            , F.OrdFuel_Frt_Total_Price
            , F.OrdFuel_Frt_Override
            , F.OrdFuel_Total_Unit_Price
            , F.OrdFuel_Quoted_Price
            , F.OrdFuel_Calc_Total_Unit_Price
            , F.OrdFuel_Price_Incl_Taxes
            , F.OrdFuel_Price_Incl_Freight
            , F.OrdFuel_Sys_Unit_Price
            , F.OrdFuel_Sys_Unit_Discount
            , F.OrdFuel_PriceChg_User_Key
            , F.OrdFuel_Price_Locked
            , F.OrdFuel_FuelDel_Key
            , F.OrdFuel_FuelDelProd_Key
            , F.OrdFuel_Tax_In_Inv
            , F.OrdFuel_Posted_Dest_Tank_No
            , F.OrdFuel_Orig_Key
            , F.OrdFuel_Frt_In_Inventory
            , F.OrdFuel_Frt_PL_In_Inventory
            , F.OrdFuel_Frt_PL_Amt
            , F.OrdFuel_Frt_PL_In_Inv_Amt
            , F.OrdFuel_Notes
            , F.OrdFuel_Use_Percent_Full
            , F.OrdFuel_Percent_Full
            , F.OrdFuel_Frt_Total_Surcharge
            , F.OrdFuel_PricingRule_Key
            , F.OrdFuel_PricingRule_Multiples_Found
            , F.OrdFuel_Margin_Exception
            , F.OrdFuel_ODFuelPrcRule_Key
            , F.OrdFuel_ODFuelDscRule_Key
            , F.OrdFuel_FrtOvd_Actual_Per_Unit
            , F.OrdFuel_FrtOvd_Surchg_Pct
            , F.OrdFuel_FrtOvd_Surchg_Pct_Basis
            , F.OrdFuel_FrtOvd_Surchg_Per_Unit
            , F.OrdFuel_FrtOvd_Other_Per_Unit
            , F.OrdFuel_Quoted_Price_Amount
            , F.OrdFuel_CustFuelCont_Key
            , F.OrdFuel_CustFuelContDtl_Key
            , F.OrdFuel_CustFuelCont_Override
            , F.OrdFuel_LastPosted_CustFuelContDtl_Key
            , F.OrdFuel_LastPosted_CustFuelCont_Qty
            , F.OrdFuel_LastPosted_Date
            , F.OrdFuel_CustFuelCont_UserNotified
            , F.OrdFuel_DestEquip_Key
            , F.OrdFuel_Use_Beg_Percent_Full
            , F.OrdFuel_Beg_Percent_Full
            , F.OrdFuel_Is_Short_Fill
            , F.OrdFuel_LastPosted_ODFuelPrcRule_Key
            , F.OrdFuel_DestEqDate_Key
            , F.OrdFuel_Total_Unit_Price_Unrounded
            , F.OrdFuel_ARTerms_Key
            , F.OrdFuel_Frt_Qty
            , F.OrdFuel_Total_Addl_Fees
            , F.OrdFuel_Calculated_Frt_Based_On_Units
            , @LoadDtm
            , @BatchId
        FROM [PDI-SQL-01].[PDICompany_2386_01].dbo.Order_Details_Fuel AS F
        WHERE F.OrdFuel_Ord_Key >= @MinOrdKey;

        SET @Rows = @@ROWCOUNT;

        IF @Debug = 1
            SELECT
                  Msg    = N'Completed sync: dbo.PDI_Order_Details_Fuel_Clone'
                , [Rows] = @Rows
                , UtcDtm = SYSUTCDATETIME();

    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO
