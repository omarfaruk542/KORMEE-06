DECLARE @Category VARCHAR(50),@WorkDate DATETIME
SET @Category = 'Designation Group'
SET @WorkDate = '08/01/2021'

DECLARE @MenuID INT = 20,
@UserID VARCHAR(50) = '21100000017'

DECLARE @ConvertedUserID BIGINT
SET @ConvertedUserID = (SELECT CAST(@UserID AS BIGINT))
EXEC Employee.spGetInformationSecurityEmployee @MenuID, @ConvertedUserID 
IF NOT EXISTS(SELECT * FROM Employee.InformationSecurityEmployee WHERE UserID = @ConvertedUserID)
BEGIN
	INSERT INTO Employee.InformationSecurityEmployee
	SELECT ESID,@ConvertedUserID FROM Reports.EmployeePIMSInfo A
	WHERE NOT EXISTS (SELECT * FROM Employee.InformationSecurityEmployee B WHERE A.ESID = B.ESID AND B.UserID = @ConvertedUserID)	
END

CREATE TABLE #tblCriteria(
	EntityName VARCHAR(150),
	EntityAddress VARCHAR(150),
	FieldName VARCHAR(150),
	TotalMP INT,
	Male INT,
	Female INT,
	Present INT,
	Absent INT,
	MaleAtten INT,
	FemaleAtten INT,
	MaleAbsent INT,
	FemaleAbsent INT
)

EXEC('
	INSERT INTO #tblCriteria 
	SELECT DISTINCT A.EntityName,B.Address,['+@Category+'] as FieldName,
	COUNT(*) as TotalMP,SUM(CASE WHEN Gender = ''Male'' THEN 1 ELSE 0 END) as Male,
	SUM(CASE WHEN Gender = ''Female'' THEN 1 ELSE 0 END) as Female,0,0,0,0,0,0
	FROM Reports.EmployeePIMSInfo A
	JOIN Organization.EntityAddressInfo B ON A.EntityName = B.EntityName
	JOIN Employee.InformationSecurityEmployee C ON A.ESID = C.ESID
	WHERE ['+@Category+'] IS NOT NULL AND EmployeeStatus = ''Active'' AND C.UserID = '+@ConvertedUserID+'
	GROUP BY A.EntityName,B.Address,['+@Category+']
	')

	EXEC('
	UPDATE A SET A.Present = B.Present,A.Absent = B.Absent,
	MaleAtten = B.MaleAtten,FemaleAtten = B.FemaleAtten,
	A.MaleAbsent = B.MaleAbsent,A.FemaleAbsent = B.FemaleAbsent
	FROM #tblCriteria A
	JOIN 
	(
		SELECT B.EntityName,['+@Category+'] as FieldName,
		SUM(CASE WHEN DayStatus IN (''P'',''L'',''EO'',''LEO'') THEN 1 ELSE 0 END) as Present,
		SUM(CASE WHEN DayStatus IN (''A'',''LV'') THEN 1 ELSE 0 END) as Absent,
		SUM(CASE WHEN Gender = ''Male'' AND DayStatus IN (''P'',''L'',''EO'',''LEO'') THEN 1 ELSE 0 END) as MaleAtten,
		SUM(CASE WHEN Gender = ''Female'' AND DayStatus IN (''P'',''L'',''EO'',''LEO'') THEN 1 ELSE 0 END) as FemaleAtten,
		SUM(CASE WHEN Gender = ''Male'' AND DayStatus IN (''A'',''LV'') THEN 1 ELSE 0 END) as MaleAbsent,
		SUM(CASE WHEN Gender = ''Female'' AND DayStatus IN (''A'',''LV'') THEN 1 ELSE 0 END) as FemaleAbsent
		FROM DayWisePayHour A
		JOIN Reports.EmployeePIMSInfo B ON A.ESID = B.ESID
		JOIN Employee.InformationSecurityEmployee C ON A.ESID = C.ESID
		WHERE A.WorkDate = '''+@WorkDate+''' AND C.UserID = '+@ConvertedUserID+'
		GROUP BY B.EntityName,['+@Category+']
	) B ON A.EntityName = B.EntityName AND A.FieldName = B.FieldName
')
select * from #tblCriteria