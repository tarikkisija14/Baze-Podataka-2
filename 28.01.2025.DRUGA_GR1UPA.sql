

 --5. 										
--Kreirati bazu podataka koju ćete imenovati svojim brojem indeksa. 
Go
create database IB230000

go
use IB230000


--5.1. 										max: 5 bodova
--U kreiranoj bazi podataka kreirati tabele sa sljedećom strukturom: 			
--a) Izdavaci 
--•	IzdavacID, 4 karaktera fiksne dužine i primarni ključ, 
--•	NazivIzdavaca, 40 karaktera, (zadana vrijednost „nepoznat izdavac“) 
--•	Drzava, 30 karaktera, 
--•	Logo, fotografija  

create table Izdavaci
(
  IzdavacID char(4) constraint PK_Izdavaci primary key, 
  NazivIzdavaca varchar(40) default('nepoznat izdavac'),
  Drzava varchar(30), 
  Logo Image

)

--b) Naslovi 
--•	NaslovID, 6 karaktera i primarni ključ, 
--•	Naslov, 80 karaktera (obavezan unos), 
--•	Tip, 12 karaktera fiksne dužine (obavezan unos), 
--•	Cijena, novčani tip podataka,   
--•	IzdavacID, 4 karaktera fiksne dužine, strani ključ 

create table Naslovi
(
   NaslovID char(6) constraint PK_Naslovi primary key, 
   Naslov varchar(80) not null, 
   Tip char(12) not null,
   Cijena money, 
   IzdavacID char(4) constraint FK_Naslovi_Izdavaci foreign key references Izdavaci(IzdavacID)

)



--c) Prodaja  
--•	ProdavnicaID, 4 karaktera fiksne dužine, strani i primarni ključ, 
--•	BrojNarudzbe, 20 karaktera, primarni ključ, 
--•	NaslovID, 6 karaktera, strani i primarni ključ, 
--•	DatumNarudzbe, polje za unos datuma i vremena (obavezan unos), 
--•	Kolicina, skraćeni cjelobrojni tip (obavezan unos, dozvoljen unos brojeva većih od 0


create table Prodaja
(
 ProdavnicaID char(4) constraint FK_Prodavnica_Prodaja foreign key references Prodavnice(ProdavnicaID),
 BrojNarudzbe varchar(20),
 NaslovID char(6) constraint FK_Prodavnice_Naslovi foreign key references Naslovi(NaslovID), 
 DatumNarudzbe datetime not null,
 Kolicina smallint not null check(Kolicina>0)
 constraint PK_Prodaja primary key(ProdavnicaID,BrojNarudzbe,NaslovID)
)


--d)	Prodavnice 
--•	ProdavnicaID, 4 karaktera fiksne dužine i primarni ključ, 
--•	NazivProdavnice, 40 karaktera, 
--•	Grad, 40 karaktera 

create table Prodavnice(
   ProdavnicaID char(4) constraint PK_Prodavnice primary key,
   NazivProdavnice varchar(40),
   Grad varchar(40)
)

--5.2. 										max: 5 bodova
--U kreiranu bazu kopirati podatke iz baze Pubs: 		
--a)	U tabelu Izdavaci dodati sve izdavače 
--pub_id  IzdavacID; 
--pub_name  NazivIzdavaca; 
--country  Drzava; 
--Logo  Logo 

insert into Izdavaci(IzdavacID,NazivIzdavaca,Drzava,Logo)
select p.pub_id,p.pub_name,p.country,pi.logo
from pubs.dbo.publishers as p inner join pubs.dbo.pub_info as pi on pi.pub_id=p.pub_id

--b)	U tabelu Naslovi dodati sve naslove, na mjestima gdje nema pohranjenih podataka o cijeni zamijeniti vrijednost sa 0 
--title_id  NaslovID; 
--title  Naslov; 
--type  Tip; 
--price  Cijena; 
--pub_id  IzdavacID 

insert into Naslovi(NaslovID,Naslov,Tip,Cijena,IzdavacID)
select t.title_id,t.title,t.type,t.price,t.pub_id
from pubs.dbo.titles as t



--c)	U tabelu Prodaja dodati sve stavke iz tabele prodaja 
--•	stor_id  ProdavnicaID; order_num  BrojNarudzbe; title_id  NaslovID; ord_date  DatumNarudzbe; qty  Kolicina 

insert into Prodaja(ProdavnicaID,BrojNarudzbe,NaslovID,DatumNarudzbe,Kolicina)
select sa.stor_id,sa.ord_num,sa.title_id,sa.ord_date,sa.qty
from pubs.dbo.sales as sa

--d)	U tabelu Prodavnice dodati sve prodavnice 
--•	stor_id  ProdavnicaID; store_name  NazivProdavnice; city  Grad 

insert into Prodavnice(ProdavnicaID,NazivProdavnice,Grad)
select st.stor_id,st.stor_name,st.city
from pubs.dbo.stores as st


--5.3. 										max: 15 bodova
--a)	(5 bodova) Kreirati pogled v_prodaja kojim će se prikazati statistika prodaje knjiga po izdavačima. Prikazati naziv te državu iz koje izdavači dolaze, ukupan broj napisanih naslova, te ukupnu prodanu količinu. Rezultate sortirati po ukupnoj prodanoj količini u opadajućem redoslijedu. (Novokreirana baza) 
go
create view v_prodaja
as
select i.NazivIzdavaca,i.Drzava,COUNT(n.NaslovID)as 'ukupan broj napisanih naslova',SUM(pr.Kolicina)as 'ukupna kolicina'
from Izdavaci as i inner join Naslovi as n on i.IzdavacID=n.IzdavacID
inner join Prodaja as pr on pr.NaslovID=n.NaslovID
group by i.NazivIzdavaca,i.Drzava

selecT*
from v_prodaja
order by 4 desc


--b)	(2 boda) U novokreiranu bazu iz baze Northwind dodati tabelu Employees. Prilikom kreiranja izvršiti automatsko instertovanje podataka. 
select*
into Zaposlenici
from Northwind.dbo.Employees



--c)	(5 boda) Kreirati funkciju f_4b koja će vraćati podatke u formi tabele na osnovu proslijedjenih parametra od i do, cjelobrojni tip. Funkcija će vraćati one zapise u kojima se godine radnog staža nalaze u intervalu od-do. Potrebno je da se prilikom kreiranja funkcije u rezultatu nalaze sve kolone tabele uposlenici, zajedno sa izračunatim godinama radnog staža. OBAVEZNO provjeriti ispravnost funkcije unošenjem kontrolnih vrijednosti. (Novokreirana baza) 
go
create function f_4b 
(
  @od int,
  @do int
)
returns table 
as return
select z.EmployeeID,z.Address,z.BirthDate,z.City,z.Country,z.Extension,z.FirstName,z.HireDate,z.HomePhone,z.LastName,z.Notes,z.Photo,z.PhotoPath,z.PostalCode,z.Region,z.ReportsTo,z.Title,z.TitleOfCourtesy,DATEDIFF(YEAR,z.HireDate,GETDATE())'radni staz'
from Zaposlenici as z
where DATEDIFF(YEAR,z.HireDate,GETDATE()) between @od and @do






--d)	(3 bodova) Kreirati proceduru sp_Prodavnice_insert kojom će se izvršiti insertovanje podataka unutar tabele prodavnice. OBAVEZNO kreirati testni slučaj. (Novokreirana baza) 
go
create or alter procedure sp_Prodavnice_insert
(
   @ProdavnicaID char(4),
   @NazivProdavnice varchar(40)=null,
   @Grad varchar(40)=null
)
as begin
insert into Prodavnice
values (@ProdavnicaID,@NazivProdavnice,@Grad)
end

exec sp_Prodavnice_insert 'AJDI','Market','Orasje'




--2. 										max: 12 bodova
--Baza: AdventureWorks2017
--a)	(6 bodova) Prikazati ukupnu vrijednost narudžbi za svakog kupca pojedinačno. Upitom prikazati ime i prezime kupca te ukupnu vrijednost narudžbi sa i bez popusta.
--Zaglavlje (kolone): Ime i prezime, Vrijednost bez popusta (količina * cijena), Vrijednost sa popustom.

select CONCAT(p.FirstName,' ',p.LastName),SUM(sod.OrderQty*sod.UnitPrice),SUM(sod.OrderQty*sod.UnitPrice*(1-sod.UnitPriceDiscount))
from AdventureWorks2017.Sales.SalesOrderHeader as soh inner join AdventureWorks2017.Sales.Customer
as c on c.CustomerID=soh.CustomerID
inner join AdventureWorks2017.Sales.SalesOrderDetail as sod on sod.SalesOrderID=soh.SalesOrderID
inner join AdventureWorks2017.Person.Person as p on p.BusinessEntityID=c.PersonID
group by p.FirstName,p.LastName



--b)	(6 bodova) Prikazati 5 proizvoda od kojih je ostvaren najveći profit (zarada) i 5 s najmanjim profitom. Zaglavlje: Ime proizvoda, Zarada.
select*
from(
select top 5 p.Name,SUM(sod.OrderQty*sod.UnitPrice*(1-sod.UnitPriceDiscount))'zarada'
from AdventureWorks2017.Sales.SalesOrderDetail as sod inner join AdventureWorks2017.Production.Product as p on
sod.ProductID=p.ProductID
group by p.Name
order by 2 desc) as sq1
union
select*
from(
select top 5 p.Name,SUM(sod.OrderQty*sod.UnitPrice*(1-sod.UnitPriceDiscount))'zarada'
from AdventureWorks2017.Sales.SalesOrderDetail as sod inner join AdventureWorks2017.Production.Product as p on
sod.ProductID=p.ProductID
group by p.Name
order by 2 asc
) as sq2
-- 3. 										max: 23 boda
--Baza: Northwind
--a)	(7 bodova) Prikazati kupce koji su u sklopu jedne narudžbe naručili proizvode iz tačno tri kategorije. (Northwind)
--Zaglavlje: ContactName.


select c.ContactName
from Northwind.dbo.Customers as c inner join Northwind.dbo.Orders as o on
c.CustomerID=o.CustomerID
inner join Northwind.dbo.[Order Details] as od on od.OrderID=o.OrderID
inner join Northwind.dbo.Products as p on p.ProductID= od.ProductID
inner join Northwind.dbo.Categories as ca on ca.CategoryID=p.CategoryID
group by c.ContactName
having COUNT(distinct ca.CategoryID)=3

--b)	(7 bodova) Prikazati zaposlenike koji su obradili više narudžbi od zaposlenika koji ima najmanje narudžbi u njihovoj regiji (kolona Region). (Northwind) 
--Zaglavlje: Ime i prezime.

select e.FirstName,e.LastName
from Northwind.dbo.Employees as e inner join Northwind.dbo.Orders as o on
o.EmployeeID=e.EmployeeID
group by e.FirstName,e.LastName,e.Region
having COUNT (o.OrderID)>
(
  select top 1 COUNT (o1.OrderID)
  from Northwind.dbo.Employees as e1 inner join Northwind.dbo.Orders as o1 on
o1.EmployeeID=e1.EmployeeID
 where e.Region=e1.Region or (e1.Region is null and e.Region is null)
 group by e1.EmployeeID
 order by 1 asc
)


--c)	(9 bodova) Prikazati proizvode koje naručuju kupci iz zemlje iz koje se najmanje kupuje. (Northwind)
--Zaglavlje: ProductName.

select p.ProductName
from Northwind.dbo.Products as p inner join Northwind.dbo.[Order Details] as od
on od.ProductID=p.ProductID
inner join Northwind.dbo.Orders as o on o.OrderID=od.OrderID
inner join Northwind.dbo.Customers as c on c.CustomerID=o.CustomerID
where c.Country =
(
    select top 1 c1.Country
	from Northwind.dbo.Orders as o1 inner join Northwind.dbo.Customers as c1 on o1.CustomerID=c1.CustomerID
	inner join Northwind.dbo.[Order Details] as od1 on od1.OrderID=o1.OrderID
	group by c1.Country
	order by SUM(od1.Quantity) ASc
)

--4. 										max: 20 bodova
--Baza: Pubs						
--a)	(10 bodova) Prikazati trgovine u kojima se mogu naći naslovi prodani manje puta nego što je 
--Zaglavlje: stor_name
 --prosječna prodaja naslova iz godine kad je--prodano najmanje naslova (Pubs).

 select distinct st.stor_name
 from pubs.dbo.sales as s2 inner join pubs.dbo.titles as t on s2.title_id=t.title_id
 inner join pubs.dbo.stores as st on st.stor_id=s2.stor_id
 where s2.qty <
 (
 select AVG(s1.qty)
 from  pubs.dbo.sales as s1
 where YEAR(s1.ord_date)=
 (
select top 1 YEAR(s.ord_date)
from pubs.dbo.sales as s
group by s.ord_date
order by SUM(s.qty) asc
)
)
--b)	(10 bodova) Prikazati naslove starije od najbolje  prodavanog naslova kojeg je izdao izdavač iz savezne države koja sadrži slog 'CA'.  (Pubs).
--Zaglavlje: title(naslov knjige)
--Napomena: zadatke obavezno rješavati kao podupite (na where, having, ...) – ugnježđeni upiti
 
 
 select t1.title
 from pubs.dbo.titles as t1 
 where t1.pubdate <(
 select top 1 t.pubdate
 from pubs.dbo.titles as t inner join pubs.dbo.sales as s on t.title_id=s.title_id
 inner join pubs.dbo.publishers as p on p.pub_id=t.pub_id
 where p.state like '%CA%'
 group by t.title_id,t.pubdate
 order by SUM(s.qty) desc
 )
