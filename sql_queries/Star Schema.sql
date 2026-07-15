-- DDL (Creating the Star Schema) (DDL: Data Definition Language)
CREATE TABLE Dim_Location (
    Location_ID INT AUTO_INCREMENT PRIMARY KEY,
    City VARCHAR(100),
    Locality VARCHAR(255)
);

CREATE TABLE Dim_Property_Details (
    Property_Detail_ID INT AUTO_INCREMENT PRIMARY KEY,
    Property_Type VARCHAR(50),
    Bedrooms INT,
    Bathrooms INT,
    Project_Status VARCHAR(50),  
    Transaction_Type VARCHAR(50)
);

CREATE TABLE Fact_Listings (
    Listing_ID INT AUTO_INCREMENT PRIMARY KEY,
    Location_ID INT,
    Property_Detail_ID INT,
    Total_Area_SqFt DECIMAL(15,2),
    Price BIGINT,
    Rate_Per_SqFt DECIMAL(15,2),
    FOREIGN KEY (Location_ID) REFERENCES Dim_Location(Location_ID),
    FOREIGN KEY (Property_Detail_ID) REFERENCES Dim_Property_Details(Property_Detail_ID)
);


-- DML (Inserting Data into the Star Schema) (DML: Data Manipulation Language)

-- 1. Populating Dim_Location 
INSERT INTO Dim_Location (City, Locality)
SELECT DISTINCT city, location 
FROM Staging_Real_Estate
WHERE location IS NOT NULL;

-- 2. Populating Dim_Property_Details
INSERT INTO Dim_Property_Details (Property_Type, Bedrooms, Bathrooms, Project_Status, Transaction_Type)
SELECT DISTINCT Property_Type, bedroom, bathroom, status, transaction
FROM Staging_Real_Estate
WHERE Property_Type IS NOT NULL;

-- 3. Populating Fact_Listings (Joining it all together)
INSERT INTO Fact_Listings (Location_ID, Property_Detail_ID, Total_Area_SqFt, Price, Rate_Per_SqFt)
SELECT 
    l.Location_ID,
    p.Property_Detail_ID,
    s.`total_area(sqft)`,
    s.Price,
    s.Rate_per_sqft
FROM Staging_Real_Estate s
JOIN Dim_Location l 
    ON s.city = l.City AND s.location = l.Locality
JOIN Dim_Property_Details p 
    ON s.Property_Type = p.Property_Type 
    AND s.bedroom = p.Bedrooms 
    AND s.bathroom = p.Bathrooms 
    AND s.status = p.Project_Status
    AND s.transaction = p.Transaction_Type;


-- Arbitrage Detection : Detecting properties with 20% cheaper price than the average price in the same locality

    --Creating a view to display query in Power BI for visualization and analysis of arbitrage opportunities.
CREATE VIEW View_Arbitrage_Opportunities AS

    --Creating a CTE (Common Table Expression) to calculate average price per square foot for each locality

WITH Location_Averages AS (
    SELECT Location_ID, AVG(Rate_Per_SqFt) as Avg_Neighborhood_Rate
    FROM Fact_Listings GROUP BY Location_ID
)
SELECT 
    f.*, 
    l.Locality,
    a.Avg_Neighborhood_Rate,
    ((a.Avg_Neighborhood_Rate - f.Rate_Per_SqFt) / a.Avg_Neighborhood_Rate) * 100 AS Discount_Percentage
FROM Fact_Listings f
JOIN Dim_Location l ON f.Location_ID = l.Location_ID
JOIN Location_Averages a ON f.Location_ID = a.Location_ID
WHERE f.Rate_Per_SqFt < (a.Avg_Neighborhood_Rate * 0.8);