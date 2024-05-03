SELECT * FROM GetTotalBilledThisMonth_ProfG_FP;


UPDATE  S23916715.Invoice_ProfG_FP
SET status = 'CANCELLED'
WHERE id IN (1, 2, 3, 4, 5 ,6, 8, 10, 12, 23, 38)