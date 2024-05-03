CREATE OR ALTER PROCEDURE S23916715.CreateNewCustomer_ProfG_FP(
    @email VARCHAR(320),
    @phone_num VARCHAR(12),
    @first_name VARCHAR(128),
    @last_name VARCHAR(128),
    @address VARCHAR(128),
    @address_line_two VARCHAR(128) = NULL,
    @city VARCHAR(128),
    @state CHAR(2),
    @zip_code VARCHAR(16),
    @inserted_id INT OUT
)
AS
BEGIN
    SET NOCOUNT ON

    -- Step 1: Make sure we don't already have this customer (the email should be unique)
    DECLARE @findCustomerCount INT;

    SELECT @findCustomerCount = COUNT(*) FROM S23916715.Customer_ProfG_FP WHERE email = @email;
    IF @findCustomerCount IS NOT NULL AND @findCustomerCount != 0
        BEGIN
            PRINT CONCAT('Customer with email ', @email, ' already exists!');
            RETURN
        END

    -- Step 2: Check if the given email is valid
    DECLARE @isValid INT;
    EXEC S23916715.ValidateEmail_ProfG_FP @email, @isValid OUT;
    SELECT @isValid;

    -- Step 3: Make sure all of the provided fields aren't null
    -- Note: We don't need to check the email since our validate function does it
    IF @phone_num IS NULL OR
       @first_name IS NULL OR
       @last_name IS NULL OR
       @address IS NULL OR
       @city IS NULL OR
       @state IS NULL OR
       @zip_code IS NULL
        BEGIN
            PRINT 'Please provide all required fields'
            RETURN
        END


    -- At this point we can insert our customer into our database
    BEGIN TRY
        INSERT INTO S23916715.Customer_ProfG_FP
        (email,
         phone_num,
         first_name,
         last_name,
         address,
         address_line_two,
         city, state, zip_code)
        VALUES (@email,
                @phone_num,
                @first_name,
                @last_name,
                @address,
                @address_line_two,
                @city, @state, @zip_code)

        -- Set our output variable to the ID of the last inserted ID (scoped)
        SET @inserted_id = SCOPE_IDENTITY();

        PRINT 'Successfully added new customer'
    END TRY
    BEGIN CATCH
        PRINT 'Something went wrong when creating new customer';
        RETURN
    END CATCH


    SET NOCOUNT OFF
END