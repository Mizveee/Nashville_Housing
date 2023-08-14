CREATE TABLE NashvilleHousing(
        UniqueID int PRIMARY KEY,
        ParcelID varchar,
        LandUse varchar,
        PropertyAddress varchar,
        SaleDate varchar,
        SalePrice varchar,
        LegalReference varchar,
        SoldAsVacant varchar,
        OwnerName varchar,
        OwnerAddress varchar,
        Acreage varchar,
        TaxDistrict varchar,
        LandValue varchar,
        BuildingValue varchar,
        TotalValue varchar,
        YearBuilt varchar,
        Bedrooms varchar,
        FullBath varchar,
        HalfBath varchar);
        
SELECT *
FROM nashvillehousing;   

-------------DATA CLEANING IN SQL-------------------------------------

------1. Standardize date formats-------

SELECT saledate
FROM nashvillehousing;

SELECT saledate, CAST(saledate AS date)
FROM nashvillehousing;

UPDATE nashvillehousing
SET saledate = CAST(saledate AS date);

-------2. Populate Property Address data-------

SELECT *
FROM nashvillehousing
    WHERE propertyaddress is null
    ORDER BY uniqueid;

SELECT a.parcelid, a.propertyaddress, b.parcelid, b.propertyaddress,COALESCE(a.propertyaddress, b.propertyaddress)
FROM nashvillehousing a
JOIN nashvillehousing b
    ON a.parcelid = b.parcelid
    AND a.uniqueid <> b.uniqueid
    WHERE a.propertyaddress IS null;

UPDATE nashvillehousing
SET propertyaddress = COALESCE(a.propertyaddress, b.propertyaddress)
FROM nashvillehousing a
JOIN nashvillehousing b
ON a.parcelid = b.parcelid
AND a.uniqueid <> b.uniqueid
WHERE a.propertyaddress IS null;

---3. Breakout Address into individual columns (Address, city, state)

SELECT propertyaddress
FROM nashvillehousing;

SELECT
    split_part(propertyaddress, ',', 1) AS address,
    split_part(propertyaddress, ',', 2)AS city
FROM nashvillehousing;

ALTER TABLE nashvillehousing
ADD COLUMN city varchar;

UPDATE nashvillehousing
SET city = split_part(propertyaddress, ',', 2);

ALTER TABLE nashvillehousing
ADD COLUMN address varchar;

UPDATE nashvillehousing
SET address = split_part(propertyaddress, ',', 1);

---4. Breakout for Owner Address

SELECT owneraddress
FROM nashvillehousing;

SELECT
    split_part(owneraddress, ',', 1) AS owneradd,
    split_part(owneraddress, ',', 2)AS ownercity,
    split_part(owneraddress, ',', 3)AS ownerstate
FROM nashvillehousing;

ALTER TABLE nashvillehousing
ADD COLUMN owneradd varchar;

UPDATE nashvillehousing
SET owneradd = split_part(owneraddress, ',', 1);

ALTER TABLE nashvillehousing
ADD COLUMN ownercity varchar;

UPDATE nashvillehousing
SET ownercity = split_part(owneraddress, ',', 2);

ALTER TABLE nashvillehousing
ADD COLUMN ownerstate varchar;

UPDATE nashvillehousing
SET ownerstate = split_part(owneraddress, ',', 3);

---5.Change Y and N to Yes and No in soldasvacant field

SELECT DISTINCT(soldasvacant),COUNT(soldasvacant)
FROM nashvillehousing
GROUP BY soldasvacant
ORDER BY COUNT(soldasvacant) DESC

SELECT soldasvacant,
        CASE
            WHEN soldasvacant = 'Y' THEN 'Yes'
            WHEN soldasvacant = 'N' THEN 'No'
            ELSE soldasvacant
         END
FROM nashvillehousing;


UPDATE nashvillehousing
SET soldasvacant = CASE
            WHEN soldasvacant = 'Y' THEN 'Yes'
            WHEN soldasvacant = 'N' THEN 'No'
            ELSE soldasvacant
         END;
         
        
---6. Remove Duplicates
DELETE FROM nashvillehousing
WHERE uniqueid IN
    (SELECT uniqueid
     FROM
            (SELECT *,
                ROW_NUMBER()OVER (
                PARTITION BY parcelid,
                             propertyaddress,
                            saleprice,
                            saledate,
                            legalreference
                 ORDER BY uniqueid
             )row_num
    FROM nashvillehousing) t
    WHERE t.row_num > 1);
    
    
 ----8. Delete unused columns
 
 ALTER TABLE nashvillehousing
 DROP COLUMN owneraddress,
 DROP COLUMN taxdistrict,
 DROP COLUMN propertyaddress;
