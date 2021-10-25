ALTER FUNCTION [dbo].[unidate]
(
    @Date NVARCHAR(10)
)
RETURNS NVARCHAR(10)
AS
BEGIN
	DECLARE @result NVARCHAR(50) = ''
    DECLARE @DD NVARCHAR(2) = RIGHT(dbo.uninum(@Date),2) 
	DECLARE @MM NVARCHAR(2) = LEFT(RIGHT(dbo.uninum(@Date),4),2)
	DECLARE @YYYY NVARCHAR(4) = LEFT(dbo.uninum(@Date),4)
    RETURN @DD+'/'+@MM+'/'+@YYYY 
END
GO
SELECT [dbo].[unidate](CONVERT(VARCHAR(10),GETDATE(),112))