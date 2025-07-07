--1. Kroz SQL kod kreirati bazu podataka sa imenom vašeg broja indeksa.

CREATE DATABASE IB230000

Go
use IB230000


--2. U kreiranoj bazi podataka kreirati tabele sa sljedećom strukturom:
--a) Uposlenici
--• UposlenikID, 9 karaktera fiksne dužine i primarni ključ,
--• Ime, 20 karaktera (obavezan unos),
--• Prezime, 20 karaktera (obavezan unos),
--• DatumZaposlenja, polje za unos datuma i vremena (obavezan unos),
--• OpisPosla, 50 karaktera (obavezan unos)

create table Uposlenici
(
 UposlenikID char(9) constraint PK_Uposlenici primary key,
 Ime varchar(20)not null,
 Prezime varchar(20)not null,
 DatumZaposlenja datetime not null,
 OpisPosla varchar(50) not null
)

--b) Naslovi
--• NaslovID, 6 karaktera i primarni ključ,
--• Naslov, 80 karaktera (obavezan unos),
--• Tip, 12 karaktera fiksne dužine (obavezan unos),
--• Cijena, novčani tip podataka,
--• NazivIzdavaca, 40 karaktera,
--• GradIzadavaca, 20 karaktera,
--• DrzavaIzdavaca, 30 karaktera

create table Naslovi
(
   NaslovID varchar(6) constraint PK_Naslovi primary key,
   Naslov varchar(80) not null,
   Tip char(12) not null,
   Cijena money,
   NazivIzdavaca varchar(40),
   GradIzdavaca varchar(20),
   DrzavaIzdavaca varchar(30)
)

--c) Prodaja
--• ProdavnicaID, 4 karaktera fiksne dužine, strani i primarni ključ,
--• BrojNarudzbe, 20 karaktera, primarni ključ,
--• NaslovID, 6 karaktera, strani i primarni ključ,
--• DatumNarudzbe, polje za unos datuma i vremena (obavezan unos),
--• Kolicina, skraćeni cjelobrojni tip (obavezan unos)

create table Prodaja
(

ProdavnicaID char(4) constraint FK_Prodaja_Prodavnica foreign key references Prodavnice(ProdavnicaID),
BrojNarudzbe varchar(20),
NaslovID varchar(6) constraint FK_Prodaja_Naslovi foreign key references Naslovi(NaslovID),
DatumNarudzbe datetime not null,
Kolicina smallint not null
constraint PK_Prodaja primary key (ProdavnicaID,BrojNarudzbe,NaslovID)
)


--d) Prodavnice
--• ProdavnicaID, 4 karaktera fiksne dužine i primarni ključ,
--• NazivProdavnice, 40 karaktera,
--• Grad, 40 karaktera
--6 bodova

create table Prodavnice
(
 ProdavnicaID char(4) constraint PK_Propdavnice primary key,
 NazivProdavnice varchar(40),
 Grad varchar(40)

)


--3. Iz baze podataka Pubs u svoju bazu podataka prebaciti sljedeće podatke:
--a) U tabelu Uposlenici dodati sve uposlenike
--• emp_id -> UposlenikID
--• fname -> Ime
--• lname -> Prezime
--• hire_date -> DatumZaposlenja
--• job_desc -> OpisPosla

insert into Uposlenici(UposlenikID,Ime,Prezime,DatumZaposlenja,OpisPosla)
select e.emp_id,e.fname,e.lname,e.hire_date,j.job_desc
from pubs.dbo.employee as e inner join pubs.dbo.jobs as j on j.job_id=e.job_id


--b) U tabelu Naslovi dodati sve naslove, na mjestima gdje nema pohranjenih podataka -o- nazivima izdavača
--zamijeniti vrijednost sa nepoznat izdavac
--• title_id -> NaslovID
--• title -> Naslov
--• type -> Tip
--• price -> Cijena
--• pub_name -> NazivIzdavaca
--• city -> GradIzdavaca
--• country -> DrzavaIzdavaca


insert into Naslovi(NaslovID,Naslov,Tip,Cijena,NazivIzdavaca,GradIzdavaca,DrzavaIzdavaca)
select t.title_id,t.title,t.type,t.price, ISNULL(p.pub_name, 'nepoznat izdavac'),p.city,p.country
from pubs.dbo.titles as t left join pubs.dbo.publishers as p on t.pub_id=p.pub_id

--c) U tabelu Prodaja dodati sve stavke iz tabele prodaja
--• stor_id -> ProdavnicaID
--• order_num -> BrojNarudzbe
--• title_id -> NaslovID
--• ord_date -> DatumNarudzbe
--• qty -> Kolicina

insert into Prodaja(ProdavnicaID,BrojNarudzbe,NaslovID,	DatumNarudzbe,Kolicina)
selecT s.stor_id,s.ord_num,s.title_id,s.ord_date,s.qty
from pubs.dbo.sales as s


--d) U tabelu Prodavnice dodati sve prodavnice
--• stor_id -> ProdavnicaID
--• store_name -> NazivProdavnice
--• city -> Grad
--6 bodova

insert into Prodavnice(ProdavnicaID,NazivProdavnice,Grad)
select s.stor_id,s.stor_name,s.city
from pubs.dbo.stores as s

--4.
--a) (6 bodova) Kreirati proceduru sp_update_naslov kojom će se uraditi update --podataka u tabelu Naslovi.
--Korisnik može da pošalje jedan ili više parametara i pri tome voditi računa da se -ne- desi gubitak/brisanje
--zapisa. OBAVEZNO kreirati testni slučaj za kreiranu proceduru. (Novokreirana baza)

go
create procedure sp_update_naslov
(
 @NaslovID varchar(6),
 @Naslov varchar(80)=null,
 @Tip CHAR(12)=NULL, 
 @Cijena MONEY=NULL,
 @NazivIzdavaca VARCHAR(40)=NULL,
 @GradIzdavaca VARCHAR(20)=NULL,
 @DrzavaIzdavaca VARCHAR(30)=NULL
)
as
begin
update Naslovi
set
Naslov=IIF(@Naslov IS null,Naslov,@Naslov),
Tip =IIF(@Tip IS null,Tip,@Tip),
Cijena=IIF(@Cijena IS null,Cijena,@Cijena),
NazivIzdavaca=IIF(@NazivIzdavaca IS null,NazivIzdavaca,@NazivIzdavaca),
GradIzdavaca = IIF(@GradIzdavaca IS NULL, GradIzdavaca, @GradIzdavaca),
DrzavaIzdavaca=IIF(@DrzavaIzdavaca is null,DrzavaIzdavaca,@DrzavaIzdavaca)
where @NaslovID=NaslovID
end


exec sp_update_naslov @NaslovID='BU1032', @Cijena=30

select* from naslovi

--b) (7 bodova) Kreirati upit kojim će se prikazati ukupna prodana količina i ukupna --zarada bez popusta za
--svaku kategoriju proizvoda pojedinačno. Uslov je da proizvodi ne pripadaju --kategoriji bicikala, da im je
--boja bijela ili crna te da ukupna prodana količina nije veća od 20000. Rezultate --sortirati prema ukupnoj
--zaradi u opadajućem redoslijedu. (AdventureWorks2017)

select p.Name,SUM(sod.OrderQty),SUM(sod.UnitPrice*sod.OrderQty)
from AdventureWorks2017.Sales.SalesOrderDetail as sod inner join AdventureWorks2017.Sales.SalesOrderHeader as soh
on sod.SalesOrderID=soh.SalesOrderID
inner join AdventureWorks2017.Production.Product as p on p.ProductID=sod.ProductID
inner join AdventureWorks2017.Production.ProductSubcategory
as ps on ps.ProductSubcategoryID=p.ProductSubcategoryID
inner join AdventureWorks2017.Production.ProductCategory as pc on
pc.ProductCategoryID=ps.ProductCategoryID
where pc.Name not like 'Bikes ' and p.Color in ('White','Black')
group by p.Name
having SUM(sod.OrderQty)<=20000
order by 3 desc


--c) (8 bodova) Kreirati upit koji prikazuje kupce koji su u maju mjesecu 2013 ili --2014 godine naručili
--proizvod „Front Brakes“ u količini većoj od 5. Upitom prikazati spojeno ime i --prezime kupca, email,
--naručenu količinu i datum narudžbe formatiran na način dan.mjesec.godina --(AdventureWorks2017)

select CONCAT(p.FirstName,' ',p.LastName)as 'ime i prezime',ea.EmailAddress,sod.OrderQty,FORMAT(soh.OrderDate,'dd.MM.yyyy')
from AdventureWorks2017.Sales.SalesOrderHeader as soh inner join AdventureWorks2017.Sales.SalesOrderDetail as sod on
soh.SalesOrderID=sod.SalesOrderID
inner join AdventureWorks2017.Sales.Customer as c on c.CustomerID=soh.CustomerID
inner join AdventureWorks2017.Person.Person as p on p.BusinessEntityID=c.PersonID
inner join AdventureWorks2017.Production.Product as pp on pp.ProductID=sod.ProductID
inner join AdventureWorks2017.Person.EmailAddress as ea on ea.BusinessEntityID=p.BusinessEntityID
where MONTH(soh.OrderDate)=5 and YEAR(soh.OrderDate)in(2013,2014) and pp.Name like 'Front Brakes' and sod.OrderQty>5


--d) (10 bodova) Kreirati upit koji će prikazati naziv kompanije dobavljača koja je --dobavila proizvode, koji
--se u najvećoj količini prodaju (najprodavaniji). Uslov je da proizvod pripada --kategoriji morske hrane i
--da je dostavljen/isporučen kupcu. Također uzeti u obzir samo one proizvode na -kojima- je popust odobren.
--U rezultatima upita prikazati naziv kompanije dobavljača i ukupnu prodanu količinu --proizvoda.
--(Northwind)

select s.CompanyName,SUM(od.Quantity)
from Northwind.dbo.Suppliers as s inner join Northwind.dbo.Products as p on p.SupplierID=s.SupplierID
inner join Northwind.dbo.[Order Details] as od on od.ProductID=p.ProductID
inner join Northwind.dbo.orders as o on o.OrderID=od.OrderID
INNER JOIN Northwind.dbo.Categories AS c ON c.CategoryID = p.CategoryID
where s.SupplierID in
(
   select top 1 s1.SupplierID
   from Northwind.dbo.Suppliers as s1 inner join Northwind.dbo.Products as p1 on p1.SupplierID=s1.SupplierID
inner join Northwind.dbo.[Order Details] as od1 on od1.ProductID=p1.ProductID
inner join Northwind.dbo.orders as o1 on o1.OrderID=od1.OrderID
inner join Northwind.dbo.Categories as ca1 on ca1.CategoryID=p1.CategoryID
where ca1.CategoryName like 'Seafood' and od1.Discount>0 and o1.ShippedDate is not null
group by s1.SupplierID
order by SUM(od1.Quantity) desc
)
group by s.CompanyName
order by 2 desc

--e) (11 bodova) Kreirati upit kojim će se prikazati narudžbe u kojima je na osnovu --popusta kupac uštedio
--2000KM i više. Upit treba da sadrži identifikacijski broj narudžbe, spojeno ime i --prezime kupca, te
--stvarnu ukupnu vrijednost narudžbe zaokruženu na 2 decimale. Rezultate sortirati po- -ukupnoj vrijednosti
--narudžbe u opadajućem redoslijedu.

select soh.SalesOrderID,CONCAT(p.FirstName,' ',p.LastName),round(SUM(sod.UnitPrice*sod.OrderQty*(1-sod.UnitPriceDiscount)),2)
from AdventureWorks2017.Sales.SalesOrderHeader as soh inner join AdventureWorks2017.Sales.SalesOrderDetail as sod on
soh.SalesOrderID=sod.SalesOrderID
inner join AdventureWorks2017.Sales.Customer as c on c.CustomerID=soh.CustomerID
inner join AdventureWorks2017.Person.Person as p on p.BusinessEntityID=c.PersonID
group by soh.SalesOrderID,CONCAT(p.FirstName,' ',p.LastName)
having SUM(sod.UnitPrice*sod.OrderQty)-SUM(sod.UnitPrice*sod.OrderQty*(1-sod.UnitPriceDiscount))>=2000
order by 3 desc

--5.
--a) (13 bodova) Kreirati upit koji će prikazati kojom kompanijom (ShipMethod(Name)) --je isporučen najveći
--broj narudžbi, a kojom najveća ukupna količina proizvoda. (AdventureWorks2017)

select*
from(
select top 1 sm.Name, COUNT(soh.SalesOrderID)'broj', 'broj narudzbi'as tip
from AdventureWorks2017.Sales.SalesOrderHeader as soh inner join AdventureWorks2017.Sales.SalesOrderDetail as sod on
soh.SalesOrderID=sod.SalesOrderID
inner join AdventureWorks2017.Purchasing.ShipMethod as sm on sm.ShipMethodID=soh.ShipMethodID
group by sm.Name	
order by 2 desc
)as sq1
union
select* 
from(

select top 1 sm.Name, SUM(sod.OrderQty)'broj','kolicina proizvoda'as tip
from AdventureWorks2017.Sales.SalesOrderHeader as soh inner join AdventureWorks2017.Sales.SalesOrderDetail as sod on
soh.SalesOrderID=sod.SalesOrderID
inner join AdventureWorks2017.Purchasing.ShipMethod as sm on sm.ShipMethodID=soh.ShipMethodID
group by sm.Name	
order by 2 desc
)as sq2


--b) (8 bodova) Modificirati prethodno kreirani upit na način ukoliko je jednom --kompanijom istovremeno
--isporučen najveći broj narudžbi i najveća ukupna količina proizvoda upitom -prikazati- poruku „Jedna
--kompanija“, u suprotnom „Više kompanija“ (AdventureWorks2017)

select
case when
(
select top 1 sm.Name
from AdventureWorks2017.Sales.SalesOrderHeader as soh inner join AdventureWorks2017.Sales.SalesOrderDetail as sod on
soh.SalesOrderID=sod.SalesOrderID
inner join AdventureWorks2017.Purchasing.ShipMethod as sm on sm.ShipMethodID=soh.ShipMethodID
group by sm.Name	
order by COUNT(soh.SalesOrderID) desc

)
=
(
select top 1 sm.Name
from AdventureWorks2017.Sales.SalesOrderHeader as soh inner join AdventureWorks2017.Sales.SalesOrderDetail as sod on
soh.SalesOrderID=sod.SalesOrderID
inner join AdventureWorks2017.Purchasing.ShipMethod as sm on sm.ShipMethodID=soh.ShipMethodID
group by sm.Name	
order by SUM(sod.OrderQty) desc

)
then 'jedna kompanija'
else 'vise kompanija'
end

--c) (4 boda) Kreirati indeks IX_Naslovi_Naslov kojim će se ubrzati pretraga prema --naslovu. OBAVEZNO
--kreirati testni slučaj. (NovokreiranaBaza)
create index IX_Naslovi_Naslov ON Naslovi(Naslov);

select*
from Naslovi
where Naslov like '%A%'

--25 bodova
--6. Dokument teorijski_ispit 22SEP23, preimenovati vašim brojem indeksa, te u tom --dokumentu izraditi pitanja.
--20 bodova
--SQL skriptu (bila prazna ili ne) imenovati Vašim brojem indeksa npr IB210001.sql, --teorijski dokument imenovan
--Vašim brojem indexa npr IB210001.docx upload-ovati ODVOJEDNO na ftp u folder -Upload.
--Maksimalan broj bodova:100
--Prag prolaznosti: 55