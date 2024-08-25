CREATE TABLE Nashville_Housing (
    UniqueID INT, 
    ParcelID VARCHAR(20), 
    LandUse	VARCHAR(50), 
    PropertyAddress	VARCHAR(100), 
    SaleDate DATE, 
    SalePrice INT, 
    LegalReference VARCHAR(20), 
    SoldAsVacant VARCHAR(3), 
    OwnerName VARCHAR(100), 
    OwnerAddress VARCHAR(100), 
    Acreage FLOAT, 
    TaxDistrict VARCHAR(30), 
    LandValue INT, 
    BuildingValue INT, 
    TotalValue INT, 
    YearBuilt INT, 
    Bedrooms INT, 
    FullBath INT, 
    HalfBath INT
);

SELECT n_h1.ParcelID, n_h1.PropertyAddress, n_h2.ParcelID,
    n_h2.PropertyAddress
FROM Nashville_Housing n_h1
JOIN Nashville_Housing n_h2
    ON n_h1.ParcelID = n_h2.ParcelID
    AND n_h1.UniqueID <> n_h2.UniqueID
WHERE n_h1.PropertyAddress IS NULL;

-- Populating NULL Property Address values

UPDATE Nashville_Housing a
JOIN Nashville_Housing b 
    ON a.ParcelID = b.ParcelID
    AND a.UniqueID <> b.UniqueID
SET a.PropertyAddress = b.PropertyAddress
WHERE a.PropertyAddress IS NULL;

-- Breaking down PropertyAddress and OwnerAddress columns 
-- into seperate columns for address/city/state

SELECT
SUBSTRING(PropertyAddress, 1, POSITION("," IN PropertyAddress)-1) 
    AS Address,
SUBSTRING(PropertyAddress, POSITION("," IN PropertyAddress)+2, 
    LENGTH(PropertyAddress)) AS City
FROM Nashville_Housing;

ALTER TABLE Nashville_Housing
ADD Property_Address VARCHAR(100);

UPDATE Nashville_Housing
SET Property_Address = 
    SUBSTRING(PropertyAddress, 1, POSITION("," IN PropertyAddress)-1)
;

ALTER TABLE Nashville_Housing
ADD Property_City VARCHAR(50);

UPDATE Nashville_Housing
SET Property_City = 
    SUBSTRING(PropertyAddress, POSITION("," IN PropertyAddress)+2, 
    LENGTH(PropertyAddress))
;

SELECT 
SUBSTRING_INDEX(OwnerAddress, ",", 1) AS Owner_Address,
SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ",", 2), ",", -1) 
    AS Owner_City,
SUBSTRING_INDEX(OwnerAddress, ",", -1) AS Owner_State
FROM Nashville_Housing;

ALTER TABLE Nashville_Housing
ADD Owner_Address VARCHAR(50), ADD Owner_City VARCHAR(50),
ADD Owner_State VARCHAR(5);

UPDATE Nashville_Housing
SET
Owner_Address = SUBSTRING_INDEX(OwnerAddress, ",", 1),
Owner_City = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ",", 2), ",", -1),
Owner_State = SUBSTRING_INDEX(OwnerAddress, ",", -1);

-- Changing Y/N to Yes/No in SoldAsVacant column

UPDATE Nashville_Housing
SET SoldAsVacant = CASE WHEN SoldAsVacant = "Y" THEN "Yes"
                     WHEN SoldAsVacant = "N" THEN "No"
                     ELSE SoldAsVacant
                     END
;

-- Remove Duplicates

DELETE FROM Nashville_Housing
WHERE ParcelID IN(
    SELECT ParcelID
    FROM (
        SELECT *, 
            ROW_NUMBER() OVER(
                PARTITION BY ParcelID,
                            PropertyAddress,
                            SalePrice,
                            SaleDate,
                            LegalReference
                            ORDER BY
                                UniqueID) row_num 
            FROM Nashville_Housing) a
WHERE row_num > 1);

-- Delete unused columns

ALTER TABLE Nashville_Housing
DROP COLUMN PropertyAddress,
DROP COLUMN OwnerAddress;