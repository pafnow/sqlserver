SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[ZZ0_IntegrityLog](
	[IntegrityLogId] [int] IDENTITY(1,1) NOT NULL,
	[ErrorCode] [varchar](5) NOT NULL,
	[ErrorDetails] [varchar](8000) NOT NULL,
	[Group] [int] NOT NULL,
	[PK1] [sql_variant] NOT NULL,
	[PK2] [sql_variant] NOT NULL,
	[OpenDate] [date] NOT NULL,
	[CloseDate] [date] NULL,
 CONSTRAINT [PK_ZZ0_IntegrityLog] PRIMARY KEY CLUSTERED 
(
	[IntegrityLogId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[ZZ0_IntegrityLog] ADD  CONSTRAINT [DF_ZZ0_IntegrityLog_PK2]  DEFAULT ('') FOR [PK2]
GO

ALTER TABLE [dbo].[ZZ0_IntegrityLog]  WITH CHECK ADD  CONSTRAINT [FK_ZZ0_IntegrityLog_IntegrityConfig] FOREIGN KEY([ErrorCode])
REFERENCES [dbo].[ZZ0_IntegrityConfig] ([ErrorCode])
GO

ALTER TABLE [dbo].[ZZ0_IntegrityLog] CHECK CONSTRAINT [FK_ZZ0_IntegrityLog_IntegrityConfig]
GO

ALTER TABLE [dbo].[ZZ0_IntegrityLog]  WITH CHECK ADD  CONSTRAINT [CK_ZZ0_IntegrityLog_CloseDate] CHECK  (([CloseDate]<=getdate() AND [CloseDate]>=[OpenDate]))
GO

ALTER TABLE [dbo].[ZZ0_IntegrityLog] CHECK CONSTRAINT [CK_ZZ0_IntegrityLog_CloseDate]
GO

ALTER TABLE [dbo].[ZZ0_IntegrityLog]  WITH CHECK ADD  CONSTRAINT [CK_ZZ0_IntegrityLog_OpenDate] CHECK  (([OpenDate]<=getdate()))
GO

ALTER TABLE [dbo].[ZZ0_IntegrityLog] CHECK CONSTRAINT [CK_ZZ0_IntegrityLog_OpenDate]
GO