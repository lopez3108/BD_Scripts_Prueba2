SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- Create Juan Felipe oquendo 
-- Date 25-09-2023
-- makers
CREATE PROCEDURE [dbo].[sp_GetInfoChecksByMaker]
(
   @Account varchar(50), @Routing varchar(50), @MakerId int = NULL
)
AS
BEGIN

SELECT * FROM (
  SELECT Checks.CheckId
  , Checks.CheckFront 
  , Checks.CheckBack
  ,Checks.DateCashed AS CheckDate
  , u.Name
  , c.ClienteId,
  '+' AS showLabel,
  'CHECK' AS Section
  FROM Checks
       INNER JOIN
       Clientes c
       ON c.ClienteId = Checks.ClientId
       INNER JOIN
       Users u
       ON c.UsuarioId = u.UserId
  WHERE Checks.Account = @Account AND
        Checks.Routing = @Routing AND
        (Checks.Maker = @MakerId OR
        @MakerId IS NULL)

  UNION ALL

  SELECT  NULL CheckId
  , NULL CheckFront
  , NULL CheckBack
  ,rc.CreationDate AS CheckDate
  , u.Name
  , c.ClienteId, '+' AS showLabel,
  'RETURNCHECK' AS Section

  FROM dbo.ReturnedCheck rc
       INNER JOIN Clientes c ON c.ClienteId = rc.ClientId
       INNER JOIN  Users u ON c.UsuarioId = u.UserId
       INNER JOIN  dbo.Makers ON rc.MakerId = Makers.MakerId
         WHERE rc.Account = @Account AND  rc.Routing = @Routing AND (rc.MakerId = @MakerId OR
        @MakerId IS NULL )
) CheckDate
     ORDER BY  CheckDate.CheckDate DESC
END;
GO