CREATE DATABASE Academy;
USE Academy;

CREATE TABLE Teachers (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(MAX) NOT NULL,
    Surname NVARCHAR(MAX) NOT NULL
);

CREATE TABLE Assistants (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    TeacherId INT NOT NULL,
    FOREIGN KEY (TeacherId) REFERENCES Teachers(Id)
);

CREATE TABLE Curators (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    TeacherId INT NOT NULL,
    FOREIGN KEY (TeacherId) REFERENCES Teachers(Id)
);

CREATE TABLE Deans (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    TeacherId INT NOT NULL,
    FOREIGN KEY (TeacherId) REFERENCES Teachers(Id)
);

CREATE TABLE Heads (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    TeacherId INT NOT NULL,
    FOREIGN KEY (TeacherId) REFERENCES Teachers(Id)
);

CREATE TABLE Faculties (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Building INT NOT NULL CHECK (Building BETWEEN 1 AND 5),
    Name NVARCHAR(100) NOT NULL UNIQUE,
    DeanId INT NOT NULL,
    FOREIGN KEY (DeanId) REFERENCES Deans(Id)
);

CREATE TABLE Departments (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Building INT NOT NULL CHECK (Building BETWEEN 1 AND 5),
    Name NVARCHAR(100) NOT NULL UNIQUE,
    FacultyId INT NOT NULL,
    HeadId INT NOT NULL,
    FOREIGN KEY (FacultyId) REFERENCES Faculties(Id),
    FOREIGN KEY (HeadId) REFERENCES Heads(Id)
);

CREATE TABLE Groups (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(10) NOT NULL UNIQUE,
    Year INT NOT NULL CHECK (Year BETWEEN 1 AND 5),
    DepartmentId INT NOT NULL,
    FOREIGN KEY (DepartmentId) REFERENCES Departments(Id)
);

CREATE TABLE GroupsCurators (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    CuratorId INT NOT NULL,
    GroupId INT NOT NULL,
    FOREIGN KEY (CuratorId) REFERENCES Curators(Id),
    FOREIGN KEY (GroupId) REFERENCES Groups(Id)
);

CREATE TABLE Subjects (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE Lectures (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    SubjectId INT NOT NULL,
    TeacherId INT NOT NULL,
    FOREIGN KEY (SubjectId) REFERENCES Subjects(Id),
    FOREIGN KEY (TeacherId) REFERENCES Teachers(Id)
);

CREATE TABLE GroupsLectures (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    GroupId INT NOT NULL,
    LectureId INT NOT NULL,
    FOREIGN KEY (GroupId) REFERENCES Groups(Id),
    FOREIGN KEY (LectureId) REFERENCES Lectures(Id)
);

CREATE TABLE LectureRooms (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Building INT NOT NULL CHECK (Building BETWEEN 1 AND 5),
    Name NVARCHAR(10) NOT NULL UNIQUE
);

CREATE TABLE Schedules (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Class INT NOT NULL CHECK (Class BETWEEN 1 AND 8),
    DayOfWeek INT NOT NULL CHECK (DayOfWeek BETWEEN 1 AND 7),
    Week INT NOT NULL CHECK (Week BETWEEN 1 AND 52),
    LectureId INT NOT NULL,
    LectureRoomId INT NOT NULL,
    FOREIGN KEY (LectureId) REFERENCES Lectures(Id),
    FOREIGN KEY (LectureRoomId) REFERENCES LectureRooms(Id)
);

-- INSERTING

INSERT INTO Teachers (Name, Surname) VALUES
('Edward', 'Hopper'),
('Alex', 'Carmack'),
('John', 'Doe'),
('Jane', 'Smith'),
('Michael', 'Johnson');

INSERT INTO Assistants (TeacherId) VALUES
(1), (2), (3);

INSERT INTO Curators (TeacherId) VALUES
(4), (5);

INSERT INTO Deans (TeacherId) VALUES
(1), (2);

INSERT INTO Heads (TeacherId) VALUES
(3), (4);

INSERT INTO Faculties (Building, Name, DeanId) VALUES
(1, 'Computer Science', 1),
(2, 'Mathematics', 2);

INSERT INTO Departments (Building, Name, FacultyId, HeadId) VALUES
(1, 'Software Development', 1, 1),
(2, 'Data Science', 1, 2);

INSERT INTO Groups (Name, Year, DepartmentId) VALUES
('F505', 5, 1),
('F404', 4, 2);

INSERT INTO GroupsCurators (CuratorId, GroupId) VALUES
(1, 1), (2, 2);

INSERT INTO Subjects (Name) VALUES
('Database Systems'),
('Algorithms'),
('Web Development');

INSERT INTO Lectures (SubjectId, TeacherId) VALUES
(1, 1), (2, 2), (3, 3);

INSERT INTO LectureRooms (Building, Name) VALUES
(1, 'A311'),
(2, 'A104'),
(3, 'B201');

INSERT INTO Schedules (Class, DayOfWeek, Week, LectureId, LectureRoomId) VALUES
(1, 1, 1, 1, 1),
(2, 3, 2, 2, 2),
(3, 5, 3, 3, 3);


-- SELECTING

-- 1
SELECT LR.Name FROM LectureRooms LR
INNER JOIN Schedules S ON S.LectureRoomId = LR.Id
INNER JOIN Lectures L ON S.LectureId = L.Id
INNER JOIN Teachers T ON L.TeacherId = T.Id
WHERE T.Name = 'Edward' AND T.Surname = 'Hopper'
GROUP BY LR.Name;

-- 2
SELECT DISTINCT T.Surname FROM Teachers T
INNER JOIN Assistants A ON T.Id = A.TeacherId
INNER JOIN Lectures L ON T.Id = L.TeacherId
INNER JOIN GroupsLectures GL ON GL.GroupId = L.Id
INNER JOIN Groups G ON GL.GroupId = G.Id
WHERE G.Name = 'F505';

-- 3
SELECT S.Name FROM Subjects S
INNER JOIN Lectures L ON L.SubjectId = S.Id
INNER JOIN Teachers T ON L.TeacherId = T.Id
INNER JOIN GroupsLectures GL ON GL.LectureId = L.Id
INNER JOIN Groups G ON GL.GroupId = G.Id
WHERE T.Name = 'Alex' AND T.Surname = 'Carmack' AND G.Year = 5
GROUP BY S.Name;

-- 4
SELECT DISTINCT T.Surname FROM Teachers T
WHERE T.Id NOT IN (
	SELECT DISTINCT L.TeacherId FROM Lectures L
	INNER JOIN Schedules S ON S.LectureId = L.Id
	WHERE S.DayOfWeek = 1
);

-- 5
SELECT LR.Name, LR.Building FROM LectureRooms LR
WHERE LR.Id NOT IN (
	SELECT DISTINCT S.LectureRoomId 
	FROM Schedules S
	WHERE S.DayOfWeek = 3
	AND S.Week = 2
	AND S.Class = 3
);

-- 6
SELECT DISTINCT T.Name, T.Surname
FROM Teachers T
JOIN Deans D ON T.Id = D.TeacherId
JOIN Faculties F ON D.Id = F.DeanId
JOIN Departments Dep ON Dep.FacultyId = F.Id
JOIN Groups G ON G.DepartmentId = Dep.Id
JOIN GroupsLectures GL ON GL.GroupId = G.Id
JOIN Lectures L ON GL.LectureId = L.Id
WHERE F.Name = 'Computer Science'
AND T.Id NOT IN (
    SELECT C.TeacherId
    FROM Curators C
    JOIN GroupsCurators GC ON C.Id = GC.CuratorId
    JOIN Groups G ON GC.GroupId = G.Id
    JOIN Departments Dep ON G.DepartmentId = Dep.Id
    WHERE Dep.Name = 'Software Development'
);


-- 7 
SELECT Building FROM Faculties
UNION
SELECT Building FROM LectureRooms
UNION
SELECT Building FROM Departments;

-- 8 task
SELECT T.Name, T.Surname, 'Dean' AS Role
FROM Teachers T
JOIN Deans D ON T.Id = D.TeacherId
UNION
SELECT T.Name, T.Surname, 'Head' AS Role
FROM Teachers T
JOIN Heads H ON T.Id = H.TeacherId
UNION
SELECT T.Name, T.Surname, 'Teacher' AS Role
FROM Teachers T
WHERE T.Id NOT IN (SELECT TeacherId FROM Deans UNION SELECT TeacherId FROM Heads UNION SELECT TeacherId FROM Curators UNION SELECT TeacherId FROM Assistants)
UNION
SELECT T.Name, T.Surname, 'Curator' AS Role
FROM Teachers T
JOIN Curators C ON T.Id = C.TeacherId
UNION
SELECT T.Name, T.Surname, 'Assistant' AS Role
FROM Teachers T
JOIN Assistants A ON T.Id = A.TeacherId
ORDER BY Role;

-- 9
SELECT DISTINCT S.DayOfWeek FROM Schedules S
INNER JOIN LectureRooms LR ON S.LectureRoomId = LR.Id
WHERE LR.Name IN ('A311', 'A104');

-- deleting db

DROP TABLE GroupsCurators;
DROP TABLE GroupsLectures;
DROP TABLE Schedules;
DROP TABLE Lectures;
DROP TABLE GroupLectures;
DROP TABLE Students;

DROP TABLE Assistants;
DROP TABLE Curators;
DROP TABLE Deans;
DROP TABLE Heads;
DROP TABLE Groups;
DROP TABLE Departments;
DROP TABLE Faculties;
DROP TABLE LectureRooms;
DROP TABLE Subjects;
DROP TABLE Teachers;

USE master;
DROP DATABASE Academy;