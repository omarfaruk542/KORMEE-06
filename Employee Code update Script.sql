DECLARE @TableName VARCHAR(250),@Query VARCHAR(250)
DECLARE @OldEmployeeCode VARCHAR(20) = '13004691'
DECLARE @NewEmployeeCode VARCHAR(20) = '13004591'

DECLARE EmployeeCodeUpload CURSOR FOR
select C.name+'.'+B.name as TableName,'SELECT * FROM '+C.name+'.'+B.name as Query
from sys.columns A
JOIN sys.objects B ON A.object_id  = B.object_id
JOIN sys.schemas C ON B.schema_id = C.schema_id
where B.type = 'U' AND A.name = 'Employeecode'

OPEN EmployeeCodeUpload
FETCH NEXT FROM EmployeeCodeUpload INTO @TableName,@Query
WHILE @@FETCH_STATUS = 0
BEGIN

EXEC('
	IF EXISTS ('+@Query+' WHERE EmployeeCode = '''+@OldEmployeeCode+''')
		BEGIN
			UPDATE '+@TableName+' SET EmployeeCode = '''+@NewEmployeeCode+''' WHERE EmployeeCode = '''+@OldEmployeeCode+'''
		END
	')

FETCH NEXT FROM EmployeeCodeUpload INTO @TableName,@Query
END
CLOSE EmployeeCodeUpload 
DEALLOCATE EmployeeCodeUpload