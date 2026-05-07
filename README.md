# pdi-clone-core

Canonical home for all PDI clone sync artifacts shared across pipelines.
Target database: **PDI-SQL-02 / PDI_PricingLink**.
Source of truth: **PDI-SQL-01 / PDICompany_2386_01** (accessed via linked-server four-part naming).

---

## Orchestration & SYNC Procs (`sql/procedures/`)

### Orchestration & Registry
| File | Object | Purpose |
|---|---|---|
| `sp_PDI_AllClones_Register.sql` | `dbo.sp_PDI_AllClones_Register` | Registers or updates a clone table in the clone registry |
| `sp_PDI_AllClones_List.sql` | `dbo.sp_PDI_AllClones_List` | Reports all `*_Clone` tables with row counts and last sync timestamp |
| `sp_PDI_AllClones_SYNC.sql` | `dbo.sp_PDI_AllClones_SYNC` | Orchestrates full sync across all registered clones |

### Tier-1 Core SYNC Procs (D2 - 2026-05-07)
| File | Object | Pattern | Notes |
|---|---|---|---|
| `sp_PDI_Customer_Loc_Attribute_Assignments_Clone_SYNC.sql` | `dbo.sp_PDI_Customer_Loc_Attribute_Assignments_Clone_SYNC` | TRUNCATE+INSERT | Customer location attributes; wired into AllClones_SYNC |
| `sp_PDI_Customers_SYNC.sql` | `dbo.sp_PDI_Customers_SYNC` | TRUNCATE+INSERT | Customer master |
| `sp_PDI_Customer_Locations_SYNC.sql` | `dbo.sp_PDI_Customer_Locations_SYNC` | TRUNCATE+INSERT | Customer delivery locations with State lookup |
| `sp_PDI_Drivers_SYNC.sql` | `dbo.sp_PDI_Drivers_SYNC` | TRUNCATE+INSERT | Driver master; includes `Sync_Dtm` staleness tracking |
| `sp_PDI_Orders_SYNC.sql` | `dbo.sp_PDI_Orders_SYNC` | TRUNCATE+INSERT (windowed) | Order headers, 90-day rolling window scope |
| `sp_PDI_Products_SYNC.sql` | `dbo.sp_PDI_Products_SYNC` | TRUNCATE+INSERT | Product master |
| `sp_PDI_Site_Tank_Dates_Clone_SYNC.sql` | `dbo.sp_PDI_Site_Tank_Dates_Clone_SYNC` | TRUNCATE+INSERT | Site tank date records; required for PE-021 export pre-check |
| `sp_PDI_Site_Tank_Details_Clone_SYNC.sql` | `dbo.sp_PDI_Site_Tank_Details_Clone_SYNC` | TRUNCATE+INSERT | Tank→product mapping; required for PE-021 export pre-check |
| `sp_PDI_Sites_SYNC.sql` | `dbo.sp_PDI_Sites_SYNC` | TRUNCATE+INSERT | Site/warehouse master |
| `sp_PDI_Terminals_SYNC.sql` | `dbo.sp_PDI_Terminals_SYNC` | TRUNCATE+INSERT | Terminal master |
| `sp_PDI_Vehicles_SYNC.sql` | `dbo.sp_PDI_Vehicles_SYNC` | TRUNCATE+INSERT | Vehicle/truck master; includes `Sync_Dtm` staleness tracking |

### CITT Integration SYNC Procs (D2 - 2026-05-07)
| File | Object | Pattern | Notes |
|---|---|---|---|
| `sp_PDI_CITT_Axxis_Grav_PDI_Products_SYNC.sql` | `dbo.sp_PDI_CITT_Axxis_Grav_PDI_Products_SYNC` | TRUNCATE+INSERT | Axxis→PDI product xref |
| `sp_PDI_CITT_Axxis_Grav_PDI_Terminals_SYNC.sql` | `dbo.sp_PDI_CITT_Axxis_Grav_PDI_Terminals_SYNC` | TRUNCATE+INSERT | Axxis→PDI terminal xref |
| `sp_PDI_CITT_Axxis_Grav_PDI_Vend_FIVC_SYNC.sql` | `dbo.sp_PDI_CITT_Axxis_Grav_PDI_Vend_FIVC_SYNC` | TRUNCATE+INSERT | Axxis→PDI vendor xref |

### Fuel Costs SYNC Family (D4 - 2026-05-07)
| File | Object | Pattern | Purpose |
|---|---|---|---|
| `sp_PDI_Fuel_Costs_Clone_SYNC_Run.sql` | `dbo.sp_PDI_Fuel_Costs_Clone_SYNC_Run` | TRUNCATE+INSERT | Full-replace entry point; called by AllClones_SYNC |
| `sp_PDI_Fuel_Costs_Clone_SYNC_CatchUp.sql` | `dbo.sp_PDI_Fuel_Costs_Clone_SYNC_CatchUp` | MERGE (upsert) | Incremental catch-up (configurable window, default 7 days) |
| `sp_PDI_Fuel_Costs_Clone_SYNC_HealMissing.sql` | `dbo.sp_PDI_Fuel_Costs_Clone_SYNC_HealMissing` | INSERT (NOT EXISTS) | Backfill missing records within 30-day window |
| `sp_PDI_Fuel_Costs_Clone_SYNC_ReconcileDeletes.sql` | `dbo.sp_PDI_Fuel_Costs_Clone_SYNC_ReconcileDeletes` | DELETE (NOT EXISTS) | Remove orphaned records |
| `sp_PDI_Fuel_Costs_Clone_SYNC_Upsert.sql` | `dbo.sp_PDI_Fuel_Costs_Clone_SYNC_Upsert` | MERGE (upsert) | Full upsert on all current records |

### Legacy SYNC Procs
| File | Object | Pattern | Notes |
|---|---|---|---|
| `sp_PDI_FIVC_Vendor_Clone_SYNC.sql` | `dbo.sp_PDI_FIVC_Vendor_Clone_SYNC` | TRUNCATE+INSERT | Syncs `PDI_FIVC_Vendor_Clone` from local SQL-02 views |
| `sp_PDI_Order_Details_Fuel_Clone_SYNC.sql` | `dbo.sp_PDI_Order_Details_Fuel_Clone_SYNC` | TRUNCATE+INSERT (windowed) | Windowed 90-day sync of fuel delivery line items; runs after Orders step |
| `sp_PDI_Vendors_Clone_SYNC.sql` | `dbo.sp_PDI_Vendors_Clone_SYNC` | TRUNCATE+INSERT | Syncs `PDI_Vendors_Clone` from SQL-01 with class/type label joins |
| `sp_PDI_SI_Users_SYNC.sql` | `dbo.sp_PDI_SI_Users_SYNC` | TRUNCATE+INSERT | SI user master; includes `Sync_Dtm` staleness tracking |

---

## Clone Tables (`sql/tables/`)

All tables reside in `dbo` on **PDI-SQL-02 / PDI_PricingLink**.
Discovery is convention-based: `sp_PDI_AllClones_List` scans `sys.tables WHERE name LIKE '%[_]Clone'`.

| File | Table | Rows (approx.) | Staleness Column | Notes |
|---|---|---|---|---|
| `tbl_PDI_CITT_Axxis_Grav_PDI_Products_Clone.sql` | `PDI_CITT_Axxis_Grav_PDI_Products_Clone` | ~58 | — | Axxis→PDI/Gravitate product xref |
| `tbl_PDI_CITT_Axxis_Grav_PDI_Terminals_Clone.sql` | `PDI_CITT_Axxis_Grav_PDI_Terminals_Clone` | ~90 | — | Axxis→PDI/Gravitate terminal xref |
| `tbl_PDI_CITT_Axxis_Grav_PDI_Vend_FIVC_Clone.sql` | `PDI_CITT_Axxis_Grav_PDI_Vend_FIVC_Clone` | ~53 | — | Axxis→PDI/Gravitate supplier xref |
| `tbl_PDI_Customer_Locations_Clone.sql` | `PDI_Customer_Locations_Clone` | ~66K | — | Customer delivery location master |
| `tbl_PDI_Customers_Clone.sql` | `PDI_Customers_Clone` | ~41K | — | Customer master |
| `tbl_PDI_Drivers_Clone.sql` | `PDI_Drivers_Clone` | ~521 | `Sync_Dtm` (D5) | Driver master; batch load pattern |
| `tbl_PDI_FIVC_Vendor_Clone.sql` | `PDI_FIVC_Vendor_Clone` | ~262 | — | Fuel contract / vendor join |
| `tbl_PDI_Fuel_Costs_Clone.sql` | `PDI_Fuel_Costs_Clone` | ~7.6M | `Sync_Dtm` | Fuel cost records; batch load pattern; includes D4 SYNC family |
| `tbl_PDI_Order_Details_Fuel_Clone.sql` | `PDI_Order_Details_Fuel_Clone` | ~rolling 90d | `Sync_Dtm` | Fuel delivery line items (windowed; 80 cols, `OrdFuel_Key` PK, IX on `OrdFuel_Ord_Key`) |
| `tbl_PDI_Orders_Clone.sql` | `PDI_Orders_Clone` | ~23K | — | Order header records; batch load pattern |
| `tbl_PDI_Products_Clone.sql` | `PDI_Products_Clone` | ~195 | — | Product master |
| `tbl_PDI_SI_Users_Clone.sql` | `PDI_SI_Users_Clone` | ~379 | `Sync_Dtm` (D5) | SI user master; batch load pattern |
| `tbl_PDI_Sites_Clone.sql` | `PDI_Sites_Clone` | ~1K | — | Site/warehouse master; batch load pattern |
| `tbl_PDI_Site_Tank_Dates_Clone.sql` | `PDI_Site_Tank_Dates_Clone` | ~varies | `Sync_Dtm` | Site tank date records; PE-021 site→tank resolution |
| `tbl_PDI_Site_Tank_Details_Clone.sql` | `PDI_Site_Tank_Details_Clone` | ~varies | `Sync_Dtm` | Tank→product mapping; PE-021 tank product validation |
| `tbl_PDI_Terminals_Clone.sql` | `PDI_Terminals_Clone` | ~3.2K | — | Terminal master |
| `tbl_PDI_Trucks_Clone.sql` | `PDI_Trucks_Clone` | ~470 | `Sync_Dtm` (D5) | Vehicle master; batch load pattern |
| `tbl_PDI_Vendors_Clone.sql` | `PDI_Vendors_Clone` | ~5.2K | — | Vendor master with class/type labels |

**Batch load pattern** = table uses `Clone_Load_Dtm` or `Clone_LoadDtmUtc` / `Clone_LoadBatchId` columns instead of `Sync_Dtm`. These are loaded by a separate pipeline, not the AllClones_SYNC orchestrator.

**Sync_Dtm column** = Added during D5 staleness tracking initiative (2026-05-07). Populated on each SYNC proc run to enable operational visibility of clone freshness. Query `sp_PDI_AllClones_List` to monitor `Max_Sync_Dtm` timestamps.

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

