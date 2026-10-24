-- Run as the operating-system root user:  sudo mysql < create-dba-user.sql
-- The course's working account. IF NOT EXISTS makes the script safe to run again; the password is the
-- course value (a lab password: never use it on a real server).
CREATE USER IF NOT EXISTS 'dba'@'localhost' IDENTIFIED BY 'Course#Pass84';
-- Full rights on every database, but no GRANT OPTION: dba cannot hand its rights to other accounts.
GRANT ALL PRIVILEGES ON *.* TO 'dba'@'localhost';
