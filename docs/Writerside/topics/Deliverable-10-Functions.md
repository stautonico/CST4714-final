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

## 5. Validate Email

This function is a reusable function designed to simplify code in some logic functions.
It takes an email address and checks if the email is valid and returns a `BIT`

<code-block lang="sql">
CREATE OR ALTER FUNCTION S23916715.ValidateEmail_ProfG_FP(
    @email VARCHAR(128)
)
    RETURNS BIT
AS
BEGIN
    -- Valid by default

    -- This function tries its best to check if a provided email is valid
    DECLARE @usernamePartLen INT;
    DECLARE @domainPartLen INT;
    DECLARE @pos INT;

    -- Check if we have '@'
    SET @pos = CHARINDEX('@', @email);
    IF @pos = 0 OR @pos = LEN(@email)
        RETURN 0;

    -- Make sure we don't have > 1 '@'
    DECLARE @atCount INT;
    SET @atCount = LEN(@email) - LEN(REPLACE(@email, '@', ''));

    IF @atCount != 1
        RETURN 0;

    -- Split by the '@' to extract the username and domain parts
    SET @usernamePartLen = @pos - 1; -- One character to the left = the length of the username (from beginning of str)
    SET @domainPartLen = LEN(@email) - @pos;
    -- The size of our entire string - the pos of '@' = the length of our domain portion

    -- Make sure we have minimum lengths
    IF @usernamePartLen < 1 OR @domainPartLen < 3
        RETURN 0;

    -- Check for invalid characters
    IF CHARINDEX('`&\:;,\"-_<>[]()', @email) > 0
        RETURN 0;

    -- Make sure the username portion doesn't contain any '@'s
    IF CHARINDEX('@', SUBSTRING(@email, 0, @usernamePartLen)) > 0
        RETURN 0;

    -- It's valid so return true
    RETURN 1;

END
</code-block>