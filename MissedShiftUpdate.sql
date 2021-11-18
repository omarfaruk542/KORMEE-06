CREATE PROC [ProcessInformation].[MissedShiftUpdate]
AS
BEGIN
DECLARE @StartDate DATETIME,@EndDate DATETIME
SET @StartDate='04/01/2021'
SET @EndDate=GETDATE()

WHILE(@StartDate<=@EndDate)
BEGIN
	EXEC ProcessInformation.spMissedShift @StartDate
	SET @StartDate=DATEADD(DD,1,@StartDate)
END
END