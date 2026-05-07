# pdi-clone-core

Canonical home for all PDI clone sync artifacts shared across pipelines.
Target database: **PDI-SQL-02 / PDI_PricingLink**.
Source of truth: **PDI-SQL-01 / PDICompany_2386_01** (accessed via linked-server four-part naming).

---

## Orchestration Procs (`sql/procedures/`)

| File | Object | Purpose |
|---|---|---|
| `sp_PDI_AllClones_Register.sql` | `dbo.sp_PDI_AllClones_Register` | Registers or updates a clone table in the clone registry |
| `sp_PDI_AllClones_List.sql` | `dbo.sp_PDI_AllClones_List` | Reports all `*_Clone` tables with row counts and last sync timestamp |
| `sp_PDI_AllClones_SYNC.sql` | `dbo.sp_PDI_AllClones_SYNC` | Orchestrates full sync across all registered clones |
| `sp_PDI_FIVC_Vendor_Clone_SYNC.sql` | `dbo.sp_PDI_FIVC_Vendor_Clone_SYNC` | Syncs `PDI_FIVC_Vendor_Clone` from local SQL-02 views |
| `sp_PDI_Order_Details_Fuel_Clone_SYNC.sql` | `dbo.sp_PDI_Order_Details_Fuel_Clone_SYNC` | Windowed 90-day sync of `PDI_Order_Details_Fuel_Clone` from SQL-01 (runs after Orders step) |
| `sp_PDI_Vendors_Clone_SYNC.sql` | `dbo.sp_PDI_Vendors_Clone_SYNC` | Syncs `PDI_Vendors_Clone` from SQL-01 with class/type label joins |

---

## Clone Tables (`sql/tables/`)

All tables reside in `dbo` on **PDI-SQL-02 / PDI_PricingLink**.
Discovery is convention-based: `sp_PDI_AllClones_List` scans `sys.tables WHERE name LIKE '%[_]Clone'`.

| File | Table | Rows (approx.) | Notes |
|---|---|---|---|
| `tbl_PDI_CITT_Axxis_Grav_PDI_Products_Clone.sql` | `PDI_CITT_Axxis_Grav_PDI_Products_Clone` | ~58 | Axxis→PDI/Gravitate product xref |
| `tbl_PDI_CITT_Axxis_Grav_PDI_Terminals_Clone.sql` | `PDI_CITT_Axxis_Grav_PDI_Terminals_Clone` | ~90 | Axxis→PDI/Gravitate terminal xref |
| `tbl_PDI_CITT_Axxis_Grav_PDI_Vend_FIVC_Clone.sql` | `PDI_CITT_Axxis_Grav_PDI_Vend_FIVC_Clone` | ~53 | Axxis→PDI/Gravitate supplier xref |
| `tbl_PDI_Customer_Locations_Clone.sql` | `PDI_Customer_Locations_Clone` | ~66K | Customer delivery location master |
| `tbl_PDI_Customers_Clone.sql` | `PDI_Customers_Clone` | ~41K | Customer master |
| `tbl_PDI_Drivers_Clone.sql` | `PDI_Drivers_Clone` | ~521 | Driver master (batch load pattern) |
| `tbl_PDI_FIVC_Vendor_Clone.sql` | `PDI_FIVC_Vendor_Clone` | ~262 | Fuel contract / vendor join |
| `tbl_PDI_Fuel_Costs_Clone.sql` | `PDI_Fuel_Costs_Clone` | ~7.6M | Fuel cost records (batch load pattern) |
| `tbl_PDI_Order_Details_Fuel_Clone.sql` | `PDI_Order_Details_Fuel_Clone` | ~rolling 90d | Fuel delivery line items (windowed; 80 cols, `OrdFuel_Key` PK, IX on `OrdFuel_Ord_Key`) |
| `tbl_PDI_Orders_Clone.sql` | `PDI_Orders_Clone` | ~23K | Order header records (batch load pattern) |
| `tbl_PDI_Products_Clone.sql` | `PDI_Products_Clone` | ~195 | Product master |
| `tbl_PDI_SI_Users_Clone.sql` | `PDI_SI_Users_Clone` | ~379 | SI user master (batch load pattern) |
| `tbl_PDI_Sites_Clone.sql` | `PDI_Sites_Clone` | ~1K | Site/warehouse master (batch load pattern) |
| `tbl_PDI_Terminals_Clone.sql` | `PDI_Terminals_Clone` | ~3.2K | Terminal master |
| `tbl_PDI_Trucks_Clone.sql` | `PDI_Trucks_Clone` | ~470 | Vehicle master (batch load pattern) |
| `tbl_PDI_Vendors_Clone.sql` | `PDI_Vendors_Clone` | ~5.2K | Vendor master with class/type labels |

**Batch load pattern** = table uses `Clone_Load_Dtm` or `Clone_LoadDtmUtc` / `Clone_LoadBatchId` columns instead of `Sync_Dtm`. These are loaded by a separate pipeline, not the AllClones_SYNC orchestrator.

---

## Deploy Instructions

Deploy any file individually using `sqlcmd -i`:

```powershell
# Example — deploy or update the Vendors SYNC proc
sqlcmd -S PDI-SQL-02 -d PDI_PricingLink -E -i ".\sql\procedures\sp_PDI_Vendors_Clone_SYNC.sql"

# Example — create a table (idempotent — uses IF OBJECT_ID IS NULL guard)
sqlcmd -S PDI-SQL-02 -d PDI_PricingLink -E -i ".\sql\tables\tbl_PDI_Vendors_Clone.sql"
```

All proc scripts use `CREATE OR ALTER` — safe to re-run on existing objects.

---

## Clone Health Check

```sql
EXEC dbo.sp_PDI_AllClones_List;
```

Returns: `SchemaName`, `TableName`, `Rows`, `Max_Sync_Dtm`, `Max_Sync_Dtm_Pacific`, `CreateDate`, `ModifyDate`.
Tables with `NULL` for `Max_Sync_Dtm` use the batch load pattern — their sync timestamp is tracked differently.

---

## Adding a New Clone Table

See forge skill candidate `Sql.addCloneTable` in
`csl-pricing-supply/semantic-index/AI-primitives-registry/forge_skills_registry.md`.

Quick checklist:
1. Pull column schema from `sys.columns` on SQL-01.
2. Create `sql/tables/tbl_<TableName>.sql` (idempotent, `IF OBJECT_ID IS NULL` guard).
3. Create `sql/procedures/sp_PDI_<ShortName>_Clone_SYNC.sql` (`CREATE OR ALTER`, truncate-and-reload).
4. Deploy both via `sqlcmd -i`.
5. Register: `EXEC dbo.sp_PDI_AllClones_Register ...`
6. Verify: `EXEC dbo.sp_PDI_AllClones_List` — confirm `Rows > 0` and `Max_Sync_Dtm` is populated.

