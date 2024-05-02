# Invoice Genie

General idea: Invoicing database

## 10 tables?
- Invoice -
- InvoiceLine -
- Customer -
- Product -
- Price -
- InvoicePaymentRecord -
- Revision -
- RevisionLine - 
- Discount -
- InterationLog (keep track of who modified what and when (+ maybe what they changed?))
ONE MORE TABLE (at least)


Delete data after n amount of time?

write functions to create all of the data? add product, add invoice, etc


https://drawdb.vercel.app/editor


TODO: Create trigger to set the `updated` field whenever an update happens





1.     Write a 2 – 3 pages proposal of the business problem that needs to be solved.

a.     This proposal should include a description of the organization/department
b.     Name your product
c.     Explain its audience
d.     Explain your product’s contribution to the improvement of business

2. Draw the Physical Entity-Relationship Diagram (ERD) that represents your database model. (Normalized to 3NF)
a. There must be a minimum of 10 tables in this database model

3. Create, populate, and secure the entities (30 rows each via data pipeline stored procedure)
4. Describe fifteen scripts/reports, how the newly implemented system would require for answering 15 typical questions. Be very descriptive.
5. Data security: (at least three fields) client's sensitive data/information such as email/phone number/ credit cards etc. are expected to be secure and masked when on display.
6. Identify and describe the business rules/processes that will be automated by the database application.
7. Business indicates that the system becomes very slow when some canned reports are running. There are numerous ways to resolve this issue, identify one and implement it.
8. Data retention policy: data is kept indefinitely. There are numerous ways to resolve this issue, find one and implement it.
9. Generate at least three (3) payloads as Json output for downstream consumption. (hint: use requirement #4)
10. Write and test four (4) user-defined functions.
      - Functions must be used in either the stored procedures’ or the views’.
11. Write and test seven (7) stored procedures to implement the business rules.
(
create new customer, DONE
create new invoice, DONE
create new product, DONE
add product to invoice (calls create new invoice if doesn't exist)
get invoices by customer, DONE
get unpaid invoices for this month
)
     - At least three (3) of the store procedures must have error handling in its processing
     - At least two (2) of the store procedures must have transaction management in its processing
     - At least one (1) of the store procedures must be nested – called by another store procedure and return a status to its caller. The caller must evaluate the return status
     - All seven (7) store procedures must have adequate and appropriate comments
12. Write and test seven (7) triggers for seven (7) separate tables to implement the business rules.

        At least two (2) of the trigger must be for delete
        At least one (1) of the trigger must be for insert
        At least two (2) of the trigger must be for update
        At least one (1) of the trigger must be for insert/delete/update

13. Presentations 5/7 & 5/9 (audience consists of 75% business)
