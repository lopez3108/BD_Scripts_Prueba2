SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[sp_GetAllCashiersBillHistory] @AgencyId INT = NULL
AS
     BEGIN
	   IF(@AgencyId IS NULL)--Cuando agencyId is null, es porque está haciendo la consulta un admin o manager, y en este caso debe retornar todos los cajeros
            BEGIN 
			SELECT DISTINCT Users.Name, 
               Users.UserId     
        FROM Cashiers
             INNER JOIN Users ON Cashiers.UserId = Users.UserId
             INNER JOIN AgenciesxUser ON AgenciesxUser.UserId = Cashiers.UserId		
             
             AND IsActive = 1

			 END
			 ELSE --Para los cajeros debe retornar la lista de cashiers de la misma agencia, o los cajeros que en algún momento hicieron bills para la agencyId
			 BEGIN
			 SELECT DISTINCT * FROM ( SELECT  Users.Name, 
               Users.UserId     
        FROM Cashiers
             INNER JOIN Users ON Cashiers.UserId = Users.UserId
             INNER JOIN AgenciesxUser ON AgenciesxUser.UserId = Cashiers.UserId
			   WHERE(AgenciesxUser.AgencyId = @AgencyId
             )
             

			UNION ALL
			SELECT DISTINCT 
               Users.Name, 
               Users.UserId     
        FROM SystemToolsBill s
		      INNER JOIN Users ON Users.UserId = S.CreatedBy
             INNER JOIN Agencies A ON a.AgencyId = s.AgencyId
             
        WHERE(A.AgencyId = @AgencyId)
			 ) AS Q
             
			 END

			 
			
      
	

		--	 UNION

		--	 	   SELECT DISTINCT 
  --             Users.Name, 
  --             Users.UserId
  --      --AgenciesxUser.AgencyId
  --     select * FROM SystemToolsBill
  --           INNER JOIN Users ON Cashiers.UserId = Users.UserId
  --           INNER JOIN AgenciesxUser ON AgenciesxUser.UserId = Cashiers.UserId
  --           LEFT JOIN Admin ON Admin.UserId = Users.UserId
  --      WHERE(AgenciesxUser.AgencyId = @AgencyId
  --            OR @AgencyId IS NULL)
  --           AND IsActive = 1


  --       SELECT Users.Name,
  --              Cashiers.CashierId,
  --              Users.UserId
  --      select * FROM Cashiers
  --            INNER JOIN select * from Users ON Cashiers.UserId = Users.UserId
		--	  Inner join AgenciesxUser au on au.UserId = Users.UserId
  --       WHERE Cashiers.IsActive = 1 and au.AgencyId = @AgencyId
  --       ORDER BY Users.Name;
    END;
	 --select * from AgenciesxUser
GO