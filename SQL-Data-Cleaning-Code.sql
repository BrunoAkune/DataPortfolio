/*
Cleaning Data in SQL Queries
*/

Select *
From PortfolioProject.dbo.NashvilleHousing

---------------------------------------------------------------------


-- Standardize Date Format
Select SaleDateConverter, CONVERT(Date,SaleDate)
From PortfolioProject.dbo.NashvilleHousing

update NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE NashvilleHousing
Add SaleDateConverter Date;

Update NashvilleHousing
SET SaleDateConverter = CONVERT(Date,SaleDate)


----------------------------------------------------------------------


-- Populate Property Address data
Select *
From PortfolioProject.dbo.NashvilleHousing
--Where PropertyAddress is NULL
order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,  b.PropertyAddress) 
From PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID] <> b.[UniqueID] 
where a.PropertyAddress is null

update a
SET PropertyAddress =  ISNULL(a.PropertyAddress,  b.PropertyAddress) 
From PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID] <> b.[UniqueID] 


----------------------------------------------------------------------


-- Breaking out Address into Individual Columns (Address, City, State)
Select PropertyAddress
From PortfolioProject.dbo.NashvilleHousing

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address

From PortfolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add PropertySplitAddress NvarChar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashvilleHousing
Add PropertySplitCity NvarChar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

Select *
From PortfolioProject.dbo.NashvilleHousing

/* Cleaning Owner Data */
Select OwnerAddress
From PortfolioProject.dbo.NashvilleHousing

Select
PARSENAME(REPLACE(OwnerAddress, ',' , '.'), 3)
, PARSENAME(REPLACE(OwnerAddress, ',' , '.'), 2)
, PARSENAME(REPLACE(OwnerAddress, ',' , '.'), 1)
From PortfolioProject.dbo.NashvilleHousing

/*Update Table Owner */
ALTER TABLE NashvilleHousing
Add OwnerSplitAddress NvarChar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',' , '.'), 3)


ALTER TABLE NashvilleHousing
Add OwnerSplitCity NvarChar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',' , '.'), 2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState NvarChar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',' , '.'), 1)

Select *
From PortfolioProject.dbo.NashvilleHousing

----------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field
Select Distinct(SoldAsVacant), count(SoldAsVacant)
From PortfolioProject.dbo.NashvilleHousing
Group by SoldAsVacant
order by 2

Select SoldAsVacant
,Case When SoldAsVacant = 'Y' THEN 'Yes'
	  When SoldAsVacant = 'N' THEN 'No'
	  Else SoldAsVacant
	  END
From PortfolioProject.dbo.NashvilleHousing

Update NashvilleHousing
SET SoldAsVacant = Case When SoldAsVacant = 'Y' THEN 'Yes'
	  When SoldAsVacant = 'N' THEN 'No'
	  Else SoldAsVacant
	  END


----------------------------------------------------------------------


-- Remove Duplicates
WIth RowNumCTE AS(
Select *, 
	ROW_NUMBER()Over(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,	
				 LegalReference
				 ORDER BY
					UniqueID
				) row_num

From PortfolioProject.dbo.NashvilleHousing
--order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1


----------------------------------------------------------------------


-- Delete Unsed Columns

Select *
From PortfolioProject.dbo.NashvilleHousing

Alter Table PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress 

Alter Table PortfolioProject.dbo.NashvilleHousing
DROP COLUMN SaleDate