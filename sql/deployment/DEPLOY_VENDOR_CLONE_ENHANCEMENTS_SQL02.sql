USE [PDI_PricingLink];
GO

:setvar RootDir "."

:r ..\tables\tbl_PDI_Vendors_Clone.sql
:r ..\procedures\sp_PDI_Vendors_Clone_SYNC.sql

PRINT 'Vendor clone enhancements deployed.';
GO
