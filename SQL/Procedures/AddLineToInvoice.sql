CREATE OR ALTER PROCEDURE S23916715.AddNewLineToInvoice_ProfG_FP(
    @invoice_num INT,
    @product_name VARCHAR(128) = NULL,
    @product_sku VARCHAR(128) = NULL,
    @product_id INT = NULL,
    @price_id INT,
    @quantity INT,
    @discount_id INT = NULL,
    @description VARCHAR(1024) = NULL,
    @inserted_id INT OUT
)
AS
BEGIN
    SET NOCOUNT ON

    -- Step 1: Make sure the invoice exists
    DECLARE @invoice_id INT;

    SELECT @invoice_id = id FROM S23916715.Invoice_ProfG_FP WHERE num = @invoice_num;
    IF @invoice_id IS NULL
        BEGIN
            PRINT CONCAT('Invoice with the number ', @invoice_num, ' doesn''t exist')
            RETURN
        END

    -- Step 2: Check if we're going to find the product by id or name&sku
    -- We can't have both id and product&sku
    IF @product_id IS NOT NULL AND @product_sku IS NOT NULL AND @product_name IS NOT NULL
        BEGIN
            PRINT 'You can''t provide both product ID and product name&sku'
            RETURN
        END
        -- We have to have at least one of the two
    ELSE
        IF @product_id IS NULL AND (@product_name IS NULL OR @product_sku IS NULL)
            BEGIN
                PRINT 'You must provide at least product ID or product name&sku'
                RETURN
            END

    -- Now we can try to find the product
    SELECT @product_id = id
    FROM S23916715.Product_ProfG_FP
    WHERE (@product_id IS NOT NULL AND id = @product_id)
       OR (@product_name IS NOT NULL AND @product_sku IS NOT NULL AND name = @product_name AND sku = @product_sku);

    IF @@ROWCOUNT = 0
        BEGIN
            PRINT 'Product doesn''t exist'
            RETURN
        END

    -- We can try to find the price
    DECLARE @pricesProductId INT

    SELECT @pricesProductId = product FROM S23916715.Price_ProfG_FP WHERE id = @price_id;

    IF @pricesProductId IS NULL
        BEGIN
            PRINT 'The provided price does not exist'
            RETURN
        END

    -- The price must belong to the provided product
    IF @pricesProductId != @product_id
        BEGIN
            PRINT 'The provided price does not belong to the provided product'
            RETURN
        END

    -- Validate our provided quantity
    IF @quantity <= 0
        BEGIN
            PRINT 'Quantity must be > 0'
            RETURN
        END

    -- If we have a discount id, validate it
    IF @discount_id IS NOT NULL
        BEGIN
            DECLARE @discountCount INT;
            SELECT @discountCount = COUNT(*) FROM S23916715.Discount_ProfG_FP WHERE id = @discount_id;
            IF @discountCount = 0
                BEGIN
                    PRINT 'Discount does not exist'
                    RETURN
                END
        END

    -- Finally, insert our new invoice line
    BEGIN TRY
        INSERT INTO S23916715.InvoiceLine_ProfG_FP (invoice, product, price, quantity, discount, description)
        VALUES (@invoice_id, @product_id, @price_id, @quantity, @discount_id, @description);

        -- Set our output var to the new ID
        SET @inserted_id = SCOPE_IDENTITY();

        PRINT CONCAT('Successfully added line to in invoice num ', TRY_CAST(@invoice_num AS VARCHAR))
    END TRY
    BEGIN CATCH
        PRINT 'Something went wrong when inserting new line into invoice'
        RETURN
    END CATCH

    SET NOCOUNT OFF
END