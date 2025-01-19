-- Library Management System SQL Project :

-- [1] CREATING TABLE : 

DROP TABLE IF EXISTS branch ;
DROP TABLE IF EXISTS employees;
DROP TABLE IF EXISTS books;
DROP TABLE IF EXISTS issued_status;
DROP TABLE IF EXISTS members;
DROP TABLE IF EXISTS return_status;

CREATE TABLE branch(
branch_id VARCHAR(50) PRIMARY KEY,
manager_id  VARCHAR(50),
branch_address  VARCHAR(50),
contact_no VARCHAR(50)
);

CREATE TABLE employees(
emp_id VARCHAR(50) PRIMARY KEY,
emp_name VARCHAR(50),
job_position VARCHAR(50),
salary INT ,
branch_id VARCHAR(50) --FK
);

ALTER TABLE employees
ALTER COLUMN salary TYPE FLOAT;

CREATE TABLE books(
isbn VARCHAR(50) PRIMARY KEY,
book_title VARCHAR(100),
category VARCHAR(50),
rental_price FLOAT,
status VARCHAR(25),
author VARCHAR(50),
publisher VARCHAR(50)
);

CREATE TABLE issued_status(
issued_id VARCHAR(50) PRIMARY KEY,
issued_member_id VARCHAR(50), --FK
issued_book_name VARCHAR(100),
issued_date	 DATE,
issued_book_isbn VARCHAR(50), --FK
issued_emp_id VARCHAR(50) -- FK
);

CREATE TABLE members (
member_id VARCHAR(50) PRIMARY KEY,
member_name VARCHAR(50),
member_address VARCHAR(75),
reg_date  DATE
);

CREATE TABLE return_status (
return_id VARCHAR(50) PRIMARY KEY,
issued_id VARCHAR(50), 
return_book_name  VARCHAR(100),
return_date DATE,
return_book_isbn VARCHAR(50) --FK
);

ALTER TABLE return_status
DROP CONSTRAINT return_status_issued_id_fkey; 

INSERT INTO return_status(return_id, issued_id, return_date) 
VALUES
('RS101', 'IS101', '2023-06-06'),
('RS102', 'IS105', '2023-06-07'),
('RS103', 'IS103', '2023-08-07'),
('RS104', 'IS106', '2024-05-01'),
('RS105', 'IS107', '2024-05-03'),
('RS106', 'IS108', '2024-05-05'),
('RS107', 'IS109', '2024-05-07'),
('RS108', 'IS110', '2024-05-09'),
('RS109', 'IS111', '2024-05-11'),
('RS110', 'IS112', '2024-05-13'),
('RS111', 'IS113', '2024-05-15'),
('RS112', 'IS114', '2024-05-17'),
('RS113', 'IS115', '2024-05-19'),
('RS114', 'IS116', '2024-05-21'),
('RS115', 'IS117', '2024-05-23'),
('RS116', 'IS118', '2024-05-25'),
('RS117', 'IS119', '2024-05-27'),
('RS118', 'IS120', '2024-05-29');

-- FOREIGN KEY : 

ALTER TABLE employees 
ADD FOREIGN KEY (branch_id) REFERENCES branch(branch_id) ON DELETE CASCADE ;

ALTER TABLE issued_status 
ADD FOREIGN KEY (issued_book_isbn) REFERENCES books(isbn) ON DELETE CASCADE ;

ALTER TABLE issued_status 
ADD FOREIGN KEY (issued_emp_id) REFERENCES employees(emp_id) ON DELETE CASCADE ;

ALTER TABLE issued_status 
ADD FOREIGN KEY (issued_member_id) REFERENCES members(member_id) ON DELETE CASCADE ;

ALTER TABLE return_status 
ADD FOREIGN KEY (issued_id) REFERENCES issued_status(issued_id) ON DELETE CASCADE ;

ALTER TABLE return_status 
ADD FOREIGN KEY (return_book_isbn) REFERENCES books(isbn) ON DELETE CASCADE ;

SELECT * FROM books;
SELECT * FROM branch;
SELECT * FROM employees ;
SELECT * FROM members;
SELECT * FROM issued_status;
SELECT * FROM return_status;



--[1] CRUD Operations : 

--Task 1. Create a New Book Record -- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"

SELECT 
	*
FROM
	books;


INSERT INTO
	books(isbn,book_title,category,rental_price,status,author,publisher)
VALUES
	('978-1-60129-456-2',
	'To Kill a Mockingbird',
	'Classic', 
	6.00,
	'yes',
	'Harper Lee',
	'J.B. Lippincott & Co.'
	);

SELECT 
	* 
FROM
	books
WHERE
	isbn = '978-1-60129-456-2';


--Task 2: Update an Existing Member's Address


SELECT
	* 
FROM 
	members;

UPDATE members 
SET member_address = '123 Oak st'
WHERE member_id = 'C101';

SELECT
	* 
FROM
	members
WHERE member_id = 'C101';


--Task 3: Delete a Record from the Issued Status Table -- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.


SELECT 
	* 
FROM 
	issued_status;

DELETE FROM issued_status
WHERE issued_id = 'IS121';

SELECT 
	* 
FROM 
	issued_status;


--Task 4: Retrieve All Books Issued by a Specific Employee -- Objective: Select all books issued by the employee with emp_id = 'E101'.


SELECT 
	* 
FROM
	issued_status 
WHERE issued_emp_id = 'E101'; 


-- Task 5: List Members Who Have Issued More Than One Book -- Objective: Use GROUP BY to find members who have issued more than one book.


SELECT 
	issued_emp_id AS empid,
	count(issued_id) AS No_Of_Books_Issued 
FROM 
	issued_status
GROUP BY empid 
HAVING count(issued_id) > 1 
ORDER BY count(issued_id) desc ;


--[2] CTAS (Create Table As Select) :


--Task 6: Create Summary Tables: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt**


DROP TABLE IF EXISTS  issued_book_cnt ;

CREATE TABLE issued_book_cnt AS
SELECT 
	b.book_title ,
	b. category , 
	COUNT(i.issued_book_isbn) AS No_of_Book_Issued 
FROM 
	books b 
JOIN issued_status i ON b.isbn = i.issued_book_isbn 
GROUP BY b.book_title , b.category;

SELECT * FROM issued_book_cnt ORDER BY no_of_book_issued desc;


-- [3]  Data Analysis & Findings : 


--Task 7. Retrieve All Books in a Specific Category:

SELECT 
	category ,
	book_title 
FROM 
	books 
GROUP BY category , book_title
ORDER BY category; 


--Task 8: Find Total Rental Income by Category:  ( VERY GOOD QUESTION )


SELECT
	b.category ,
	SUM(b.rental_price) Total_Rental_Price 
FROM
	books b
JOIN issued_status i ON b.isbn = i.issued_book_isbn
GROUP BY category
ORDER BY SUM(rental_price) DESC; 


--TASK 9 : List Members Who Registered in the Last 180 Days:

SELECT 
	* 
FROM 
	members 
WHERE reg_date >= CURRENT_DATE - INTERVAL '180 Days'  ;


--TASK 10 : List Employees with Their Branch Manager's Name and their branch details: ( VERY GOOD QUESTION )

SELECT 
	e2.* ,
	e.emp_id as manager_id , 
	e.emp_name AS manager_name , 
	b.branch_id , 
	b.branch_address
FROM 
	branch b 
JOIN employees e ON b.branch_id = e.branch_id 
JOIN employees e2 ON b.manager_id = e.emp_id;


--Task 11. Create a Table of Books with Rental Price Above a Certain Threshold 6USD:

DROP TABLE IF EXISTS book_price_greater_6;

CREATE TABLE book_price_greater_6 AS
SELECT 
	* 
FROM
	books 
WHERE rental_price > 6 ;

SELECT
	* 
FROM 
	book_price_greater_6 
ORDER BY rental_price;

--Task 12: Retrieve the List of Books Not Yet Returned : (GOOD QUESTION)

SELECT
	 i.issued_book_name
FROM 
	issued_status i
LEFT JOIN return_status r ON i.issued_id = r.issued_id 
WHERE r.issued_id IS NULL
ORDER BY i.issued_book_name;


-- [4] Advanced SQL Operations

INSERT INTO issued_status(issued_id, issued_member_id, issued_book_name, issued_date, issued_book_isbn, issued_emp_id)
VALUES
('IS151', 'C118', 'The Catcher in the Rye', CURRENT_DATE - INTERVAL '24 days',  '978-0-553-29698-2', 'E108'),
('IS152', 'C119', 'The Catcher in the Rye', CURRENT_DATE - INTERVAL '13 days',  '978-0-553-29698-2', 'E109'),
('IS153', 'C106', 'Pride and Prejudice', CURRENT_DATE - INTERVAL '7 days',  '978-0-14-143951-8', 'E107'),
('IS154', 'C105', 'The Road', CURRENT_DATE - INTERVAL '32 days',  '978-0-375-50167-0', 'E101');

ALTER TABLE return_status
ADD Column book_quality VARCHAR(15) DEFAULT('Good');

UPDATE return_status
SET book_quality = 'Damaged'
WHERE issued_id 
    IN ('IS112', 'IS117', 'IS118');
SELECT * FROM return_status;

-- Task 13: Identify Members with Overdue Books
-- Write a query to identify members who have overdue books (assume a 30-day return period). Display the member's_id, member's name, book title, issue date, and days overdue.

SELECT 
	member_id , 
	member_name , 
	issued_book_name , 
	issued_date , 
	CURRENT_DATE - (issued_date + INTERVAL '30 days') AS overdue_days 
FROM 
	(
	SELECT
		* , 
		CASE WHEN CURRENT_DATE >  issued_date + INTERVAL '30 Days' THEN 'OVERDUE'
		ELSE 'NO OVERDUE'
		END AS book_return_status
	FROM
		issued_status i 
	LEFT JOIN return_status r ON i.issued_id = r.issued_id 
	JOIN members m ON member_id = issued_member_id 
	WHERE return_date IS NULL
	)
WHERE book_return_status = 'OVERDUE'
ORDER BY 1;

--Task 14: Update Book Status on Return
--Write a query to update the status of books in the books table to "Yes" when they are returned (based on entries in the return_status table).

SELECT * FROM books;
SELECT * FROM return_status ;
SELECT * FROM issued_status ;

INSERT INTO return_status(return_id, issued_id, return_date , book_quality)
VALUES
('RS125', 'IS130',  CURRENT_DATE, 'Good' );


SELECT 
	r.return_id ,
	i.issued_id , 
	r.return_book_name , 
	r.return_date ,
	r.return_book_isbn , 
	CASE WHEN return_id IS NOT NULL THEN 'YES'
	ELSE 'NO'
	END AS book_return_status
FROM
	issued_status i 
LEFT JOIN return_status r ON i.issued_id = r.issued_id
ORDER BY 2;

-- WE CAN DO THIS TASK USING STORED PROCEDURE : 

CREATE OR REPLACE PROCEDURE book_return( p_return_id VARCHAR(50) , p_issued_id VARCHAR(50) , p_book_quality VARCHAR(15))
LANGUAGE plpgsql 
AS $$

DECLARE
v_isbn VARCHAR(50);

BEGIN

SELECT issued_book_isbn INTO v_isbn FROM issued_status WHERE issued_id = p_issued_id;

INSERT INTO return_status(return_id,issued_id,return_date,book_quality)
VALUES(p_return_id , p_issued_id , CURRENT_DATE , p_book_quality);

UPDATE books
SET status = 'yes'
WHERE isbn = v_isbn;

END;
$$

DROP PROCEDURE IF EXISTS book_return( p_return_id VARCHAR(50) , p_issued_id VARCHAR(50) , p_book_quality VARCHAR(15));


CALL book_return( 'RS135' , 'IS135' , 'Good'); 

--Task 15: Branch Performance Report
--Create a query that generates a performance report for each branch, showing the number of books issued, the number of books returned, and the total revenue generated from book rentals.

SELECT * from branch;
SELECT * FROM issued_status;
SELECT * FROM return_status;
SELECT * FROM books ;
SELECT * FROM employees ;

DROP TABLE IF EXISTS Branch_Performance_Report;

CREATE TABLE Branch_Performance_Report AS (
SELECT 
	 br.branch_id , 
	 COUNT(i.issued_id) AS no_of_book_issued ,
	 COUNT(r.return_id) AS no_of_book_returned ,
	 SUM(b.rental_price) AS revenue_generated
FROM
	branch br 
LEFT JOIN employees e ON br.branch_id = e.branch_id 
LEFT JOIN issued_status i ON e.emp_id = i.issued_emp_id
LEFT JOIN return_status r ON r.issued_id = i.issued_id
LEFT JOIN books b ON i.issued_book_isbn = b.isbn
GROUP BY 1
ORDER BY br.branch_id
);

SELECT * FROM Branch_Performance_Report ;


--Task 16: CTAS: Create a Table of Active Members
--Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing members who have issued at least one book in the last 2 months.

DROP TABLE IF EXISTS Active_Members ;

CREATE TABLE Active_Members AS (
SELECT
	member_id AS Active_Member_id ,
	member_name ,
	member_address,
	COUNT(issued_member_id) No_of_book_purchased ,
	MAX(issued_date) Latest_book_issued_date 
FROM 
	(SELECT
		* 
	FROM 
		issued_status i 
	JOIN members m ON i.issued_member_id = m.member_id 
	GROUP BY m.member_id , i.issued_id
	HAVING MAX(i.issued_date) >= CURRENT_DATE -  INTERVAL '2 Months' AND  COUNT(i.issued_member_id) >= 1 
	ORDER BY i.issued_date 
	) 
GROUP BY 1,2,3 
ORDER BY COUNT(issued_member_id)
);

SELECT * FROM active_members ;




--Task 17: Find Employees with the Most Book Issues Processed
--Write a query to find the top 3 employees who have processed the most book issues. Display the employee name, number of books processed, and their branch.

SELECT 
	e.emp_name ,
	b.* ,
	COUNT(issued_id) AS no_of_book_processed 
FROM branch b 
JOIN employees e ON b.branch_id = e.branch_id 
JOIN issued_status i ON e.emp_id = i.issued_emp_id 
GROUP BY 1,2
ORDER BY COUNT(issued_id) ;


--Task 18: Identify Members Issuing High-Risk Books
--Write a query to identify members who have issued books more than twice with the status "damaged" in the books table. Display the member name, book title, and the number of times they've issued damaged books.

SELECT * FROM issued_status ;
SELECT * FROM members;
SELECT * FROM  return_status; 

SELECT 
	m.member_id ,
	m.member_name ,
	i.issued_book_name AS Book_Title 
FROM  return_status r
LEFT JOIN issued_status i ON i.issued_id = r.issued_id
JOIN members m ON i.issued_member_id = m.member_id 
WHERE r.book_quality = 'Damaged';


--Task 19: Stored Procedure Objective: Create a stored procedure to manage the status of books in a library system.
--Description: Write a stored procedure that updates the status of a book in the library based on its issuance.
--The procedure should function as follows: The stored procedure should take the book_id as an input parameter. 
--The procedure should first check if the book is available (status = 'yes'). 
--If the book is available, it should be issued, and the status in the books table should be updated to 'no'.
--If the book is not available (status = 'no'), the procedure should return an error message indicating that the book is currently not available.

SELECT * from branch;
SELECT * FROM issued_status;
SELECT * FROM return_status;
SELECT * FROM books ;
SELECT * FROM employees ;

DROP PROCEDURE IF EXISTS book_status(p_issued_id VARCHAR(50) , p_issued_member_id VARCHAR(50), p_issued_emp_id VARCHAR(50),p_isbn VARCHAR(50));

CREATE OR REPLACE PROCEDURE book_status(p_issued_id VARCHAR(50) , p_issued_member_id VARCHAR(50), p_issued_emp_id VARCHAR(50),p_isbn VARCHAR(50))
LANGUAGE plpgsql
AS $$

DECLARE
	v_book_status VARCHAR(25);
	v_book VARCHAR(100);
BEGIN

SELECT status INTO v_book_status FROM books WHERE isbn = p_isbn ;

SELECT book_title INTO v_book FROM books WHERE isbn = p_isbn;

IF v_book_status = 'yes' THEN 

	INSERT INTO issued_status(issued_id,issued_member_id,issued_book_name,issued_date,issued_book_isbn,issued_emp_id)
	VALUES (p_issued_id,p_issued_member_id,v_book,CURRENT_DATE,p_isbn,p_issued_emp_id);

	UPDATE books
	SET status = 'no'
	WHERE isbn = p_isbn;
ELSE 
	RAISE NOTICE 'The Book is Currently Not Avalilable!!';
END IF ;

END;
$$

CALL book_status('IS160' , 'C107', 'E107','978-0-14-118776-1');

UPDATE books
SET status = 'yes'
WHERE isbn = '978-0-679-77644-3';



/*
Task 20: Create Table As Select (CTAS) Objective: Create a CTAS (Create Table As Select) query to identify overdue books and calculate fines.

Description: Write a CTAS query to create a new table that lists each member and the books they have issued but not returned within 30 days. The table should include: The number of overdue books. The total fines, with each day's fine calculated at $0.50. The number of books issued by each member. The resulting table should show: Member ID Number of overdue books Total fines

*/


SELECT * FROM issued_status;
SELECT * FROM members ;
SELECT * FROM return_status;

CREATE TABLE  overdue_book_fines AS (
SELECT member_id , count(no_of_issued_books) AS no_of_books , SUM(Total_fine) AS Fine FROM (
SELECT  
	m.member_id , 
	count(i.issued_id) AS No_of_issued_books , 
	EXTRACT( DAY FROM (CURRENT_DATE + interval '30 Days'- i.issued_date)) AS  due_days ,
	(EXTRACT( DAY FROM (CURRENT_DATE + interval '30 Days'- i.issued_date)) * 0.50) AS Total_fine
FROM 
	issued_status i 
LEFT JOIN return_status rs ON i.issued_id = rs.issued_id 
LEFT JOIN members m ON i.issued_member_id = m.member_id 
WHERE rs.return_id IS NULL AND i.issued_date < CURRENT_DATE - INTERVAL'30 Days'
GROUP BY 1 , i.issued_date )
GROUP BY 1
);












