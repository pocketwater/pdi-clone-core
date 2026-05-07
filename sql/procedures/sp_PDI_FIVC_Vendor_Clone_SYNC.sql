USE [PDI_PricingLink];
GO

/*
  sp_PDI_FIVC_Vendor_Clone_SYNC

  Purpose : Syncs dbo.PDI_FIVC_Vendor_Clone from SQL-02 local views
            (vw_PDI_Fuel_Contracts JOIN vw_PDI_Vendors). Truncate-and-reload
            pattern. Distinct rows to avoid contract/vendor fan-out.
  Target  : dbo.PDI_FIVC_Vendor_Clone
  Source  : dbo.vw_PDI_Fuel_Contracts, dbo.vw_PDI_Vendors (SQL-02 local views)
  Params  : @Debug bit = 0 — when 1, prints start/end diagnostics
*/

CREATE OR ALTER PROCEDURE dbo.sp_PDI_FIVC_Vendor_Clone_SYNC
    @Debug bit = 0
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @Rows int = 0;

    BEGIN TRY

        IF @Debug = 1
            SELECT
                  Msg    = 'Starting sync: dbo.PDI_FIVC_Vendor_Clone'
                , UtcDtm = SYSUTCDATETIME();

        TRUNCATE TABLE dbo.PDI_FIVC_Vendor_Clone;

        ;WITH SourceRows AS
        (
            SELECT DISTINCT
                  FC.FuelContDtl_Key
                , FC.FuelContDtl_FuelCont_Key
                , FC.FuelCont_ID
                , FC.FuelCont_Description
                , V.Vend_Key
                , V.Vend_ID
                , V.Vend_Description
            FROM dbo.vw_PDI_Fuel_Contracts AS FC
            INNER JOIN dbo.vw_PDI_Vendors AS V
                ON FC.Vend_Key = V.Vend_Key
        )
        INSERT dbo.PDI_FIVC_Vendor_Clone
        (
              FuelCont_ID
            , FuelCont_Description
            , Vend_ID
            , Vend_Description
            , FuelContDtl_Key
            , FuelContDtl_FuelCont_Key
            , Vend_Key
            , Sync_Dtm
        )
        SELECT
              SR.FuelCont_ID
            , SR.FuelCont_Description
            , SR.Vend_ID
            , SR.Vend_Description
            , SR.FuelContDtl_Key
            , SR.FuelContDtl_FuelCont_Key
            , SR.Vend_Key
            , SYSUTCDATETIME() AS Sync_Dtm
        FROM SourceRows AS SR;

        SET @Rows = @@ROWCOUNT;

        IF @Debug = 1
            SELECT
                  Msg    = 'Completed sync: dbo.PDI_FIVC_Vendor_Clone'
                , [Rows] = @Rows
                , UtcDtm = SYSUTCDATETIME();

    END TRY
    BEGIN CATCH
        THROW;
    END CATCH
END;
GO
