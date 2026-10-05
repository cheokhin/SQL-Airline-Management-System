
CREATE DATABASE airline_database;

CREATE TABLE Country(
CountryCode CHAR(2) PRIMARY KEY,
CountryName VARCHAR(50) UNIQUE NOT NULL
);

CREATE TABLE Passenger(
PassengerID CHAR(7) PRIMARY KEY,
PassengerName VARCHAR(50) NOT NULL,
PassengerDOB DATE NOT NULL,
PassportNo VARCHAR(50) UNIQUE NOT NULL,
Nationality CHAR(2) NOT NULL,
Contact VARCHAR(20),
CONSTRAINT FK_Passenger_Country FOREIGN KEY (Nationality) REFERENCES Country(CountryCode)
);


CREATE TABLE TierStatus(
TierStatusID INT IDENTITY PRIMARY KEY,
TierStatusName VARCHAR(20) UNIQUE NOT NULL
);


CREATE TABLE FrequentFlyer(
FrequentFlyerNo CHAR(6) PRIMARY KEY,
PassengerID CHAR(7) UNIQUE NOT NULL,
JoinDate DATE NOT NULL,
TierStatusID INT NOT NULL,
MilesBalance INT NOT NULL,
LastAccrualDate DATE NOT NULL,
CONSTRAINT FK_FrequentFlyer_Passenger FOREIGN KEY (PassengerID) REFERENCES Passenger(PassengerID),
CONSTRAINT FK_FrequentFlyer_TierStatus FOREIGN KEY (TierStatusID) REFERENCES TierStatus(TierStatusID)
);


CREATE TABLE BookingChannel(
BookingChannelID INT IDENTITY PRIMARY KEY,
BookingChannelName VARCHAR(20) UNIQUE NOT NULL
);


CREATE TABLE Booking(
PNR CHAR(5) PRIMARY KEY,
PassengerID CHAR(7) NOT NULL,
BookingDate DATE NOT NULL,
BookingChannelID INT NOT NULL,
CONSTRAINT FK_Booking_Passenger FOREIGN KEY (PassengerID) REFERENCES Passenger(PassengerID),
CONSTRAINT FK_Booking_BookingChannel FOREIGN KEY (BookingChannelID) REFERENCES BookingChannel(BookingChannelID)
);


CREATE TABLE AircraftType(
AircraftTypeNo INT IDENTITY PRIMARY KEY,
AircraftModel VARCHAR(50) UNIQUE NOT NULL,
Capacity INT NOT NULL,
CONSTRAINT CK_AircraftType_Capacity CHECK (Capacity > 0)
);


CREATE TABLE FlightRoute(
RouteNo INT IDENTITY PRIMARY KEY,
Origin VARCHAR(50) NOT NULL,
OriginCountry CHAR(2) NOT NULL,
Destination VARCHAR(50) NOT NULL,
DestinationCountry CHAR(2) NOT NULL,
Distance INT,
CONSTRAINT FK_FlightRoute_OriginCountry FOREIGN KEY (OriginCountry) REFERENCES Country(CountryCode),
CONSTRAINT FK_FlightRoute_DestinationCountry FOREIGN KEY (DestinationCountry) REFERENCES Country(CountryCode),
CONSTRAINT CK_FlightRoute_OriginDestination CHECK (Origin <> Destination),
CONSTRAINT CK_FlightRoute_Distance CHECK (Distance >= 0)
);


CREATE TABLE Flight(
FlightNo VARCHAR(20) PRIMARY KEY,
RouteNo INT NOT NULL,
DepartureTime DATETIME NOT NULL,
ArrivalTime DATETIME NOT NULL,
AircraftTypeNo INT NOT NULL,
CONSTRAINT FK_Flight_FlightRoute FOREIGN KEY (RouteNo) REFERENCES FlightRoute(RouteNo),
CONSTRAINT FK_Flight_AircraftType FOREIGN KEY (AircraftTypeNo) REFERENCES AircraftType(AircraftTypeNo),
CONSTRAINT CK_Flight_DepartureBeforeArrival CHECK (DepartureTime < ArrivalTime)
);


CREATE TABLE TicketClass(
TicketClassID INT IDENTITY PRIMARY KEY,
TicketClassName VARCHAR(20) UNIQUE NOT NULL
);


CREATE TABLE Ticket(
TicketNo VARCHAR(20) PRIMARY KEY,
PNR CHAR(5) NOT NULL,
FlightNo VARCHAR(20) NOT NULL,
Price DECIMAL(10,2) NOT NULL,
TicketClassID INT NOT NULL,
SeatNo VARCHAR(5) NOT NULL,
BaggageFee DECIMAL(10,2) NOT NULL DEFAULT 0,
SeatSelectionFee DECIMAL(10,2) NOT NULL DEFAULT 0,
CONSTRAINT FK_Ticket_Booking FOREIGN KEY (PNR) REFERENCES Booking(PNR),
CONSTRAINT FK_Ticket_Flight FOREIGN KEY (FlightNo) REFERENCES Flight(FlightNo),
CONSTRAINT FK_Ticket_Class FOREIGN KEY (TicketClassID) REFERENCES TicketClass(TicketClassID),
CONSTRAINT UQ_Ticket_FlightSeat UNIQUE (FlightNo, SeatNo),
CONSTRAINT CK_Ticket_BaggageFee CHECK (BaggageFee >= 0),
CONSTRAINT CK_Ticket_SeatSelectionFee CHECK (SeatSelectionFee >= 0)
);


CREATE TABLE RefundStatus(
RefundStatusID INT IDENTITY PRIMARY KEY,
RefundStatusName VARCHAR(8) UNIQUE NOT NULL
);


CREATE TABLE Payment(
PaymentID CHAR(7) PRIMARY KEY,
PNR CHAR(5) UNIQUE NOT NULL,
Amount DECIMAL(10,2) NOT NULL,
PaymentDate DATE NOT NULL,
RefundStatusID INT NULL,
RefundAmount DECIMAL(10,2) NULL,
RefundRequestDate DATE NULL,
CONSTRAINT FK_Payment_Booking FOREIGN KEY (PNR) REFERENCES Booking(PNR),
CONSTRAINT FK_Payment_RefundStatus FOREIGN KEY (RefundStatusID) REFERENCES RefundStatus(RefundStatusID),
CONSTRAINT CK_Payment_Amount CHECK (Amount >= 0),
CONSTRAINT CK_Payment_RefundConsistency CHECK (
	(RefundStatusID IS NULL AND RefundAmount IS NULL AND RefundRequestDate IS NULL)
	OR (RefundStatusID IS NOT NULL AND RefundAmount IS NOT NULL AND RefundRequestDate IS NOT NULL)
)
);


CREATE TABLE Reward(
RewardID CHAR(4) PRIMARY KEY,
RewardName VARCHAR(50) NOT NULL,
MilesRequired INT NOT NULL,
Value DECIMAL(10,2) NOT NULL
);


CREATE TABLE RewardRedemption(
RedemptionID CHAR(5) PRIMARY KEY,
FrequentFlyerNo CHAR(6) NOT NULL,
RewardID CHAR(4) NOT NULL,
RedemptionDate DATE NOT NULL,
CONSTRAINT FK_RewardRedemption_FrequentFlyer FOREIGN KEY (FrequentFlyerNo) REFERENCES FrequentFlyer(FrequentFlyerNo),
CONSTRAINT FK_RewardRedemption_Reward FOREIGN KEY (RewardID) REFERENCES Reward(RewardID)
);


CREATE TABLE SpecialService(
ServiceID CHAR(4) PRIMARY KEY,
ServiceName VARCHAR(50) NOT NULL,
StandardFee DECIMAL(10,2) NOT NULL,
CONSTRAINT CK_SpecialService_StandardFee CHECK (StandardFee >= 0)
);


CREATE TABLE TicketSpecialService(
TicketNo VARCHAR(20) NOT NULL,
ServiceID CHAR(4) NOT NULL,
CONSTRAINT PK_TicketSpecialService PRIMARY KEY(TicketNo, ServiceID),
CONSTRAINT FK_TicketSpecialService_Ticket FOREIGN KEY(TicketNo) REFERENCES Ticket(TicketNo),
CONSTRAINT FK_TicketSpecialService_SpecialService FOREIGN KEY(ServiceID) REFERENCES SpecialService(ServiceID)
);


INSERT INTO Country
(CountryCode, CountryName)
VALUES
('MY', 'Malaysia'),
('SG', 'Singapore'),
('CN', 'China'),
('US', 'United States'),
('UK', 'United Kingdom'),
('AU', 'Australia'),
('CA', 'Canada'),
('IN', 'India'),
('PH', 'Philippines'),
('JP', 'Japan'),
('BR', 'Brazil'),
('SA', 'South Africa');


INSERT INTO Passenger
(PassengerID, PassengerName, PassengerDOB, PassportNo, Nationality, Contact)
VALUES
('P000001' , 'John' , '1990-01-01' , 'A12345678' , 'MY' , '+60 12 3334444') ,
('P000002' , 'Mary' , '1985-05-10' , 'A34567888' , 'MY' , '+60 11 55855899') ,
('P000003' , 'Adam' , '1988-07-22' , 'A98765432' , 'CN' , '+86 10 1234 5678') ,
('P000004' , 'James' , '1992-09-15' , 'A99887766' , 'MY' , '+60 19 221 5999') ,
('P000005' , 'Steven' , '1980-12-03' , 'A43210987' , 'US' , '+1 123 456 7890') ,
('P000006' , 'Alice' , '1995-11-11' , 'A11223344' , 'MY' , '+60 12 8888999') ,
('P000007' , 'Robert' , '1978-03-28' , 'B22334455' , 'UK' , '+44 20 7946 0958') ,
('P000008' , 'Linda' , '1993-02-17' , 'C33445566' , 'AU' , '+61 3 9999 8888') ,
('P000009' , 'Michael' , '1986-04-14' , 'D44556677' , 'MY' , '+60 10 2222333') ,
('P000010' , 'Sarah' , '1990-06-06' , 'E55667788' , 'CA' , '+1 416 555 0199') ,
('P000011' , 'Emma' , '1987-03-12' , 'F12345678' , 'MY' , '+60 17 9999000') ,
('P000012' , 'Chong' , '1991-08-25' , 'G23456789' , 'MY' , '+60 19 8888111') ,
('P000013' , 'Priya' , '1995-12-05' , 'H34567890' , 'IN' , '+91 9876543210') ,
('P000014' , 'Lee' , '2000-07-14' , 'J45678901' , 'CN' , '+86 10 87654321') ,
('P000015' , 'Miguel' , '1983-02-20' , 'K56789012' , 'PH' , '+63 9123456789') ,
('P000016' , 'Sara' , '1992-11-30' , 'L67890123' , 'MY' , '+60 13 7654321') ,
('P000017' , 'Yuki' , '1998-05-09' , 'M78901234' , 'JP' , '+81 90 12345678') ,
('P000018' , 'Carlos' , '1975-06-02' , 'N89012345' , 'BR' , '+55 11 99998888') ,
('P000019' , 'Anna' , '1989-09-18' , 'O90123456' , 'AU' , '+61 412345678') ,
('P000020' , 'Wei' , '1993-10-22' , 'P01234567' , 'CN' , '+86 21 12348765') ,
('P000021' , 'Nadia' , '1994-04-16' , 'Q12345098' , 'MY' , '+60 12 3456789') ,
('P000022' , 'Omar' , '1990-12-29' , 'R23450109' , 'SA' , '+966 50 1234567') ,
('P000023' , 'Sofia' , '1997-01-03' , 'S34501230' , 'UK' , '+44 7911122233') ,
('P000024' , 'Tom' , '1981-06-07' , 'T45612345' , 'US' , '+1 213 5556677') ,
('P000025' , 'Zara' , '1996-08-19' , 'U56723456' , 'MY' , '+60 14 9991234'),
('P000026' , 'Lucy' , '2015-02-11' , 'A79881766' , 'MY' , '+60 14 0495532'),
('P000027' , 'Harden' , '1989-08-26' , 'T41025375' , 'US' , '+1 213 1565687'),
('P000028', 'Aisha', '1999-03-30', 'V67890123', 'MY', '+60 11 22334455'),
('P000029', 'Noah', '2016-01-19', 'Y90124567', 'SG', '+65 81234567'),
('P000030', 'Elena', '1997-12-24', 'Z34561278', 'CA', '+1 604 8887777');


INSERT INTO TierStatus
(TierStatusName)
VALUES ('Bronze'), ('Silver'), ('Gold'), ('Platinum');


INSERT INTO FrequentFlyer
(FrequentFlyerNo, PassengerID, JoinDate, TierStatusID, MilesBalance, LastAccrualDate)
VALUES
('FF0001' , 'P000001' , '2019-01-01' , 2 , 55000 , '2024-01-01'),
('FF0002' , 'P000002' , '2020-03-01' , 1 , 14500 , '2024-01-02'),
('FF0003' , 'P000003' , '2021-02-05' , 3 , 2500 , '2024-01-03'),
('FF0004' , 'P000006' , '2021-05-10' , 1 , 9000 , '2024-01-04'),
('FF0005' , 'P000007' , '2021-08-12' , 2 , 20000 , '2024-01-05'),
('FF0006' , 'P000008' , '2021-11-01' , 3 , 3200 , '2024-01-06'),
('FF0007' , 'P000010' , '2022-06-18' , 1 , 8000 , '2024-01-07'),
('FF0008' , 'P000011' , '2022-09-01' , 1 , 12000 , '2024-02-10'),
('FF0009' , 'P000012' , '2023-01-15' , 1 , 5000 , '2024-03-05'),
('FF0010' , 'P000013' , '2023-06-20' , 2 , 30000 , '2024-04-01'),
('FF0011' , 'P000014' , '2023-12-01' , 2 , 45000 , '2024-01-20'),
('FF0012' , 'P000015' , '2024-03-10' , 3 , 60000 , '2024-05-06'),
('FF0013' , 'P000016' , '2024-03-30' , 1 , 8000 , '2024-06-01'),
('FF0014' , 'P000017' , '2024-04-12' , 1 , 15000 , '2024-10-20'),
('FF0015' , 'P000018' , '2024-04-25' , 3 , 52000 , '2024-05-15'),
('FF0016' , 'P000019' , '2024-05-11' , 2 , 25000 , '2024-05-28'),
('FF0017' , 'P000020' , '2025-01-15' , 2 , 40000 , '2025-03-18'),
('FF0018' , 'P000021' , '2025-02-07' , 1 , 7000 , '2025-03-02'),
('FF0019' , 'P000022' , '2025-02-14' , 3 , 55000 , '2025-03-22'),
('FF0020' , 'P000023' , '2025-03-08' , 2 , 33000 , '2025-04-18'),
('FF0021' , 'P000024' , '2025-03-17' , 1 , 9000 , '2025-04-30'),
('FF0022' , 'P000025' , '2025-04-02' , 1 , 6000 , '2025-05-05'),
('FF0023', 'P000030', '2024-12-01', 2, 50000, '2025-06-01');


INSERT INTO BookingChannel (BookingChannelName)
VALUES ('Website'), ('Mobile App'), ('Agent');


INSERT INTO Booking
(PNR, PassengerID, BookingDate, BookingChannelID)
VALUES
('R0001', 'P000001', '2020-04-05', 2),
('R0002', 'P000002', '2022-04-06', 1),
('R0003', 'P000003', '2022-06-10', 1),
('R0004', 'P000004', '2023-02-10', 3),
('R0005', 'P000005', '2024-03-01', 2),
('R0006', 'P000006', '2024-05-01', 1),
('R0007', 'P000007', '2024-07-01', 2),
('R0008', 'P000008', '2024-06-01', 1),
('R0009', 'P000009', '2024-04-15', 3),
('R0010', 'P000010', '2024-01-10', 2),
('R0011', 'P000011', '2024-01-15', 1),
('R0012', 'P000012', '2024-02-20', 2),
('R0013', 'P000013', '2024-03-10', 3),
('R0014', 'P000014', '2024-03-25', 1),
('R0015', 'P000015', '2024-04-01', 2),
('R0016', 'P000016', '2024-04-12', 3),
('R0017', 'P000017', '2024-04-18', 1),
('R0018', 'P000018', '2024-04-22', 2),
('R0019', 'P000019', '2024-04-28', 3),
('R0020', 'P000020', '2024-05-05', 1),
('R0021', 'P000021', '2024-05-10', 2),
('R0022', 'P000022', '2024-05-15', 3),
('R0023', 'P000023', '2024-05-20', 1),
('R0024', 'P000024', '2024-05-25', 2),
('R0025', 'P000025', '2024-06-08', 3),
('R0026', 'P000026', '2025-01-08', 2),
('R0027', 'P000027', '2025-01-10', 2),
('R0028', 'P000028', '2025-06-10', 1),
('R0029', 'P000029', '2025-03-15', 2),
('R0030', 'P000005', '2025-02-28', 3),
('R0031', 'P000030', '2025-05-15', 1),
('R0032', 'P000026', '2025-05-30', 1);


INSERT INTO RefundStatus (RefundStatusName)
VALUES ('Pending'), ('Approved'), ('Rejected');


INSERT INTO Payment
(PaymentID, PNR, Amount, PaymentDate, RefundStatusID, RefundAmount, RefundRequestDate)
VALUES
('PAY0001', 'R0001', 2000, '2024-04-05', NULL, NULL, NULL),
('PAY0002', 'R0002', 500, '2022-04-07', NULL, NULL, NULL),
('PAY0003', 'R0003', 300, '2022-02-10', NULL, NULL, NULL),
('PAY0004', 'R0004', 1200, '2023-02-12', 2, 1200, '2023-02-13'),
('PAY0005', 'R0005', 1800, '2024-03-05', NULL, NULL, NULL),
('PAY0006', 'R0006', 600, '2024-05-02', NULL, NULL, NULL),
('PAY0007', 'R0007', 1500, '2023-07-02', 2, 1500, '2023-07-03'),
('PAY0008', 'R0008', 750, '2024-06-02', NULL, NULL, NULL),
('PAY0009', 'R0009', 1100, '2024-04-16', NULL, NULL, NULL),
('PAY0010', 'R0010', 1300, '2024-01-11', NULL, NULL, NULL),
('PAY0011', 'R0011', 1800, '2024-01-15', NULL, NULL, NULL),
('PAY0012', 'R0012', 400,  '2024-02-20', 2, 100, '2024-02-22'),
('PAY0013', 'R0013', 750,  '2024-03-10', NULL, NULL, NULL),
('PAY0014', 'R0014', 2200, '2024-03-25', 3, 200, '2024-03-30'),
('PAY0015', 'R0015', 1300, '2024-04-01', NULL, NULL, NULL),
('PAY0016', 'R0016', 410,  '2024-04-12', 2, 150, '2024-04-14'),
('PAY0017', 'R0017', 800,  '2024-04-18', NULL, NULL, NULL),
('PAY0018', 'R0018', 950,  '2024-04-22', NULL, NULL, NULL),
('PAY0019', 'R0019', 2000, '2024-04-28', 3, 500, '2024-05-02'),
('PAY0020', 'R0020', 400,  '2024-05-05', NULL, NULL, NULL),
('PAY0021', 'R0021', 1700, '2024-05-10', 2, 250, '2024-05-11'),
('PAY0022', 'R0022', 2100, '2024-05-15', 3, 300, '2024-05-16'),
('PAY0023', 'R0023', 850,  '2024-05-20', NULL, NULL, NULL),
('PAY0024', 'R0024', 1950, '2024-05-25', 2, 200, '2024-05-27'),
('PAY0025', 'R0025', 1200, '2024-06-08', NULL, NULL, NULL),
('PAY0026', 'R0026', 300, '2025-01-08', NULL, NULL, NULL),
('PAY0027', 'R0027', 300, '2025-01-11', NULL, NULL, NULL),
('PAY0028', 'R0030', 800, '2025-03-01', 2, 800, '2025-03-02');


INSERT INTO AircraftType
(AircraftModel, Capacity)
VALUES
('Boeing 737', 160),
('Airbus A350', 180),
('Airbus A330', 280);


INSERT INTO FlightRoute
(Origin, OriginCountry, Destination, DestinationCountry, Distance)
VALUES
('KL', 'MY', 'Melbourne', 'AU', 4000),
('KL', 'MY', 'Singapore', 'SG', 190),
('KL', 'MY', 'Tokyo', 'JP', 3300),
('KL', 'MY', 'Langkawi', 'MY', 250),
('Florida', 'US', 'KL', 'MY', 10000),
('Cebu', 'PH', 'KL', 'MY', 1600);


INSERT INTO Flight
(FlightNo, RouteNo, DepartureTime, ArrivalTime, AircraftTypeNo)
VALUES
('F0001' , 1 , '2023-03-01 10:00' , '2023-03-01 17:45' , 3),
('F0002' , 2 , '2023-08-05 18:00' , '2023-08-05 19:30' , 1),
('F0003' , 3 , '2024-10-10 02:00' , '2024-10-10 09:10' , 2),
('F0004' , 3 , '2024-10-11 05:00' , '2024-10-11 12:10' , 2),
('F0005' , 2 , '2025-01-10 04:00' , '2025-01-10 05:30' , 1),
('F0006' , 1 , '2025-01-11 10:00' , '2025-01-11 17:45' , 3),
('F0007' , 5 , '2025-01-20 00:00' , '2025-01-20 22:15' , 1),
('F0008' , 4 , '2025-01-27 00:00' , '2025-01-27 01:15' , 1),
('F0009' , 1 , '2025-02-21 11:00' , '2025-02-21 18:45' , 3),
('F00010' , 2 , '2025-02-25 14:00' , '2025-02-25 15:30' , 1),
('F00011' , 1 , '2025-03-01 20:00' , '2025-03-02 03:45' , 3),
('F00012' , 2 , '2025-05-15 03:00' , '2025-05-15 04:30' , 1),
('F00013' , 6 , '2025-06-05 07:00' , '2025-06-05 13:30' , 3),
('F00014' , 1 , '2025-06-06 10:00' , '2025-06-06 17:45' , 3),
('F00015' , 6 , '2025-06-10 03:00' , '2025-06-10 09:30' , 3);


INSERT INTO TicketClass
(TicketClassName)
VALUES ('Economy'), ('Business'), ('First-Class');


INSERT INTO Ticket
(TicketNo, PNR, FlightNo, Price, TicketClassID, SeatNo, BaggageFee, SeatSelectionFee)
VALUES
('T0001', 'R0001', 'F0001', 1800, 3, '1A', 200, 0),
('T0002', 'R0002', 'F0002', 400, 2, '2C', 0, 0),
('T0003', 'R0003', 'F0002', 300, 1, '7A', 0, 0),
('T0004', 'R0004', 'F0003', 1100, 1, '10F', 100, 0),
('T0005', 'R0005', 'F0003', 900, 2, '3B', 45, 20),
('T0006', 'R0006', 'F0004', 1200, 3, '2A', 90, 35),
('T0007', 'R0007', 'F0005', 500, 1, '5A', 0, 0),
('T0008', 'R0008', 'F0001', 1700, 2, '4C', 60, 25),
('T0009', 'R0009', 'F0002', 600, 1, '6B', 10, 10),
('T0010', 'R0010', 'F0003', 1000, 2, '7C', 50, 15),
('T0011', 'R0011', 'F0001', 1800, 2, '3A', 50, 20),
('T0012', 'R0012', 'F0002', 400, 1, '4B', 0, 0),
('T0013', 'R0013', 'F0003', 750, 1, '5C', 20, 10),
('T0014', 'R0014', 'F0004', 2200, 3, '1A', 100, 50),
('T0015', 'R0015', 'F0005', 1300, 2, '2D', 60, 20),
('T0016', 'R0016', 'F0001', 410, 1, '4E', 0, 0),
('T0017', 'R0017', 'F0002', 800, 2, '6A', 40, 10),
('T0018', 'R0018', 'F0003', 950, 2, '7B', 60, 15),
('T0019', 'R0019', 'F0004', 2000, 3, '2B', 90, 30),
('T0020', 'R0020', 'F0005', 400, 1, '5E', 0, 0),
('T0021', 'R0021', 'F0001', 1700, 2, '6C', 55, 25),
('T0022', 'R0022', 'F0002', 2100, 3, '1C', 100, 50),
('T0023', 'R0023', 'F0003', 850, 1, '3D', 25, 5),
('T0024', 'R0024', 'F0004', 1950, 3, '2C', 95, 40),
('T0025', 'R0025', 'F0009', 1200, 3, '1C', 100, 50),
('T0026', 'R0026', 'F0008', 300, 1, '1A', 0, 0),
('T0027', 'R0027', 'F0008', 2000, 1, '1B', 0, 0),
('T0028', 'R0028', 'F00012', 450, 1, '9A', 0, 0),
('T0029', 'R0029', 'F00010', 700, 2, '10A', 75, 0),
('T0030', 'R0030', 'F00010', 600, 1, '11C', 30, 10),
('T0031', 'R0031', 'F00012', 600, 1, '12C', 30, 10),
('T0032', 'R0032', 'F0008', 200, 1, '15D', 0, 0);


INSERT INTO Reward
(RewardID, RewardName, MilesRequired, Value)
VALUES
('R001', 'Discount', 1000, 200),
('R002', 'Upgrade', 3000, 600),
('R003', 'Meal', 500, 100),
('R004', 'Merchandise', 500, 100);


INSERT INTO RewardRedemption
(RedemptionID , FrequentFlyerNo , RewardID , RedemptionDate)
VALUES
('RD001' , 'FF0001' , 'R003' , '2024-04-05'),
('RD002' , 'FF0002' , 'R004' , '2022-04-10'),
('RD003' , 'FF0005' , 'R001' , '2024-05-15'),
('RD004' , 'FF0006' , 'R002' , '2024-06-05'),
('RD005', 'FF0010', 'R001', '2025-01-18'),
('RD006', 'FF0023', 'R001', '2025-06-01'),
('RD007', 'FF0023', 'R002', '2025-06-10');


INSERT INTO SpecialService
(ServiceID , ServiceName , StandardFee)
VALUES
('S001' , 'Meal' , 40),
('S002' , 'Wheelchair' , 20),
('S003' , 'Pet travel' , 100);


INSERT INTO TicketSpecialService
(TicketNo, ServiceID)
VALUES 
('T0001', 'S001'),
('T0001', 'S003'),
('T0002', 'S001'),
('T0003', 'S002'),
('T0004', 'S002'),
('T0005', 'S001'),
('T0031', 'S002');





-- List all passengers who have booked flights in the business or first-class with their respective ticket numbers, flight numbers, and departure times. 
SELECT P.PassengerName, T.TicketNo, T.FlightNo, F.DepartureTime, TC.TicketClassName 
FROM Passenger P, Booking B, Ticket T, Flight F, TicketClass TC
WHERE P.PassengerID = B.PassengerID 
	AND B.PNR = T.PNR 
	AND T.FlightNo = F.FlightNo 
	AND T.TicketClassID = TC.TicketClassID 
	AND TC.TicketClassName IN ('Business', 'First-Class');
	
-- Show the total number of passengers who have booked tickets through the website for economy class in the last 30 days. 
SELECT COUNT(*) AS TotalPassengers
FROM Passenger P, Booking B, Ticket T, TicketClass TC, BookingChannel BC
WHERE P.PassengerID = B.PassengerID 
	AND B.PNR = T.PNR 
	AND T.TicketClassID = TC.TicketClassID 
	AND B.BookingChannelID = BC.BookingChannelID 
	AND TC.TicketClassName = 'Economy' 
	AND BC.BookingChannelName = 'Website' 
	AND B.BookingDate >= DATEADD(DAY, -30, GETDATE());

-- Display the average baggage fee for passengers in business and first-class over the last 6 months. 
SELECT AVG(T.BaggageFee) AS AverageBaggageFee
FROM Ticket T, TicketClass TC, Booking B
WHERE T.TicketClassID = TC.TicketClassID
	AND T.PNR = B.PNR
	AND TC.TicketClassName IN ('Business', 'First-Class')
	AND B.BookingDate >= DATEADD(MONTH,�-6,�GETDATE());

-- Show the list of members who have earned more than 50,000 miles in total, along with their associated flight routes (Origin-Destination). 
SELECT DISTINCT
    P.PassengerName,
    FR.Origin + '-' + FR.Destination AS Route,
    FF.MilesBalance
FROM FrequentFlyer FF
JOIN Passenger P ON FF.PassengerID = P.PassengerID
JOIN Booking B ON P.PassengerID = B.PassengerID
JOIN Ticket T ON T.PNR = B.PNR
JOIN Flight F ON T.FlightNo = F.FlightNo
JOIN FlightRoute FR ON F.RouteNo = FR.RouteNo
WHERE FF.MilesBalance�>�50000;

-- Show the list of refunds requested by passengers where the refund amount is greater than the average refund for month of March, including the Passenger Name, Refund Amount, and Refund Status.
SELECT 
    P.PassengerName,
    PY.RefundAmount,
    RS.RefundStatusName AS RefundStatus
FROM Payment PY
JOIN Booking B ON PY.PNR = B.PNR
JOIN Passenger P ON B.PassengerID = P.PassengerID
JOIN RefundStatus RS ON PY.RefundStatusID = RS.RefundStatusID
WHERE PY.RefundAmount > (
    SELECT AVG(RefundAmount)
    FROM Payment
    WHERE RefundAmount IS NOT NULL
        AND MONTH(RefundRequestDate)�=�3
);

-- Find the total revenue generated for each ticket class (Economy, Business, First-Class) for all bookings in the last 6 months, broken down by flight route (Origin-Destination). Exclude passengers who have requested refunds in the last 6 months. 
SELECT 
    FR.Origin + '-' + FR.Destination AS Route,
    TC.TicketClassName,
    SUM(T.Price + T.BaggageFee + T.SeatSelectionFee) AS TotalRevenue
FROM Ticket T
JOIN Booking B ON T.PNR = B.PNR
JOIN Flight F ON T.FlightNo = F.FlightNo
JOIN FlightRoute FR ON F.RouteNo = FR.RouteNo
JOIN TicketClass TC ON T.TicketClassID = TC.TicketClassID
WHERE 
    B.BookingDate >= DATEADD(MONTH, -6, GETDATE())
    AND B.PNR NOT IN (
        SELECT PNR FROM Payment
        WHERE RefundRequestDate >= DATEADD(MONTH, -6, GETDATE())
    )
GROUP BY FR.Origin, FR.Destination, TC.TicketClassName
ORDER BY Route, TC.TicketClassName;
 
-- List the 5 flights with the highest number of bookings. Include flight number, origin, destination, and number of bookings. 
SELECT TOP 5 
    T.FlightNo,
    FR.Origin,
    FR.Destination,
    COUNT(*) AS NumBookings
FROM Ticket T
JOIN Flight F ON T.FlightNo = F.FlightNo
JOIN FlightRoute FR ON F.RouteNo = FR.RouteNo
GROUP BY T.FlightNo, FR.Origin, FR.Destination
ORDER BY NumBookings DESC;

-- Which passenger has redeemed the most expensive reward in January 2025, and what is the name and value of that reward?
SELECT TOP 1
    P.PassengerName,
    R.RewardName,
    R.Value
FROM RewardRedemption RR
JOIN FrequentFlyer FF ON RR.FrequentFlyerNo = FF.FrequentFlyerNo
JOIN Passenger P ON FF.PassengerID = P.PassengerID
JOIN Reward R ON RR.RewardID = R.RewardID
WHERE RR.RedemptionDate >= '2025-01-01' AND RR.RedemptionDate < '2025-02-01'
ORDER BY R.Value DESC;

-- List the full names of passengers who have booked wheelchair assistance and redeemed at least one reward, where the value of the redeemed reward is greater than the average value of all rewards. Group the results by the service name. 

WITH HighValueRedeem AS (
    SELECT DISTINCT FF.PassengerID
    FROM RewardRedemption RR
    JOIN FrequentFlyer FF ON RR.FrequentFlyerNo = FF.FrequentFlyerNo
    JOIN Reward R ON RR.RewardID = R.RewardID
    WHERE R.Value > (SELECT AVG(Value) FROM Reward)
),
WheelchairUsers AS (
    SELECT DISTINCT B.PassengerID
    FROM TicketSpecialService TSS
    JOIN SpecialService SS ON TSS.ServiceID = SS.ServiceID
    JOIN Ticket T ON TSS.TicketNo = T.TicketNo
    JOIN Booking B ON T.PNR = B.PNR
    WHERE SS.ServiceName = 'Wheelchair'
)
SELECT P.PassengerName, 'Wheelchair' AS ServiceName
FROM Passenger P
WHERE P.PassengerID IN (SELECT PassengerID FROM HighValueRedeem)
  AND P.PassengerID IN (SELECT PassengerID FROM WheelchairUsers);

-- Identify the days with the least travelers for the February 2025.
WITH DailyCounts AS (
    SELECT CAST(DepartureTime AS DATE) AS TravelDate, COUNT(*) AS TotalTravelers
    FROM Ticket T
    JOIN Flight F ON T.FlightNo = F.FlightNo
    WHERE DepartureTime >= '2025-02-01' AND DepartureTime < '2025-03-01'
    GROUP BY CAST(DepartureTime AS DATE)
)
SELECT TravelDate, TotalTravelers
FROM DailyCounts
WHERE TotalTravelers = (SELECT MIN(TotalTravelers) FROM DailyCounts);

-- Find number of passengers who have taken domestic flights in the month of January 2025.
SELECT COUNT(DISTINCT B.PassengerID) AS NumDomesticPassengers_Jan2025
FROM Ticket T
JOIN Flight F ON T.FlightNo = F.FlightNo
JOIN FlightRoute FR ON F.RouteNo = FR.RouteNo
JOIN Booking B ON T.PNR = B.PNR
WHERE FR.OriginCountry = 'MY' AND FR.DestinationCountry = 'MY'
	AND F.DepartureTime >= '2025-01-01' AND F.DepartureTime < '2025-02-01';

-- Find the number of passengers above 15 years old on domestic flights.
SELECT COUNT(DISTINCT B.PassengerID) AS NumDomesticPassengers_Above15
FROM Ticket T
JOIN Flight F ON T.FlightNo = F.FlightNo
JOIN FlightRoute FR ON F.RouteNo = FR.RouteNo
JOIN Booking B ON T.PNR = B.PNR
JOIN Passenger P ON B.PassengerID = P.PassengerID
WHERE FR.OriginCountry = 'MY' AND FR.DestinationCountry = 'MY'
	AND DATEDIFF(YEAR, P.PassengerDOB, F.DepartureTime) > 15;

-- Show the total ticket revenue for flights departing in January 2025, grouped by flight number and ordered by highest revenue. 
SELECT F.FlightNo, SUM(T.Price + T.BaggageFee + T.SeatSelectionFee) AS TotalRevenue
FROM Ticket T
JOIN Flight F ON T.FlightNo = F.FlightNo
WHERE F.DepartureTime BETWEEN '2025-01-01' AND '2025-01-31'
GROUP BY F.FlightNo
ORDER BY TotalRevenue DESC;

-- Which month has the highest prices for international flights?
SELECT TOP 1 MONTH(F.DepartureTime) AS MonthNumber, AVG(T.Price) AS AveragePrice
FROM Ticket T
JOIN Flight F ON T.FlightNo = F.FlightNo
JOIN FlightRoute FR ON F.RouteNo = FR.RouteNo
WHERE FR.OriginCountry <> 'MY' OR FR.DestinationCountry <> 'MY'
GROUP BY MONTH(F.DepartureTime)
ORDER BY AveragePrice DESC;

--  Which class is most preferred by passengers for their flights?
SELECT TOP 1 TC.TicketClassName, COUNT(*) AS NumberOfBookings
FROM Ticket T
JOIN TicketClass TC ON T.TicketClassID = TC.TicketClassID
GROUP BY TC.TicketClassName
ORDER BY NumberOfBookings DESC;	
