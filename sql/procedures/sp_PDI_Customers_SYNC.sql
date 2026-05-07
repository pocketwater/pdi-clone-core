USE [PDI_PricingLink];
GO

/*
  sp_PDI_Customers_SYNC

  Purpose : Full-replace sync of dbo.PDI_Customers_Clone from
            [PDI-SQL-01].PDICompany_2386_01.dbo.Customers.

  Called by : dbo.sp_PDI_AllClones_SYNC
  Frequency : Each AllClones_SYNC run.
*/

CREATE OR ALTER PROCEDURE dbo.sp_PDI_Customers_SYNC
    @Debug bit = 0,
    @RowsAffected int = NULL OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @Rows int = 0;
    DECLARE @SyncDtm datetime2(3) = SYSUTCDATETIME();

    BEGIN TRY
        IF @Debug = 1
            SELECT 'Starting sync: dbo.PDI_Customers_Clone' AS Msg, @SyncDtm AS UtcDtm;

        TRUNCATE TABLE dbo.PDI_Customers_Clone;

        INSERT dbo.PDI_Customers_Clone
        (
              Cust_Key
            , Cust_ID
            , Cust_Description
            , Sync_Dtm
        )
        SELECT
              CONVERT(int, C.Cust_Key)
            , CONVERT(varchar(10), C.Cust_ID)
            , CONVERT(varchar(100), C.Cust_Description)
            , @SyncDtm
        FROM [PDI-SQL-01].PDICompany_2386_01.dbo.Customers AS C
        WHERE C.Cust_Key IS NOT NULL;

        SET @Rows = @@ROWCOUNT;
        SET @RowsAffected = @Rows;

        IF @Debug = 1
            SELECT 'Completed sync: dbo.PDI_Customers_Clone' AS Msg, @Rows AS [Rows], @SyncDtm AS UtcDtm;

        RETURN 0;
    END TRY
    BEGIN CATCH
        IF @Debug = 1
            SELECT CONCAT('sp_PDI_Customers_SYNC failed. Error ', ERROR_NUMBER(), ', Line ', ERROR_LINE(), ': ', ERROR_MESSAGE()) AS ErrorMessage;

        THROW;
    END CATCH
END;
GO
