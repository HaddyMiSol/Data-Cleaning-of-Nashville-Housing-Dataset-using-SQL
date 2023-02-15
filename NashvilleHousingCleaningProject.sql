SELECT  *
From dbo.HouseCleaning

--Convert SaleDate from Datetime to Date

ALTER TABLE dbo.HouseCleaning
ADD SaleDateConverted Date;

UPDATE dbo.HouseCleaning
SET SaleDateConverted = CONVERT(Date,SaleDate)

-- Populate Property Address data

Select *
From dbo.HouseCleaning
Where PropertyAddress is null
order by ParcelID



Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From dbo.HouseCleaning a
JOIN dbo.HouseCleaning b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From dbo.HouseCleaning a
JOIN dbo.HouseCleaning b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

--Split the Property into Address, City 

ALTER TABLE dbo.HouseCleaning
ADD PropertyHomeAddress Nvarchar(255);

UPDATE dbo.HouseCleaning
SET PropertyHomeAddress  = PARSENAME(REPLACE(PropertyAddress,',','.'),2)

ALTER TABLE dbo.HouseCleaning
ADD PropertyCity Nvarchar(255);

UPDATE dbo.HouseCleaning
SET PropertyCity  = PARSENAME(REPLACE(PropertyAddress,',','.'),1)





--Split the Owner Address into Address, City and State

ALTER TABLE dbo.HouseCleaning
ADD OwnerHomeAddress Nvarchar(255);

UPDATE dbo.HouseCleaning
SET OwnerHomeAddress  = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE dbo.HouseCleaning
ADD OwnerCity Nvarchar(255);

UPDATE dbo.HouseCleaning
SET OwnerCity  = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE dbo.HouseCleaning
ADD OwnerState Nvarchar(255);

UPDATE dbo.HouseCleaning
SET OwnerState  = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

SELECT  *
From dbo.HouseCleaning

--Change 'Y' to Yes and 'N' to No in the SoldAsVacant Column

SELECT Distinct (SoldAsVacant), Count(SoldAsVacant)
From dbo.HouseCleaning
Group by SoldAsVacant
Order by 2

Update 
dbo.HouseCleaning
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
                        WHEN SoldAsVacant = 'N' THEN 'No'
	                    ELSE SoldAsVacant
	                    END
    
	
--Remove Duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyHomeAddress,
				 PropertyCity,
				 SalePrice,
				 SaleDateConverted,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From dbo.HouseCleaning
--order by ParcelID
)
Select *
From RowNumCTE
--Where row_num = 1
Order by PropertyHomeAddress


-- Delete Unused Columns


Select *
From dbo.HouseCleaning


ALTER TABLE dbo.HouseCleaning
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
