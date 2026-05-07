USE [PDI_PricingLink];
GO

/*
  sp_PDI_CITT_Axxis_Grav_PDI_Products_SYNC

  Purpose : Full-replace sync of dbo.PDI_CITT_Axxis_Grav_PDI_Products_Clone from
            CitySV CITT Axxis integration products source.

  Called by : dbo.sp_PDI_AllClones_SYNC
  Frequency : Each AllClones_SYNC run.
*/

CREATE OR ALTER PROCEDURE dbo.sp_PDI_CITT_Axxis_Grav_PDI_Products_SYNC
    @Debug bit = 0
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @Rows int = 0;
    DECLARE @SyncDtm datetime2(3) = SYSUTCDATETIME();

    BEGIN TRY
        IF @Debug = 1
            SELECT 'Starting sync: dbo.PDI_CITT_Axxis_Grav_PDI_Products_Clone' AS Msg, @SyncDtm AS UtcDtm;

        TRUNCATE TABLE dbo.PDI_CITT_Axxis_Grav_PDI_Products_Clone;

        INSERT dbo.PDI_CITT_Axxis_Grav_PDI_Products_Clone
        (
              Prod_Key
            , Prod_ID
            , Prod_Description
            , Sync_Dtm
        )
        SELECT
              CONVERT(int, P.Prod_Key)
            , CONVERT(varchar(20), P.Prod_ID)
            , CONVERT(varchar(100), P.Prod_Description)
            , @SyncDtm
        FROM [PDI-SQL-01].PDICompany_2386_01.dbo.Products AS P
        WHERE P.Prod_Key IS NOT NULL;

        SET @Rows = @@ROWCOUNT;

        IF @Debug = 1
            SELECT 'Completed sync: dbo.PDI_CITT_Axxis_Grav_PDI_Products_Clone' AS Msg, @Rows AS [Rows], @SyncDtm AS UtcDtm;

        RETURN 0;
    END TRY
    BEGIN CATCH
        IF @Debug = 1
            SELECT CONCAT('sp_PDI_CITT_Axxis_Grav_PDI_Products_SYNC failed. Error ', ERROR_NUMBER(), ', Line ', ERROR_LINE(), ': ', ERROR_MESSAGE()) AS ErrorMessage;

        THROW;
    END CATCH
END;
GO
