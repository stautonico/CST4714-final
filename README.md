# Invoice Genie

- Target company: Law firm
- End users: Finance department at law firm

# Deliverable 1

- Tools: Technologies that would go with the database (the theoretical application)
- Resources: The resources required to build this app (frontend/backend devs, servers to run the application, etc.)
- Challenges: Problems and challenges developing/implementing the application (integration, research, etc.)
- Expected ROI: Number or percent of the expected return on investment. Example: after 3 months of use, we would save n%
  over paying for a commercial solution1

## Deliverable 4

- Stored procedures which report some data, aka show amount of unpaid invoices from this month, number of new customers,
  etc
- Required: 15
    1. GetInvoicesByCustomer [GetInvoicesByCustomer.sql](SQL%2FDeliverable4_Reports%2FGetInvoicesByCustomer.sql)
    2.
  GetInvoicesFromThisMonth [GetInvoicesFromThisMonth.sql](SQL%2FDeliverable4_Reports%2FGetInvoicesFromThisMonth.sql)
    3.
  CustomersThatHaveUnpaidInvoices [CustomersThatHaveUnpaidInvoices.sql](SQL%2FDeliverable4_Reports%2FCustomersThatHaveUnpaidInvoices.sql)
    4. CustomerView [CustomerView.sql](SQL%2FViews%2FCustomerView.sql)
    5. GetUnpaidInvoices (toggleable json) [GetUnpaidInvoices.sql](SQL%2FDeliverable4_Reports%2FGetUnpaidInvoices.sql)
    6. GetPaidInvoices (toggleable json) [GetPaidInvoices.sql](SQL%2FDeliverable4_Reports%2FGetPaidInvoices.sql)
    7. GetStaleInvoices (haven't been touched in at least 30
       days) [GetStaleInvoices.sql](SQL%2FDeliverable4_Reports%2FGetStaleInvoices.sql)
    8. GetInvoicesByNum (toggleable json)
    9. GetPricesForProduct
    10. GetTotalBilledThisMonth
    11. GetTotalPaidThisMonth
    12. CalculateRemainingBalance
    13. GetInvoicePayments (uses data masking)

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

- The one that handles insert/update/delete, there should be a different action for all 3 events. YOU CAN'T JUST
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

- For Q7, use profiling to identify slow or redundant queries, and optimize/improve them.

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

3. Create, populate, and secure the entities (30 rows each via data pipeline stored procedure)
4. Describe fifteen scripts/reports, how the newly implemented system would require for answering 15 typical questions.
   Be very descriptive.

To write in the paper:
systems become slow when things are running, identify and resolve.
