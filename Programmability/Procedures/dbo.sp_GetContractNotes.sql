SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- =============================================
-- Author:		David Jaramillo
-- Description:	Retorna las notas de un contrato
--2025-10-20 JF / 6786 Ajuste para contratos cerrados el mismo día de creación
-- =============================================
CREATE PROCEDURE [dbo].[sp_GetContractNotes] @ContractId INT
AS

BEGIN

  SELECT
    dbo.ContractNotes.ContractNotesId
   ,dbo.ContractNotes.ContractId
   ,dbo.ContractNotes.Note
--   ,dbo.ContractNotes.CreationDate
   ,dbo.ContractNotes.CreatedBy
   ,dbo.Users.Name AS CreatedByName
   ,FORMAT(dbo.ContractNotes.CreationDate, 'MM-dd-yyyy h:mm:ss tt', 'en-US') CreationDate
  FROM dbo.ContractNotes
  INNER JOIN dbo.Users
    ON dbo.ContractNotes.CreatedBy = dbo.Users.UserId
  WHERE dbo.ContractNotes.ContractId = @ContractId
  ORDER BY dbo.ContractNotes.CreationDate ASC



END


GO