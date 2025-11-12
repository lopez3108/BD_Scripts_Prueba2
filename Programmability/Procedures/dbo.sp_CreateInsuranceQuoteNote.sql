SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- 2025-02-23 CB/6365: Insurance quot
---2025-07-15 LF/6668:Aumento de caracteres de Note de 100 a 2000

CREATE PROCEDURE [dbo].[sp_CreateInsuranceQuoteNote] 
@InsuranceQuoteNoteId INT = NULL,
@InsuranceQuoteId INT,
@Note VARCHAR(2000),
@CreatedBy INT,
@CreationDate DATETIME
AS
BEGIN

IF(@InsuranceQuoteNoteId IS NULL)
BEGIN


INSERT INTO [dbo].[InsuranceQuoteNote]
           ([InsuranceQuoteId]
           ,[Note]
           ,[CreationDate]
           ,[CreatedBy])
     VALUES
           (@InsuranceQuoteId
           ,@Note
           ,@CreationDate
           ,@CreatedBy)





		   SELECT @@IDENTITY

		   END
 

END
GO