/*

Cleaning Nashville Housing Data in SQL Queries

*/

SELECT *
FROM HousingProject.dbo.NashvilleHousing

-- Change Sales Date to remove the time

SELECT SaleDate, CONVERT(Date,SaleDate)
FROM HousingProject.dbo.NashvilleHousing

UPDATE HousingProject.dbo.NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update HousingProject.dbo.NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate);

SELECT SaleDateConverted, CONVERT(Date,SaleDate)
FROM HousingProject.dbo.NashvilleHousing

-- Populate Address Data

-- This shows us there are duplicates in the address where the Parcel IDs are the same
SELECT *
FROM HousingProject.dbo.NashvilleHousing
WHERE PropertyAddress is null
ORDER BY ParcelID

-- The ISNULL is what is populated with addresses from b.Property Address into a.property addressses which are currently null

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM HousingProject.dbo.NashvilleHousing a 
JOIN HousingProject.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
	WHERE a.PropertyAddress is null

-- Now we use update to populate addresses into the property adresses that are null
UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM HousingProject.dbo.NashvilleHousing a 
JOIN HousingProject.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
	WHERE a.PropertyAddress is null

-- Divid Address Column into Address City and State Columns
SELECT PropertyAddress
FROM HousingProject.dbo.NashvilleHousing
--WHERE PropertyAddress is null
--ORDER BY ParcelID

SELECT SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as City
FROM HousingProject.dbo.NashvilleHousing

ALTER TABLE HousingProject.dbo.NashvilleHousing
Add PropertySplitAddress NVARCHAR(255);

Update HousingProject.dbo.NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1);

ALTER TABLE HousingProject.dbo.NashvilleHousing
Add PropertySplitCity NVARCHAR(255);

Update HousingProject.dbo.NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress));

SELECT *
FROM HousingProject.dbo.NashvilleHousing

-- Do the same for Owner Address (Using Parsename)
Select OwnerAddress
From HousingProject.dbo.NashvilleHousing

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
From HousingProject.dbo.NashvilleHousing


ALTER TABLE HousingProject.dbo.NashvilleHousing
Add OwnerSplitAddress NVARCHAR(255);

Update HousingProject.dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3);

ALTER TABLE HousingProject.dbo.NashvilleHousing
Add OwnerSplitCity NVARCHAR(255);

Update HousingProject.dbo.NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2);

ALTER TABLE HousingProject.dbo.NashvilleHousing
Add OwnerSplitState NVARCHAR(255);

Update HousingProject.dbo.NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1);


-- Change the values Y and N in the "Sold as Vacant" field to Yes and No

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From HousingProject.dbo.NashvilleHousing
Group By SoldAsVacant
Order By 2

Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From HousingProject.dbo.NashvilleHousing

Update HousingProject.dbo.NashvilleHousing
SET SoldAsVacant =
		CASE When SoldAsVacant = 'Y' THEN 'Yes'
		When SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END

-- REMOVE DUPLICATES (Will be Deleting)

-- Shows us all duplicates usign a CTE
WITH RowNumCTE AS (
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
From HousingProject.dbo.NashvilleHousing
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress

-- Now to Delete them
WITH RowNumCTE AS (
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
From HousingProject.dbo.NashvilleHousing
)
DELETE 
From RowNumCTE
Where row_num > 1

-- Now there are no more duplicates

-- Delete Unused Columns

SELECT *
FROM HousingProject.dbo.NashvilleHousing

-- We dont need the Property or Owner Adress that was previously there due to the work we did in the previous steps, splitting them into separate columns

ALTER TABLE HousingProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE HousingProject.dbo.NashvilleHousing
DROP COLUMN SaleDate