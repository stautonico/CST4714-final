CREATE OR ALTER PROCEDURE S23916715.GetPricesForProduct_ProfG_FP(
    @product_id INT = NULL,
    @product_name VARCHAR(128) = NULL,
    @product_sku VARCHAR(128) = NULL
)
AS
BEGIN
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

    -- If we don't have the product id, we need to find it
    IF @product_id IS NULL
        BEGIN
            SELECT @product_id = id FROM S23916715.Product_ProfG_FP WHERE name = @product_name AND sku = @product_sku;

            IF @product_sku IS NULL
                BEGIN
                    PRINT CONCAT('Product with name ', @product_name, ' and sku ', @product_sku, ' doesn''t exist')
                    RETURN
                END
        END

    SELECT id,
           TRY_CAST(amount AS FLOAT) / 100 AS price
    FROM S23916715.Price_ProfG_FP
    WHERE product = @product_id;
END