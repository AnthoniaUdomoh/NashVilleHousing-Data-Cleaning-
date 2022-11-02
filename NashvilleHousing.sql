---Data Cleaning for Nashville Housing

--Cleaning Data in SQL Queries
Select *
From [Portfolio Project]. .NashvilleHousing

--Standardize Sales Date
Select SaleDateConverted, CONVERT(Date, SaleDate) 
From [Portfolio Project]. .NashvilleHousing

Update NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate) 

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate) 

--Populate Null Property Address using Parcel ID (Self Join)
Select ParcelID, PropertyAddress
From [Portfolio Project]. .NashvilleHousing
--Where PropertyAddress is null
order by PropertyAddress

Select A.SaleDate, A.ParcelID, A.PropertyAddress, B.SaleDate, B.ParcelID, B.PropertyAddress, ISNULL(A.PropertyAddress, B.PropertyAddress)
From [Portfolio Project]. .NashvilleHousing A
JOIN [Portfolio Project]. .NashvilleHousing B
on A.ParcelID = B.ParcelID
AND A.[UniqueID ] <> B.[UniqueID ]
Where A.PropertyAddress is null
--Included the dates to ensure I am not working with duplicates

Update a --Using an alias here instead of the Table name because of the Join function
SET PropertyAddress = ISNULL(A.PropertyAddress, B.PropertyAddress)
From [Portfolio Project]. .NashvilleHousing A
JOIN [Portfolio Project]. .NashvilleHousing B
on A.ParcelID = B.ParcelID
AND A.[UniqueID ] <> B.[UniqueID ]
Where A.PropertyAddress is null

--Breaking down Addresses into Address, City & State
Select PropertyAddress
From [Portfolio Project]. .NashvilleHousing

---Using SUBSTRING
Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as Address

From [Portfolio Project]. .NashvilleHousing


Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))  as Address

From [Portfolio Project]. .NashvilleHousing


ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) 

ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) 


--Using Parsename (only work with periods and backwards)

Select 
PARSENAME(REPLACE(OwnerAddress,',', '.'),3)
, PARSENAME(REPLACE(OwnerAddress,',', '.'), 2)
, PARSENAME(REPLACE(OwnerAddress,',', '.'), 1)
From [Portfolio Project]. .NashvilleHousing


ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',', '.'),3)

ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity =  PARSENAME(REPLACE(OwnerAddress,',', '.'), 2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState =  PARSENAME(REPLACE(OwnerAddress,',', '.'), 1)


---Replace Y & N to Yes & No in the SoldAsVacant column

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From [Portfolio Project]. . NashvilleHousing
Group by SoldAsVacant
order by 2


Select SoldAsVacant
, CASE when SoldAsVacant = 'Y' Then 'Yes'
       when SoldAsVacant = 'N' Then 'No'
	   else SoldAsVacant
	   end
From [Portfolio Project]. .NashvilleHousing

Update NashvilleHousing
SET SoldAsVacant = CASE when SoldAsVacant = 'Y' Then 'Yes'
       when SoldAsVacant = 'N' Then 'No'
	   else SoldAsVacant
	   end

---Remove duplicates 

WITH RowNumCTE AS(
Select *
       ,ROW_NUMBER() OVER (
	   PARTITION BY ParcelID,
	                PropertyAddress,
					SalePrice,
					SaleDate,
					LegalReference
					Order by
					UniqueID
					) row_num

From [Portfolio Project]. .NashvilleHousing
)
Select *
From RowNumCTE
where row_num > 1
order by PropertyAddress

--Delete
WITH RowNumCTE AS(
Select *
       ,ROW_NUMBER() OVER (
	   PARTITION BY ParcelID,
	                PropertyAddress,
					SalePrice,
					SaleDate,
					LegalReference
					Order by
					UniqueID
					) row_num

From [Portfolio Project]. .NashvilleHousing
)
DELETE
From RowNumCTE
where row_num > 1


---To delete unused columns if need be

Select *
From [Portfolio Project]. .NashvilleHousing

ALTER TABLE [Portfolio Project]. .NashvilleHousing
DROP COLUMN SaleDate, OwnerAddress, PropertyAddress, Taxdistrict