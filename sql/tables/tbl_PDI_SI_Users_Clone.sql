USE [PDI_PricingLink];
GO

/*
  PDI_SI_Users_Clone

  Purpose : Local clone of PDI SI user records. Supports user key resolution
            across pipeline views and audit trails.
  Refresh : dbo.sp_PDI_AllClones_SYNC (registered clone)
*/

IF OBJECT_ID('dbo.PDI_SI_Users_Clone', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.PDI_SI_Users_Clone
    (
          User_Key        decimal(15, 0)  NOT NULL
        , User_ID         varchar(50)     NULL
        , Clone_Load_Dtm  datetime2(3)    NOT NULL
        , Clone_Source    varchar(100)    NOT NULL
        , CONSTRAINT PK_PDI_SI_Users_Clone
            PRIMARY KEY CLUSTERED (User_Key)
    );
END;
GO
