SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ZZ0_IntegrityConfig](
	[ErrorCode] [varchar](5) NOT NULL,
	[ErrorDesc] [varchar](200) NOT NULL,
	[TableField] [varchar](255) NOT NULL,
	[Query] [varchar](8000) NULL,
	[IsEnabled] [bit] NOT NULL,
	[Priority] [tinyint] NULL,
	[Comment] [varchar](500) NULL,
	[LastLogUpdate] [date] NULL,
	[NbOpenCases] [int] NULL,
 CONSTRAINT [PK_ZZ0_IntegrityConfig] PRIMARY KEY CLUSTERED 
(
	[ErrorCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [dbo].[ZZ0_IntegrityConfig] ADD  CONSTRAINT [DF_ZZ0_IntegrityConfig_IsEnabled]  DEFAULT ((1)) FOR [IsEnabled]
GO