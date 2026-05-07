USE [PDI_PricingLink];
GO

/*
  sp_PDI_Orders_SYNC

  Purpose : Windowed sync of dbo.PDI_Orders_Clone from
            [PDI-SQL-01].PDICompany_2386_01.dbo.Orders.
            Scope: Recent orders (90-day rolling window from latest delivery date).

  Called by : dbo.sp_PDI_AllClones_SYNC
  Frequency : Each AllClones_SYNC run.
*/

CREATE OR ALTER PROCEDURE dbo.sp_PDI_Orders_SYNC
    @Debug bit = 0
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @Rows int = 0;
    DECLARE @LoadDtm datetime2(3) = SYSUTCDATETIME();
    DECLARE @WindowStart datetime2 = DATEADD(day, -90, CAST(SYSUTCDATETIME() AS date));

    BEGIN TRY
        IF @Debug = 1
            SELECT 'Starting sync: dbo.PDI_Orders_Clone' AS Msg, @LoadDtm AS UtcDtm, @WindowStart AS WindowStart;

        TRUNCATE TABLE dbo.PDI_Orders_Clone;

        INSERT dbo.PDI_Orders_Clone
        (
              Ord_Key
            , Ord_No
            , Ord_Cust_PO_No
            , Ord_Reference_No
            , Clone_LoadDtmUtc
        )
        SELECT
              CONVERT(bigint, O.Ord_Key)
            , CONVERT(varchar(30), O.Ord_No)
            , CONVERT(varchar(50), O.Ord_Cust_PO_No)
            , CONVERT(varchar(50), O.Ord_Reference_No)
            , @LoadDtm
        FROM [PDI-SQL-01].PDICompany_2386_01.dbo.Orders AS O
        WHERE O.Ord_Key IS NOT NULL
          AND O.Ord_Act_Deliv_DateTime >= @WindowStart;

        SET @Rows = @@ROWCOUNT;

        IF @Debug = 1
            SELECT 'Completed sync: dbo.PDI_Orders_Clone' AS Msg, @Rows AS [Rows], @LoadDtm AS UtcDtm;

        RETURN 0;
    END TRY
    BEGIN CATCH
        IF @Debug = 1
            SELECT CONCAT('sp_PDI_Orders_SYNC failed. Error ', ERROR_NUMBER(), ', Line ', ERROR_LINE(), ': ', ERROR_MESSAGE()) AS ErrorMessage;

        THROW;
    END CATCH
END;
GO
