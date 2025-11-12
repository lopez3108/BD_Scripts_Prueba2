SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetAllPhoneValidationMethods]
AS
     SET NOCOUNT ON;
     BEGIN
         SELECT *
         FROM [dbo].PhoneValidationMethods
         ORDER BY Code;
     END;
GO