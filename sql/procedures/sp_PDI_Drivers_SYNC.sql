USE [PDI_PricingLink];
GO

/*
  sp_PDI_Drivers_SYNC

  Purpose : Full-replace sync of dbo.PDI_Drivers_Clone from
            [PDI-SQL-01].PDICompany_2386_01.dbo.Drivers.

  Called by : dbo.sp_PDI_AllClones_SYNC
  Frequency : Each AllClones_SYNC run.
*/

CREATE OR ALTER PROCEDURE dbo.sp_PDI_Drivers_SYNC
    @Debug bit = 0
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @Rows int = 0;
    DECLARE @SyncDtm datetime2(3) = SYSUTCDATETIME();

    BEGIN TRY
        IF @Debug = 1
            SELECT 'Starting sync: dbo.PDI_Drivers_Clone' AS Msg, @SyncDtm AS UtcDtm;

        TRUNCATE TABLE dbo.PDI_Drivers_Clone;

        INSERT dbo.PDI_Drivers_Clone
        (
              Driver_Key
            , Driver_ID
            , Driver_Name
            , Driver_Vend_Key
            , Clone_Load_Dtm
            , Clone_Source
            , Sync_Dtm
        )
        SELECT
              CONVERT(decimal(15, 0), D.Driver_Key)
            , CONVERT(varchar(10), D.Driver_ID)
            , CONVERT(varchar(40), D.Driver_Name)
            , CONVERT(decimal(15, 0), D.Driver_Vend_Key)
            , @SyncDtm
            , '[PDI-SQL-01].PDICompany_2386_01.dbo.Drivers'
            , @SyncDtm
        FROM [PDI-SQL-01].PDICompany_2386_01.dbo.Drivers AS D
        WHERE D.Driver_Key IS NOT NULL;

        SET @Rows = @@ROWCOUNT;

        IF @Debug = 1
            SELECT 'Completed sync: dbo.PDI_Drivers_Clone' AS Msg, @Rows AS [Rows], @SyncDtm AS UtcDtm;

        RETURN 0;
    END TRY
    BEGIN CATCH
        IF @Debug = 1
            SELECT CONCAT('sp_PDI_Drivers_SYNC failed. Error ', ERROR_NUMBER(), ', Line ', ERROR_LINE(), ': ', ERROR_MESSAGE()) AS ErrorMessage;

        THROW;
    END CATCH
END;
GO
