USE [PDI_PricingLink];
GO

/*
  sp_PDI_Site_Tank_Details_Clone_SYNC

  Purpose : Full-replace sync of dbo.PDI_Site_Tank_Details_Clone from
            [PDI-SQL-01].PDICompany_2386_01.dbo.Site_Tank_Details.
            Only the key columns required by the PE-021 pre-export
            blocker query are cloned.

  Called by : dbo.sp_PDI_AllClones_SYNC (after sp_PDI_Site_Tank_Dates_Clone_SYNC step)
  Consumer  : Invoke-PDI_ODE_Gravitate_Export.ps1 PE-021 blocker query
  Frequency : Each AllClones_SYNC run.
*/

CREATE OR ALTER PROCEDURE dbo.sp_PDI_Site_Tank_Details_Clone_SYNC
    @Debug bit = 0
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @Rows int = 0;
    DECLARE @SyncDtm datetime2(3) = SYSUTCDATETIME();

    BEGIN TRY
        IF @Debug = 1
            SELECT 'Starting sync: dbo.PDI_Site_Tank_Details_Clone' AS Msg, @SyncDtm AS UtcDtm;

        TRUNCATE TABLE dbo.PDI_Site_Tank_Details_Clone;

        INSERT dbo.PDI_Site_Tank_Details_Clone
        (
              SiteTankDtl_Key
            , SiteTankDtl_Date_Key
            , SiteTankDtl_Tank_No
            , SiteTankDtl_Prod_Key
            , Sync_Dtm
        )
        SELECT
              CONVERT(decimal(15, 0), DTL.SiteTankDtl_Key)
            , CONVERT(decimal(15, 0), DTL.SiteTankDtl_Date_Key)
            , CONVERT(smallint, DTL.SiteTankDtl_Tank_No)
            , CONVERT(decimal(15, 0), DTL.SiteTankDtl_Prod_Key)
            , @SyncDtm
        FROM [PDI-SQL-01].PDICompany_2386_01.dbo.Site_Tank_Details AS DTL
        WHERE DTL.SiteTankDtl_Key IS NOT NULL;

        SET @Rows = @@ROWCOUNT;

        IF @Debug = 1
            SELECT 'Completed sync: dbo.PDI_Site_Tank_Details_Clone' AS Msg, @Rows AS [Rows], @SyncDtm AS UtcDtm;

        RETURN 0;
    END TRY
    BEGIN CATCH
        IF @Debug = 1
            SELECT CONCAT('sp_PDI_Site_Tank_Details_Clone_SYNC failed. Error ', ERROR_NUMBER(), ', Line ', ERROR_LINE(), ': ', ERROR_MESSAGE()) AS ErrorMessage;

        THROW;
    END CATCH
END;
GO
