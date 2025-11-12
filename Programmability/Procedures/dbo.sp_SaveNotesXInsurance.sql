SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- 2025-03-04 LF/6352: Permitir agregar notas a los INSURANCE
---2025-06-25 LF/6630: Aumentar los caracteres para la note a (2000)
CREATE PROCEDURE [dbo].[sp_SaveNotesXInsurance]
(@NotesXInsuranceId INT = NULL,
@CreatedBy INT,
@Note VARCHAR(2000),
@CreationDate DATETIME,
@InsuranceId INT,
@InsuranceConceptTypeId INT)

AS
BEGIN
  IF (@NotesXInsuranceId IS NULL)
  BEGIN
    INSERT INTO [dbo].NotesXInsurance (CreatedBy, Note, CreationDate, InsuranceId,InsuranceConceptTypeId)
                            VALUES (@CreatedBy,@Note,@CreationDate,@InsuranceId,@InsuranceConceptTypeId);
  END

  end
GO