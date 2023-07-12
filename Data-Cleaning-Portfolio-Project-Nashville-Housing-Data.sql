SELECT *
FROM NashVilleHousingData

-- Standardize Date Format
SELECT SaleDate, SaleDateConverted
FROM NashVilleHousingData

ALTER TABLE NashVilleHousingData
ADD SaleDateConverted Date;

UPDATE NashVilleHousingData
SET SaleDateConverted = CONVERT(date, SaleDate)


-- Populate Property Address data
SELECT PropertyAddress
FROM NashVilleHousingData
WHERE PropertyAddress IS NULL
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
FROM NashVilleHousingData AS a
JOIN NashVilleHousingData AS b
ON a.ParcelID=b.ParcelID
AND a.UniqueID<>b.UniqueID
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL (a.PropertyAddress, b.PropertyAddress)
FROM NashVilleHousingData AS a
JOIN NashVilleHousingData AS b
ON a.ParcelID=b.ParcelID
AND a.UniqueID<>b.UniqueID


--Breaking out Address into Individual Columns (Address, City, State)
SELECT PropertyAddress, PropertySplitAddress, PropertySplitCity
FROM NashVilleHousingData

SELECT PropertyAddress, SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address
,SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+2, LEN(PropertyAddress)) AS City
FROM NashVilleHousingData

ALTER TABLE NashvilleHousingData
ADD PropertySplitAddress varchar(255);

UPDATE NashVilleHousingData
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1);

ALTER TABLE NashvilleHousingData
ADD PropertySplitCity varchar (255);

UPDATE NashVilleHousingData
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+2, LEN(PropertyAddress));

--Spliting Owner Address
SELECT OwnerAddress, OwnerSplitAddress, OwnerSplitCity, OwnerSplitState
FROM NashVilleHousingData

ALTER TABLE NashvilleHousingData
ADD OwnerSplitAddress varchar(255), 
OwnerSplitCity varchar(255),
OwnerSplitState varchar(255);

UPDATE NashVilleHousingData
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)



-- Change Y and N to Yes and No in "Sold as Vacant" field
SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM NashVilleHousingData
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant='Y' THEN 'Yes'
	 WHEN SoldAsVacant='N' THEN 'No'
	 ELSE SoldAsVacant
END
FROM NashVilleHousingData

UPDATE NashVilleHousingData
SET SoldAsVacant = CASE
WHEN SoldAsVacant='Y' THEN 'Yes'
WHEN SoldAsVacant='N' THEN 'No'
ELSE SoldAsVacant
END


-- Remove Duplicates
WITH RowNumCTE AS
(SELECT *, ROW_NUMBER() OVER (PARTITION BY
	ParcelID,
	PropertyAddress,
	SaleDate,
	SalePrice,
	LegalReference
ORDER BY UniqueID) AS row_num
FROM NashVilleHousingData)

SELECT * FROM RowNumCTE


-- Delete Unused Columns
SELECT *
FROM NashVilleHousingData

ALTER TABLE NashVilleHousingData
DROP COLUMN PropertyAddress, SaleDate, OwnerAddress, TaxDistrict