CREATE FUNCTION [SysInfo].[DepartmentLocal](@Department VARCHAR(50))
RETURNS [nvarchar](250)
AS
BEGIN
	RETURN (SELECT HKLocalName FROM EmployeeMasterDataLocal WHERE HKEntryName = @Department AND HKMasterName = 'Department')
END
GO
CREATE FUNCTION [SysInfo].[DesignationLocal](@Designation VARCHAR(50))
RETURNS [nvarchar](250)
AS
BEGIN
	RETURN (SELECT HKLocalName FROM EmployeeMasterDataLocal WHERE HKEntryName = @Designation AND HKMasterName = 'Designation')
END
GO
CREATE FUNCTION [SysInfo].[SectionLocal](@Section VARCHAR(50))
RETURNS [nvarchar](250)
AS
BEGIN
	RETURN (SELECT HKLocalName FROM EmployeeMasterDataLocal WHERE HKEntryName = @Section AND HKMasterName = 'Section Info')
END
GO
CREATE FUNCTION [SysInfo].[DesignationGroupLocal](@DesignationGroup VARCHAR(50))
RETURNS [nvarchar](250)
AS
BEGIN
	RETURN (SELECT HKLocalName FROM EmployeeMasterDataLocal WHERE HKEntryName = @DesignationGroup AND HKMasterName = 'Designation Group')
END
