-- Insert 100 customers with realistic data
INSERT INTO customers (first_name, last_name, email, phone, city, created_at)
SELECT
	ELT((n % 12) + 1,
		'surya','vijay','Aditya','Arjun','Vihaan','Reyansh',
		'Ishaan','Kabir','Anaya','Diya','Aadhya','Ira'
	) AS first_name,
	ELT((n % 12) + 1,
		'kumar','Verma','Patel','Reddy','Iyer','Nair',
		'Gupta','nambi','sam','Joshi','Chopra','Bose'
	) AS last_name,
	CONCAT(
		LOWER(ELT((n % 12) + 1,
			'surya','vijay','Aditya','Arjun','Vihaan','Reyansh',
			'Ishaan','Kabir','arbi','Diya','Aadhya','Ira'
		)),
		'.',
		LOWER(ELT((n % 12) + 1,
			'kumar','Verma','Patel','Reddy','Iyer','Nair',
			'Gupta','nambi','sam','Joshi','Chopra','Bose'
		)),
		n,
		'@example.com'
	) AS email,
	CONCAT('+91', LPAD(((n * 7919) % 10000000000), 10, '0')) AS phone,
	ELT((n % 10) + 1,
		'Mumbai','Delhi','Bengaluru','Hyderabad','Chennai',
		'Kolkata','Pune','Coimbatore','madurai','Kochi'
	) AS city,
	CURRENT_DATE - INTERVAL (n % 365) DAY AS created_at
FROM (
	SELECT a.n + (b.n * 10) + 1 AS n
	FROM (
		SELECT 0 AS n UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4
		UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9
	) a
	CROSS JOIN (
		SELECT 0 AS n UNION ALL SELECT 1 UNION ALL SELECT 2 UNION ALL SELECT 3 UNION ALL SELECT 4
		UNION ALL SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7 UNION ALL SELECT 8 UNION ALL SELECT 9
	) b
) seq
WHERE n <= 100;

