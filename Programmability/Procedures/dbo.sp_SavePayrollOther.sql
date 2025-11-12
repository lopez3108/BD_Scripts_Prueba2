SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- 2025-05-02 JF/6473: Requerir documentos para others en el payroll add @FileName

CREATE PROCEDURE [dbo].[sp_SavePayrollOther] (@PayrollId INT,
@PayrollOtherTypeDescription VARCHAR(15),
@Description VARCHAR(150),
@Usd DECIMAL(18, 2),
@AgencyId INT = NULL,
@FileName VARCHAR(256) = NULL)
AS
BEGIN
  DECLARE @PayrollOtherTypesId INT;
  SET @PayrollOtherTypesId = (SELECT
      PayrollOtherTypesId
    FROM PayrollOtherTypes
    WHERE Description = @PayrollOtherTypeDescription);
  INSERT INTO [dbo].PayrollOthers (PayrollId,
  PayrollOtherTypesId,
  Usd,
  AgencyId,
  Description,
  FileName)
    VALUES (@PayrollId, @PayrollOtherTypesId, @Usd, @AgencyId, @Description, @FileName);
  SELECT
    @@IDENTITY;
END;

GO