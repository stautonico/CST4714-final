CREATE OR ALTER VIEW S23916715.View_Customers_ProfG_FP AS
SELECT id,
       CONCAT(
               LEFT(email, 1), -- Grab the first letter from the username
               REPLICATE('*',
                         LEN(SUBSTRING(email, 2, CHARINDEX('@', email) - 2))), -- Mask everything in between the first and last letter of the username portion of the address
               RIGHT(email, 1), -- Grab the first letter from the username
               SUBSTRING(email, CHARINDEX('@', email), LEN(email)) -- Append the domain
       ) AS masked_email,
       CONCAT(
               '***-***-',
               SUBSTRING(phone_num, 9, 4)
       ) AS masked_phone_number,
       first_name,
       last_name,
       address,
       address_line_two,
       city,
       state,
       zip_code
FROM S23916715.Customer_ProfG_FP;