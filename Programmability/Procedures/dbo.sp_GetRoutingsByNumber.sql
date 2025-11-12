SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- =============================================
-- Author:		John Terry García 
-- Description:	Selecciona cheques de returnedcheck y checks por clientId
-- =============================================
CREATE PROCEDURE [dbo].[sp_GetRoutingsByNumber](@Number VARCHAR(50) = NULL)
AS
     BEGIN
         SELECT *
         FROM routings
         WHERE Number LIKE '%'+@Number+'%'
               OR @Number IS NULL;
     END;
GO