--------------My_Project: Inventory Management(DML)
Use Inventory_Management;

go
begin try
begin tran
exec sp_Items 'Item no 1','Shirts','Red'
exec sp_Items 'Item no 2','Shirts','Red'
exec sp_Items 'Item no 3','T-Shirts','Blue'
exec sp_Items 'Item no 4','T-Shirts','Blue'
exec sp_Items 'Item no 5','T-Shirts','Red'
commit tran
end try
begin catch
print @@error
print ERROR_MESSAGE()
rollback tran;
end catch
go
Select * from Items;

go
begin try
begin tran
exec sp_Items2 'Ac-01','Rice',5
exec sp_Items2 'Ac-02','Fish',15
exec sp_Items2 'Ac-03','Meet',25
exec sp_Items2 'Ac-04','Fish',30
exec sp_Items2 'Ac-05','Meet',10
commit tran
end try
begin catch
print @@error
print ERROR_MESSAGE()
rollback tran;
end catch
go
Select * from Items2;

go
begin try
begin tran
exec sp_Item_Price 'Item no 1',330
exec sp_Item_Price 'Item no 2',650
exec sp_Item_Price 'Item no 3',300
exec sp_Item_Price 'Item no 4',580
exec sp_Item_Price 'Item no 5',550
commit tran
end try
begin catch
print @@error
print ERROR_MESSAGE()
rollback tran;
end catch
go
Select * from Item_Price;

go
begin try
begin tran
exec sp_Lots 'Lot 1','10%'
exec sp_Lots 'Lot 2','10%'
commit tran
end try
begin catch
print @@error
print ERROR_MESSAGE()
rollback tran;
end catch
go
Select * from Lots;

go
begin try
begin tran
exec sp_Item_Details 'Lot 1','Item no 1',60,'2021-01-02'
exec sp_Item_Details 'Lot 1','Item no 2',50,'2021-01-03'
exec sp_Item_Details 'Lot 2','Item no 1',80,'2021-02-02'
exec sp_Item_Details 'Lot 2','Item no 2',70,'2021-02-04'
commit tran
end try
begin catch
print @@error
print ERROR_MESSAGE()
rollback tran;
end catch
Select * from Item_Details;
go

begin try
begin tran
exec sp_Purchase2 'v-01',1,'Ac-02',4
exec sp_Purchase2 'v-01',2,'Ac-01',5
exec sp_Purchase2 'v-02',1,'Ac-02',5
exec sp_Purchase2 'v-02',2,'Ac-03',13
commit tran
end try
begin catch
print @@error
print ERROR_MESSAGE()
rollback tran;
end catch
Select * from purchase2;

go
begin try
begin tran
exec sp_fees 1,100
exec sp_fees 2,200
exec sp_fees 3,300
exec sp_fees 4,400
commit tran
end try
begin catch
print @@error
print ERROR_MESSAGE()
rollback tran;
end catch
go
select * from fees;

go

Select * from Items;
select * from items2;
Select * from Item_Price;
Select * from Lots;
Select * from Item_Details;
Select * from purchase2;
select * from fees;

go

-------------------select,where,order by clause--------
Select * from Item_Details where Qty >50 order by Date;
go

-------------------------update -----------------------------

update Item_Price set [Unit Price]= 350 where [Item no] = 'Item no 3';

Select * from Item_Price;
go

--------------------------delete--------------------------------

Delete from Item_Details where Qty = 75;

select * from Item_Details;
go

---------------------------Join---------------------------------

Select Lots.Lot,Items.[Item no],Item,Items.Color,Item_Details.Qty,
Item_Price.[Unit Price],Item_Details.Date,lots.vat from Item_Details join 
lots on Item_Details.Lot=lots.Lot join items on Items.[Item no]=Item_Details.[Item no]
join Item_Price on Item_Price.[Item no]=Item_Details.[Item no];
go

------------------Aggregate funtions-------------------------

Select [Item no],sum([Unit Price]) as 'Total' from Item_Price 
group by [Item no] with rollup;
go

-----------------Trigger insert values------------------------

Insert into Item_stock values
			('Item no 1','Shirt',5),
			('Item no 2','Shirt',0),
			('Item no 3','T-Shirt',10),
			('Item no 4','T-Shirt',20),
			('Item no 5','T-Shirt',8),
			('Item no 6','Polo Shirt',12),
			('Item no 7','Polo Shirt',6),
			('Item no 8','Polo Shirt',8)
go
Select * from Item_stock;

go
----------testing  trigger after inserted-------------------
Insert into Purchase values('V-01',1,'Item no 1',10);
Insert into Purchase values('V-01',2,'Item no 2',15);
Insert into Purchase values('V-01',3,'Item no 1',5);
Insert into Purchase values('V-01',4,'Item no 3',10);
Insert into Purchase values('V-01',5,'Item no 4',20);
go
Select * from Purchase;

-------------------testing trigger after update----------------
update Purchase set Qty = 22 where Vow_no = 'V-01'and SL_no =1;

go

---------------testing trigger after limited record---------
--Insert into Purchase values('V-01',6,'Item no 6',15);
--Insert into Purchase values('V-01',7,'Item no 7',18);
go

----------------insert Procedure testing----------------------
--Exec Sp_insert_purchase 'V-01',7,'Item no 7',18;
go
--Select * from Purchase;

go
-------------------------delete--------------------------
delete from Items where [Item no]= 'Item no 6''T-Shirts''Red'
go

------------over--aggreagate function but no group by----------
select [Item no],[Unit Price],
sum([Unit Price]) over (partition by [Item no])
from Item_Price;
go
select * from Item_Price
go
----------Delete Procedure from Purchase table testing------------
Exec Sp_Delete_Purchase 'V-01',7;
go
Select * from Purchase;
go

----------testing Scalar function-------------------
select dbo.fn_PurchaseRecord();
go

----------testing table function----------------------
select * from fn_PurchaseTable('V-01');
go

---------------testing view-----------------------
select * from View_joinitem;

go

-------------Join and Aggregate Function----------------
Select Items.[Item no],Item_Details.lot,count(*) 
from items,Item_Details,lots where 
items.[Item No]=Item_Details.[Item No] 
and Item_Details.lot=lots.lot
and items.[Item No] in( 'Item no 1','Item no 2','Item no 3')
group by Items.[Item No],Item_Details.lot

------------------rollup---------------------
Select Items.[Item no],Item_Details.lot,count(*) 
from items,Item_Details,lots where 
items.[Item No]=Item_Details.[Item No] 
and Item_Details.lot=lots.lot
and items.[Item No] in( 'Item no 1','Item no 2','Item no 3')
group by Items.[Item No],Item_Details.lot with rollup

-----------------cube----------------------------
Select Items.[Item no],Item_Details.lot,count(*) 
from items,Item_Details,lots where 
items.[Item No]=Item_Details.[Item No] 
and Item_Details.lot=lots.lot
and items.[Item No] in( 'Item no 1','Item no 2','Item no 3')
group by Items.[Item No],Item_Details.lot with cube

go

----------------grouping sets-------------------
Select Items.[Item no],Item_Details.lot,count(*) 
from items,Item_Details,lots where 
items.[Item No]=Item_Details.[Item No] 
and Item_Details.lot=lots.lot
and items.[Item No] in( 'Item no 1','Item no 2','Item no 3')
group by grouping sets(Items.[Item No],Item_Details.lot)

go
------------------subquery-------------------
select * from items where [item no] in
(select [item no] from Item_Details);
go
------------------cte-------------------
with
i as (select * from items),
c as (select * from Item_Price),
l as (select * from lots),
id as (select * from Item_Details)
select * from i,c,l,id where id.[Item no]=i.[Item No]
and id.lot=l.Lot and id.[Item no]=c.[Item no];

go

-------------------case-------------------
with
i as (select * from items),
c as (select * from Item_Price),
l as (select * from lots),
id as (select * from Item_Details)
select *,[Unit Price]*qty as totalprice,
case when [Unit Price]*qty>14000 then 'Very Good'
when [Unit Price]*qty>10000 then 'Good'
else 'Bad' end as Comment
 from i,c,l,id where id.[Item no]=i.[item no] 
and id.lot=l.lot and id.[Item no]=c.[Item no]
go

---------------- merge----------------------
go
merge itemsrecycle l2
using 
(
select Item_Details.[item no],item,color,[unit price],
Item_Details.lot,vat,qty,date from items,Item_Price,lots,
Item_Details where Item_Details.[Item no]=items.[Item No]
and Item_Details.lot=lots.Lot 
and Item_Details.[Item no]=Item_Price.[Item no]
) l
on l2.[Item no]=l.[Item no]
when matched then
update set l2.color=l.color,l2.item=l.item,
l2.[unit price]=l.[unit price],l2.lot=l.lot,l2.vat=l.vat,
l2.qty=l.qty,l2.date=l.date
when not matched then
insert values(l.[item no],l.item,l.color,l.[unit price],l.lot
,l.vat,l.qty,l.date);
select * from itemsrecycle;