/* 
=======================================================================================
Kwaliteitscontrole
=======================================================================================
Doel van het script:
  Dit script voert diverse kwaliteitscontroles uit op de consistentie, nauwkeurigheid 
  en standaardisatie van gegevens in de 'silver'-schema's. 
Het omvat controles op:
  - Null- of dubbele primaire sleutels.
  - Ongewenste spaties in tekenreeksvelden.
  - Standaardisatie en consistentie van gegevens.
  - Ongeldige datumbereiken en -volgordes.
  - Consistentie van gegevens tussen gerelateerde velden.

Gebruiksaanwijzing:
  - Voer deze controles uit na het laden van de gegevens in de Silver Layer.
  - Onderzoek en los eventuele afwijkingen op die tijdens de controles worden gevonden.
=======================================================================================
*/

-- ==========================================================================
-- Controleerd 'silver.crm_cust_info'
-- ==========================================================================
-- Controleer op NULLs of duplicaten in de primary key.
-- Verwachting: Geen resultaten
SELECT
  cst_id,
  COUNT(*)
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL;

-- Controleer op lege ruimtes.
-- Verwachting: Geen resultaten.
SELECT 
  cst_key
FROM silver.crm_cust_info
WHERE cst_key != TRIM(cst_key);

-- Gegevens & Standaardisatie en consistentie.
SELECT DISTINCT
  cst_marital_status
FROM silver.crm_cust_info;

-- ==========================================================================
-- Controleerd 'silver.crm_prd_info'
-- ==========================================================================
-- Controleer op NULLs of duplicaten in de primary key.
-- Verwachting: Geen resultaten
SELECT
  prd_id,
  COUNT(*)
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR cst_id IS NULL;

-- Controleer op lege ruimtes.
-- Verwachting: Geen resultaten.
SELECT 
  prd_nm
FROM silver.crm_prd_info
WHERE prd_nm != TRIM(prd_nmy);

-- Controleer op NULLs- of negatieve waarden in de cost.
-- Verwachting: Geen resultaten.
SELECT
  prd_cost
FROM silver.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL;

-- Gegevens & Standaardisatie en consistentie.
SELECT DISTINCT
  prd_line
FROM silver.crm_prd_info;

-- Controleer op ongeldige datumbestellingen (Start Datum > Eind Datum).
-- Verwachting: Geen resultaten.
SELECT
  *
FROM silver.crm_prd_info
WHERE prd_end_dt < prd_start_dt;

-- ==========================================================================
-- Controleerd 'silver.crm_sales_details'
-- ==========================================================================
-- Controleer op ongeldige datums.
-- Verwachting: Geen ongeldige datums.
SELECT
  NULLIF(sls_due_dt, 0) AS sls_due_dt
FROM bronze.crm_sales_details
WHERE sls_due_dt <= 0
  OR LEN(sls_due_dt) != 8
  OR sls_due_dt > GETDATE()
  OR sls_due_dt < 19000101; -- de datum wanneer het bedrijf is begonnen.

-- Controleer op ongeldige datumbestellingen (Besteldatum > verzend-/vervaldatum).
-- Verwachting: Geen ongeldige datums.
SELECT
  *
FROM silver.crm_sales_details
WHERE sls_order_dt > sls_ship_dt
  OR sls_order_dt > sls_due_dt;

-- Controleer de consistentie van de gegevens: tussen verkoop, hoeveelheid en prijs.
-- Verwachting: Geen resultaten.
-- >> Waarden mogen niet NULL, nul of negatief zijn.
SELECT DISTINCT
  sls_sales,
  sls_quantity,
  sls_price
FROM silver.crm_sales_details
WHERE sls_sales != sls_quantity * sls_price
  OR sls_sales IS NULL 
  OR sls_quantity IS NULL 
  OR sls_price IS NULL
  OR sls_sales <=0 
  OR sls_quantity <=0 
  OR sls_price <=0
ORDER BY sls_sales, sls_quantity, sls_price;

-- ==========================================================================
-- Controleerd 'silver.erp_cust_az12'
-- ==========================================================================
-- Identiviseer datums die buiten bereik zijn.
-- Verwachting: Geboortedatum tussen 120 jaar geleden en vandaag.
SELECT DISTINCT
	bdate
FROM silver.erp_cust_az12
WHERE bdate < DATEADD(YEAR, -120, GETDATE()) OR bdate > GETDATE()

-- Gegevens & Standaardisatie en consistentie.
SELECT DISTINCT
  gen
FROM silver.erp_cust_az12;

-- ==========================================================================
-- Controleerd 'silver.erp_loc_a101'
-- ==========================================================================
-- Gegevens & Standaardisatie en consistentie.
SELECT DISTINCT
  cntry
FROM silver.erp_loc_az12
ORDER BY cntry;

-- ==========================================================================
-- Controleerd 'silver.erp_px_cat_g1v2'
-- ==========================================================================
-- Controleer op lege ruimtes.
-- Verwachting: Geen resultaten.
SELECT 
  *
FROM silver.erp_px_cat_g1v2
WHERE cat != TRIM(cat)
  OR subcat != TRIM(subcat)
  OR maintenance != TRIM(maintenance);

-- Gegevens & Standaardisatie en consistentie.
SELECT DISTINCT
  maintenance
FROM silver.erp_px_cat_g1v2
