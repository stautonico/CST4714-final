# Invoice Genie

- Target company: Law firm
- End users: Finance department at lawfirm

# Deliverable 1
- Tools: Technologies that would go with the database (the theoretical application)
- Resources: The resources required to build this app (frontend/backend devs, servers to run the application, etc.)
- Challenges: Problems and challenges developing/implementing the application (integration, research, etc.)
- Expected ROI: Number or percent of the expected return on investment. Example: after 3 months of use, we would save n%
  over paying for a commercial solution1
 
## Deliverable 4
- Stored procedures which report some data, aka show amount of unpaid invoices from this month, number of new customers, etc
- Required: 15
  1. GetInvoicesByCustomer [GetInvoicesByCustomer.sql](SQL%2FDeliverable4_Reports%2FGetInvoicesByCustomer.sql)
  2. GetInvoicesFromThisMonth [GetInvoicesFromThisMonth.sql](SQL%2FDeliverable4_Reports%2FGetInvoicesFromThisMonth.sql)
  3. CustomersThatHaveUnpaidInvoices [CustomersThatHaveUnpaidInvoices.sql](SQL%2FDeliverable4_Reports%2FCustomersThatHaveUnpaidInvoices.sql)
  4. CustomerView [CustomerView.sql](SQL%2FViews%2FCustomerView.sql)
  5. GetUnpaidInvoices (toggleable json) [GetUnpaidInvoices.sql](SQL%2FDeliverable4_Reports%2FGetUnpaidInvoices.sql)
  6. GetPaidInvoices (toggleable json) [GetPaidInvoices.sql](SQL%2FDeliverable4_Reports%2FGetPaidInvoices.sql)
  7. GetStaleInvoices (haven't been touched in at least 30 days) [GetStaleInvoices.sql](SQL%2FDeliverable4_Reports%2FGetStaleInvoices.sql)
  8. GetInvoicesByNum (toggleable json)
  9. GetPricesForProduct
  10. GetTotalBilledThisMonth 
  11. GetTotalPaidThisMonth
  12. CalculateRemainingBalance
  13. GetInvoicePayments

## Deliverable 7
- Partial credit for describing without implementing it

## Deliverable 8
- Data needs to be kept forever. Mark things as deleted instead of permanently deleting them.
- Like 7, partial credit for describing without implementing
## Deliverable 9
- At least 3 of the reports from from [Deliverable 4](#deliverable-4) need to return json

## Deliverable 10
- Write and test 4 functions that must be used in either a stored procedure or a view
- Eg. the validate email stored procedure should be a function
- Maybe use for [Deliverable 4](#deliverable-4)

# Deliverable 11
- Handling bad arguments counts as error handling
- Transaction management (2)
- Must have at least 1 nested procedure

## Deliverable 12
-  The one that handles insert/update/delete, there should be a different action for all 3 events. YOU CAN'T JUST
   MODIFY THE `UPDATED` FIELD FOR ALL 3 ACTIONS

## Deliverable 13
- 10 Minutes
- Show demo
- Quickly run through proposal document

## Email to professor
- Business proposal
- ERD
- Document showing all code and relevant output (label with which question they apply to)


## Notes
- Mask the check numbers in the invoice payment record
- Implement constraints to validate that a given enum value (like invoice status) is only one of the allowed values
- Make table for invoice status instead of hardcoding varchar
- Add more invoice statuses (overpaid, etc)
- In proposal, note how all prices are stored in ints then converted to float
- Draw ERD (after everything is done)




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

write functions to create all of the data? add product, add invoice, etc

https://drawdb.vercel.app/editor

TODO: Create trigger to set the `updated` field whenever an update happens

1.     Write a 2 – 3 pages proposal of the business problem that needs to be solved.

a. This proposal should include a description of the organization/department
b. Name your product
c. Explain its audience
d. Explain your product’s contribution to the improvement of business

2. Draw the Physical Entity-Relationship Diagram (ERD) that represents your database model. (Normalized to 3NF)
   a. There must be a minimum of 10 tables in this database model

3. Create, populate, and secure the entities (30 rows each via data pipeline stored procedure)
4. Describe fifteen scripts/reports, how the newly implemented system would require for answering 15 typical questions.
   Be very descriptive.
5. Data security: (at least three fields) client's sensitive data/information such as email/phone number/ credit cards
   etc. are expected to be secure and masked when on display.
6. Identify and describe the business rules/processes that will be automated by the database application.
7. Business indicates that the system becomes very slow when some canned reports are running. There are numerous ways to
   resolve this issue, identify one and implement it.
8. Data retention policy: data is kept indefinitely. There are numerous ways to resolve this issue, find one and
   implement it.
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
    get unpaid invoices for this month DONE
    )
    - At least three (3) of the store procedures must have error handling in its processing
    - At least two (2) of the store procedures must have transaction management in its processing
    - At least one (1) of the store procedures must be nested – called by another store procedure and return a status to
      its caller. The caller must evaluate the return status
    - All seven (7) store procedures must have adequate and appropriate comments
12. Write and test seven (7) triggers for seven (7) separate tables to implement the business rules.

        At least two (2) of the trigger must be for delete
        At least one (1) of the trigger must be for insert
        At least two (2) of the trigger must be for update
        At least one (1) of the trigger must be for insert/delete/update

13. Presentations 5/7 & 5/9 (audience consists of 75% business)
