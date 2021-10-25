ALTER function dbo.InWordBNG(@Number DECIMAL(38,2))
returns Nvarchar(4000)
BEGIN
--Step 1:Divide the original number into Real and Decimal Parts
DECLARE @RealPart INT = PARSENAME(@Number, 2)
DECLARE @DecimalPart INT = PARSENAME(@Number, 1)
DECLARE @InWord NVARCHAR(4000)

-- Step 2: Generate Number to Words between 1 to 99

--Generate Numbers From 1 to 19
;WITH generateNumbersFrom1To19CTE AS(
SELECT 0 AS Digit , N'শূণ্য' AS NumberToWords UNION ALL
SELECT 1 , N'এক'  UNION ALL
SELECT 2 , N'দুই'  UNION ALL
SELECT 3 , N'তিন' UNION ALL
SELECT 4 , N'চার' UNION ALL
SELECT 5 , N'পাঁচ' UNION ALL
SELECT 6 , N'ছয়'  UNION ALL
SELECT 7 , N'সাত' UNION ALL
SELECT 8 , N'আট' UNION ALL
SELECT 9 , N'নয়' UNION ALL
SELECT 10 , N'দশ'  UNION ALL
SELECT  11 , N'এগার'  UNION ALL
SELECT  12 , N'বার' UNION ALL
SELECT  13 , N'তের' UNION ALL
SELECT  14 , N'চৌদ্দ' UNION ALL
SELECT  15 , N'পনের' UNION ALL
SELECT  16 , N'ষোল' UNION ALL
SELECT  17 , N'সতের' UNION ALL
SELECT  18 , N'আঠার' UNION ALL
SELECT  19 , N'ঊনিশ'  UNION ALL
SELECT  20 , N'বিশ'  UNION ALL
SELECT  21 , N'একুশ'  UNION ALL
SELECT  22 , N'বাইশ'  UNION ALL
SELECT  23 , N'তেইশ'  UNION ALL
SELECT  24 , N'চব্বিশ'  UNION ALL
SELECT  25 , N'পঁচিশ'  UNION ALL
SELECT  26 , N'ছাব্বিশ'  UNION ALL
SELECT  27 , N'সাতাইশ'  UNION ALL
SELECT  31 , N'একত্রিশ' )

--Generate Numbers From 20 to 99
,generateNumbersFrom20To99 AS(

SELECT Rn=20
UNION ALL
SELECT Rn=Rn+1
FROM GenerateNumbersFrom20To99 WHERE Rn<99)

-- Generate Numbers between 1 to 99
,numberTableFrom1to99CTE AS(

SELECT * FROM generateNumbersFrom1To19CTE
UNION ALL

SELECT 
Rn
,NumberToWords=

            IIF(Rn/10 = 2,N'বিশ'
            ,IIF(Rn/10 = 3,N'ত্রিশ'
            ,IIF(Rn/10 = 4,N'চল্লিশ'
            ,IIF(Rn/10 = 5,N'পঞ্চাশ'
            ,IIF(Rn/10 = 6,N'ষাট'
            ,IIF(Rn/10 = 7,N'সত্তর'
            ,IIF(Rn/10 = 8,N'আশি'
            ,IIF(Rn/10 = 9,N'নব্বই',''))))))))  +
            IIF(Rn%10 = 1,N'এক'
            ,IIF(Rn%10 = 2,N'দুই'
            ,IIF(Rn%10 = 3,N'তিন'
            ,IIF(Rn%10 = 4,N'চার'
            ,IIF(Rn%10 = 5,N'পাঁচ'
            ,IIF(Rn%10 = 6,N'ছয়'
            ,IIF(Rn%10 = 7,N'সাত'
            ,IIF(Rn%10 = 8,N'আট'
            ,IIF(Rn%10 = 9,N'নয়','')))))))))
FROM GenerateNumbersFrom20To99)

-- Step 3: Divide the number into their digits
, getDigitsCTE AS (
SELECT 
            UnitarySystemPosition=1
            ,Quotient = @RealPart / 10 
            ,Remainder = @RealPart % 10  

UNION ALL

SELECT 
            UnitarySystemPosition=UnitarySystemPosition+1
            ,Quotient / 10
            , Quotient % 10

FROM getDigitsCTE

WHERE Quotient > 0
)

-- Step 4: Position the result of Step 3 according to the unitary system.
,transformDigitsIntoUnitarySystem AS(
SELECT

Crore=
    STUFF((SELECT '' + 
    dw.Remainder + ' ' 
    FROM getDigitsCTE dw
    WHERE UnitarySystemPosition IN(8,9)
    ORDER BY dw.UnitarySystemPosition DESC
    FOR XML PATH('')),1,0,'')

,Lac=
    STUFF((SELECT '' + 
    dw.Remainder + ' ' 
    FROM getDigitsCTE dw
    WHERE UnitarySystemPosition IN(6,7)
    ORDER BY dw.UnitarySystemPosition DESC
    FOR XML PATH('')),1,0,'')
,Thousand = 
    STUFF((SELECT '' + 
    dw.Remainder + ' ' 
    FROM getDigitsCTE dw
WHERE UnitarySystemPosition IN(4,5)
ORDER BY dw.UnitarySystemPosition DESC
FOR XML PATH('')),1,0,'')

,Hundred = 
    STUFF((SELECT '' + 
    dw.Remainder + ' ' 
    FROM getDigitsCTE dw
WHERE UnitarySystemPosition IN(3)
ORDER BY dw.UnitarySystemPosition DESC
FOR XML PATH('')),1,0,'')

,TensAndUnit = 
    STUFF((SELECT '' + 
    dw.Remainder + ' ' 
    FROM getDigitsCTE dw
WHERE UnitarySystemPosition IN(1,2)
ORDER BY dw.UnitarySystemPosition DESC
FOR XML PATH('')),1,0,''))

-- Step 5: Label the numbers into the unitary system
,labelNumbersInUnitarySystemCTE AS(
SELECT  
SlNo=ROW_NUMBER() OVER(ORDER BY (SELECT 1))
, UnitarySystem
, Numbers
FROM 
(SELECT   Crore,Lac,Thousand,Hundred, TensAndUnit
FROM transformDigitsIntoUnitarySystem) p
UNPIVOT
(Numbers FOR UnitarySystem IN 
( Crore,Lac,Thousand,Hundred, TensAndUnit)
)AS unpvt)

--Step 6: Combine the Result of Step 1 and 5 to generate number to words for Real Part
,digitWordsCombinationForRealPartCTE AS(
SELECT 
    sd.*
    ,NumberToWords=nd.NumberToWords + ' ' + IIF(sd.UnitarySystem = 'TensAndUnit','',sd.UnitarySystem)
FROM labelNumbersInUnitarySystemCTE sd
JOIN numberTableFrom1to99CTE nd ON nd.Digit = sd.Numbers)

SELECT @InWord =    STUFF((SELECT '' + 
                    dw.NumberToWords + ' ' 
                    FROM digitWordsCombinationForRealPartCTE dw
                    ORDER BY dw.SlNo 
                    FOR XML PATH('')),1,0,'')

                            --Decimal Part
					
                    +
					CASE WHEN @DecimalPart > 0 THEN 
                    N'টাকা'
                    +
                    (       SELECT
                                    n.NumberToWords
                            FROM numberTableFrom1to99CTE n
                            WHERE n.Digit = @DecimalPart
                    )+N' পয়সা মাত্র।'
					ELSE N' টাকা মাত্র।' END
							
return REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@InWord,'  ',''),'Crore',N' কোটি'),'Lac',N' লক্ষ'),'Thousand',N' হাজার'),'Hundred',N' শত')
END
GO
select dbo.InWordBNG(150050.00)


