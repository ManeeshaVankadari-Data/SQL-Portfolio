-- ==========================================
-- World Layoffs Data Cleaning Project
-- Portfolio Script: Data Cleaning & Standardization
-- ==========================================

-- 1. Data Exploration & Staging Table Creation
SELECT * 
FROM layoffs;

-- Create a staging table to preserve raw data
CREATE TABLE staging_layoffs LIKE layoffs;

INSERT INTO staging_layoffs
SELECT * FROM layoffs;

-- 2. Deduplication (Identifying and Removing Duplicates)
WITH Duplicates_CTE AS (
    SELECT *,
           ROW_NUMBER() OVER(
               PARTITION BY company, location, industry, total_laid_off, 
                            percentage_laid_off, `date`, stage, country, funds_raised_millions
           ) AS row_num
    FROM staging_layoffs
)
SELECT * 
FROM Duplicates_CTE
WHERE row_num > 1;

-- Create a secondary staging table to handle row deletions safely
CREATE TABLE `staging_layoffs2` (
  `company` TEXT,
  `location` TEXT,
  `industry` TEXT,
  `total_laid_off` INT DEFAULT NULL,
  `percentage_laid_off` TEXT,
  `date` TEXT,
  `stage` TEXT,
  `country` TEXT,
  `funds_raised_millions` INT DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO staging_layoffs2
SELECT *,
       ROW_NUMBER() OVER(
           PARTITION BY company, location, industry, total_laid_off, 
                        percentage_laid_off, `date`, stage, country, funds_raised_millions
       ) AS row_num
FROM staging_layoffs;

-- Delete identified duplicates
SET SQL_SAFE_UPDATES = 0;

DELETE FROM staging_layoffs2
WHERE row_num > 1;

-- 3. Data Standardization (Text & Categorical Cleansing)
-- Trim whitespaces from company names
UPDATE staging_layoffs2
SET company = TRIM(company);

-- Standardize industry categories (e.g., merging Variations of 'Crypto')
SELECT DISTINCT industry FROM staging_layoffs2 ORDER BY industry;

UPDATE staging_layoffs2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

-- Fix trailing punctuation/typos in country designations
SELECT DISTINCT country FROM staging_layoffs2 ORDER BY country;

UPDATE staging_layoffs2
SET country = REPLACE(country, '.', '')
WHERE country LIKE 'United States%';

-- 4. Date Format Standardization
-- Convert text field to a uniform datetime layout and modify the column type
UPDATE staging_layoffs2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

ALTER TABLE staging_layoffs2
MODIFY COLUMN `date` DATE;

-- 5. Populating Missing Values (Null Handling via Self-Join)
-- Set blank rows to NULL for consistent evaluations
UPDATE staging_layoffs2
SET industry = NULL 
WHERE industry = '';

-- Backfill missing industry data by matching historical company location configurations
UPDATE staging_layoffs2 t1
JOIN staging_layoffs2 t2
    ON t1.company = t2.company
    AND t1.location = t2.location
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
  AND t2.industry IS NOT NULL;

-- 6. Removing Stripped & Irrelevant Records
-- Drop rows where core quantitative values are totally missing
DELETE FROM staging_layoffs2
WHERE total_laid_off IS NULL
  AND percentage_laid_off IS NULL;

-- Remove structural staging metadata columns
ALTER TABLE staging_layoffs2
DROP COLUMN row_num;

-- Final output inspection
SELECT * FROM staging_layoffs2;
