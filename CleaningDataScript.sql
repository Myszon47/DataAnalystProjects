--- Cleaning Data in SQL


--- Standarize Date Format

SELECT SaleDate, CONVERT(Date,SaleDate)
FROM Housing;

UPDATE Housing
SET SaleDate = CONVERT(Date,SaleDate);

SELECT SaleDate
FROM Housing;

ALTER TABLE Housing
ADD date_only DATE;

UPDATE Housing
SET date_only = CONVERT(Date,SaleDate);

SELECT date_only
FROM Housing;

ALTER TABLE Housing
DROP COLUMN SaleDate;

EXEC sp_rename 'Housing.date_only', 'SaleDate', 'COLUMN';


-- Populate Property Address data

SELECT PropertyAddress
FROM Housing
WHERE PropertyAddress is NULL

SELECT *
FROM Housing
WHERE PropertyAddress is NULL

SELECT ParcelID, PropertyAddress
FROM Housing
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Housing a
JOIN Housing b
ON a.ParcelID = b.ParcelID AND
a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Housing a
JOIN Housing b
ON a.ParcelID = b.ParcelID AND
a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL


-- Breaking out Address into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM Housing

SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as Address_2
FROM Housing

ALTER TABLE Housing
ADD PropertySplitAddress NVARCHAR(255);

UPDATE Housing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1);

ALTER TABLE Housing
ADD PropertySplitCity NVARCHAR(255);

UPDATE Housing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress));

SELECT *
FROM Housing


SELECT OwnerAddress
FROM Housing

SELECT PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)
FROM Housing

ALTER TABLE Housing
ADD OwnerSplitAddress NVARCHAR(255);

UPDATE Housing
SET OwnerSplitAddress =  PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3);

ALTER TABLE Housing
ADD OwnerSplitCity NVARCHAR(255);

UPDATE Housing
SET OwnerSplitCity =  PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2);

ALTER TABLE Housing
ADD OwnerSplitState NVARCHAR(255);

UPDATE Housing
SET OwnerSplitState =  PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1);

SELECT *
FROM Housing


-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT SoldAsVacant 
FROM Housing


SELECT SoldAsVacant, 
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM Housing

UPDATE Housing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END;

SELECT DISTINCT SoldAsVacant 
FROM Housing

-- Remove Duplicates

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
		PARTITION BY ParcelID,
						PropertyAddress,
						SalePrice,
						SaleDate,
						LegalReference
						ORDER BY UniqueID) row_num
FROM Housing
)
DELETE
FROM RowNumCTE
WHERE row_num > 1

SELECT *,
	ROW_NUMBER() OVER (
		PARTITION BY ParcelID,
						PropertyAddress,
						SalePrice,
						SaleDate,
						LegalReference
						ORDER BY UniqueID) row_num
FROM Housing


-- Delete Unused Columns

SELECT *
FROM Housing

ALTER TABLE Housing
DROP COLUMN OwnerAddress, PropertyAddress