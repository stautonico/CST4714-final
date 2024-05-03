CREATE OR ALTER PROCEDURE S23916715.CreateNewProduct_ProfG_FP(
    @name VARCHAR(128),
    @description VARCHAR(1204) = NULL,
    @sku VARCHAR(128),
    @inserted_id INT OUT
)
AS
BEGIN
    SET NOCOUNT ON

    -- Step 1: Make sure we don't already have a product with this name or sku
    DECLARE @findProductCount INT;

    -- The name and the sku field don't need to be unique on their own, but the combination needs to be
    SELECT @findProductCount = COUNT(*) FROM S23916715.Product_ProfG_FP WHERE name = @name AND sku = @sku;
    IF @findProductCount IS NOT NULL AND @findProductCount != 0
        BEGIN
            PRINT CONCAT('Product with the name ', @name, ' and sku ', @sku, ' already exist');
            RETURN
        END

    -- Step 2: Make sure we have all of the required fields
    IF @name IS NULL OR
       @sku IS NULL
        BEGIN
            PRINT 'Please provide all required fields'
            RETURN
        END

    BEGIN TRY
        INSERT INTO S23916715.Product_ProfG_FP
            (name, description, sku)
        VALUES (@name,
                @description,
                @sku)

        -- Set our output variable to the ID of the last inserted ID (scoped)
        SET @inserted_id = SCOPE_IDENTITY();

        PRINT 'Successfully added new product'

    END TRY
    BEGIN CATCH
        PRINT 'Something went wrong when creating new product';
        RETURN
    END CATCH

    SET NOCOUNT OFF
END
