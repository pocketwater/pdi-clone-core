USE [PDI_PricingLink];
GO

/*
  sp_PDI_Vehicles_SYNC

  Purpose : Full-replace sync of dbo.PDI_Trucks_Clone from
            [PDI-SQL-01].PDICompany_2386_01.dbo.Vehicles.

  Called by : dbo.sp_PDI_AllClones_SYNC
  Frequency : Each AllClones_SYNC run.
*/

CREATE OR ALTER PROCEDURE dbo.sp_PDI_Vehicles_SYNC
    @Debug bit = 0
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @Rows int = 0;
    DECLARE @SyncDtm datetime2(3) = SYSUTCDATETIME();

    BEGIN TRY
        IF @Debug = 1
            SELECT 'Starting sync: dbo.PDI_Trucks_Clone' AS Msg, @SyncDtm AS UtcDtm;

        TRUNCATE TABLE dbo.PDI_Trucks_Clone;

        INSERT dbo.PDI_Trucks_Clone
        (
              Vehicle_Key
            , Vehicle_ID
            , Vehicle_Description
            , Vehicle_Vend_Key
            , Vehicle_VehicleType_Key
            , Vehicle_EquipmentType_Key
            , Vehicle_ProfitSite_Key
            , Clone_Load_Dtm
            , Clone_Source
            , Sync_Dtm
        )
        SELECT
              CONVERT(decimal(15, 0), V.Vehicle_Key)
            , CONVERT(varchar(15), V.Vehicle_ID)
            , CONVERT(varchar(30), V.Vehicle_Description)
            , CONVERT(decimal(15, 0), V.Vehicle_Vend_Key)
            , CONVERT(decimal(15, 0), V.Vehicle_VehicleType_Key)
            , CONVERT(decimal(15, 0), V.Vehicle_EquipmentType_Key)
            , CONVERT(decimal(15, 0), V.Vehicle_ProfitSite_Key)
            , @SyncDtm
            , '[PDI-SQL-01].PDICompany_2386_01.dbo.Vehicles'
            , @SyncDtm
        FROM [PDI-SQL-01].PDICompany_2386_01.dbo.Vehicles AS V
        WHERE V.Vehicle_Key IS NOT NULL;

        SET @Rows = @@ROWCOUNT;

        IF @Debug = 1
            SELECT 'Completed sync: dbo.PDI_Trucks_Clone' AS Msg, @Rows AS [Rows], @SyncDtm AS UtcDtm;

        RETURN 0;
    END TRY
    BEGIN CATCH
        IF @Debug = 1
            SELECT CONCAT('sp_PDI_Vehicles_SYNC failed. Error ', ERROR_NUMBER(), ', Line ', ERROR_LINE(), ': ', ERROR_MESSAGE()) AS ErrorMessage;

        THROW;
    END CATCH
END;
GO
