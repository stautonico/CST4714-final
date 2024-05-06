# Deliverable 10 (Functions)

## 1. Get Invoice Status ID

Given the status name (as a `VARCHAR`), return the ID (PK) of the status

<code-block lang="sql">
CREATE OR ALTER FUNCTION S23916715.GetInvoiceStatusId_ProfF_FP(@status VARCHAR(128))
    RETURNS INT
AS
BEGIN
    -- Try to find the status by the value
    DECLARE @status_id INT;

    SELECT @status_id = id FROM S23916715.InvoiceStatus_ProfG_FP WHERE status = @status;

    RETURN @status_id;

END
</code-block>

## 2. Get Payment Method ID

Given the payment method name (as a `VARCHAR`), return the ID (PK) of the `PaymentMethod`

<code-block lang="sql">
CREATE OR ALTER FUNCTION S23916715.GetPaymentMethodId_ProfF_FP(@payment_method VARCHAR(128))
    RETURNS INT
AS
BEGIN
    -- Try to find the payment method by the value
    DECLARE @method_id INT;

    SELECT @method_id = id FROM S23916715.PaymentMethod_ProfG_FP WHERE method = @payment_method;

    RETURN @method_id;

END
</code-block>

## 3. Calculate Remaining Balance

[See Deliverable 4 #12](starter-topic.md#12-calculate-remaining-balance)

## 4. Find Amount Paid

[See Deliverable 4 #14](starter-topic.md#14-find-amount-paid)