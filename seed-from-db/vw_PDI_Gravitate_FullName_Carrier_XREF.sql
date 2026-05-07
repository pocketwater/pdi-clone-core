CREATE   VIEW dbo.vw_PDI_Gravitate_FullName_Carrier_XREF
AS
SELECT TOP (100) PERCENT TD.TransTableDetail_Trans_From AS [.Long_Name], TD.TransTableDetail_Trans_To AS SCAC, TD.TransTableDetail_Description AS FIFC_Vend_ID
FROM   [PDI-SQL-01].PDICompany_2386_01.dbo.Translation_Table_Detail AS TD INNER JOIN
             [PDI-SQL-01].PDICompany_2386_01.dbo.Translation_Table_Header AS TH ON TD.TransTableDetail_HeaderKey = TH.TransTable_Key
WHERE (TH.TransTable_Description = 'Costs_Grav_FullName_Carrier')
ORDER BY SCAC


