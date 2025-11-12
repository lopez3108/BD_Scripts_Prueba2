SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO
Create procedure [dbo].[sp_SaveMoneyTransferModifications]  @MoneyTransferModificationId int=null, @ClientName varchar(50),
@Telephone varchar (10), @TransactionNumber varchar(20),@ProviderId int, @ValidationCode varchar(4),  
@CreationDate datetime, @CreatedBy int,  @AgencyId int  
AS
Begin
IF @MoneyTransferModificationId is null
Begin
Insert into  MoneyTransferModifications(ClientName, Telephone, TransactionNumber, ProviderId, ValidationCode, CreationDate, CreatedBy, AgencyId)
Values (@ClientName, @Telephone, @TransactionNumber, @ProviderId, @ValidationCode, @CreationDate, @CreatedBy, @AgencyId);
END
ELSE 
Begin
update  MoneyTransferModifications set ClientName=@ClientName, Telephone=@Telephone,TransactionNumber=@TransactionNumber, ProviderId=@ProviderId,
 ValidationCode=@ValidationCode, CreationDate=@CreationDate, CreatedBy=@CreatedBy, AgencyId=@AgencyId where MoneyTransferModificationId=@MoneyTransferModificationId
End
END
GO