SET QUOTED_IDENTIFIER, ANSI_NULLS ON
GO

-- =============================================
-- Author:	Johan
-- Description:	Crea los fraud alert
-- Creation Date: 16-05-2023
-- =============================================
CREATE PROCEDURE [dbo].[sp_CreateFraudAlert]
 ( @FraudId INT = null
 ,@Maker VARCHAR(80) 
 ,@FileNumber VARCHAR(20) = NULL  
 ,@MakerAddress VARCHAR(100) = NULL 
 ,@Account VARCHAR(50) 
 ,@CheckType VARCHAR(50) = null
 ,@NumberRouting  VARCHAR(15) = null
 ,@CheckNumber VARCHAR(50) = null

 ,@ClientName VARCHAR(50) = null
 ,@Country VARCHAR(50) = null
 ,@IdentificacionNumber VARCHAR(30) = null
 ,@DOB DATETIME = null
 ,@TransactionDate DATETIME = null
 
 ,@ClientAddress VARCHAR(100) = NULL 
 ,@Telephone VARCHAR(20) = null 
 ,@CreatedName VARCHAR(80) = null
 ,@CreationDate DATETIME = null
 ,@LastUpdatedName VARCHAR(80) = null
 ,@LastUpdatedOn DATETIME= null,
  @AgencyId INT = null,
  @AgencyName  VARCHAR(200) = NULL ,
  @StateAbreviation   VARCHAR(5) = null ,
  @State  VARCHAR(255) = null,
  @BankName VARCHAR(60)  = NULL,
  @CreatedBy INT = null,
  @IsNotFraud BIT = null,
  @Foto varchar(max)= null,
  @IdSaved              INT OUTPUT
 
 )
AS
     
     IF (@FraudId is NULL)
BEGIN
         INSERT INTO [dbo].FraudAlert
         (Maker,
          MakerAddress,
          Account,
          NumberRouting,
          CheckNumber,
    
          CheckType,
          FileNumber,
          ClientName,
          Country,
          IdentificacionNumber,
          DOB,
          ClientAddress,
          Telephone,         
          TransactionDate,
          
    		  CreatedName,
          CreationDate,
          LastUpdatedName,
          LastUpdatedOn,
          AgencyId,
          AgencyName,
          StateAbreviation,
          State,
          BankName,
          CreatedBy,
          IsNotFraud,
          Foto
          
         )
         VALUES
         (@Maker,
          @MakerAddress,
          @Account,
          @NumberRouting,
          @CheckNumber,         
         
          @CheckType,
          @FileNumber,
          @ClientName,
          @Country,
          @IdentificacionNumber,
          @DOB,
          @ClientAddress,
          @Telephone,
          @TransactionDate,
               
    		  @CreatedName,
          @CreationDate,
          @LastUpdatedName,
          @LastUpdatedOn,
          @AgencyId,
          @AgencyName,
          @StateAbreviation,
          @State,
          @BankName,
          @CreatedBy,
          @IsNotFraud,
          @Foto
         
         );
          SET @IdSaved = @@IDENTITY;
 END;
else
         
          
             BEGIN
                 UPDATE FraudAlert
                   SET
           Maker = @Maker,
           MakerAddress = @MakerAddress,
          Account = @Account,
          NumberRouting = @NumberRouting,
          CheckNumber = @CheckNumber,
         
          CheckType = @CheckType,
          FileNumber = @FileNumber,
          ClientName = @ClientName, 
          Country = @Country,
          IdentificacionNumber = @IdentificacionNumber,
          DOB = @DOB,
          TransactionDate = @TransactionDate,
       
          ClientAddress =  @ClientAddress,  
          Telephone =  @Telephone,
    		  CreatedName = @CreatedName,
          CreationDate = @CreationDate,
          LastUpdatedName = @LastUpdatedName,
          LastUpdatedOn = @LastUpdatedOn,
          StateAbreviation = @StateAbreviation,
          State = @State,
          BankName =@BankName,
          IsNotFraud =@IsNotFraud,
          Foto = @Foto
                 WHERE FraudId = @FraudId;
                	SET @IdSaved = @FraudId;
          
              END;







GO