CREATE FUNCTION [dbo].[uninum]
(
    @NumValue NVARCHAR(50)
)
RETURNS NVARCHAR(50)
AS
BEGIN
    DECLARE @length         INT,
            @loopCounter    INT,            
            @subvalue       NVARCHAR(1),
            @banglaValue    NVARCHAR(1),
            @result         NVARCHAR(50),
            @amount         NVARCHAR(50)

    SET @amount = @NumValue
    SELECT @length = LEN(@amount)
    SET @result = ''

    IF(@length > 0)
    BEGIN
        SET @loopCounter = 1;
        WHILE(@loopCounter <= @length)
        BEGIN
            SELECT @subvalue = SUBSTRING(@amount, @loopCounter, 1)

            IF(@subvalue = N'.')
            BEGIN
                SET @banglaValue = @subvalue
            END
            ELSE IF(@subvalue = N',')
            BEGIN
                SET @banglaValue = @subvalue
            END
            ELSE
            BEGIN
                SET @banglaValue = CASE
                                        WHEN @subvalue = '0' THEN N'০'
                                        WHEN @subvalue = '1' THEN N'১'
                                        WHEN @subvalue = '2' THEN N'২'
                                        WHEN @subvalue = '3' THEN N'৩'
                                        WHEN @subvalue = '4' THEN N'৪'
                                        WHEN @subvalue = '5' THEN N'৫'
                                        WHEN @subvalue = '6' THEN N'৬'
                                        WHEN @subvalue = '7' THEN N'৭'
                                        WHEN @subvalue = '8' THEN N'৮'
                                        WHEN @subvalue = '9' THEN N'৯'
                                    END                                 

            END         
            SET @loopCounter = @loopCounter + 1     
            SET @result = @result + @banglaValue
        END
    END
    RETURN @result  
END