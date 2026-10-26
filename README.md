# Cruise Booking Analytics with dbt Core and DuckDB

A local analytics project using dbt Core, DuckDB, and SQL to turn anonymized cruise booking records into monthly passenger totals and validate key data fields.

## Project overview

This project loads 61 booked passenger records from a CSV seed, builds a monthly aggregation model, and runs three automated data-quality tests. The database runs locally; no paid cloud account is required.

## Tools

- dbt Core
- DuckDB and the dbt-duckdb adapter
- SQL
- Visual Studio Code

## Data preparation

The source was a cruise booking spreadsheet. Preparation was completed before loading the CSV into dbt:

- Ignored row 1 and used row 2 as column headers.
- Retained only records whose status was BOOKED; excluded two cancelled records.
- Replaced passenger names with generic IDs, passenger1 through passenger61.
- Excluded the unused contact columns.
- Standardized booking dates to YYYY-MM-DD.
- Used the first day of each date range, assumed 2026, and filled blank dates from the preceding date entry before filtering records.

Range-based dates are approximations, not exact booking dates. Generic IDs are assigned in retained worksheet order and are not persistent identifiers across reordered weekly snapshots. The original spreadsheet is not required to run this project.

## Project files

```text
cruise_bookings/
  dbt_project.yml
  models/
    monthly_bookings.sql
  seeds/
    cruise_bookings.csv
    bookings_tests.yml
```

The tree shows the files used for this workflow. Default dbt starter examples may also be present; the commands below select only this project's booking resources.

## How it works

1. dbt seed loads the prepared CSV into the cruise_bookings table.
2. monthly_bookings uses ref('cruise_bookings') to declare its dependency on the seed.
3. SQL converts dates to booking months and counts passenger rows.
4. Seed tests check for missing dates, missing passenger IDs, and duplicate passenger IDs.

Each input row represents one booked passenger. Months without bookings are absent from the output.

## Run locally

Install Python and Git, clone or download the repository, and open a PowerShell terminal in the folder containing dbt_project.yml.

Create an environment and install the adapter:

```powershell
py -m venv .venv
.\.venv\Scripts\python.exe -m pip install dbt-duckdb
```

Create or edit your local profile file at `$HOME\.dbt\profiles.yml`. The top-level profile name must match the `profile:` setting in dbt_project.yml. For a profile named cruise_bookings:

```yaml
cruise_bookings:
  target: dev
  outputs:
    dev:
      type: duckdb
      path: cruise_bookings.duckdb
      threads: 1
```

If the folder does not exist, create it first. Keep profiles.yml local and out of the repository.

Run:

```powershell
.\.venv\Scripts\dbt.exe debug
.\.venv\Scripts\dbt.exe seed --select cruise_bookings.csv
.\.venv\Scripts\dbt.exe run --select monthly_bookings
.\.venv\Scripts\dbt.exe test --select "resource_type:seed"
.\.venv\Scripts\dbt.exe show --select monthly_bookings --limit 20
```

The demonstrated environment used dbt Core 1.12.6 and dbt-duckdb 1.11.0. Other versions have not been verified for this project.

## Results

| Booking month | Passenger count |
| --- | ---: |
| February 2026 | 9 |
| March 2026 | 5 |
| April 2026 | 9 |
| May 2026 | 10 |
| June 2026 | 1 |
| September 2026 | 13 |
| October 2026 | 14 |
| **Total** | **61** |

All three booking data tests passed:

- passenger_id: unique
- passenger_id: not_null
- booking_date: not_null

These tests validate those specific conditions; they do not establish that every source value is correct.

## Weekly refresh

Prepare each new spreadsheet using the same rules and replace seeds/cruise_bookings.csv while keeping the filename and columns consistent. Rerun the seed, model, and test commands. If column types change, a seed full refresh may be needed. Spreadsheet conversion is currently manual, not an automated part of this dbt project.

## Repository hygiene

Exclude virtual environments, logs, target files, local database files, personal profiles, and original contact spreadsheets. Suggested .gitignore entries:

```gitignore
.venv/
target/
logs/
dbt_packages/
*.duckdb
*.duckdb.wal
profiles.yml
```

## Skills demonstrated

CSV ingestion using dbt seeds, SQL aggregation, model dependencies with ref(), automated data-quality tests, and local analytics development with DuckDB.
