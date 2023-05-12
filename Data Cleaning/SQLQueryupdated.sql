 /*

Cleaning Data in SQL Queries

*/
SELECT * FROM dbo.Datacleaning
--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

SELECT SaleDateupdated, CONVERT(Date,SaleDate)                --just to visualise the difference
FROM PortfolioProject.dbo.Datacleaning

--UPDATE Datacleaning 
--SET SaleDate = Convert(Date,SaleDate)                        --Not working

ALTER TABLE Datacleaning                                       -- Add a new colum with type date
ADD SaleDateupdated Date

UPDATE Datacleaning                                            -- update the values inside the salesdateupdated table
SET SaleDateupdated = Convert(Date,SaleDate)

 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data [check the parcel ID , same parcel ID will have same property address]
SELECT *                                                     --looking into all the content
FROM PortfolioProject.dbo.Datacleaning

SELECT *                                                     --looking into all the null in property address
FROM PortfolioProject.dbo.Datacleaning
Where PropertyAddress is null


--The [property address with Null will be replaced with similar pracelID address][isnull[value1,value2] when NUll replace value 1 with value2]
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)  ReplacingAddress
FROM PortfolioProject.dbo.Datacleaning a            
JOIN PortfolioProject.dbo.Datacleaning b              -- Join the table with itself
    ON a.ParcelID = b.ParcelID                        -- when parcel id is same and Unique ID is not same 
	AND a.[UniqueID]<> b.[UniqueID]                    
Where a.PropertyAddress is null                       --show all the null value in property address


--Update the Table
UPDATE a
SET a.PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject.dbo.Datacleaning a            
JOIN PortfolioProject.dbo.Datacleaning b              -- Join the table with itself
    ON a.ParcelID = b.ParcelID                        -- when parcel id is same and Unique ID is not same 
	AND a.[UniqueID]<> b.[UniqueID]                    
Where a.PropertyAddress is null    


--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM PortfolioProject.dbo.Datacleaning


SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',' , PropertyAddress) -1) As Address ,
SUBSTRING(PropertyAddress , CHARINDEX(',' , PropertyAddress) +1, Len(PropertyAddress)) As City
FROM PortfolioProject.dbo.Datacleaning
 
ALTER TABLE Datacleaning                                       -- Add a new colum with address
ADD PropertySplitAddress Nvarchar(255) 

UPDATE Datacleaning                                            -- update the values inside the  only addess
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',' , PropertyAddress) -1)

ALTER TABLE Datacleaning                                       -- Add a new colum with city
ADD PropertySplitCity Nvarchar(255)

UPDATE Datacleaning                                            -- update the values inside the  only addess
SET PropertySplitCity = SUBSTRING(PropertyAddress,  CHARINDEX(',' , PropertyAddress) +1,LEN(PropertyAddress))
-----------------------------------
--OWNER ADDress [Lets devide the address using ParseName]


SELECT OwnerAddress
FROM PortfolioProject.dbo.Datacleaning

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',','.'), 3) ,          --ParseName will split the words before and after full stop
PARSENAME(REPLACE(OwnerAddress, ',','.'), 2) ,          --Using Replace we converted , to . 
PARSENAME(REPLACE(OwnerAddress, ',','.'), 1)
FROM PortfolioProject.dbo.Datacleaning

ALTER TABLE Datacleaning                                       -- Add a new colum with address
ADD OwnerSplitAddress Nvarchar(255) 

UPDATE Datacleaning                                            -- update the values inside the  only addess
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',','.'), 3)

ALTER TABLE Datacleaning                                       -- Add a new colum with city
ADD OwnerSplitCity Nvarchar(255)

UPDATE Datacleaning                                            -- update the values inside the  only addess
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',','.'), 2)

ALTER TABLE Datacleaning                                       -- Add a new colum with city
ADD OwnerSplitState Nvarchar(255)

UPDATE Datacleaning                                            -- update the values inside the  only addess
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',','.'), 1)
--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject.dbo.Datacleaning
GROUP BY SoldAsVacant
ORDER BY 2
 

 SELECT SoldAsVacant,
     CASE WHEN SoldAsVacant='Y' THEN 'Yes'
	      WHEN SoldAsVacant='N' THEN 'NO'
		  ELSE SoldAsVacant
	 END SoldAsVacantUpdated
FROM PortfolioProject.dbo.Datacleaning

UPDATE Datacleaning
SET SoldAsVacant= CASE WHEN SoldAsVacant='Y' THEN 'Yes'
	      WHEN SoldAsVacant='N' THEN 'NO'
		  ELSE SoldAsVacant
	 END



-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates
SELECT * 
FROM PortfolioProject.dbo.Datacleaning
 
WITH RowNUMCTE AS (                                                --Created a instnt table CTE 
SELECT *, Row_Number() OVER ( PARTITION BY ParcelID,PropertyAddress, SaleDate,Saleprice, LegalReference 
                              ORDER BY UniqueID) Row_num            -- checking for duplicates in all the above things and give them a number
                                                                    -- If row_num is 2 or more then they are all dupliacte
FROM PortfolioProject.dbo.Datacleaning          
)

--SELECT * FROM RowNUMCTE                                       --Seeing all duplicates
--  WHERE row_num >1
--  Order by PropertyAddress

DELETE FROM RowNUMCTE                                            --Deleting all duplicate
  WHERE row_num >1
  
---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

SELECT * FROM PortfolioProject.dbo.Datacleaning

ALTER TABLE PortfolioProject.dbo.Datacleaning                            
DROP COLUMN PropertyAddress, OwnerAddress, SaleDate, TaxDistrict             --Delete these columns



