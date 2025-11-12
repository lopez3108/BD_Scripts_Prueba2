SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[sp_GetClienteDetails](@ClientId INT)
AS
    BEGIN
        SELECT Clientes.ClienteId, 
               Clientes.Foto, 
               Clientes.FingerPrint, 
               Clientes.Doc1Front, 
               Clientes.Doc1Back, 
               Clientes.Doc1Type, 
               Clientes.Doc1Number, 
               Clientes.Doc1Country, 
               Clientes.Doc1State, 
               Clientes.Doc1Expire, 
               Clientes.Doc2Front, 
               Clientes.Doc2Back, 
               Clientes.Doc2Type, 
               Clientes.Doc2Number, 
               Clientes.Doc2Country, 
               Clientes.Doc2State, 
               Clientes.Doc2Expire, 
               UPPER(TypeID.Description) AS Doc1TypeName, 
               UPPER(Countries.Name) AS Doc1CountryName, 
               UPPER(Countries_1.Name) AS Doc2CountryName, 
               UPPER(TypeID_1.Description) AS Doc2TypeName, 
			   users.BirthDay as BirthDay,
			   users.Address as Address,
               dbo.fn_GetClientCashedAmount(ClienteId) AS CashedAmount, 
               dbo.fn_GetClientNumberOfChecks(ClienteId) AS NumberChecks, 
               dbo.fn_GetClientBouncedAmount(ClienteId) AS BouncedAmount, 
               dbo.fn_GetClientNumberOfChecksBounced(ClienteId) AS NumberChecksBounced,
			   Clientes.CreationDate,
				Clientes.CreatedBy,
				u1.Name as CreatedByName,
         cast(Clientes.IsClientVIP AS bit) AS IsClientVIP,
		    CASE WHEN Clientes.IsClientVIP = 1 
			THEN 'YES'
			ELSE 'NO'
			END
			AS IsClientVIPText,
      vip.Name as VipUser,
      Clientes.VIPDate AS VipDate,
    vipA.Code + ' - ' +   vipA.Name AS VipAgency,
     clientes.ReasonOne,
     clientes.ReasonTwo
     

  FROM Clientes

             LEFT JOIN TypeID ON Clientes.Doc1Type = TypeID.TypeId
             LEFT JOIN Countries ON Clientes.Doc1Country = Countries.CountryId
			        inner join  users on  users.userid = Clientes.usuarioId
        left join  users vip on  vip.userid = Clientes.VIPUserId
          left join  Agencies  vipA on  vipA.AgencyId = Clientes.VIPAgencyId
             LEFT OUTER JOIN Countries AS Countries_1 ON Clientes.Doc2Country = Countries_1.CountryId
             LEFT OUTER JOIN TypeID AS TypeID_1 ON Clientes.Doc2Type = TypeID_1.TypeId
			 LEFT JOIN Users as u1 ON Clientes.CreatedBy = u1.UserId
        WHERE ClienteId = @ClientId;
    END;
GO