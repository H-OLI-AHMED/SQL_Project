---------------- My_Project: Inventory Management(DDL)
Use Master
Drop database if exists Inventory_Management 
create database Inventory_Management 
on primary (name='Inventory_Management_data',filename = 'C:\SQL\Inventory_Management_data.mdf',
size=10mb,maxsize=100mb,filegrowth=5%)
log on(name='Inventory_Management_log',filename = 'C:\SQL\Inventory_Management_log.ldf',
size=10mb,maxsize=10mb,filegrowth=5%)
go
Use Inventory_Management;
go
Drop table if exists Items 
Create table Items
(
	[Item no]	varchar(100)  Primary key,
	Item		varchar(100),
	Color		varchar(100)
);
go
Drop proc if exists sp_Items 
go
Create proc sp_Items @Item_no varchar(100),
                     @Item    varchar(100),
					 @Color   varchar(100)
as
insert into Items values 
                     (@Item_no,@Item,@Color);
go
Drop table if exists Items2 
Create table Items2
(
StockCode	varchar(100) primary key,
Name		Varchar(100),
Stock		int
);
go
Drop proc if exists sp_Items2 
go
Create proc sp_Items2 @StockCode varchar(100),
                      @Name      Varchar(100),
					  @Stock	 int
as
insert into Items2 values 
                      (@StockCode,@Name,@Stock);
go
Drop table if exists Item_Price
Create table Item_Price
(
	[Item no]		varchar(100) 
	Primary key     references 
	Items([Item no]),
	[Unit Price]	money
);
go
Drop proc if exists sp_Item_Price 
go
Create proc sp_Item_Price @Item_no varchar(100),
                          @Unit_Price money
as
insert into Item_Price values 
                          (@Item_no,@Unit_Price);
go
Drop table if exists Lots
Create table Lots
(
	Lot		varchar(100)  Primary key,
	Vat		varchar(100)
);
go
Drop proc if exists sp_Lots 
go
Create proc sp_Lots @Lot varchar(100),
                    @Vat varchar(100)
as
insert into  Lots values 
                   (@Lot,@Vat);
go
Drop table if exists Item_Details
Create table Item_Details
(
	Lot			varchar(100) references Lots(Lot),
	[Item no]	varchar(100) references Item_Price([Item no]),
	Qty			int,
	Date		date
);
go
Drop proc if exists sp_Item_Details 
go
Create proc sp_Item_Details @Lot varchar(100),
                            @Item_no varchar(100),
							@Qty int ,@Date date
as
insert into  Item_Details  values 
                           (@Lot,@Item_no,@Qty,@Date);
go
Drop table if exists Purchase2
create table Purchase2
(
Vno varchar(100),
Slno		int,
Itemcode	Varchar(100),
Qty			int,
            primary key(Vno,Slno)
);
go
Drop proc if exists sp_Purchase2
go
Create proc sp_Purchase2 @Vno      varchar(100),
                         @Slno     int,
						 @Itemcode Varchar(100),
						 @Qty      int
as
insert into  Purchase2 values 
                        (@Vno,@Slno,@Itemcode,@Qty);
go
Drop table if exists fees
Create table fees
(
id			 int primary key,
amount		 money
);
go
Drop proc if exists sp_fees
go
Create proc sp_fees @id	int,
                    @amount	money
as
insert into  fees values 
                   (@id,@amount);
go

--Alter clause(add a column)
Alter table Item_Details add Report varchar(100);

Select * from Item_Details
go

--Alter clause(delete a column)

Alter table Item_Details Drop column Report;

Select * from Item_Details;
go

--trigger--It is a store procedure which runs insert,update,delete 
Drop table if exists Item_stock
Create table Item_stock
(
Stock_code  varchar(100)	Primary key,
            Name varchar(100),
Stock       int
);
go

Drop table if exists Purchase
Create table Purchase
(
Vow_no    varchar(100),
SL_no     int,
[Item no] varchar(100) references Item_Price([Item no]),
Qty       int,
Primary key(Vow_no, SL_no)
);
go

Select * from Item_stock;
Select * from Purchase;
go
--create trigger-----------------------------------------------------
Drop Trigger if exists trig_item_purchase
go
Create Trigger trig_item_purchase
on Purchase after insert 
as
update Item_stock set Stock = Stock + inserted.Qty from inserted where Stock_code=
(select [Item no] from inserted)
go

--create update trigger-----------------
Drop trigger if exists trig_item_purchase_update
go
Create trigger trig_item_purchase_update
on purchase after update
as
update Item_stock set stock = stock + inserted.Qty from inserted where Stock_code =
(select [Item no] from inserted)
update Item_stock set stock = stock - deleted.Qty from deleted where Stock_code =
(select [Item no] from deleted)
go

--create Limited record with trigger in transaction----------------------------------
Drop trigger if exists trig_limit_record
go
Create trigger trig_limit_record
on Purchase after insert 
as
begin tran
declare @a int
select @a = count(*) from Purchase
if(@a>6)
begin 
print 'You cannot insert record more than 6'
rollback
end
else 
commit;
go

--create Procedure with insert-----------------------------
Drop Proc if exists Sp_insert_purchase
go
Create Proc Sp_insert_purchase(@vno varchar(100),@Slno int,@Ic varchar(100), @Q int)
as
begin try
insert into Purchase values(@vno,@Slno,@Ic,@Q)
end try
begin catch
declare @error varchar(100)
set @error = 'My error show>' + convert(varchar,ERROR_NUMBER()) +':' + ERROR_MESSAGE()
raiserror (@error,16,1)
end catch
go

--Create Procedure with Delete------------------------------
Drop Proc if exists Sp_Delete_Purchase
go
Create Proc Sp_Delete_Purchase(@vno varchar(100), @slno int)
as
begin try 
Delete from Purchase where Vow_no = @vno and SL_no = @slno
end try
begin catch
declare @error varchar(100)
set @error = 'My error show>' + convert(varchar,ERROR_NUMBER()) +':' + ERROR_MESSAGE()
raiserror (@error,16,1)
end catch
go

--Create a Scalar function-----------------------------
Drop function if exists fn_PurchaseRecord
go
Create function fn_PurchaseRecord()
returns int
as
begin
Declare @a int
Select @a = count(*) from Purchase
return @a
end
go

--Create table function-------------------------
Drop function if exists fn_PurchaseTable
go
Create function fn_PurchaseTable(@vno varchar(100))
returns table
as
return select * from Purchase where Vow_no = @vno;
go


--Create a View-------------------
Drop View if exists View_joinitem
go
Create View View_joinitem
as
Select Lots.Lot,Items.[Item no],Item,Items.Color,Item_Details.Qty,
Item_Price.[Unit Price],Item_Details.Date,lots.vat from Item_Details join 
lots on Item_Details.Lot=lots.Lot join items on Items.[Item no]=Item_Details.[Item no]
join Item_Price on Item_Price.[Item no]=Item_Details.[Item no];
go 
--Create Merge
If exists(select * from sysobjects where name='ItemsRecycle')
drop table ItemsRecycle
Create table ItemsRecycle
(
[item no]    varchar(100),
item         varchar(100),
color        varchar(100),
[unit price] int,
lot          varchar(100),
vat          varchar(100),
qty          int,
date         varchar(100));
go
--Create index--
create index IX_Items_Item
on Items(Item)

