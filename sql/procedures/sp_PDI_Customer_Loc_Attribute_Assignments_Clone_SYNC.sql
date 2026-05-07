SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE OR ALTER PROCEDURE dbo.sp_PDI_Customer_Loc_Attribute_Assignments_Clone_SYNC
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @LoadDtm datetime2(3) = SYSUTCDATETIME();
    DECLARE @BatchId uniqueidentifier = NEWID();

    TRUNCATE TABLE dbo.PDI_Customer_Loc_Attribute_Assignments_Clone;

    INSERT INTO dbo.PDI_Customer_Loc_Attribute_Assignments_Clone
    (
          CustLocAttAssign_CustLoc_Key
        , CustLocAttAssign_Att_Key
        , CustLocAttAssign_Value
        , Clone_LoadDtmUtc
        , Clone_LoadBatchId
    )
    SELECT
          CLAA.CustLocAttAssign_CustLoc_Key
        , CLAA.CustLocAttAssign_Att_Key
        , NULLIF(LTRIM(RTRIM(CONVERT(varchar(100), CLAA.CustLocAttAssign_Value))), '')
        , @LoadDtm
        , @BatchId
    FROM [PDI-SQL-01].[PDICompany_2386_01].dbo.Customer_Loc_Attribute_Assignments AS CLAA;
END;
GO
