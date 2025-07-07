--1.Kreirati bazu podataka sa imenom vaseg broja indeksa
CREATE DATABASE IB230000

GO
USE IB230000

--2.U kreiranoj bazi tabelu sa strukturom : 
--a) Uposlenici 
-- UposlenikID cjelobrojni tip i primarni kljuc autoinkrement,
-- Ime 10 UNICODE karaktera (obavezan unos)
-- Prezime 20 UNICODE karaktera (obaveznan unos),
-- DatumRodjenja polje za unos datuma i vremena (obavezan unos)
-- UkupanBrojTeritorija cjelobrojni tip

create table Uposlenici
(
  UposlenikID int constraint PK_Uposlenici primary key identity(1,1),
  Ime nvarchar(10) not null,
  Prezime nvarchar(20) not null,
  DatumRodjenja datetime not null,
  UkupanBrojTeritorija int
)

--b) Narudzbe
-- NarudzbaID cjelobrojni tip i primarni kljuc autoinkrement,
-- UposlenikID cjelobrojni tip i strani kljuc,
-- DatumNarudzbe polje za unos datuma i vremena,
-- ImeKompanijeKupca 40 UNICODE karaktera,
-- AdresaKupca 60 UNICODE karaktera,
-- UkupanBrojStavkiNarudzbe cjelobrojni tip

create table Narudzbe
(
 NarudzbaID int constraint PK_Narudzbe primary key identity(1,1),
 UposlenikID int constraint FK_Uposlenik_narudzbe foreign key references Uposlenici(UposlenikID),
 DatumNaruzdbe datetime,
 ImeKompanijeKupca nvarchar(40),
 AdresaKupca nvarchar(40),
 UkupanBrojStavkiNaruzdbe int
)


--c) Proizvodi
-- ProizvodID cjelobrojni tip i primarni kljuc autoinkrement,
-- NazivProizvoda 40 UNICODE karaktera (obaveznan unos),
-- NazivKompanijeDobavljaca 40 UNICODE karaktera,
-- NazivKategorije 15 UNICODE karaktera

create table Proizvodi
(

 ProizvodID int constraint PK_Proizvodi primary key identity(1,1),
 NazivProizvoda nvarchar(40) not null,
 NazivKompanijeDobavljaca nvarchar(40),
 NazivKategorije nvarchar(15)
)


--d) StavkeNarudzbe
-- NarudzbaID cjelobrojni tip strani i primarni kljuc,
-- ProizvodID cjelobrojni tip strani i primarni kljuc,
-- Cijena novcani tip (obavezan unos),
-- Kolicina kratki cjelobrojni tip (obavezan unos),
-- Popust real tip podataka (obavezno)

--(4 boda)

create table StavkeNarudzbe(
   NarudzbaID int constraint FK_Narudzba_SN foreign key references Narudzbe(NarudzbaID),
   ProizvodID int constraint FK_Proizvodi_SN foreign key references Proizvodi(ProizvodID),
   Cijena money not null,
   Kolicina smallint not null,
   Popust real not null,
   constraint PK_SN primary key (NarudzbaID,ProizvodID)
)


--3.Iz baze Northwind u svoju prebaciti sljedece podatke :
--a) U tabelu uposlenici sve uposlenike , Izracunata vrijednost za svakog uposlenika
-- na osnovnu EmployeeTerritories -> UkupanBrojTeritorija
set identity_insert Uposlenici on
insert into Uposlenici(UposlenikID,Ime,Prezime,DatumRodjenja,UkupanBrojTeritorija)
select e.EmployeeID,e.FirstName,e.LastName,e.BirthDate,COUNT(et.TerritoryID)
from Northwind.dbo.Employees as e inner join Northwind.dbo.EmployeeTerritories as et on
et.EmployeeID=e.EmployeeID
group by e.EmployeeID,e.FirstName,e.LastName,e.BirthDate
set identity_insert Uposlenici off
--b) U tabelu narudzbe sve narudzbe, Izracunata vrijensot za svaku narudzbu pojedinacno 
-- ->UkupanBrojStavkiNarudzbe

set identity_insert Narudzbe on
insert into Narudzbe(NarudzbaID,UposlenikID,DatumNaruzdbe,ImeKompanijeKupca,AdresaKupca,UkupanBrojStavkiNaruzdbe)
select o.OrderID,o.EmployeeID,o.OrderDate,c.CompanyName,c.Address,SUM(od.Quantity)
from Northwind.dbo.Orders as o inner join Northwind.dbo.Customers as c on c.CustomerID=o.CustomerID inner join
 Northwind.dbo.[Order Details] as od on od.OrderID=o.OrderID
 group by o.OrderID,o.EmployeeID,o.OrderDate,c.CompanyName,c.Address
 set identity_insert Narudzbe off


--c) U tabelu proizvodi sve proizvode

set identity_insert Proizvodi on
insert into Proizvodi(ProizvodID,NazivProizvoda,NazivKompanijeDobavljaca,NazivKategorije)
select p.ProductID,p.ProductName,s.CompanyName,c.CategoryName
from Northwind.dbo.Products as p inner join Northwind.dbo.Suppliers as s on s.SupplierID=p.SupplierID
                                 inner join Northwind.dbo.Categories as c on c.CategoryID=p.CategoryID
set identity_insert Proizvodi off


--d) U tabelu StavkeNrudzbe sve narudzbe

--(5 bodova)
insert into StavkeNarudzbe(NarudzbaID,ProizvodID,Cijena,Kolicina,Popust)
select od.OrderID,od.ProductID,od.UnitPrice,od.Quantity,od.Discount
from Northwind.dbo.[Order Details] as od


--4. 
--a) (4 boda) Kreirati indeks kojim ce se ubrzati pretraga po nazivu proizvoda, OBEVAZENO kreirati testni slucaj (Nova baza)

create index ix_Naziv on Proizvodi(NazivProizvoda)

SELECT * FROM Proizvodi WHERE NazivProizvoda LIKE '%A%';
--b) (4 boda) Kreirati proceduru sp_update_proizvodi kojom ce se izmjeniti podaci o prpoizvodima u tabeli. Korisnici mogu poslati jedan ili vise parametara te voditi raucna da ne dodje do gubitka podataka.(Nova baza)

go
create or alter procedure sp_update_proizvodi
(
   @ProizvodID int ,
   @NazivProizvoda nvarchar(40) ,
   @NazivKompanijeDobavljaca nvarchar(40)=null,
   @NazivKategorije nvarchar(15)=null

)
as begin
update Proizvodi
set
NazivProizvoda=IIF(@NazivProizvoda is null, NazivProizvoda,@NazivProizvoda),
NazivKompanijeDobavljaca=IIF(@NazivKompanijeDobavljaca IS null,NazivKompanijeDobavljaca,@NazivKompanijeDobavljaca),
NazivKategorije=IIF(@NazivKategorije is null,NazivKategorije,@NazivKategorije)
WHERE ProizvodID = @ProizvodID
end


--c) (5 bodova) Kreirati funckiju f_4c koja ce vratiti podatke u tabelarnom obliku na osnovnu prosljedjenog parametra idNarudzbe cjelobrojni tip. Funckija ce vratiti one narudzbe ciji id odgovara poslanom parametru. Potrebno je da se prilikom kreiranja funkcije u rezultatu nalazi id narudzbe, ukupna vrijednost bez popusta. OBAVEZNO testni slucaj (Nova baza)

go
create function f_4c 
(
@NarudzbaID int
)
returns table
as return
select n.NarudzbaID,SUM(sn.Cijena*sn.kolicina)'zarada'
from narudzbe as n inner join StavkeNarudzbe as sn on n.NarudzbaID=sn.NarudzbaID
where n.NarudzbaID=@NarudzbaID
group by n.NarudzbaID

select * from f_4c(10250)

--d) (6 bodova) Pronaci najmanju narudzbu placenu karticom i isporuceno na porducje Europe, uz id narudzbe prikazati i spojeno ime i prezime kupca te grad u koji je isporucena narudzba (AdventureWorks)

select top 1 CONCAT(p.FirstName,' ',p.LastName) as 'ime i prezime',soh.SalesOrderID,ad.City
from AdventureWorks2017.Sales.SalesOrderHeader as soh inner join AdventureWorks2017.Sales.Customer
as c on c.CustomerID=soh.CustomerID
inner join AdventureWorks2017.Person.Person as p on p.BusinessEntityID=c.PersonID
inner join AdventureWorks2017.Person.Address as ad on ad.AddressID=soh.ShipToAddressID
inner join AdventureWorks2017.Sales.SalesTerritory as st on st.TerritoryID=soh.TerritoryID
where soh.CreditCardID is not null and st.[Group] like 'Europe'
order by soh.TotalDue asc

--e) (6 bodova) Prikazati ukupan broj porizvoda prema specijalnim ponudama.Potrebno je prebrojati samo one proizvode koji pripadaju kategoriji odjece ili imaju zabiljezen model (AdventureWorks)

select sop.SpecialOfferID,COUNT(p.ProductID)
from AdventureWorks2017.Production.Product p inner join AdventureWorks2017.Production.ProductSubcategory
as ps on ps.ProductSubcategoryID=p.ProductSubcategoryID
inner join AdventureWorks2017.Production.ProductCategory as pc on
pc.ProductCategoryID=ps.ProductCategoryID
inner join AdventureWorks2017.Sales.SpecialOfferProduct as sop on sop.ProductID=p.ProductID
where pc.Name like 'clothing' and p.ProductModelID is not null
group by sop.SpecialOfferID
 

--f) (9 bodova) Prikazatu 5 kupaca koji su napravili najveci broj narudzbi u zadnjih 30% narudzbi iz 2011 ili 2012 god. (AdventureWorks)

select top 5 c.CustomerID,COUNT(soh.SalesOrderID)
from AdventureWorks2017.Sales.SalesOrderHeader as soh inner join AdventureWorks2017.Sales.Customer as c on
soh.CustomerID=c.CustomerID
where soh.SalesOrderID in
(
    select top 30 PERCENT sohh.SalesOrderID
	from AdventureWorks2017.Sales.SalesOrderHeader as sohh
	where year(sohh.OrderDate)in(2011,2012)
	
)
group by c.CustomerID
order by 2 desc

--g) (10 bodova) Menadzmentu kompanije potrebne su informacije o najmanje prodavanim porizvodima. ...kako bi ih eliminisali iz ponude. Obavezno prikazati naziv o kojem se proizvodu radi i kvartal i godinu i adekvatnu poruku. (AdventureWorks)
select sq1.Name,sq1.kvartal,sq1.godina,sq1.[ukupno prodanih]
from(
select p.Name,YEAR(soh.OrderDate)as 'godina',DATEPART(QUARTER,soh.OrderDate)as'kvartal',SUM(sod.OrderQty)as 'ukupno prodanih'
from AdventureWorks2017.Sales.SalesOrderDetail as sod inner join AdventureWorks2017.Sales.SalesOrderHeader as soh on
sod.SalesOrderID=soh.SalesOrderID
inner join AdventureWorks2017.Production.Product as p on p.ProductID=sod.ProductID
group by p.name,YEAR(soh.OrderDate),DATEPART(QUARTER,soh.OrderDate)
) as sq1
where sq1.[ukupno prodanih]=
(
select MIN(suma.[minimalno prodanih])
from(
  select sum(sod1.OrderQty)'minimalno prodanih'
  from AdventureWorks2017.Sales.SalesOrderDetail as sod1 inner join AdventureWorks2017.Sales.SalesOrderHeader as soh1 on
sod1.SalesOrderID=soh1.SalesOrderID
inner join AdventureWorks2017.Production.Product as p1 on p1.ProductID=sod1.ProductID
where YEAR(soh1.OrderDate)=sq1.godina and DATEPART(QUARTER,soh1.OrderDate)=sq1.kvartal
group by sod1.ProductID
)as suma
)
order by sq1.godina,sq1.kvartal



--5.
--a) (11 bodova) Prikazati kupce koji su kreirali narudzbe u minimalno 5 razlicitih mjeseci u 2012 godini.

select c.CustomerID
from AdventureWorks2017.Sales.SalesOrderHeader as soh inner join AdventureWorks2017.Sales.Customer as c on 
c.CustomerID=soh.CustomerID
where YEAR(soh.OrderDate)=2012
group by c.CustomerID
having COUNT(distinct(month(soh.OrderDate)))>=5


--b) (16 bodova) Prikazati 5 narudzbi sa najvise narucenih razlicitih proizvoda i 5 narudzbi sa najvise porizvoda koji pripadaju razlicitim potkategorijama. Upitom prikazati ime i prezime kupca, id narudzbe te ukupnu vrijednost narudzbe sa popoustom zaokruzenu na 2 decimale (AdventureWorks)
select*
from(
select top 5 p.FirstName,p.LastName, soh.SalesOrderID,round(SUM(sod.UnitPrice*sod.OrderQty*(1-sod.UnitPriceDiscount)),2)'zarada'
from AdventureWorks2017.Sales.SalesOrderDetail as sod inner join AdventureWorks2017.Sales.SalesOrderHeader as soh
on sod.SalesOrderID=soh.SalesOrderID
inner join AdventureWorks2017.Sales.Customer as c on c.CustomerID=soh.CustomerID
inner join AdventureWorks2017.Person.Person as p on p.BusinessEntityID=c.PersonID
group by p.FirstName,p.LastName,soh.SalesOrderID
order by COUNT(distinct sod.ProductID) desc
) as sq1
union 
select*
from(
select top 5 pp.FirstName,pp.LastName, soh.SalesOrderID,round(SUM(sod.UnitPrice*sod.OrderQty*(1-sod.UnitPriceDiscount)),2)'zarada'
from AdventureWorks2017.Sales.SalesOrderDetail as sod inner join AdventureWorks2017.Sales.SalesOrderHeader as soh
on sod.SalesOrderID=soh.SalesOrderID
inner join AdventureWorks2017.Production.Product as p on p.ProductID=sod.ProductID
inner join AdventureWorks2017.Sales.Customer as c on c.CustomerID=soh.CustomerID
inner join AdventureWorks2017.Person.Person as pp on pp.BusinessEntityID=c.PersonID
group by pp.FirstName,pp.LastName, soh.SalesOrderID
order by COUNT(distinct p.ProductSubcategoryID) desc

)as sq2