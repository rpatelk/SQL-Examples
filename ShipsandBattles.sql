REM   Script: ShipsandBattles.sql
REM   This is the file for Ships and Battles

--Below are the statements to setup the tables.
CREATE TABLE Ships ( 
                name         VARCHAR(64) 	NOT NULL    PRIMARY KEY,  
                country      VARCHAR(64) 	NOT NULL,
                yearLaunched INTEGER        NOT NULL,
                numGuns      INTEGER     	NOT NULL, 
                gunSize      INTEGER) 	    NOT NULL);

CREATE TABLE Battles ( 
                battleName  VARCHAR(64) 	NOT NULL    PRIMARY KEY,
                ship        VARCHAR(64)     NOT NULL,
                result      VARCHAR(64)     NOT NULL);

--Below are the statements to insert data into each table.

--Ships
INSERT INTO Ships VALUES ('Enterprise', 'USA', 1925, 17, 13);
INSERT INTO Ships VALUES ('Voyager', 'USA', 1928, 11, 9);
INSERT INTO Ships VALUES ('Aconit', 'Russia', 1929, 18, 13);
INSERT INTO Ships VALUES ('Achille', 'Russia', 1935, 15, 14);
INSERT INTO Ships VALUES ('Gorshkov', 'France', 1940, 17, 10);
INSERT INTO Ships VALUES ('Nevsky', 'France', 1941, 11, 9);

--Battles
INSERT INTO Battles VALUES ('Surigao Strait', 'Enterprise', "damaged");
INSERT INTO Battles VALUES ('Surigao Strait', 'Voyager', "sunk");
INSERT INTO Battles VALUES ('Surigao Strait', 'Gorshkov', "sunk");
INSERT INTO Battles VALUES ('Surigao Strait', 'Nevsky', "damaged");
INSERT INTO Battles VALUES ('Surigao Strait', 'Aconit', "sunk");
INSERT INTO Battles VALUES ('Prime', 'Enterprise', "sunk");
INSERT INTO Battles VALUES ('Prime', 'Nevsky', "damaged");
INSERT INTO Battles VALUES ('Prime', 'Achille', "damaged");

--Below our SQL statements for specific searches.

--Battleships launched before 1930 had 16-inch guns. Lists their names, their country, and the number of guns they carried.
SELECT name, country, numGuns 
FROM Ships 
WHERE yearLaunched < 1930 AND gunSize = 16

--Battleship(s) that had the guns with the largest gun size.
SELECT name 
FROM Ships 
WHERE gunSize >= ALL (SELECT gunSize 
                      FROM Ships)

--Battleships that had the guns with the second largest gun size no matter how many other ships had that larger gun size. 
--Lists their names and their gun size.
SELECT name, gunSize 
FROM Ships 
WHERE gunSize = (SELECT MAX(gunSize) 
                 FROM SHIPS 
                 WHERE gunSize <> (SELECT MAX(gunSize) 
                                   FROM Ships))

--Lists, for each country, the average number of guns carried by their battleships.
SELECT country AVG(numGuns) AS avgGuns 
FROM SHIPS 
GROUP BY country

--Lists all the pairs of countries that fought each other in battles. Lists each pair only once, and lists them with the country that 
--comes first in alphabetical order first.
SELECT DISTINCT s1.country, s2.country 
FROM Ships s1, Ships s2, Battles b1, Battles b2 
WHERE s1.name = b1.ship AND s2.name = b2.ship 
      AND b1.battleName = b2.battleName 
      AND s1.country <> s2.country

--For the battle of Surigao Strait, for each country engaged in this battle (had one or more battleships participating), this 
--statement gives the number of its battleships that were sunk.
SELECT country, COUNT(*) AS numSunk 
FROM Ships, Battles 
WHERE Ships.name = Battles.ship 
      AND battleName = 'Surigao Strait' 
      AND result = 'sunk' 
GROUP BY country 
UNION 
SELECT DISTINCT country, 0 AS numSunk 
FROM Ships ss 
WHERE ss.name IN (SELECT ship 
                  FROM Battles 
                  WHERE battleName = 'Surigao Strait') 
                  AND NOT EXISTS 
                  (SELECT * 
                  FROM Ships, Battles 
                  WHERE country = ss.country 
                        AND Ships.name = Battles.ship 
                        AND battleName = 'Surigao Strait' 
                        AND result = 'sunk')
