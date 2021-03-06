ALTER FUNCTION [dbo].[unimonth]
(
    @MonthNo INT
)
RETURNS NVARCHAR(50)
AS
BEGIN
    DECLARE @length         INT,            
        @banglaValue    NVARCHAR(50),
        @result         NVARCHAR(50)            

    
SELECT @length = LEN(@MonthNo)
SET @result = ''

IF(@length > 0)
BEGIN
SET @banglaValue = CASE                                        
                        WHEN @MonthNo = '01' THEN N'জানুয়ারি'
                        WHEN @MonthNo = '02' THEN N'ফেব্রুয়ারী '
                        WHEN @MonthNo = '03' THEN N'মার্চ'
                        WHEN @MonthNo = '04' THEN N'এপ্রিল'
                        WHEN @MonthNo = '05' THEN N'মে'
                        WHEN @MonthNo = '06' THEN N'জুন'
                        WHEN @MonthNo = '07' THEN N'জুলাই'
                        WHEN @MonthNo = '08' THEN N'আগষ্ট'
                        WHEN @MonthNo = '09' THEN N'সেপ্টেম্বর'
						WHEN @MonthNo = '10' THEN N'অক্টোবর'
						WHEN @MonthNo = '11' THEN N'নভেম্বর'
						WHEN @MonthNo = '12' THEN N'ডিসেম্বর'
                    END  
		SET @result = @banglaValue                                               
    END
    RETURN @result  
END

GO 
select [dbo].[unimonth](01)