DECLARE @ReportID INT
DECLARE @ReportFieldID INT
DECLARE @ReportSeq INT
DECLARE @FieldName VARCHAR(50)

DECLARE ReportCriteria CURSOR FOR
SELECT ReportId FROM Reports.ReportSuite where ReportName IS NOT NULL

OPEN ReportCriteria
FETCH NEXT FROM ReportCriteria INTO @ReportID
WHILE @@FETCH_STATUS = 0
BEGIN

	DECLARE FieldInsert CURSOR FOR
	SELECT * FROM
	(
		SELECT 'MenuID' as FieldName
		UNION
		SELECT 'UserID' as FieldName
	) A

	OPEN FieldInsert
	FETCH NEXT FROM FieldInsert INTO @FieldName
	WHILE @@FETCH_STATUS = 0 
	BEGIN 

		SET @ReportFieldID = (SELECT MAX(ReportFieldId) + 1 FROM Reports.ReportSuiteField)
		SET @ReportSeq = (SELECT MAX(SeqNo) + 1 FROM Reports.ReportSuiteField WHERE ReportId = @ReportID)

		IF NOT EXISTS (SELECT * FROM Reports.ReportSuiteField WHERE ReportId = @ReportID AND ValueField = @FieldName)
		BEGIN
			INSERT INTO Reports.ReportSuiteField
			SELECT @ReportFieldID as FieldID,@ReportID as ReportID,@FieldName as ValueField,@FieldName as LabelField,@FieldName as Label,NULL as DefaultValue,
			'String' as FiledType,NULL as MapField,1 as IsSysParameter,NULL as Ref,NULL as Operators,0 as FilterOnly,@ReportSeq as SeqNo,0 as MultiSelect
		END

	FETCH NEXT FROM FieldInsert INTO @FieldName
	END
	CLOSE FieldInsert
	DEALLOCATE FieldInsert

FETCH NEXT FROM ReportCriteria INTO @ReportID
END
CLOSE ReportCriteria
DEALLOCATE ReportCriteria

