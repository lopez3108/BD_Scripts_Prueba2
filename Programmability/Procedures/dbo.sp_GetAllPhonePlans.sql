SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetAllPhonePlans](@Active BIT = NULL)
AS
     BEGIN
         SELECT *,

		       CASE
                   WHEN Active = 1
                   THEN 'ACTIVE'
                   ELSE 'INACTIVE'
                END AS [ActiveFormat],

                Description+' - '+'$'+CONVERT(VARCHAR(12), CAST(Usd AS MONEY), 1) AS DescriptionUsd
         FROM PhonePlans
         WHERE(Active = @Active
               OR @Active IS NULL);
     END;


GO