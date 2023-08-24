/* Cleaning Data */

SELECT *
FROM ProjectPortfolio.dbo.NashvilleHousing

--Standardize date formatting--

SELECT SaleDate, CONVERT(date, saledate)
FROM ProjectPortfolio.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT(date, SaleDate)

SELECT SaleDate 
FROM ProjectPortfolio.dbo.NashvilleHousing


--------------------------------------------------------------

-- Populate Property Address Data --

--Check for null values
SELECT *
FROM ProjectPortfolio.dbo.NashvilleHousing
Where PropertyAddress is Null

/*
When we run:
SELECT *
FROM ProjectPortfolio.dbo.NashvilleHousing
Where PropertyAddress is Null
order by ParcelID
 
we see that for the same parcelID, if the ID is repeated, the Property address is the same. That means we can
populate the null Property Address with an address by using another row with the same ParcelID.

*/

SELECT a.parcelID, a.propertyaddress, b.parcelID, b.propertyaddress, ISNULL(a.propertyaddress, b.propertyaddress)
FROM ProjectPortfolio.dbo.NashvilleHousing a
JOIN ProjectPortfolio.dbo.NashvilleHousing b
    ON a.parcelID = b.parcelID
    AND a.uniqueID <> b.uniqueID 
where a.propertyaddress is null


Update a 
SET PropertyAddress = ISNULL(a.propertyaddress, b.propertyaddress)
FROM ProjectPortfolio.dbo.NashvilleHousing a
JOIN ProjectPortfolio.dbo.NashvilleHousing b
    ON a.parcelID = b.parcelID
    AND a.uniqueID <> b.uniqueID 
where a.propertyaddress is null



-----------------------------------------------

-- Break address info into separate columns (address, city, state)
--char index, goes to position of the comma, minus one so it does not include the comma in the address

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)- 1) as Address
    , SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+ 1, LEN(PropertyAddress)) as Address
From ProjectPortfolio.dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
ADD PropertySplitAddress nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)- 1)


ALTER TABLE NashvilleHousing
ADD PropertySplitCity nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+ 1, LEN(PropertyAddress))


SELECT *
FROM ProjectPortfolio.dbo.NashvilleHousing


--Another method to split up the address
SELECT OwnerAddress
FROM ProjectPortfolio.dbo.NashvilleHousing

SELECT
PARSENAME(REPLACE(OwnerAddress, ',','.'),3)
,PARSENAME(REPLACE(OwnerAddress, ',','.'),2)
,PARSENAME(REPLACE(OwnerAddress, ',','.'),1)
FROM ProjectPortfolio.dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',','.'),3)

ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',','.'),2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',','.'),1)

------------------------------------------------------------------

--Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant), Count(SoldAsVacant)
FROM ProjectPortfolio.dbo.NashvilleHousing
GROUP by SoldAsVacant
Order by 2

SELECT SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
       When SoldAsVacant = 'N' THEN 'No'
       ELSE SoldAsVacant
       END
FROM ProjectPortfolio.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
       When SoldAsVacant = 'N' THEN 'No'
       ELSE SoldAsVacant
       END
FROM ProjectPortfolio.dbo.NashvilleHousing

-------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE AS(
SELECT *,
    ROW_NUMBER() OVER  (
    PARTITION BY ParcelID,
                 PropertyAddress,
                 SalePrice,
                 SaleDate,
                 LegalReference
                 ORDER BY
                    UniqueID 
    ) row_num

FROM ProjectPortfolio.dbo.NashvilleHousing
)

DELETE
FROM RowNumCTE
Where row_num >1



---------------------------------------------------------------

--Delete Unused Columns
--Since we split up the addresses, no need for the columns with address, city, and state combined


SELECT *
FROM ProjectPortfolio.dbo.NashvilleHousing

ALTER TABLE ProjectPortfolio.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress







