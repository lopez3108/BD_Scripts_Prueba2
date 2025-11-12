CREATE TABLE [dbo].[Cashiers] (
  [CashierId] [int] IDENTITY,
  [UserId] [int] NOT NULL,
  [IsActive] [bit] NOT NULL CONSTRAINT [DF_Cashiers_IsActive] DEFAULT (1),
  [ViewReports] [bit] NULL CONSTRAINT [DF__Cashiers__ViewRe__52E34C9D] DEFAULT (1),
  [AllowManipulateFiles] [bit] NOT NULL CONSTRAINT [DF_Cashiers_AllowManipulateFiles] DEFAULT (0),
  [CashFund] [decimal](18, 2) NOT NULL CONSTRAINT [DF_Cashiers_CashFund] DEFAULT (0),
  [AccessProperties] [bit] NOT NULL CONSTRAINT [DF__Cashiers__Access__68C86C1B] DEFAULT (0),
  [IsManager] [bit] NOT NULL CONSTRAINT [DF_Cashiers_IsManager] DEFAULT (0),
  [IsAdmin] [bit] NOT NULL CONSTRAINT [DF_Cashiers_IsManager1] DEFAULT (0),
  [SecurityLevelId] [int] NULL,
  [SecurityCode] [varchar](50) NULL,
  [ExpirationDateCode] [datetime] NULL,
  [ExpirationDateUrl] [datetime] NULL,
  [TrainingToDoId] [int] NULL,
  [ReviewToDoId] [int] NULL,
  [ComplianceRol] [int] NULL CONSTRAINT [DF_Cashiers_ComplianceRol] DEFAULT (1),
  [IsComissions] [bit] NOT NULL CONSTRAINT [DF__Cashiers__IsComi__6CF8EFB2] DEFAULT (0),
  [ValidComissions] [date] NULL,
  [CycleDateVacation] [date] NULL,
  [IsSocialSecurityInternal] [bit] NULL CONSTRAINT [DF_Cashiers_IsSocialSecurityInternal] DEFAULT (0),
  [IsW4Internal] [bit] NULL CONSTRAINT [DF_Cashiers_IsW4Internal] DEFAULT (0),
  [IsConfidentialityInternal] [bit] NULL CONSTRAINT [DF_Cashiers_IsConfidentialityInternal] DEFAULT (0),
  [IsAddressProofInternal] [bit] NULL CONSTRAINT [DF_Cashiers_IsAddressProofInternal] DEFAULT (0),
  [IsDirectDepositInternal] [bit] NULL CONSTRAINT [DF_Cashiers_IsDirectDepositInternal] DEFAULT (0),
  [IsBiometricInformationInternal] [bit] NULL CONSTRAINT [DF_Cashiers_IsBiometricInformationInternal] DEFAULT (0),
  [IsIdentificationInternal] [bit] NULL CONSTRAINT [DF_Cashiers_IsIdentificationInternal] DEFAULT (0),
  [IsEmploymentApplicationInternal] [bit] NULL CONSTRAINT [DF_Cashiers_IsEmploymentApplicationInternal] DEFAULT (0),
  [CycleDateLeaveHours] [date] NULL,
  CONSTRAINT [PK_Cashiers] PRIMARY KEY CLUSTERED ([CashierId])
)
ON [PRIMARY]
GO

ALTER TABLE [dbo].[Cashiers]
  ADD CONSTRAINT [FK_Cashiers_SecurityLevel] FOREIGN KEY ([SecurityLevelId]) REFERENCES [dbo].[SecurityLevel] ([SecurityLevelId])
GO

EXEC sys.sp_addextendedproperty N'MS_Description', 'Save the cycle for leave hours ', 'SCHEMA', N'dbo', 'TABLE', N'Cashiers'
GO