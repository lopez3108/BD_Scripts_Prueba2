SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
-- =============================================
-- Author:      JF
-- Create date: 10/08/2024 12:39 p. m.
-- Database:    developing
-- Description: task : 5696 Falta información de dirección cliente y agencia
-- =============================================



CREATE PROCEDURE [dbo].[sp_GetClientsList]
(@Name      VARCHAR(200) = NULL,
 @Telephone VARCHAR(30)  = NULL,
 @Account   VARCHAR(30)  = NULL,
 @MakerId   INT          = NULL,
 @Birthday  DATETIME     = NULL
)
AS
     BEGIN

	 declare @searchCriteria VARCHAR(100) = NULL
	set @searchCriteria = @Name

	IF(@searchCriteria IS NULL)
	BEGIN

	set @searchCriteria = '""'

	END

         SELECT DISTINCT Clientes.ClienteId AS ClientId,
                Users.Name,
                Users.Telephone,
                Users.Address AS Address1 ,
                Users.Address +' '+ UPPER(zc.City) +' '+ UPPER(zc.State) +', '+' '+ Users.ZipCode  AS Address,
                zc.City,
                zc.State,
                zc.StateAbre,
                Users.ZipCode,
                Users.BirthDay,
                Clientes.Doc1Number ClientDoc1Number,
                Clientes.Doc2Number ClientDoc2Number,
                Clientes.Doc1Front,
                clientes.Doc1Back,
                Clientes.Doc2Front,
                Clientes.Doc2Back,
                CAST(Users.BirthDay AS DATE) DOB

         FROM Clientes
              INNER JOIN Users ON Clientes.UsuarioId = Users.UserId
              LEFT JOIN Checks ON Clientes.ClienteId = Checks.ClientId
              INNER JOIN   ZipCodes zc ON zc.ZipCode = Users.ZipCode
         --WHERE (@Name IS NULL OR FREETEXT (Users.[Name], @searchCriteria))
		 WHERE (@Name IS NULL OR Users.[Name] LIKE '%'+@searchCriteria+'%' )
              AND (Users.Telephone = @Telephone
                   OR @Telephone IS NULL)
              AND (CAST(Users.BirthDay AS DATE) = CAST(@Birthday AS DATE)
                   OR @Birthday IS NULL)
              AND (Checks.Maker = @MakerId
                   OR @MakerId IS NULL)
              AND (Checks.Account LIKE '%'+@Account+'%'
                   OR @Account IS NULL);
     END;


GO