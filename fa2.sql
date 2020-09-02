create table Orders
(
    OrderId int(5) PRIMARY KEY auto_increment,
    CustId int(4) unique,
    SweetId varchar(6) unique,
    QtyOrdered int(5) not null,
    DateOfOrder date not null,
    DeliveryStatus varchar(10) not null,
    constraint C_f foreign key(CustId) references CustomerDetails(CustId),
    constraint s_f foreign key(SweetId) references SweetDetails(SweetId)
)Engine=InnoDB,
auto_increment=10001;


select cd.CustId,CustName,PhoneNo from CustomerDetails cd inner join Orders o on  cd.CustId=o.CustId
where o.DeliveryStatus='Pending' order by o.DateofOrder limit 1;

SELECT distinct SUBSTRING_index(CustName," ",1) as CustName
FROM CustomerDetails cd inner join Orders o  on cd.CustId=o.CustId where o.DeliveryStatus="Delivered";

 select SweetName from SweetDetails sd inner join Orders o
 on sd.SweetId=o.SweetId group by QtyOrdered order by max(QtyOrdered) desc limit 1;
 
 SELECT  C_f,Foreign key 
FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS 
WHERE TABLE_NAME='Orders' AND TABLE_SCHEMA='os_T1082806';

create trigger UpdateQtyInStock
after insert 
on Orders
for each row
update SweetDetails
set
QtyInStock=QtyInStock-new.QtyOrdered
where SweetId=new.SweetId;

DROP FUNCTION IF EXISTS CustomerBilling;
delimiter //
create function CustomerBilling(c_id int(20))
returns float
begin
declare c_status integer(1);
declare totalbill integer(10);
declare d_status integer(10);
declare total integer(20);
select count(*) into c_status from CustomerDetails where CustId=c_id;
if (c_status=0) then
	set totalbill=-1;
else
	select count(*) into d_status from Orders where DeliveryStatus='Pending' and CustId=c_id;
	if (d_status=0) then
		set totalbill=-2;
	else
		--select sum(bill) from(select o.QtyOrdered * sd.CostPerKg as bill from Orders o inner join SweetDetails sd 
		--on sd.SweetId = o.SweetId where o.DeliveryStatus = 'Pending' and CustId=c_id) into total;
		set total = 1230;
		
		if (total>500 and total<1000) then
			set totalbill= (0.95)*total;
		elseif (total<1000) then
			set totalbill = (0.90)*total;
		else
			set totalbill=total;
		END IF;
		
	END IF;
END IF;
return totalbill;
end;
//
delimiter ;
