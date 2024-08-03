-- Creating Table and define column data types before importing data
CREATE TABLE nashvilleDB (
	UniqueID int,
	ParcelID FLOAT,	
	LandUse	varchar(50),
	PropertyAddress	varchar(50),
	SaleDate DATE,
	SalePrice int,
	LegalReference int,
	SoldAsVacant varchar(50),
	OwnerName varchar(50),
	OwnerAddress varchar(50),
	Acreage	FLOAT,
	TaxDistrict varchar(50),
	LandValue int,	
	BuildingValue int,	
	TotalValue int,
	YearBuilt int,	
	Bedrooms int,
	FullBath int,
	HalfBat int
);

-- Changing data types
ALTER TABLE nashvilleDB
ALTER COLUMN ParcelID SET DATA TYPE varchar(50);

-- Changing data types
ALTER TABLE nashvilleDB
ALTER COLUMN LegalReference SET DATA TYPE varchar(50);

-- Changing data types
ALTER TABLE nashvilleDB
ALTER COLUMN OwnerName SET DATA TYPE varchar;

-- Changing data types
ALTER TABLE nashvilleDB
ALTER COLUMN OwnerAddress SET DATA TYPE varchar;

-- Changing data types
ALTER TABLE nashvilleDB
ALTER COLUMN SalePrice SET DATA TYPE varchar(50);

--importing csv file
COPY nashvilleDB FROM 'C:\Users\Ani\Downloads\Nashville Housing Data for Data Cleaning_Database.csv' DELIMITER ',' CSV HEADER;

SELECT * FROM nashvilleDB

/*Removing null from property address*/
-- data cleaning
SELECT * FROM nashvilleDB
WHERE propertyaddress is null
ORDER By parcelid

-- Self join for checking if any property address is exists for same parcelid 
SELECT a.uniqueid, a.parcelid, a.propertyaddress, b.parcelid, b.propertyaddress
FROM nashvilleDB AS a
JOIN nashvilleDB AS b
	ON a.parcelid = b.parcelid
	AND a.uniqueid <> b.uniqueid
WHERE a.propertyaddress is NULL

--Removing null from property address
UPDATE nashvilleDB AS a
SET propertyaddress = COALESCE(a.propertyaddress,b.propertyaddress)
FROM nashvilleDB AS b
WHERE a.parcelid = b.parcelid
	AND a.uniqueid <> b.uniqueid
 	AND a.propertyaddress is NULL

/*Breaking property address into address, city, state*/
-- Distributing Owner address in proper way to use it further if required
SELECT owneraddress FROM nashvilleDB

--splitting street, city & state
SELECT
	split_part(owneraddress,',', 1) AS street,
	split_part(owneraddress,',', 2) AS city,
	split_part(owneraddress,',', 3) AS state_usa
FROM nashvilleDB;

--Adding column into the table to accomodate changes 
ALTER TABLE nashvilleDB ADD COLUMN ownerAdd varchar(50);
ALTER TABLE nashvilleDB ADD COLUMN ownerCity varchar(50);
ALTER TABLE nashvilleDB ADD COLUMN ownerState varchar(50);

-- Update the new OwnerAdd column with the street part of the address
UPDATE nashvilleDB
SET ownerAdd = split_part(owneraddress,',', 1);

-- Update the new OwnerCity column with the city part of the address
UPDATE nashvilleDB
SET ownerCity = split_part(owneraddress,',', 2);

-- Update the new OwnerState column with the state part of the address
UPDATE nashvilleDB
SET ownerState = split_part(owneraddress,',', 3);


--Chacking changes
SELECT * FROM nashvilleDB


/*Convert 'SoldAsVacant' column to Yes/No */
--Checking count for all the unique value in the 'SoldAsVacant' column
	
SELECT DISTINCT(soldasvacant), COUNT(soldasvacant)
FROM nashvilleDB
GROUP BY soldasvacant
ORDER By 2

--Checking and convertin y/n to yes/no

UPDATE nashvilleDB 
SET soldasvacant =
	CASE 
		WHEN soldasvacant = 'YES' THEN 'Yes'
		WHEN soldasvacant = 'N' THEN 'No'
	ELSE soldasvacant
	END

/*Removing duplicate records*/
--asin row numbers to detect duplicates as per the columns mentioned in query
SELECT *,
	ROW_NUMBER() OVER(
		PARTITION BY parcelid,
					 propertyaddress,
					 saledate,
					 saleprice,
					 legalreference
		ORDER BY uniqueid
		) AS row_num
FROM nashvilleDB
ORDER BY row_num DESC;

-- Filtering required data
WITH RowNumCTE AS (
	SELECT *,
		ROW_NUMBER() OVER(
			PARTITION BY parcelid,
						 propertyaddress,
						 saledate,
						 saleprice,
						 legalreference
			ORDER BY uniqueid
			) AS row_num
	FROM nashvilleDB
)
SELECT *
FROM RowNumCTE
WHERE row_num >1;

-- Deletin duplicates

WITH RowNumCTE AS (
	SELECT *,
		ROW_NUMBER() OVER(
			PARTITION BY parcelid,
						 propertyaddress,
						 saledate,
						 saleprice,
						 legalreference
			ORDER BY uniqueid
			) AS row_num
	FROM nashvilleDB
)
DELETE FROM nashvilleDB
USING RowNumCTE
WHERE nashvilleDB.uniqueid = RowNumCTE.uniqueid
	AND row_num >1;


--Chacking changes
SELECT COUNT(*) FROM nashvilleDB

SELECT * FROM nashvilleDB

--Deleting unnecessary columns

ALTER TABLE nashvilleDB
DROP COLUMN taxdistrict, 
DROP COLUMN fullbath, 
DROP COLUMN halfbat

SELECT * FROM nashvilleDB










