SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetropertyBillsCompareByPeriod] 
@PropertiesId INT,
@FromDate DATETIME,
@ToDate DATETIME
AS
     SET NOCOUNT ON;
     BEGIN
        

		create table #Temp
(
    PropertiesId int, 
    BillType Varchar(50), 
    FromdDate DateTime, 
    ToDate DatetIme, 
    Usd decimal(18,2),
    Gallons int NULL
)

-- Bill taxes

IF(EXISTS(SELECT *
  FROM [dbo].[PropertiesBillTaxes]
  Where PropertiesId = @PropertiesId AND
  CAST(CreationDate as Date) >= CAST(@FromDate as DATE) AND
  CAST(CreationDate as Date) <= CAST(@ToDate as DATE)))
  BEGIN

INSERT INTO #Temp
SELECT [PropertiesId],
'BillTaxes',
@FromDate,
@ToDate,
 SUM([Usd])
      ,NULL
  FROM [dbo].[PropertiesBillTaxes]
  Where PropertiesId = @PropertiesId AND
  CAST(CreationDate as Date) >= CAST(@FromDate as DATE) AND
  CAST(CreationDate as Date) <= CAST(@ToDate as DATE)
  GROUP BY [PropertiesId]

  END
  ELSE
  BEGIN

  INSERT INTO #Temp
SELECT @PropertiesId,
'BillTaxes',
@FromDate,
@ToDate,
 0
      ,NULL
  END

  -- Bill water

  IF(EXISTS(SELECT *
  FROM [dbo].[PropertiesBillWater]
  Where PropertiesId = @PropertiesId AND
  CAST(CreationDate as Date) >= CAST(@FromDate as DATE) AND
  CAST(CreationDate as Date) <= CAST(@ToDate as DATE)))
  BEGIN

INSERT INTO #Temp
SELECT [PropertiesId],
'BillWater',
@FromDate,
@ToDate,
 SUM([Usd])
      ,SUM(Gallons)
  FROM [dbo].[PropertiesBillWater]
  Where PropertiesId = @PropertiesId AND
  CAST(CreationDate as Date) >= CAST(@FromDate as DATE) AND
  CAST(CreationDate as Date) <= CAST(@ToDate as DATE)
  GROUP BY [PropertiesId]

  END
  ELSE
  BEGIN

  INSERT INTO #Temp
SELECT @PropertiesId,
'BillWater',
@FromDate,
@ToDate,
 0,0


  END

    -- Bill insurance

	IF(EXISTS(SELECT *
  FROM [dbo].[PropertiesBillInsurance]
  Where PropertiesId = @PropertiesId AND
  CAST(CreationDate as Date) >= CAST(@FromDate as DATE) AND
  CAST(CreationDate as Date) <= CAST(@ToDate as DATE)))
  BEGIN

INSERT INTO #Temp
SELECT [PropertiesId],
'BillInsurance',
@FromDate,
@ToDate,
 SUM([Usd])
      ,NULL
  FROM [dbo].[PropertiesBillInsurance]
  Where PropertiesId = @PropertiesId AND
  CAST(CreationDate as Date) >= CAST(@FromDate as DATE) AND
  CAST(CreationDate as Date) <= CAST(@ToDate as DATE)
  GROUP BY [PropertiesId]

  END
  ELSE
  BEGIN

  INSERT INTO #Temp
SELECT @PropertiesId,
'BillInsurance',
@FromDate,
@ToDate,
 0
      ,NULL

  END

    -- Bill labor


	IF(EXISTS(SELECT *
  FROM [dbo].[PropertiesBillLabor]
  Where PropertiesId = @PropertiesId AND ApartmentId IS NULL AND
  CAST(CreationDate as Date) >= CAST(@FromDate as DATE) AND
  CAST(CreationDate as Date) <= CAST(@ToDate as DATE)))
  BEGIN

INSERT INTO #Temp
SELECT [PropertiesId],
'BillLabor',
@FromDate,
@ToDate,
 SUM([Usd])
      ,NULL
  FROM [dbo].[PropertiesBillLabor]
  Where PropertiesId = @PropertiesId AND ApartmentId IS NULL AND
  CAST(CreationDate as Date) >= CAST(@FromDate as DATE) AND
  CAST(CreationDate as Date) <= CAST(@ToDate as DATE)
  GROUP BY [PropertiesId]

  END
  ELSE
  BEGIN

INSERT INTO #Temp
SELECT @PropertiesId,
'BillLabor',
@FromDate,
@ToDate,
0
      ,NULL

  END

      -- Bill other

	  IF(EXISTS(SELECT *
  FROM [dbo].[PropertiesBillOthers]
  Where PropertiesId = @PropertiesId AND
  CAST(CreationDate as Date) >= CAST(@FromDate as DATE) AND
  CAST(CreationDate as Date) <= CAST(@ToDate as DATE)))
  BEGIN

INSERT INTO #Temp
SELECT [PropertiesId],
'BillOther',
@FromDate,
@ToDate,
 SUM(
 CASE WHEN IsCredit = 1 THEN 
 [Usd] ELSE
 ([USd] * -1) END)
      ,NULL
  FROM [dbo].[PropertiesBillOthers]
  Where PropertiesId = @PropertiesId AND
  CAST(CreationDate as Date) >= CAST(@FromDate as DATE) AND
  CAST(CreationDate as Date) <= CAST(@ToDate as DATE)
  GROUP BY [PropertiesId]

  END
  ELSE
  BEGIN

  INSERT INTO #Temp
SELECT @PropertiesId,
'BillOther',
@FromDate,
@ToDate,
 0
      ,NULL

  END


  SELECT * FROM #Temp


  Drop Table #Temp



     END;
GO