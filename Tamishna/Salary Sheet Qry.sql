CREATE PROC Reports.spRPTSalarySheets
 @FromDate DATETIME,@ToDate DATETIME,@MenuID INT,@UserID BIGINT
--SET @FromDate = '07/01/2021'
--SET @ToDate = '07/31/2021'
--SET @MenuID = 157
--SET @UserID = 16100001102400000 --21100000017
AS
BEGIN
DECLARE @SalaryProcID VARCHAR(20)
SELECT TOP 1 @SalaryProcID = SalaryProcID FROM Reports.MonthWiseSalaryInfo WHERE FromDate = @FromDate AND ToDate = @ToDate

EXEC Employee.spGetInformationSecurityEmployee @MenuID,@UserID
IF NOT EXISTS(SELECT * FROM Employee.InformationSecurityEmployee WHERE UserID = @UserID)
BEGIN
	INSERT INTO Employee.InformationSecurityEmployee
	SELECT ESID,@UserID FROM Reports.EmployeePIMSInfo A
	WHERE NOT EXISTS (SELECT * FROM Employee.InformationSecurityEmployee B WHERE A.ESID = B.ESID AND B.UserID = @UserID)	
END

SELECT DATENAME(MONTH,B.FromDate) as [Month], DATENAME(Year,B.FromDate) as [Year],
A.ESID,A.EmployeeCode,G.BankAccNo,A.EmployeeName,A.Designation,[Grade Info],[Section Info],A.DOJ,[Line Info],
ISNULL(C.WorkOffDay,0)+
ISNULL(C.PWorkOffDay,0)+
ISNULL(C.LWorkOffDay,0)+
Isnull(C.PHoliDay,0)+
Isnull(C.LHoliDay,0)+        
ISNULL(C.HoliDay,0) as HDays,
ISNULL(C.PresentDay,0) + 
ISNULL(C.LateDay,0) + 
ISNULL(C.EarlyOutDay,0) AS PresentDays,EL,CL,SL,C.MLV,
ISNULL(C.WorkOffDay,0)+
ISNULL(C.PWorkOffDay,0)+
ISNULL(C.LWorkOffDay,0)+
Isnull(C.PHoliDay,0)+
Isnull(C.LHoliDay,0)+        
ISNULL(C.HoliDay,0)+ 
(C.PresentDay + C.LateDay + C.EarlyOutDay) + EL + CL + SL as PayDays,
ORGBASIC as Basic,[ORGHOUSE RENT] as [House Rent],ORGMEDICAL as Medical,ORGCONVEYANCE as Conveyance,
[ORGFOOD ALLOWANCE] as [Food Allowance],ORGGROSS as Gross,ISNULL(C.AbsentDay,0) as AbsentDay,ABSENTEEISM,
ISNULL(GROSS,0) - ISNULL(ABSENTEEISM,0) as SalaryEarned,
ISNULL([ATTENDANCE BONUS],0) as [Attendance Bonus],
ISNULL(F.OTHour,0) as OTHour, 
CAST(ROUND(ISNULL(ORGBASIC,0) / 104,2) as decimal(18,2)) as OTRate,
CAST(ISNULL(F.OTHour,0) * ROUND(ISNULL(ORGBASIC,0) / 104,2) as decimal(18,2)) as OTAmount,
(ISNULL(GROSS,0) - ISNULL(ABSENTEEISM,0)) +
ISNULL([ATTENDANCE BONUS],0) + 
CAST(ISNULL(F.OTHour,0) * ROUND(ISNULL(ORGBASIC,0) / 104,2) as decimal(18,2)) as GrossPay,
CAST(0 as decimal(18,2)) as Stamp,
(ISNULL(GROSS,0) - ISNULL(ABSENTEEISM,0)) +
ISNULL([ATTENDANCE BONUS],0) + 
CAST(ISNULL(F.OTHour,0) * ROUND(ISNULL(ORGBASIC,0) / 104,2) as decimal(18,2)) as NetPay

FROM [Reports].[SalaryWiseEmployeePIMSInfo] A
JOIN Reports.MonthWiseSalaryInfo B ON A.ESID = B.ESID AND A.SystemID = B.SalaryProcessMasterID
JOIN 
(
	SELECT A.*,ISNULL(B.CL,0) as CL,ISNULL(B.SL,0) as SL,ISNULL(B.EL,0) as EL,ISNULL(B.MLV,0) as MLV 
	FROM PayRoll.SalaryWiseAttendanceSummary A
	LEFT JOIN PayRoll.SalaryWiseLeaveSummary B ON A.ESID = B.ESID AND A.SalaryProcessSystemID = B.SalaryProcessSystemID
) C ON B.ESID = C.ESID AND B.FromDate = C.FromDate AND B.ToDate = C.ToDate AND B.SalaryProcessSystemID = C.SalaryProcessSystemID
LEFT JOIN 
(
	SELECT ESID,SUM(OTHour) as OTHour from Attendance.ProcessedOverTime
	WHERE WorkDate BETWEEN @FromDate AND @ToDate
	GROUP BY ESID
) F ON A.ESID = F.ESID
JOIN Employee.InformationSecurityEmployee E ON A.ESID = E.ESID	
LEFT JOIN Employee.EmployeeBankAccountInfo G ON A.ESID = G.ESID AND IsDefault = 1
WHERE SalaryProcID = @SalaryProcID AND E.UserID = @UserID

END