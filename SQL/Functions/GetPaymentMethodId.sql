CREATE OR ALTER FUNCTION S23916715.GetPaymentMethodId_ProfF_FP(@payment_method VARCHAR(128))
    RETURNS INT
AS
BEGIN
    -- Try to find the payment method by the value
    DECLARE @method_id INT;

    SELECT @method_id = id FROM S23916715.PaymentMethod_ProfG_FP WHERE method = @payment_method;

    RETURN @method_id;
END