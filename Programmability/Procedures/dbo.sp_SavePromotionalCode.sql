SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

--Udapted on 12-10-2024 JT/TASK add new fiedls   @Percentage, @RedeemFromDate, @RedeemToDate
--Udapted on 16-06-2025 JF/TASK 6598  Agregar columnas de creación y edición

CREATE PROCEDURE [dbo].[sp_SavePromotionalCode] (@PromotionalCodeId INT = NULL,
@Description VARCHAR(40),
@FromDate DATETIME,
@ToDate DATETIME,
@Message VARCHAR(250),
@Reusable BIT,
@Usd DECIMAL(18, 2),
@Code CHAR(4) = NULL,
@CreationDate DATETIME,
@CreatedBy INT = NULL,
@SentSMSDate DATETIME = NULL,
@Percentage BIT = NULL,
@RedeemFromDate DATETIME = NULL,
@RedeemToDate DATETIME = NULL)
AS
BEGIN
  IF (@PromotionalCodeId IS NULL)
  BEGIN
    INSERT INTO [dbo].PromotionalCodes (Description,
    FromDate,
    ToDate,
    Message,
    Reusable,
    Usd,
    Code,
    CreationDate,
    CreatedBy,
    Percentage,
    RedeemFromDate,
    RedeemToDate)
      VALUES (@Description, @FromDate, @ToDate, @Message, @Reusable, @Usd, @Code, @CreationDate, @CreatedBy, @Percentage, @RedeemFromDate, @RedeemToDate);
  END;
  ELSE
  BEGIN
    UPDATE [dbo].PromotionalCodes
    SET Description = @Description
       ,FromDate = @FromDate
       ,ToDate = @ToDate
       ,Message = @Message
       ,Reusable = @Reusable
       ,Usd = @Usd
       ,Code = @Code
       ,Percentage = @Percentage
       ,RedeemFromDate = @RedeemFromDate
       ,RedeemToDate = @RedeemToDate
       ,LastUpdatedOn = @CreationDate
       ,LastUpdatedBy = @CreatedBy
    WHERE PromotionalCodeId = @PromotionalCodeId;
  END;
END;


GO