CREATE TABLE Staging_Real_Estate (
    Name TEXT,
    Price BIGINT,
    Rate DOUBLE,
    property VARCHAR(100),
    status VARCHAR(100),
    floor VARCHAR(100),
    transaction VARCHAR(100),
    facing VARCHAR(100),
    overlooking VARCHAR(255),
    ownership VARCHAR(100),
    parking INT,
    bathroom DOUBLE,
    balcony DOUBLE,
    city VARCHAR(100),
    location VARCHAR(255),
    Rate_per_sqft DOUBLE,
    bedroom INT,
    carpet_area_sqft DOUBLE,
    total_area DOUBLE,
    Area_Unit VARCHAR(50),
    Area DOUBLE,
    Property_Type VARCHAR(100),
    `carpet_area(in sqft)` DOUBLE,
    Z_Score DOUBLE,
    `total_area(sqft)` DOUBLE
);


LOAD DATA LOCAL INFILE
'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Real_Estate_Cleaned_3.csv'
INTO TABLE Staging_Real_Estate
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

Select count(*) from Staging_Real_Estate;

