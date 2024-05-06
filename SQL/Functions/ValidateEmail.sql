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