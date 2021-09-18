ALTER FUNCTION [Reports].[GetEntityLocalID](@EntityID INT)
RETURNS NVARCHAR(100)
AS
BEGIN
	DECLARE @EntityName NVARCHAR(100)
	SET @EntityName = (SELECT EntityNameLocal FROM Organization.EntityAddressInfo WHERE EntityID = @EntityID)
	RETURN @EntityName
END
Go
select [Reports].[GetEntityLocalID](1032)
