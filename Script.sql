CREATE DATABASE Hospital;
USE Hospital;


CREATE TABLE Departments (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Building INT NOT NULL CHECK (Building BETWEEN 1 AND 5),
    Financing MONEY NOT NULL CHECK (Financing >= 0) DEFAULT 0,
    Name NVARCHAR(100) NOT NULL UNIQUE CHECK (Name <> '')
);

CREATE TABLE Diseases (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL UNIQUE CHECK (Name <> '')
);

CREATE TABLE Doctors (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(MAX) NOT NULL CHECK (Name <> ''),
    Salary MONEY NOT NULL CHECK (Salary > 0),
    Surname NVARCHAR(MAX) NOT NULL CHECK (Surname <> '')
);

CREATE TABLE Examinations (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL UNIQUE CHECK (Name <> '')
);

CREATE TABLE Wards (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(20) NOT NULL UNIQUE CHECK (Name <> ''),
    Places INT NOT NULL CHECK (Places >= 1),
    DepartmentId INT NOT NULL FOREIGN KEY REFERENCES Departments(Id)
);

CREATE TABLE DoctorsExaminations (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Date DATE NOT NULL CHECK (Date <= GETDATE()) DEFAULT GETDATE(),
    DiseaseId INT NOT NULL FOREIGN KEY REFERENCES Diseases(Id),
    DoctorId INT NOT NULL FOREIGN KEY REFERENCES Doctors(Id),
    ExaminationId INT NOT NULL FOREIGN KEY REFERENCES Examinations(Id),
    WardId INT NOT NULL FOREIGN KEY REFERENCES Wards(Id)
);

CREATE TABLE Interns (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    DoctorId INT NOT NULL FOREIGN KEY REFERENCES Doctors(Id)
);

CREATE TABLE Professors (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    DoctorId INT NOT NULL FOREIGN KEY REFERENCES Doctors(Id)
);
-- INSERTING

INSERT INTO Departments (Building, Financing, Name)
VALUES
(1, 15000, 'Cardiology'),
(2, 20000, 'Ophthalmology'),
(3, 25000, 'Physiotherapy'),
(4, 30000, 'Neurology'),
(5, 35000, 'Pediatrics');

INSERT INTO Diseases (Name)
VALUES
('Hypertension'),
('Glaucoma'),
('Arthritis'),
('Migraine'),
('Asthma');

INSERT INTO Doctors (Name, Salary, Surname)
VALUES
('John', 5000, 'Doe'),
('Jane', 6000, 'Smith'),
('Alice', 7000, 'Johnson'),
('Bob', 8000, 'Brown'),
('Charlie', 9000, 'Davis');

INSERT INTO Wards (Name, Places, DepartmentId)
VALUES
('Ward A', 10, 1),
('Ward B', 20, 2),
('Ward C', 5, 3),
('Ward D', 15, 4),
('Ward E', 25, 5);

INSERT INTO Examinations (Name)
VALUES
('Blood Test'),
('Eye Exam'),
('X-Ray'),
('MRI'),
('Ultrasound');

INSERT INTO DoctorsExaminations (Date, DiseaseId, DoctorId, ExaminationId, WardId)
VALUES
('2023-10-01', 1, 1, 1, 1),
('2023-10-02', 2, 2, 2, 2),
('2023-10-03', 3, 3, 3, 3),
('2023-10-04', 4, 4, 4, 4),
('2023-10-05', 5, 5, 5, 5);

INSERT INTO Interns (DoctorId)
VALUES
(1),
(2);

INSERT INTO Professors (DoctorId)
VALUES
(3),
(4);

-- SELECTING 

SELECT W.Name, W.Places FROM Wards W
INNER JOIN Departments D ON W.DepartmentId = D.Id
WHERE D.Building = 5 And W.Places >= 5
AND EXISTS (SELECT 1 FROM Wards W2
			INNER JOIN Departments D2 ON W2.DepartmentId = D2.Id
			WHERE D2.Building = 5 AND W2.Places > 15
);

SELECT D.Name FROM Departments D
INNER JOIN Wards W ON W.DepartmentId = D.Id
INNER JOIN DoctorsExaminations DE ON DE.WardId = W.Id 
WHERE DE.Date >= (DATEADD(DAY, -7, GETDATE()));

SELECT D.Name FROM Diseases D 
LEFT JOIN DoctorsExaminations DE ON DE.DiseaseId = D.Id
WHERE DE.Id IS Null;

SELECT D.Name + ' ' + D.Surname AS FULL_NAME
FROM Doctors D
LEFT JOIN DoctorsExaminations DE ON DE.DoctorId = D.Id
WHERE DE.Id IS NULL;

SELECT DISTINCT D.Name FROM Departments D
LEFT JOIN Wards W ON W.DepartmentId = D.Id
LEFT JOIN DoctorsExaminations DE ON DE.WardId = W.Id
WHERE DE.Id IS NULL;

SELECT D.Surname FROM Doctors D
INNER JOIN Interns I ON I.DoctorId = D.Id;

SELECT D.Surname FROM Doctors D
INNER JOIN Interns I ON I.DoctorId = D.Id
WHERE D.Salary > ANY(SELECT D2.Salary FROM Doctors D2);

SELECT W.Name FROM Wards W
WHERE W.Places > ALL(
	SELECT W2.Places 
	FROM Wards W2 
	INNER JOIN Departments D ON W2.DepartmentId = D.Id
	WHERE D.Building = 3
);

SELECT D.Surname FROM Doctors D
INNER JOIN DoctorsExaminations DE ON DE.DoctorId = D.Id
INNER JOIN Wards W ON DE.WardId = W.Id
INNER JOIN Departments DEP ON W.DepartmentId = DEP.Id
WHERE DEP.Name IN ('Ophthalmology', 'Physiotherapy');

SELECT D.Name FROM Departments D
INNER JOIN Wards W ON W.DepartmentId = D.Id
INNER JOIN DoctorsExaminations DE ON DE.WardId = W.Id
INNER JOIN Doctors DOC ON DE.DoctorId = DOC.Id
WHERE DOC.Id IN (SELECT I.DoctorId FROM Interns I)
AND DOC.Id IN (SELECT P.DoctorId FROM Professors P);

SELECT Doc.Name + ' ' + Doc.Surname AS FullName, Dep.Name AS DepartmentName
FROM Doctors Doc
JOIN DoctorsExaminations DE ON Doc.Id = DE.DoctorId
JOIN Wards W ON DE.WardId = W.Id
JOIN Departments Dep ON W.DepartmentId = Dep.Id
WHERE Dep.Financing > 20000;

SELECT TOP 1 Dep.Name
FROM Departments Dep
JOIN Wards W ON Dep.Id = W.DepartmentId
JOIN DoctorsExaminations DE ON W.Id = DE.WardId
JOIN Doctors Doc ON DE.DoctorId = Doc.Id
ORDER BY Doc.Salary DESC;

SELECT D.Name, COUNT(DE.Id) FROM Diseases D
LEFT JOIN DoctorsExaminations DE ON DE.ExaminationId = D.Id
GROUP BY D.Name;

-- deleting db

DROP TABLE DoctorsExaminations;
DROP TABLE Interns;
DROP TABLE Professors;
DROP TABLE Examinations;
DROP TABLE Wards;
DROP TABLE Diseases;
DROP TABLE Doctors;
DROP TABLE Departments;

USE master;
DROP DATABASE Hospital;