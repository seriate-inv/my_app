CREATE DATABASE IF NOT EXISTS my_app;
USE my_app;

-- TC Heating Coil Table
CREATE TABLE IF NOT EXISTS TC_Heating_coil (
    id INT AUTO_INCREMENT PRIMARY KEY,
    entry_index INT NOT NULL,
    temperature DECIMAL(10,2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
desc TC_Heating_coil;

-- Homogenizer Table (simplified and consistent)
CREATE TABLE IF NOT EXISTS homogenizer (
  id INT AUTO_INCREMENT PRIMARY KEY,
  entry_index INT,
  temperature DOUBLE,
  speed DOUBLE,
  timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
);
-- drop table TI5_heat_exchanger;
-- TI5 Heat Exchanger Table
DROP TABLE IF EXISTS TI5_heat_exchanger;
CREATE TABLE IF NOT EXISTS TI5_heat_exchanger (
    id INT AUTO_INCREMENT PRIMARY KEY,
    entry_index INT NOT NULL,
    temperature DECIMAL(10,2) NOT NULL,
    timestamp DATETIME NOT NULL
);
-- drop table homogenizer;
select * from TC_Heating_coil;
select * from homogenizer;
select * from TI5_heat_exchanger;

-- DROP TABLE TI122_chiller;
CREATE TABLE TI101_chiller (
    id INT AUTO_INCREMENT PRIMARY KEY,
    value DOUBLE NOT NULL,
    index_position INT NOT NULL,
    timestamp DATETIME NOT NULL
);
-- For TI107 (TI7)
CREATE TABLE IF NOT EXISTS TI107_chiller (
    id INT AUTO_INCREMENT PRIMARY KEY,
    value DOUBLE NOT NULL,
    index_position INT NOT NULL,
    timestamp DATETIME NOT NULL
);

-- For TI122 (TI22)
CREATE TABLE IF NOT EXISTS TI122_chiller (
    id INT AUTO_INCREMENT PRIMARY KEY,
    value DOUBLE NOT NULL,
    index_position INT NOT NULL,
    timestamp DATETIME NOT NULL
);

-- For TI109 (TI9) - Read-only display
CREATE TABLE IF NOT EXISTS TI109_chiller (
    id INT AUTO_INCREMENT PRIMARY KEY,
    value DOUBLE NOT NULL,
    index_position INT NOT NULL,
    timestamp DATETIME NOT NULL
);

-- For TI121 (TI21) - Read-only display
CREATE TABLE IF NOT EXISTS TI121_chiller (
    id INT AUTO_INCREMENT PRIMARY KEY,
    value DOUBLE NOT NULL,
    index_position INT NOT NULL,
    timestamp DATETIME NOT NULL
);

CREATE TABLE IF NOT EXISTS TI102_chiller (
    id INT AUTO_INCREMENT PRIMARY KEY,
    value DOUBLE NOT NULL,
    index_position INT NOT NULL,
    timestamp DATETIME NOT NULL
);


select * from TI101_chiller;
select * from TI107_chiller;
select * from TI122_chiller;
 