DROP DATABASE IF EXISTS library;
CREATE DATABASE library;
USE library;

DROP TABLE IF EXISTS books;
CREATE TABLE books (
    isbn VARCHAR(25) PRIMARY KEY,
    book_title VARCHAR(60),
    category VARCHAR(20),
    rental_price DECIMAL(2 , 1 ),
    status VARCHAR(10),
    author VARCHAR(30),
    publisher VARCHAR(30)
);

DROP TABLE IF EXISTS branch;
CREATE TABLE branch(
	branch_id VARCHAR(15) PRIMARY KEY,
    manager_id VARCHAR(20),
    branch_address VARCHAR(20),
    contact_no VARCHAR(20)
    );
    
    
DROP TABLE IF EXISTS employee;
CREATE TABLE employee(
	emp_id VARCHAR(10) PRIMARY KEY,
    emp_name VARCHAR(20),
    position VARCHAR(20),
    salary INT,
	branch_id VARCHAR(15),
     FOREIGN KEY (branch_id) REFERENCES branch(branch_id)
    );

DROP TABLE IF EXISTS members;    
CREATE TABLE members(
	member_id VARCHAR(25) PRIMARY KEY,
    member_name VARCHAR(20),
    pmember_address VARCHAR(20),
    reg_date DATE
    );
    
DROP TABLE IF EXISTS issued_status;
CREATE TABLE issued_status(
	issued_id VARCHAR(15) PRIMARY KEY,
    issued_member_id VARCHAR(25),
    issued_book_name VARCHAR(60),
	issued_date DATE,
    issued_book_isbn VARCHAR(25),
    issued_emp_id VARCHAR(10),
	FOREIGN KEY ( issued_member_id ) REFERENCES members( member_id ),
	FOREIGN KEY ( issued_book_isbn ) REFERENCES books(isbn ),
    FOREIGN KEY ( issued_emp_id ) REFERENCES employee(emp_id )
    );
    
DROP TABLE IF EXISTS return_status;
CREATE TABLE return_status(
	return_id VARCHAR(15) PRIMARY KEY,
    issued_id VARCHAR(15),
    return_book_name VARCHAR(60),
	return_date DATE,
    return_book_isbn VARCHAR(25),
	FOREIGN KEY ( issued_id ) REFERENCES issued_status(issued_id)
    );
    
#Ensuring Whether the data is imported correctly or not
SELECT COUNT(*) FROM books;
SELECT COUNT(*) FROM branch;
SELECT COUNT(*) FROM employee;
SELECT COUNT(*) FROM members;
SELECT COUNT(*) FROM issued_status;
SELECT COUNT(*) FROM return_status;

SELECT * FROM books;
SELECT * FROM branch;
SELECT * FROM employee;
SELECT * FROM members;
SELECT * FROM issued_status;
SELECT * FROM return_status;

#1. create new book record into books table:  "('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"
INSERT INTO books(isbn,book_title, category, rental_price, status, author, publisher)
VALUES('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');
SELECT 
    *
FROM
    books;

#2. update an existing member's address: member_id = C107, address to 127 Walnut St
UPDATE members 
SET 
    member_address = '127 Walnut St'
WHERE
    member_id = 'C107';

SELECT 
    *
FROM
    members;


#3. delete a record from the issued_status table where issued_id = IS113.
#We cant delete the above record because it is linked with the return_status table.
#To delete this record from issued_status first we have to delete the record from return_status.
#then we can delete from the issued_status.
# or We Should drop and recreate the issued_id with ON DELETE CASCADE.
DELETE FROM return_status 
WHERE
    issued_id = 'IS113';
#deleteting record after deleting from the return_status.
DELETE FROM issued_status 
WHERE
    issued_id = 'IS113';
SELECT * FROM issued_status;


#4. retrieve all books issued by specific employee: emp_id = "E107"
SELECT 
   *
FROM
    issued_status
WHERE
    issued_emp_id = 'E107';

#5. lis members who issued more than one book
SELECT 
    COUNT(issued_emp_id), issued_emp_id
FROM
    issued_status
GROUP BY issued_emp_id
HAVING COUNT(issued_emp_id) > 1;

#6. create a summary table- each book and total book_issued__count
CREATE TABLE issued_books_count AS (SELECT isbn, book_title, COUNT(issued_id) AS total_book_count FROM
    books AS b
        LEFT JOIN
    issued_status AS ist ON b.isbn = ist.issued_book_isbn
GROUP BY isbn , book_title);
SELECT 
    *
FROM
    issued_books_count;
SELECT 
    SUM(total_book_count)
FROM
    issued_books_count;

#7. retrieve all books in specific category- "History"
SELECT 
    *
FROM
    books
WHERE
    category = 'History';

#8. find total rental price of each catgory
SELECT 
    category, SUM(rental_price)
FROM
    books
GROUP BY category
ORDER BY category;

#9. find total income by each catgory
SELECT 
    category, SUM(rental_price)
FROM
    issued_status AS ist
        JOIN
    books AS b ON ist.issued_book_isbn = b.isbn
GROUP BY category
ORDER BY category;

#10. list mmembers who registered in the last 180 days;
SELECT * FROM members
WHERE current_date()-reg_date<=180;

#11. list employee with branch Manager's name and branch details
SELECT 
    emp_id, manager_id, e.branch_id, branch_address, contact_no
FROM
    employee AS e
        JOIN
    branch AS b ON e.branch_id = b.branch_id;
    
#12. create a table of books with rental price above 5  (high_cost_books)
DROP TABLE IF EXISTS high_cost_books;
CREATE TABLE high_cost_books AS (SELECT * FROM
    books
WHERE
    rental_price > 6);
SELECT 
    *
FROM
    high_cost_books;
    
#13. retrieve the list of books not yet returned
SELECT 
    *
FROM
    issued_status AS isb
        LEFT JOIN
    return_status AS rs ON isb.issued_id = rs.issued_id
WHERE
    rs.return_id IS NULL;
#14. Identify members with Overdue Books(return period is 25 days)
SELECT 
    m.member_id,
    m.member_name,
    ist.issued_id,
    ist.issued_book_isbn,
    ist.issued_emp_id,
    rst.return_date
FROM
    issued_status AS ist
        LEFT JOIN
    members AS m ON ist.issued_member_id = m.member_id
        LEFT JOIN
    return_status AS rst ON rst.issued_id = ist.issued_id
WHERE
    return_date IS NULL
        AND CURRENT_DATE() - ist.issued_date > 25;

#15. CREATE TABLE FOR  branch performance report no.of books issued, no.of books returned and amount of revenue generated
CREATE TABLE branch_report AS (SELECT br.branch_id,
    COUNT(ist.issued_id),
    COUNT(rst.return_id),
    SUM(b.rental_price) FROM
    books AS b
        JOIN
    issued_status AS ist ON b.isbn = ist.issued_book_isbn
        JOIN
    employee AS e ON ist.issued_emp_id = e.emp_id
        JOIN
    branch AS br ON br.branch_id = e.branch_id
        LEFT JOIN
    return_status AS rst ON rst.issued_id = ist.issued_id
GROUP BY br.branch_id
ORDER BY br.branch_id);
SELECT * FROM branch_report;

#16. create table of actice members in last 1 year;
DROP TABLE IF EXISTS active_members;
CREATE TABLE active_members AS (SELECT * FROM
    issued_status AS ist
        JOIN
    members AS m ON ist.issued_member_id = m.member_id
WHERE
    ist.issued_date >= CURRENT_DATE() - INTERVAL 365 DAY);
SELECT 
    *
FROM
    active_members;

#17. find the employee the most books issued processed
SELECT 
    issued_emp_id,  COUNT(issued_emp_id) AS emp_id
FROM
    issued_status
GROUP BY issued_emp_id
ORDER BY COUNT(issued_emp_id) DESC;

#18. stored procedure for counting books of a specific category.
DROP PROCEDURE IF EXISTS cat_book_count;
DELIMITER //
CREATE  PROCEDURE cat_book_count(IN pcategory VARCHAR(20))
BEGIN
    DECLARE total_count INT;
    SELECT COUNT(*) INTO total_count  
    FROM books 
    WHERE category = pcategory;

    SELECT total_count AS book_count;
END //

DELIMITER ;

CALL cat_book_count('History');
SELECT * FROM  return_status;
#19. stored procedure to update book status on return.when book is returned the status in book should update from "No" to "Yes".
DROP PROCEDURE IF EXISTS update_status_on_return;
DELIMITER //
CREATE PROCEDURE update_status_on_return(preturn_id VARCHAR(20), pissued_id VARCHAR(20))
BEGIN
	DECLARE pisbn VARCHAR(20);
	INSERT INTO return_status(return_id, issued_id, return_date)
    VALUES(preturn_id, pissued_id, current_date()
    );
    SELECT issued_book_isbn INTO pisbn FROM issued_status WHERE issued_id = pissued_id;
    UPDATE  books
    SET status = 'Yes'
    WHERE isbn = pisbn;
    SELECT 'Book is updated';
END //
DELIMITER ;

CALL update_status_on_return("R119", "IS121");				
CALL update_status_on_return("RS120", 'IS136');

#20. stored procedure for issueing book if book status='yes' and then staus set to 'No' and  else if staus = 'No' say tell Unavailable.
#take parameter isbn which is book_id.
#and take issued id, issued member id and emp_id to update issued_status table.
DROP PROCEDURE IF EXISTS update_status_on_book_issue;
DELIMITER //
CREATE PROCEDURE update_status_on_book_issue(pbook_id VARCHAR(20), pissued_id VARCHAR(10), pissued_member_id VARCHAR(20), pissued_emp_id VARCHAR(20))
BEGIN
	DECLARE book_status VARCHAR(20);
    DECLARE book_name VARCHAR(60);
    SELECT status, book_title INTO book_status,book_name FROM books WHERE isbn = pbook_id;
    IF book_status = "Yes" THEN
		INSERT INTO issued_status(issued_id,issued_member_id, issued_book_name, issued_date, issued_book_isbn, issued_emp_id)
        VALUES(pissued_id, pissued_member_id, book_name, CURRENT_DATE(), pbook_id,pissued_emp_id);
        UPDATE books 
        SET status = 'No'
        WHERE isbn = pbook_id;
		SELECT 'Book is Issued Successfully';
	ELSE 
		SELECT 'Sorry, Currently the book is not available';
	END IF;
END //
DELIMITER ;
SELECT * FROM books;
CALL update_status_on_book_issue('978-0-06-025492-6', 'IS141', 'C105', 'E105');
CALL update_status_on_book_issue('978-0-06-112008-4', 'IS142','C104', 'E106');

#21. create Trigger to update book status from 'No' to 'Yes' in books table on insertion in retrun_status table
DROP TRIGGER IF EXISTS update_book_status_on_book_return;

CREATE 
    TRIGGER  update_book_status_on_book_return
 AFTER INSERT ON return_status FOR EACH ROW 
    UPDATE books SET books.status = 'Yes' WHERE
        books.isbn = NEW.return_book_isbn;
INSERT INTO return_status(return_id,issued_id, return_date, return_book_isbn) 
VALUES('RS121','IS142', CURRENT_DATE(), '978-0-06-112008-4');
SELECT 
    *
FROM
    books;
SELECT 
    *
FROM
    return_status;
