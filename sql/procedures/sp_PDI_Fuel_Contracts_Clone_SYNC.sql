USE [PDI_PricingLink];
GO

/*
  sp_PDI_Fuel_Contracts_Clone_SYNC

  Purpose : Full-replace sync of dbo.PDI_Fuel_Contracts_Clone from
            [PDI-SQL-01].PDICompany_2386_01.dbo.Fuel_Contracts.

  Called by : dbo.sp_PDI_AllClones_SYNC
  Frequency : Each AllClones_SYNC run.
*/

CREATE OR ALTER PROCEDURE dbo.sp_PDI_Fuel_Contracts_Clone_SYNC
    @Debug bit = 0
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @Rows int = 0;
    DECLARE @SyncDtm datetime2(3) = SYSUTCDATETIME();

    BEGIN TRY
        IF @Debug = 1
            SELECT 'Starting sync: dbo.PDI_Fuel_Contracts_Clone' AS Msg, @SyncDtm AS UtcDtm;

        TRUNCATE TABLE dbo.PDI_Fuel_Contracts_Clone;

        INSERT dbo.PDI_Fuel_Contracts_Clone
        (
              FuelCont_Key
            , FuelCont_ID
            , FuelCont_Type
            , FuelCont_Description
            , FuelCont_Inactive
            , Sync_Dtm
        )
        SELECT
              CONVERT(decimal(15, 0), FC.FuelCont_Key)
            , CONVERT(varchar(15), FC.FuelCont_ID)
            , CONVERT(tinyint, FC.FuelCont_Type)
            , CONVERT(varchar(40), FC.FuelCont_Description)
            , CONVERT(smallint, FC.FuelCont_Inactive)
            , @SyncDtm
        FROM [PDI-SQL-01].PDICompany_2386_01.dbo.Fuel_Contracts AS FC
        WHERE FC.FuelCont_Key IS NOT NULL;

        SET @Rows = @@ROWCOUNT;

        IF @Debug = 1
            SELECT 'Completed sync: dbo.PDI_Fuel_Contracts_Clone' AS Msg, @Rows AS [Rows], @SyncDtm AS UtcDtm;

        RETURN 0;
    END TRY
    BEGIN CATCH
        IF @Debug = 1
            SELECT CONCAT('sp_PDI_Fuel_Contracts_Clone_SYNC failed. Error ', ERROR_NUMBER(), ', Line ', ERROR_LINE(), ': ', ERROR_MESSAGE()) AS ErrorMessage;

        THROW;
    END CATCH
END;
GO
