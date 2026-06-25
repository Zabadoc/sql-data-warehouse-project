/* 
============================================================
Database en schemas maken
============================================================
Doel van het script:
    Dit script maakt een nieuwe database genaamd 'DataWarehouse' aan nadat gecontroleerd is of deze al bestaat. 
    Als de database bestaat, wordt deze verwijderd en opnieuw aangemaakt. Daarnaast zet het script drie schema's 
    op binnen de database: 'bronze', 'silver' en 'gold'.

Waarschuiwing:
    Het uitvoeren van dit script zal de hele 'DataWarehouse'-database verwijderen als deze bestaat. 
    Alle gegevens in de database worden permanent gewist. Wees voorzichtig 
    en zorg dat je de juiste back-ups hebt voordat je dit script uitvoert.
*/

USE master;
GO

-- Verwijder en maak de 'DataWarehouse' database opnieuw aan
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DataWarehouse')
BEGIN 
    ALTER DATABASE DataWarehouse SET SINGLE USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE DataWarehouse;
END;
GO

-- Maak de 'DataWarehouse' Database
CREATE DATABASE DataWarehouse;
GO

USE DataWarehouse;
GO

-- Maak Schema's
CREATE SCHEMA bronze;
GO

CREATE SCHEMA silver;
GO

CREATE SCHEMA gold;
GO
