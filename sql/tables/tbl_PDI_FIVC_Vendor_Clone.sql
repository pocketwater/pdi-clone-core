USE [PDI_PricingLink];
GO

/*
  PDI_FIVC_Vendor_Clone

  Purpose : Local clone joining PDI fuel inventory vendor contracts (FIVC) to
            vendor master records. Used by cost pipeline views to resolve
            supplier/contract pairings.
  Refresh : dbo.sp_PDI_FIVC_Vendor_Clone_SYNC
*/

IF OBJECT_ID('dbo.PDI_FIVC_Vendor_Clone', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.PDI_FIVC_Vendor_Clone
    (
          FuelCont_ID              varchar(50)   NOT NULL
        , FuelCont_Description     varchar(255)  NOT NULL
        , Vend_ID                  varchar(50)   NOT NULL
        , Vend_Description         varchar(255)  NOT NULL
        , FuelContDtl_Key          int           NOT NULL
        , FuelContDtl_FuelCont_Key int           NOT NULL
        , Vend_Key                 int           NOT NULL
        , Sync_Dtm                 datetime2(0)  NOT NULL
        , CONSTRAINT PK_PDI_FIVC_Vendor_Clone
            PRIMARY KEY CLUSTERED (FuelContDtl_Key, Vend_Key)
    );
END;
GO
