# pdi-clone-core

Canonical home for PDI clone sync artifacts shared across pipelines.

## Included Artifacts

- `sql/procedures/sp_PDI_AllClones_Register.sql`
- `sql/procedures/sp_PDI_AllClones_List.sql`
- `sql/procedures/sp_PDI_AllClones_SYNC.sql`
- `sql/procedures/sp_PDI_Vendors_Clone_SYNC.sql`
- `sql/tables/tbl_PDI_Vendors_Clone.sql`
- `sql/deployment/DEPLOY_VENDOR_CLONE_ENHANCEMENTS_SQL02.sql`

## Scope

This package currently seeds the orchestrator procedures from SQL-02 and includes the vendor clone enhancements required for carrier-name translation:

- Adds vendor class/type columns to `dbo.PDI_Vendors_Clone`
- Populates class/type labels from source lookups (`Vendor_Classes`, `Vendor_Types`)
- Keeps `sp_PDI_AllClones_SYNC` compatible with the enhanced vendor clone sync

## Deploy (SQL-02)

From repo root:

```powershell
sqlcmd -S PDI-SQL-02 -d PDI_PricingLink -E -b -i ".\sql\deployment\DEPLOY_VENDOR_CLONE_ENHANCEMENTS_SQL02.sql"
```

## Notes

- `seed-from-db/` contains raw extracted definitions from live SQL-02 used to bootstrap this repo.
- Additional clone tables/procs can be appended here as they are moved under source control.
