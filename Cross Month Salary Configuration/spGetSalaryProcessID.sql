ALTER PROC [PayRoll].[spGetSalaryProcessID]
@QType int,
@YearID int,
@FromYear varchar(15),
@ToYear varchar(15)
AS
BEGIN

TRUNCATE TABLE TempProcess.YearInformation
IF (@QType=0)
BEGIN
SET @YearID=(SELECT YearID FROM SysInfo.YearInformationMaster WHERE YearName='Salary Year'and YearID=@YearID)
select SalaryProcessSystemID,Y.SystemID AS YearID, Y.YearNo AS YearNo, SalaryProcID, A.FromDate, A.ToDate,Y.MonthNo,
DATENAME(MONTH,DATEADD(MONTH,Y.MonthNo,-1))MonthsName, IsApproved, ApprovedBy, ApprovedDate, A.IsActive from PayRoll.SalaryProcessEntity a
join SysInfo.YearInformation y on a.YearID=y.SystemID 
WHERE YearID=@YearID
END
ELSE IF (@QType=1)
BEGIN

DECLARE @YearConfig int,@StartYear int,@EndYear int,@YearCount int,@StartCount int=1,@i int=1, @flag int=1
DECLARE @Sys varchar(25),@SystemID  bigint, @EntryYear INT
DECLARE @tab AS TABLE (col VARCHAR(25)) 
SET @EntryYear = YEAR(GETDATE())

SET @YearConfig=(SELECT StartDateFromCurrentYear FROM SysInfo.YearInformationMaster WHERE YearName='Salary Year' and YearID=@YearID)
SET @StartYear=@FromYear--(SELECT CASE WHEN @YearConfig=1 THEN @FromYear ELSE (CONVERT(INT,@FromYear)-1) END)
SET @EndYear=(SELECT @FromYear)


--SELECT @YearConfig, @StartYear, @EndYear

DECLARE @FromDate DATETIME, @ToDate DATETIME
SET @FromDate = CONVERT(DATETIME,(SELECT FORMAT(CASE WHEN @YearConfig=0 THEN 
		CASE WHEN StartMonth=1 THEN 12 ELSE StartMonth-1 END 
	ELSE StartMonth END,'00')+ '/'+ FORMAT(StartDate, '00') +'/' 
	+ CONVERT(VARCHAR,CASE WHEN @YearConfig=0 THEN @StartYear-1 ELSE @StartYear END) 
			FROM SysInfo.YearInformationMaster WHERE YearName = 'Salary Year' AND YearID=@YearID))
SET @ToDate = DATEADD(DAY, -1, DATEADD(MONTH, 1, @FromDate)) 
SET @YearCount = (SELECT CONVERT(INT, @ToYear)-CONVERT(INT, @FromYear)+1)

--SELECT @FromDate, @ToDate, @YearCount		
WHILE @StartCount<=@YearCount
	BEGIN
		WHILE(@i<=12)
		BEGIN
		--SELECT *FROM PayRoll.SalaryProcessEntity
			   INSERT INTO TempProcess.YearInformation([YearID],[YearName], [FromDate], [ToDate], [YearNo], [MonthNo], [PeriodNo], [IsActive])
			   SELECT @YearID,'Salary Year' ,@FromDate,@ToDate,@StartYear,DATEPART(MM,@ToDate),@i,1
			   SET @FromDate = DATEADD(MONTH, 1, @FromDate)
			   SET @ToDate = DATEADD(DAY, -1, DATEADD(MONTH, 1, @FromDate)) 
			   SET @i=(SELECT @i+1)

		END
	
		SET @StartCount=@StartCount+1
		SET @StartYear=@StartYear+1
		SET @EndYear=@EndYear+1
		SET @i=1

	END--end of while
	
		UPDATE TempProcess.YearInformation SET SalaryProcID=A.SalaryProcID, SalaryProcessSystemID=A.SalaryProcessSystemID,
		FromDate=A.FromDate, ToDate=A.ToDate, IsActive=A.IsActive
		FROM TempProcess.YearInformation T
		JOIN SysInfo.YearInformationMaster YM ON YM.YearID=T.YearID
		Join SysInfo.YearInformation y on T.YearNo=Y.YearNo and y.YearName=T.YearName AND T.[MonthNo]=y.[MonthNo] AND YM.YearID=Y.YearMasterID
		JOIN PayRoll.SalaryProcessEntity a on a.YearID=Y.SystemID and y.YearName='Salary Year' 
		WHERE A.IsApproved=1

		UPDATE TempProcess.YearInformation
		SET SalaryProcID=CONVERT(VARCHAR(4),DATEPART(YYYY,FromDate))+CONVERT(VARCHAR(3),DATENAME(MONTH,FromDate))+format(DATEPART(DD,FromDate),'00')
		+'SP'+CONVERT(VARCHAR(4),DATEPART(YYYY,ToDate))+CONVERT(VARCHAR(3),DATENAME(MONTH,ToDate))+format(DATEPART(DD,ToDate),'00')
		WHERE SalaryProcID IS NULL AND SalaryProcessSystemID=0
			
		SELECT  SalaryProcessSystemID,Y.YearID, Y.YearNo as YearNo,SalaryProcID,
			SYSINFO.FormattedDate(y.FromDate) FromDate, SYSINFO.FormattedDate(Y.ToDate)ToDate,Y.MonthNo,
			DATENAME(MONTH,DATEADD(MONTH,Y.MonthNo,-1))MonthsName,0 AS IsApproved,0 AS ApprovedBy, getdate() ApprovedDate, 1 as IsActive
			FROM TempProcess.YearInformation y
			JOIN SysInfo.YearInformationMaster m on y.YearName=M.YearName
			WHERE Y.YearName='Salary Year'  and M.YearID=@YearID
			ORDER BY YearNo, monthno
END
		
END

GO

EXEC PayRoll.spGetSalaryProcessID 1,4,'2021','2021'