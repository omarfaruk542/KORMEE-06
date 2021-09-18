ALTER FUNCTION [Reports].[GetEntityID](@EntityID INT)
RETURNS VARCHAR(100)
AS
BEGIN
	DECLARE @EntityName VARCHAR(100)
	SET @EntityName = (SELECT EntityName FROM Organization.EntityInfo WHERE EntityID = @EntityID)
	RETURN @EntityName
END
Go
select [Reports].[GetEntityID](1032)
