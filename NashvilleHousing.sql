SELECT * 
FROM NashvilleHousingData 

-- Standardize date format 
SELECT SaleDateConverted, CONVERT(Date,SaleDate) 
FROM NashvilleHousingData 

ALTER TABLE NashvilleHousingData 
ADD SaleDateConverted Date; 

UPDATE NashvilleHousingData 
SET SaleDateConverted = CONVERT(Date, SaleDate)


-- Populate Property Address data 
SELECT n1.ParcelID, n1.PropertyAddress, n2.ParcelID, n2.PropertyAddress, ISNULL(n1.PropertyAddress, n2.PropertyAddress)
FROM NashvilleHousingData n1
JOIN NashvilleHousingData n2 
     ON n1.ParcelID = n2.ParcelID 
	 AND n1.[UniqueID] <> n2.[UniqueID] 
WHERE n1.PropertyAddress IS NULL 

UPDATE n1
SET PropertyAddress =  ISNULL(n1.PropertyAddress, n2.PropertyAddress)
FROM NashvilleHousingData n1
JOIN NashvilleHousingData n2 
     ON n1.ParcelID = n2.ParcelID 
	 AND n1.[UniqueID] <> n2.[UniqueID] 
WHERE n1.PropertyAddress IS NULL  


---- Breaking out Address into individual columns (Address, City, State) 

SELECT PropertyAddress 
FROM NashvilleHousingData 

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) AS Address 
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS Address
FROM NashvilleHousingData 

ALTER TABLE NashvilleHousingData 
ADD PropertySplitAdress varchar(55) 

UPDATE NashvilleHousingData 
SET PropertySplitAdress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) 

ALTER TABLE NashvilleHousingData 
ADD PropertySplitCity varchar(55) 

UPDATE NashvilleHousingData 
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) 


---- Breaking out Owner Address 

SELECT OwnerAddress 
FROM NashvilleHousingData 

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) 
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)  
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) 
FROM NashvilleHousingData 

-- Address
ALTER TABLE NashvilleHousingData 
ADD OwnerSplitAddress Nvarchar(255) 

UPDATE NashvilleHousingData 
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)  

-- City 
ALTER TABLE NashvilleHousingData 
ADD OwnerSplitCity Nvarchar(255) 

UPDATE NashvilleHousingData 
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)   

-- State
ALTER TABLE NashvilleHousingData 
ADD OwnerSplitState Nvarchar(255) 

UPDATE NashvilleHousingData 
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)   

SELECT OwnerSplitAddress, OwnerSplitCity, OwnerSplitState 
FROM NashvilleHousingData 

---- Change Y and N to Yes and No in "Sold as Vacant" field 

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant) 
FROM NashvilleHousingData 
GROUP BY SoldAsVacant  

SELECT SoldAsVacant  
, CASE 
      WHEN SoldAsVacant = 'Y' THEN 'Yes' 
	  WHEN SoldAsVacant = 'N' THEN 'No' 
	  ELSE SoldAsVacant 
	  END 
FROM NashvilleHousingData 

UPDATE NashvilleHousingData 
SET SoldAsVacant =
CASE 
      WHEN SoldAsVacant = 'Y' THEN 'Yes' 
	  WHEN SoldAsVacant = 'N' THEN 'No' 
	  ELSE SoldAsVacant 
	  END   


---- Removing Duplicates 

WITH RowNum_CTE AS(
SELECT *, 
     ROW_NUMBER() OVER ( 
	 PARTITION BY ParcelID, 
	              PropertyAddress, 
				  SalePrice, 
				  SaleDate, 
				  LegalReference 
				  ORDER BY 
				     UniqueID 
				     ) row_num

FROM NashvilleHousingData  
--ORDER BY ParcelID
) 

SELECT *
FROM RowNum_CTE
WHERE row_num > 1  
ORDER BY PropertyAddress


---- Delete unused columns 

SELECT *
FROM NashvilleHousingData 

ALTER TABLE NashvilleHousingData 
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress 

ALTER TABLE NashvilleHousingData 
DROP COLUMN SaleDate