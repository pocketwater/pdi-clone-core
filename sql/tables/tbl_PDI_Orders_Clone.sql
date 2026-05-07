USE [PDI_PricingLink];
GO

/*
  PDI_Orders_Clone

  Purpose : Local clone of PDI order header records. Core input for OD import
            pipeline (citysv-prices, gravitate-orders). Loaded via batch
            pattern (Clone_LoadDtmUtc column). No primary key constraint exists
            on the live table — Ord_Key is the natural business key.
  Refresh : dbo.sp_PDI_AllClones_SYNC (registered clone)
*/

IF OBJECT_ID('dbo.PDI_Orders_Clone', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.PDI_Orders_Clone
    (
          Ord_Key                                decimal(15, 0)   NOT NULL
        , Ord_No                                 varchar(15)      NOT NULL
        , Ord_Type                               tinyint          NOT NULL
        , Ord_Dest_Type                          tinyint          NOT NULL
        , Ord_Cust_Key                           decimal(15, 0)   NULL
        , Ord_CustLoc_Key                        decimal(15, 0)   NULL
        , Ord_CustCont_Key                       decimal(15, 0)   NULL
        , Ord_SalesPerson_Key                    decimal(15, 0)   NULL
        , Ord_Site_Key                           decimal(15, 0)   NULL
        , Ord_Status                             tinyint          NOT NULL
        , Ord_Entry_DateTime                     smalldatetime    NOT NULL
        , Ord_Entry_User_Key                     decimal(15, 0)   NULL
        , Ord_Cust_PO_No                         varchar(20)      NULL
        , Ord_Business_Date                      smalldatetime    NOT NULL
        , Ord_Quote_DateTime                     smalldatetime    NOT NULL
        , Ord_Order_DateTime                     smalldatetime    NULL
        , Ord_Sch_Deliv_DateTime                 smalldatetime    NULL
        , Ord_Act_Deliv_DateTime                 smalldatetime    NULL
        , Ord_Expire_DateTime                    smalldatetime    NULL
        , Ord_Reference_No                       varchar(20)      NULL
        , Ord_Total_Amount                       decimal(12, 2)   NOT NULL
        , Ord_Last_AR_Amount                     decimal(12, 2)   NOT NULL
        , Ord_Ship_To_Override                   smallint         NOT NULL
        , Ord_Order_Notes                        varchar(255)     NULL
        , Ord_Delivery_Notes                     varchar(255)     NULL
        , Ord_Driver_Key                         decimal(15, 0)   NULL
        , Ord_Vehicle_Key                        decimal(15, 0)   NULL
        , Ord_Carrier_Key                        decimal(15, 0)   NULL
        , Ord_OrdPickBatch_Key                   decimal(15, 0)   NULL
        , Ord_Need_To_Print_Invc                 smallint         NOT NULL
        , Ord_OrdBillBatch_Key                   decimal(15, 0)   NULL
        , Ord_Terms_Key                          decimal(15, 0)   NULL
        , Ord_Inv_No                             varchar(15)      NULL
        , Ord_Inv_Date                           smalldatetime    NULL
        , Ord_Post_DateTime                      smalldatetime    NULL
        , Ord_Previously_Shipped                 smallint         NOT NULL
        , Ord_Previously_Invoiced                smallint         NOT NULL
        , Ord_Rounding_Adjustment                decimal(12, 2)   NOT NULL
        , Ord_Source                             tinyint          NOT NULL
        , Ord_Import_Key                         decimal(15, 0)   NULL
        , Ord_Delivery_Directions                text             NULL
        , Ord_WhOnly_Load_Key                    decimal(15, 0)   NULL
        , Ord_DropShip_Site_Key                  decimal(15, 0)   NULL
        , Ord_Send_Inv_To_Cust                   smallint         NOT NULL
        , Ord_Credited                           smallint         NOT NULL
        , Ord_COD_Payment                        smallint         NOT NULL
        , Ord_COD_Include_CustBal                smallint         NOT NULL
        , Ord_COD_This_Order                     smallint         NOT NULL
        , Ord_COD_Last_Order                     smallint         NOT NULL
        , Ord_COD_CustBal_Amt                    decimal(16, 2)   NOT NULL
        , Ord_COD_Last_Ord_Key                   decimal(15, 0)   NULL
        , Ord_COD_Last_Ord_Amt                   decimal(12, 2)   NOT NULL
        , Ord_COD_Receipt_Amt                    decimal(12, 2)   NOT NULL
        , Ord_COD_Other_Amt                      decimal(12, 2)   NOT NULL
        , Ord_COD_Collect_Amt                    decimal(12, 2)   NOT NULL
        , Ord_COD_Defaults_Set                   smallint         NOT NULL
        , Ord_Internally_Billed                  smallint         NOT NULL
        , Ord_Billing_Period                     decimal(6, 0)    NULL
        , Ord_Cust_PO_No_Overriden               smallint         NOT NULL
        , Ord_Dispatch_Only                      smallint         NOT NULL
        , Ord_Freight_DropShip_Site_Key          decimal(15, 0)   NULL
        , Ord_Credit_Exception                   smallint         NOT NULL
        , Ord_RelForBill_User_Key                decimal(15, 0)   NULL
        , Ord_Buyback_Order                      smallint         NOT NULL
        , Ord_Buyback_Status                     tinyint          NOT NULL
        , Ord_Buyback_Ref_No                     varchar(20)      NULL
        , Ord_Buyback_VndInv_Key                 decimal(15, 0)   NULL
        , Ord_Buyback_VndInvPnd_Key              decimal(15, 0)   NULL
        , Ord_Payment_Received                   smallint         NOT NULL
        , Ord_Wh_Odometer_In                     decimal(12, 1)   NULL
        , Ord_Wh_Odometer_Out                    decimal(12, 1)   NULL
        , Ord_Wh_DateTime_In                     smalldatetime    NULL
        , Ord_Wh_DateTime_Out                    smalldatetime    NULL
        , Ord_Entered_By_CustCont_Key            decimal(15, 0)   NULL
        , Ord_Reqst_Deliv_DateTime               smalldatetime    NULL
        , Ord_Potential_BOL_Match                decimal(15, 0)   NULL
        , Ord_Has_Back_Order                     smallint         NOT NULL
        , Ord_Back_Order_Orig_Ord_Key            decimal(15, 0)   NULL
        , Ord_Back_Order_Key                     decimal(15, 0)   NULL
        , Ord_Suppress_Invc_Fees                 smallint         NOT NULL
        , Ord_Prev_Load_Key                      decimal(15, 0)   NULL
        , Ord_DSPayMethod_Key                    decimal(15, 0)   NULL
        , Ord_BankAcct_LastDigits                varchar(4)       NULL
        , Ord_DigitalSeal_Status                 tinyint          NOT NULL
        , Ord_UUID                               varchar(40)      NULL
        , Ord_Valor_1                            varchar(40)      NULL
        , Ord_Atributo_1                         varchar(255)     NULL
        , Ord_Valor_2                            varchar(40)      NULL
        , Ord_Atributo_2                         varchar(255)     NULL
        , Ord_TransferGL_Posted                  tinyint          NOT NULL
        , Ord_Posted_Using_TransFerPricing       bit              NULL
        , Ord_Buyback_Notes                      varchar(255)     NULL
        , Ord_Is_Mult_Ord                        bit              NOT NULL
        , ts                                     rowversion       NULL
        , Ord_MOIBatch_Key                       decimal(15, 0)   NULL
        , Ord_SplitNatAcct_Linked_Ord_Key        decimal(15, 0)   NULL
        , Ord_Is_SplitNatAcct_Ord                bit              NOT NULL
        , Ord_SplitNatAcct_Linked_Ord_CustLocKey decimal(15, 0)   NULL
        , Ord_Ownership_TransferAt_Origin        bit              NOT NULL
        , Ord_Buyback_Mass_Exported              bit              NOT NULL
        , Ord_Gen_Invoices                       bit              NOT NULL
        , Ord_Vehicle_Profit_Site_Key            decimal(15, 0)   NULL
        , Ord_Est_Reserve_Date                   smalldatetime    NULL
        , Ord_Est_RunOut_Date                    smalldatetime    NULL
        , Ord_Sch_Deliv_End_DateTime             smalldatetime    NULL
        , Ord_Sch_Deliv_Promised                 bit              NOT NULL
        , Ord_Is_Urgent                          bit              NOT NULL
        , Ord_Price_Date_Basis                   smallint         NOT NULL
        , Ord_Freight_Date_Basis                 smallint         NOT NULL
        , Ord_Layered_Inv_CostReval_Status       bit              NOT NULL
        , Ord_Budget                             bit              NOT NULL
        , Ord_BBSeason_Key                       decimal(15, 0)   NULL
        , Ord_OrdOriginal_Key                    decimal(15, 0)   NULL
        , Ord_OrdCredit_Key                      decimal(15, 0)   NULL
        , Ord_OrdRebill_Key                      decimal(15, 0)   NULL
        , Ord_SendCreditAndRebill_Invoice_Option tinyint          NOT NULL
        , Ord_COD_Last_OrdByType                 smallint         NOT NULL
        , Ord_COD_Last_OrdByType_Ord_Key         decimal(15, 0)   NULL
        , Ord_COD_Last_OrdByType_Amt             decimal(12, 2)   NOT NULL
        , Ord_OrigBuyBack_Ord_Key                decimal(15, 0)   NULL
        , Ord_Terms_Override                     tinyint          NOT NULL
        , Ord_CreditReasonCode_Key               decimal(15, 0)   NULL
        , Ord_Is_Ovrd_MerchAcct                  smallint         NOT NULL
        , Ord_Ovrd_MerchAcct_Key                 decimal(15, 0)   NULL
        , Clone_LoadDtmUtc                       datetime2(3)     NOT NULL
    );
END;
GO
