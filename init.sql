CREATE TABLE `f1_circuit` (
  `id` int(11) NOT NULL AUTO_INCREMENT PRIMARY KEY,
  `name` varchar(191) NOT NULL,
  `location` varchar(191) NOT NULL,
  `country` varchar(100) NOT NULL,
  `length_km` double NOT NULL,
  `laps` int NOT NULL,
  `image` varchar(191)
);

INSERT INTO `f1_circuit` (`name`, `location`, `country`, `length_km`, `laps`, `image`) VALUES
('Monaco Grand Prix', 'Monte Carlo', 'Monaco', 3.337, 78, 'https://upload.wikimedia.org/wikipedia/commons/5/5b/Monte_Carlo_circuit.png'),
('Silverstone Circuit', 'Silverstone', 'UK', 5.891, 52, 'https://upload.wikimedia.org/wikipedia/commons/1/1a/Silverstone_Circuit_Layout.png'),
('Monza Circuit', 'Monza', 'Italy', 5.793, 53, 'https://upload.wikimedia.org/wikipedia/commons/d/d5/Monza_Circuit.svg'),
('Suzuka Circuit', 'Suzuka', 'Japan', 5.807, 53, 'https://upload.wikimedia.org/wikipedia/commons/6/66/Suzuka_Circuit.svg'),
('Spa-Francorchamps', 'Stavelot', 'Belgium', 7.004, 44, 'https://upload.wikimedia.org/wikipedia/commons/7/70/Circuit_de_Spa-Francorchamps.svg');
