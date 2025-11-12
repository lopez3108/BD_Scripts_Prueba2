SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetEmails]
@Active BIT = NULL
AS
    BEGIN
        SELECT EmailsId, 
               Address, 
               Name, 
               Active,

			   CASE
                   WHEN Active = 1
                   THEN 'ACTIVE'
                   ELSE 'INACTIVE'
                END AS [ActiveFormat]

        FROM Emails
		where Active=@Active OR @Active IS NULL
    END;
GO