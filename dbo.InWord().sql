ALTER function dbo.InWord(@Number DECIMAL(38,2))
returns varchar(8000)
BEGIN
--Step 1:Divide the original number into Real and Decimal Parts
DECLARE @RealPart INT = PARSENAME(@Number, 2)
DECLARE @DecimalPart INT = PARSENAME(@Number, 1)
DECLARE @InWord NVARCHAR(4000)

-- Step 2: Generate Number to Words between 1 to 99

--Generate Numbers From 1 to 19
;WITH generateNumbersFrom1To19CTE AS(
SELECT 0 AS Digit , 'Zero' AS NumberToWords UNION ALL
SELECT 1 , 'One'  UNION ALL
SELECT 2 , 'Two'  UNION ALL
SELECT 3 , 'Three' UNION ALL
SELECT 4 , 'Four' UNION ALL
SELECT 5 , 'Five' UNION ALL
SELECT 6 , 'Six'  UNION ALL
SELECT 7 , 'Seven' UNION ALL
SELECT 8 , 'Eight' UNION ALL
SELECT 9 , 'Nine' UNION ALL
SELECT 10 , 'Ten'  UNION ALL
SELECT  11 , 'Eleven'  UNION ALL
SELECT  12 , 'Twelve' UNION ALL
SELECT  13 , 'Thirteen' UNION ALL
SELECT  14 , 'Fourteen' UNION ALL
SELECT  15 , 'Fifteen' UNION ALL
SELECT  16 , 'Sixteen' UNION ALL
SELECT  17 , 'Seventeen' UNION ALL
SELECT  18 , 'Eighteen' UNION ALL
SELECT  19 , 'Nineteen' )

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

            IIF(Rn/10 = 2,'Twenty '
            ,IIF(Rn/10 = 3,'Thirty '
            ,IIF(Rn/10 = 4,'Fourty '
            ,IIF(Rn/10 = 5,'Fifty '
            ,IIF(Rn/10 = 6,'Sixty '
            ,IIF(Rn/10 = 7,'Seventy '
            ,IIF(Rn/10 = 8,'Eighty '
            ,IIF(Rn/10 = 9,'Ninety ',''))))))))  +
            IIF(Rn%10 = 1,'One'
            ,IIF(Rn%10 = 2,'Two'
            ,IIF(Rn%10 = 3,'Three'
            ,IIF(Rn%10 = 4,'Four'
            ,IIF(Rn%10 = 5,'Five'
            ,IIF(Rn%10 = 6,'Six'
            ,IIF(Rn%10 = 7,'Seven'
            ,IIF(Rn%10 = 8,'Eight'
            ,IIF(Rn%10 = 9,'Nine','')))))))))
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
                    'Taka and '
                    +
                    (       SELECT
                                    n.NumberToWords
                            FROM numberTableFrom1to99CTE n
                            WHERE n.Digit = @DecimalPart
                    )+' Paisa'
					ELSE 'Taka Only.' END
							
return REPLACE(@InWord,'  ','')
END
GO
select dbo.InWord(31267.00)