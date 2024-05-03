CREATE OR ALTER PROCEDURE S23916715.ValidateEmail_ProfG_FP(
    @email VARCHAR(128),
    @isValid INT OUT
)
AS
BEGIN
    SET @isValid = 1;
    -- Valid by default

    -- This function tries its best to check if a provided email is valid
    DECLARE @usernamePartLen INT;
    DECLARE @domainPartLen INT;
    DECLARE @pos INT;

    -- Check if we have '@'
    SET @pos = CHARINDEX('@', @email);
    IF @pos = 0 OR @pos = LEN(@email)
        BEGIN
            SET @isValid = 0;
            RETURN
        END

    -- Split by the '@' to extract the username and domain parts
    SET @usernamePartLen = @pos - 1; -- One character to the left = the length of the username (from beginning of str)
    SET @domainPartLen = LEN(@email) - @pos;
    -- The size of our entire string - the pos of '@' = the length of our domain portion

    -- Make sure we have minimum lengths
    IF @usernamePartLen < 1 OR @domainPartLen < 3
        BEGIN
            SET @isValid = 0;
            RETURN
        END

    -- Check for invalid characters
    IF CHARINDEX('`&\:;,\"-_<>[]()', @email) > 0
        BEGIN
            SET @isValid = 0;
            RETURN
        END

    -- Make sure the username portion doesn't contain any '@'s
    IF CHARINDEX('@', SUBSTRING(@email, 0, @usernamePartLen)) > 0
        BEGIN
            SET @isValid = 0;
            RETURN
        END

END