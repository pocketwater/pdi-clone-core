USE [PDI_PricingLink];
GO

/*
  sp_PDI_Customer_Locations_SYNC

  Purpose : Full-replace sync of dbo.PDI_Customer_Locations_Clone from
            [PDI-SQL-01].PDICompany_2386_01.dbo.Customer_Locations with state lookup.

  Called by : dbo.sp_PDI_AllClones_SYNC
  Frequency : Each AllClones_SYNC run.
*/

CREATE OR ALTER PROCEDURE dbo.sp_PDI_Customer_Locations_SYNC
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
            SELECT 'Starting sync: dbo.PDI_Customer_Locations_Clone' AS Msg, @SyncDtm AS UtcDtm;

        TRUNCATE TABLE dbo.PDI_Customer_Locations_Clone;

        INSERT dbo.PDI_Customer_Locations_Clone
        (
              Cust_ID
            , Cust_Description
            , CustLoc_Key
            , CustLoc_ID
            , CustLoc_Description
            , CustLoc_City
            , CustLoc_State_Key
            , CustLoc_Active
            , Sync_Dtm
        )
        SELECT
              CONVERT(varchar(10), C.Cust_ID)
            , CONVERT(varchar(100), C.Cust_Description)
            , CONVERT(int, CL.CustLoc_Key)
            , CONVERT(varchar(10), CL.CustLoc_ID)
            , CONVERT(varchar(100), CL.CustLoc_Description)
            , CONVERT(varchar(50), CL.CustLoc_City)
            , CONVERT(varchar(10), St.State_Code)
            , CONVERT(bit, CL.CustLoc_Active)
            , @SyncDtm
        FROM [PDI-SQL-01].PDICompany_2386_01.dbo.Customer_Locations AS CL
        LEFT JOIN [PDI-SQL-01].PDICompany_2386_01.dbo.Customers AS C
            ON C.Cust_Key = CL.CustLoc_Cust_Key
        LEFT JOIN dbo.vw_PDI_States AS St
            ON CL.CustLoc_State_Key = St.State_Key
        WHERE CL.CustLoc_Key IS NOT NULL;

        SET @Rows = @@ROWCOUNT;
        SET @RowsAffected = @Rows;

        IF @Debug = 1
            SELECT 'Completed sync: dbo.PDI_Customer_Locations_Clone' AS Msg, @Rows AS [Rows], @SyncDtm AS UtcDtm;

        RETURN 0;
    END TRY
    BEGIN CATCH
        IF @Debug = 1
            SELECT CONCAT('sp_PDI_Customer_Locations_SYNC failed. Error ', ERROR_NUMBER(), ', Line ', ERROR_LINE(), ': ', ERROR_MESSAGE()) AS ErrorMessage;

        THROW;
    END CATCH
END;
GO
