CREATE DATABASE IF NOT EXISTS pandemic;
USE pandemic;

SELECT COUNT(*) AS total_rows
FROM infectious_cases;

DROP TABLE IF EXISTS infectious_cases_normalized;
DROP TABLE IF EXISTS entities;

CREATE TABLE entities (
    id INT AUTO_INCREMENT PRIMARY KEY,
    entity TEXT,
    code TEXT,
    UNIQUE KEY unique_entity_code (entity(255), code(255))
);

INSERT INTO entities (entity, code)
SELECT DISTINCT Entity, Code
FROM infectious_cases
WHERE Entity IS NOT NULL
  AND Code IS NOT NULL;

CREATE TABLE infectious_cases_normalized (
    id INT AUTO_INCREMENT PRIMARY KEY,
    entity_id INT NOT NULL,
    Year INT,
    Number_yaws TEXT,
    polio_cases INT,
    cases_guinea_worm INT,
    Number_rabies TEXT,
    Number_malaria TEXT,
    Number_hiv TEXT,
    Number_tuberculosis TEXT,
    Number_smallpox TEXT,
    Number_cholera_cases TEXT,
    CONSTRAINT fk_entity
        FOREIGN KEY (entity_id) REFERENCES entities(id)
);

INSERT INTO infectious_cases_normalized (
    entity_id,
    Year,
    Number_yaws,
    polio_cases,
    cases_guinea_worm,
    Number_rabies,
    Number_malaria,
    Number_hiv,
    Number_tuberculosis,
    Number_smallpox,
    Number_cholera_cases
)
SELECT
    e.id,
    ic.Year,
    ic.Number_yaws,
    ic.polio_cases,
    ic.cases_guinea_worm,
    ic.Number_rabies,
    ic.Number_malaria,
    ic.Number_hiv,
    ic.Number_tuberculosis,
    ic.Number_smallpox,
    ic.Number_cholera_cases
FROM infectious_cases ic
JOIN entities e
    ON ic.Entity = e.entity
   AND ic.Code = e.code;

SELECT * FROM entities LIMIT 10;

SELECT * FROM infectious_cases_normalized LIMIT 10;

SELECT
    e.id AS entity_id,
    e.entity,
    e.code,
    AVG(CAST(icn.Number_rabies AS DECIMAL(20,2))) AS avg_rabies,
    MIN(CAST(icn.Number_rabies AS DECIMAL(20,2))) AS min_rabies,
    MAX(CAST(icn.Number_rabies AS DECIMAL(20,2))) AS max_rabies,
    SUM(CAST(icn.Number_rabies AS DECIMAL(20,2))) AS sum_rabies
FROM infectious_cases_normalized icn
JOIN entities e
    ON icn.entity_id = e.id
WHERE icn.Number_rabies IS NOT NULL
  AND TRIM(icn.Number_rabies) <> ''
GROUP BY e.id, e.entity, e.code
ORDER BY avg_rabies DESC
LIMIT 10;

SELECT
    Year,
    STR_TO_DATE(CONCAT(Year, '-01-01'), '%Y-%m-%d') AS first_day_of_year,
    CURDATE() AS today_date,
    TIMESTAMPDIFF(
        YEAR,
        STR_TO_DATE(CONCAT(Year, '-01-01'), '%Y-%m-%d'),
        CURDATE()
    ) AS year_difference
FROM infectious_cases_normalized
LIMIT 10;

DROP FUNCTION IF EXISTS year_diff_from_current;

DELIMITER //

CREATE FUNCTION year_diff_from_current(input_year INT)
RETURNS INT
DETERMINISTIC
BEGIN
    DECLARE result INT;

    SET result = TIMESTAMPDIFF(
        YEAR,
        STR_TO_DATE(CONCAT(input_year, '-01-01'), '%Y-%m-%d'),
        CURDATE()
    );

    RETURN result;
END //

DELIMITER ;

SELECT
    Year,
    year_diff_from_current(Year) AS year_difference
FROM infectious_cases_normalized
LIMIT 10;
