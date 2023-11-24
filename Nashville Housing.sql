select TOP (1000) * from NashvilleHousing

/*

Cleaning Data in SQL Queries

*/

select*from NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

SELECT SaleDateConverted
from [Portfolio Project By Alex]..NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT (Date, SaleDate) 

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT (Date,SaleDate) 

-- If it doesn't Update properly



 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data


SELECT*
from [Portfolio Project By Alex]..NashvilleHousing
where PropertyAddress is null
order by ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
from [Portfolio Project By Alex]..NashvilleHousing a
JOIN [Portfolio Project By Alex]..NashvilleHousing b
ON a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM [Portfolio Project By Alex]..NashvilleHousing a
JOIN [Portfolio Project By Alex]..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null



--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

select PropertyAddress
from [Portfolio Project By Alex]..NashvilleHousing

SELECT 
SUBSTRING(PropertyAddress,  1, CHARINDEX(',',PropertyAddress)-1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress)) AS Address
from [Portfolio Project By Alex]..NashvilleHousing

ALTER TABLE [Portfolio Project By Alex]..NashvilleHousing
ADD PropertySplitAddress nvarchar(255)

UPDATE [Portfolio Project By Alex]..NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress,  1, CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE [Portfolio Project By Alex]..NashvilleHousing
ADD PropertySplitCity nvarchar(255)

UPDATE [Portfolio Project By Alex]..NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress)) 

select *
from [Portfolio Project By Alex]..NashvilleHousing



--SELECT OwnerAddress,
--SUBSTRING(OwnerAddress,  1, CHARINDEX(',',OwnerAddress)-1) AS Address
--from [Portfolio Project By Alex]..NashvilleHousing

--SELECT 
--  OwnerAddress,
--  SUBSTRING(OwnerAddress, CHARINDEX(',', OwnerAddress) + 2, CHARINDEX(',', OwnerAddress, CHARINDEX(',', OwnerAddress) + 1) - CHARINDEX(',', OwnerAddress) - 2) AS City
--FROM [Portfolio Project By Alex]..NashvilleHousing

--SELECT
--	OwnerAddress,
--	RIGHT(OwnerAddress, 2) as Region
--FROM [Portfolio Project By Alex]..NashvilleHousing
--WHERE RIGHT(OwnerAddress, 2) is not null

---

SELECT 
PARSENAME(REPLACE(OwnerAddress,',','.'),3),
PARSENAME(REPLACE(OwnerAddress,',','.'),2),
PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM [Portfolio Project By Alex]..NashvilleHousing

---

ALTER TABLE [Portfolio Project By Alex]..NashvilleHousing
ADD OwnerSplitAddress nvarchar(255)

UPDATE [Portfolio Project By Alex]..NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

---

ALTER TABLE [Portfolio Project By Alex]..NashvilleHousing
ADD OwnerSplitCity nvarchar(255)

UPDATE [Portfolio Project By Alex]..NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

---

ALTER TABLE [Portfolio Project By Alex]..NashvilleHousing
ADD OwnerSplitState nvarchar(255)

UPDATE [Portfolio Project By Alex]..NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

select *
from [Portfolio Project By Alex]..NashvilleHousing


--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT SoldAsVacant, COUNT(SoldAsVacant)
from [Portfolio Project By Alex]..NashvilleHousing
group by SoldAsVacant
order by 2

SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
from [Portfolio Project By Alex]..NashvilleHousing

UPDATE [Portfolio Project By Alex]..NashvilleHousing
SET SoldAsVacant =
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END


-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

select * from [Portfolio Project By Alex]..NashvilleHousing

WITH RowNumCte AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY UniqueId) AS row_num
from [Portfolio Project By Alex]..NashvilleHousing
)

--UNTUK MENGHAPUS DATA DUPLICATE (WHERE ROW_NUM > 1)
--DELETE 
--FROM RowNumCte
--WHERE row_num > 1
--ORDER BY PropertyAddress

SELECT *
FROM RowNumCte
WHERE row_num > 1
ORDER BY PropertyAddress

---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

select *
from [Portfolio Project By Alex]..NashvilleHousing


ALTER TABLE [Portfolio Project By Alex]..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE [Portfolio Project By Alex]..NashvilleHousing
DROP COLUMN SaleDate











-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------

--- Importing Data using OPENROWSET and BULK INSERT	

--  More advanced and looks cooler, but have to configure server appropriately to do correctly
--  Wanted to provide this in case you wanted to try it


--sp_configure 'show advanced options', 1;
--RECONFIGURE;
--GO
--sp_configure 'Ad Hoc Distributed Queries', 1;
--RECONFIGURE;
--GO


--USE PortfolioProject 

--GO 

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'AllowInProcess', 1 

--GO 

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'DynamicParameters', 1 

--GO 


---- Using BULK INSERT

--USE PortfolioProject;
--GO
--BULK INSERT nashvilleHousing FROM 'C:\Temp\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv'
--   WITH (
--      FIELDTERMINATOR = ',',
--      ROWTERMINATOR = '\n'
--);
--GO


---- Using OPENROWSET
--USE PortfolioProject;
--GO
--SELECT * INTO nashvilleHousing
--FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0',
--    'Excel 12.0; Database=C:\Users\alexf\OneDrive\Documents\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv', [Sheet1$]);
--GO

















