--1. Kroz SQL kod kreirati bazu podataka sa imenom vašeg broja indeksa.
go
create database IB230000

go
use IB230000


--2. U kreiranoj bazi podataka kreirati tabele sa sljedećom strukturom:
--a) Proizvodi
--• ProizvodID, cjelobrojna vrijednost i primarni ključ, autoinkrement
--• Naziv, 50 UNICODE karaktera (obavezan unos)
--• SifraProizvoda, 25 UNICODE karaktera (obavezan unos)
--• Boja, 15 UNICODE karaktera
--• NazivKategorije, 50 UNICODE (obavezan unos)
--• Tezina, decimalna vrijednost sa 2 znaka iza zareza

create table Proizvodi
(
  ProizvodID int constraint pk_proizvodi primary key identity(1,1), 
  Naziv nvarchar(50) not null, 
  SifraProizvoda nvarchar(50)not null,
  Boja nvarchar(15), 
  NazivKategorije nvarchar(50),
  Tezina decimal (18,2)

)


--b) ZaglavljeNarudzbe
--• NarudzbaID, cjelobrojna vrijednost i primarni ključ, autoinkrement
--• DatumNarudzbe, polje za unos datuma i vremena (obavezan unos)
--• DatumIsporuke, polje za unos datuma i vremena
--• ImeKupca, 50 UNICODE (obavezan unos)
--• PrezimeKupca, 50 UNICODE (obavezan unos)
--• NazivTeritorije, 50 UNICODE (obavezan unos)
--• NazivRegije, 50 UNICODE (obavezan unos)
--• NacinIsporuke, 50 UNICODE (obavezan unos)

create table ZaglavljeNarudzbe
(
    NarudzbaID int constraint pk_ZN primary key identity(1,1), 
	DatumNarudzbe datetime not null, 
	DatumIsporuke datetime, 
	ImeKupca nvarchar(50) not null, 
	PrezimeKupca nvarchar(50) not null, 
	NazivTeritorije nvarchar(50) not null,
	NazivRegije nvarchar(50) not null, 
	NacinIsporuke nvarchar(50) not null, 

)


--c) DetaljiNarudzbe
--• NarudzbaID, cjelobrojna vrijednost, obavezan unos i strani ključ
--• ProizvodID, cjelobrojna vrijednost, obavezan unos i strani ključ
--• Cijena, novčani tip (obavezan unos),
--• Kolicina, skraćeni cjelobrojni tip (obavezan unos),
--• Popust, novčani tip (obavezan unos)

create table DetaljiNarudzbe
(
   NarudzbaID int constraint fk_dn_narudzbe foreign key references ZaglavljeNarudzbe(NarudzbaID),
   ProizvodID int constraint fk_dn_proizvodi foreign key references Proizvodi(ProizvodID),
   Cijena money not null, 
   Kolicina smallint not null, 
   Popust money not null, 
   DetaljiNarudzbeID int constraint pk_dn primary key identity(1,1)
)

--**Jedan proizvod se može više puta naručiti, dok jedna narudžba može sadržavati više --proizvoda. U okviru jedne
--narudžbe jedan proizvod se može naručiti više puta.
--7 bodova
--3. Iz baze podataka AdventureWorks u svoju bazu podataka prebaciti sljedeće podatke:
--a) U tabelu Proizvodi dodati sve proizvode, na mjestima gdje nema pohranjenih podataka o- -težini
--zamijeniti vrijednost sa 0
--• ProductID -> ProizvodID
--• Name -> Naziv
--• ProductNumber -> SifraProizvoda
--• Color -> Boja
--• Name (ProductCategory) -> NazivKategorije
--• Weight -> Tezina

set identity_insert Proizvodi on
insert into Proizvodi(ProizvodID,Naziv,SifraProizvoda,Boja,NazivKategorije,Tezina)
select p.ProductID,p.Name,p.ProductNumber,p.Color,pc.Name,p.Weight
from AdventureWorks2017.Production.Product as p
inner join AdventureWorks2017.Production.ProductSubcategory as ps on ps.ProductSubcategoryID=p.ProductSubcategoryID
inner join AdventureWorks2017.Production.ProductCategory as pc on ps.ProductCategoryID=pc.ProductCategoryID
set identity_insert Proizvodi off

--b) U tabelu ZaglavljeNarudzbe dodati sve narudžbe
--• SalesOrderID -> NarudzbaID
--• OrderDate -> DatumNarudzbe
--• ShipDate -> DatumIsporuke
--• FirstName (Person) -> ImeKupca
--• LastName (Person) -> PrezimeKupca
--• Name (SalesTerritory) -> NazivTeritorije
--• Group (SalesTerritory) -> NazivRegije
--• Name (ShipMethod) -> NacinIsporuke

set identity_insert ZaglavljeNarudzbe on
insert into ZaglavljeNarudzbe(NarudzbaID,DatumNarudzbe,DatumIsporuke,ImeKupca,PrezimeKupca,NazivTeritorije,NazivRegije,NacinIsporuke)
selecT soh.SalesOrderID,soh.OrderDate,soh.ShipDate,p.FirstName,p.LastName,st.Name,st.[Group],sm.Name
from AdventureWorks2017.Sales.SalesOrderHeader as soh
inner join AdventureWorks2017.Sales.Customer as c on c.CustomerID=soh.CustomerID
inner join AdventureWorks2017.Person.Person as p on p.BusinessEntityID=c.PersonID
inner join AdventureWorks2017.Sales.SalesTerritory as st on st.TerritoryID=soh.TerritoryID
inner join AdventureWorks2017.Purchasing.ShipMethod as sm on sm.ShipMethodID=soh.ShipMethodID
set identity_insert ZaglavljeNarudzbe off

--c) U tabelu DetaljiNarudzbe dodati sve stavke narudžbe
--• SalesOrderID -> NarudzbaID
--• ProductID -> ProizvodID
--• UnitPrice -> Cijena
--• OrderQty -> Kolicina
--• UnitPriceDiscount -> Popust
--8 bodova

insert into DetaljiNarudzbe(NarudzbaID,ProizvodID,Cijena,Kolicina,Popust)
select sod.SalesOrderID,sod.ProductID,sod.UnitPrice,sod.OrderQty,sod.UnitPriceDiscount
from AdventureWorks2017.Sales.SalesOrderDetail as sod




--4.
--a) (6 bodova) Kreirati upit koji će prikazati ukupan broj uposlenika po odjelima. --Potrebno je prebrojati
--samo one uposlenike koji su trenutno aktivni, odnosno rade na datom odjelu. Također, -samo- uzeti u obzir
--one uposlenike koji imaju više od 10 godina radnog staža (ne uključujući graničnu --vrijednost). Rezultate
--sortirati preba broju uposlenika u opadajućem redoslijedu. (AdventureWorks2017)

select d.Name, COUNT(e.BusinessEntityID)
from AdventureWorks2017.HumanResources.Employee as e inner join AdventureWorks2017.HumanResources.EmployeeDepartmentHistory as edh on
e.BusinessEntityID=edh.BusinessEntityID
inner join AdventureWorks2017.HumanResources.Department as d on d.DepartmentID=edh.DepartmentID
where edh.EndDate is null and DATEDIFF(year,e.HireDate,GETDATE())>10
group by d.Name
order by 2 desc


--b) (10 bodova) Kreirati upit koji prikazuje po mjesecima ukupnu vrijednost poručene robe- -za skladište, te
--ukupnu količinu primljene robe, isključivo u 2012 godini. Uslov je da su troškovi -prevoza- bili između
--500 i 2500, a da je dostava izvršena CARGO transportom. Također u rezultatima upita je --potrebno
--prebrojati stavke narudžbe na kojima je odbijena količina veća od 100. --(AdventureWorks2017)

select MONTH(poh.OrderDate),SUM(pod.OrderQty*pod.UnitPrice),SUM(pod.ReceivedQty),
        sum(IIF(pod.RejectedQty>100,1,0))as'brojanje odbijenih'
from AdventureWorks2017.Purchasing.PurchaseOrderHeader as poh inner join AdventureWorks2017.Purchasing.PurchaseOrderDetail as pod  on
pod.PurchaseOrderID=poh.PurchaseOrderID
inner join AdventureWorks2017.Purchasing.ShipMethod as sm on sm.ShipMethodID=poh.ShipMethodID
where YEAR(poh.OrderDate)=2012 and poh.Freight between 500 and 2500 and sm.Name like '%CARGO%'
group by MONTH(poh.OrderDate)

--c) (10 bodova) Prikazati ukupan broj narudžbi koje su obradili uposlenici, za svakog --uposlenika
--pojedinačno. Uslov je da su narudžbe kreirane u 2011 ili 2012 godini, te da je u okviru --jedne narudžbe
--odobren popust na dvije ili više stavki. Također uzeti u obzir samo one narudžbe koje su- -isporučene u
--Veliku Britaniju, Kanadu ili Francusku. (AdventureWorks2017)

select sp.BusinessEntityID,COUNT(soh.SalesOrderID)
from AdventureWorks2017.Sales.SalesOrderHeader as soh inner join AdventureWorks2017.Sales.SalesOrderDetail as sod on
soh.SalesOrderID=sod.SalesOrderID
inner join AdventureWorks2017.Sales.SalesPerson as sp on sp.BusinessEntityID=soh.SalesPersonID
inner join AdventureWorks2017.Sales.SalesTerritory as st on st.TerritoryID=soh.TerritoryID
where YEAR(soh.OrderDate)in(2011,2012) and st.Name in ('United Kingdom','Canada','France') and 
(
    select COUNT(*)
	from AdventureWorks2017.Sales.SalesOrderDetail as sod1
    where sod1.UnitPriceDiscount>0 and sod.SalesOrderID=sod1.SalesOrderID
	group by sod1.SalesOrderID
)>=2
group by sp.BusinessEntityID



--d) (11 bodova) Napisati upit koji će prikazati sljedeće podatke o proizvodima: naziv --proizvoda, naziv
--kompanije dobavljača, količinu na skladištu, te kreiranu šifru proizvoda. Šifra se --sastoji od sljedećih
--vrijednosti: (Northwind)
--1) Prva dva slova naziva proizvoda
--2) Karakter /
--3) Prva dva slova druge riječi naziva kompanije dobavljača, uzeti u obzir one kompanije --koje u
--nazivu imaju 2 ili 3 riječi
--4) ID proizvoda, po pravilu ukoliko se radi o jednocifrenom broju na njega dodati slovo --'a', u
--suprotnom uzeti obrnutu vrijednost broja
--Npr. Za proizvod sa nazivom Chai i sa dobavljačem naziva Exotic Liquids, šifra će btiti --Ch/Li1a.
--37 bodova

select p.ProductName,s.CompanyName,p.UnitsInStock,
  LEFT(p.ProductName,2)+ '/'+SUBSTRING(s.CompanyName,CHARINDEX('',s.CompanyName)+1,2)+
  IIF(LEN(p.ProductID)=1,cast(p.ProductID as nvarchar)+'a',reverse(p.ProductID))
  from Northwind.dbo.Products as p inner join Northwind.dbo.Suppliers as s on s.SupplierID=p.SupplierID
  where LEN(s.CompanyName)-LEN(REPLACE(s.companyNAme,' ' ,''))in(1,2)

--5.
--a) (3 boda) U kreiranoj bazi kreirati index kojim će se ubrzati pretraga prema šifri i --nazivu proizvoda.
--Napisati upit za potpuno iskorištenje indexa.

create index ix_Sifra_Naziv on Proizvodi(Naziv,SifraProizvoda)

select*
from Proizvodi
where Naziv like '%a%' and SifraProizvoda like '%1%'

--b) (7 bodova) U kreiranoj bazi kreirati proceduru sp_search_products kojom će se vratiti- -podaci o
--proizvodima na osnovu kategorije kojoj pripadaju ili težini. Korisnici ne moraju unijeti- -niti jedan od
--parametara ali u tom slučaju procedura ne vraća niti jedan od zapisa. Korisnicima unosom- -već prvog
--slova kategorije se trebaju osvježiti zapisi, a vrijednost unesenog parametra težina će --vratiti one
--proizvode čija težina je veća od unesene vrijednosti.

go
create  procedure sp_search_products
(
   @NazivKategorije nvarchar(40)=null,
   @Tezina decimal (18,2) =null
)
as begin
select*
from Proizvodi as p
where 
(@NazivKategorije is not null and p.NazivKategorije like @NazivKategorije + '%')
or
(@Tezina is not null and p.Tezina > @Tezina)
end

EXEC sp_search_products 'Clo'
EXEC sp_search_products @Tezina=2.2


--c) (18 bodova) Zbog proglašenja dobitnika nagradne igre održane u prva dva mjeseca -drugog- kvartala 2013
--godine potrebno je kreirati upit. Upitom će se prikazati treća najveća narudžba --(vrijednost bez popusta)
--za svaki mjesec pojedinačno. Obzirom da je u pravilima nagradne igre potrebno nagraditi -2- osobe
--(muškarca i ženu) za svaki mjesec, potrebno je u rezultatima upita prikazati pored --navedenih stavki i o
--kojem se kupcu radi odnosno ime i prezime, te koju je nagradu osvojio. Nagrade se --dodjeljuju po
--sljedećem pravilu:
--• za žene u prvom mjesecu drugog kvartala je stoni mikser, dok je za muškarce usisivač
--• za žene u drugom mjesecu drugog kvartala je pegla, dok je za muškarc multicooker
--Obzirom da za kupce nije eksplicitno naveden spol, određivat će se po pravilu: Ako je --zadnje slovo imena
--a, smatra se da je osoba ženskog spola u suprotnom radi se o osobi muškog spola. --Rezultate u formiranoj
--tabeli dobitnika sortirati prema vrijednosti narudžbe u opadajućem redoslijedu. --(AdventureWorks2017)
--28 bodova

SELECT * FROM
(
SELECT * FROM
(SELECT TOP 1 *
FROM
(SELECT TOP 3 p.FirstName, p.LastName, SUM(soh.TotalDue) Vrijednost,
'stoni mikser' Nagrada
FROM AdventureWorks2017.Person.Person AS p
INNER JOIN AdventureWorks2017.Sales.Customer AS c
ON p.BusinessEntityID=c.PersonID
INNER JOIN AdventureWorks2017.Sales.SalesOrderHeader AS soh
ON c.CustomerID=soh.CustomerID
WHERE MONTH(soh.OrderDate)=4 AND YEAR(soh.OrderDate)=2013
AND RIGHT(p.FirstName, 1)='a'
GROUP BY p.FirstName, p.LastName
ORDER BY 3 DESC) as zeneApril
ORDER BY zeneApril.Vrijednost) AS sq1
UNION
SELECT * FROM
(SELECT TOP 1 *
FROM
(SELECT TOP 3 p.FirstName, p.LastName, SUM(soh.TotalDue) Vrijednost,
'usisivac' Nagrada
FROM AdventureWorks2017.Person.Person AS p
INNER JOIN AdventureWorks2017.Sales.Customer AS c
ON p.BusinessEntityID=c.PersonID
INNER JOIN AdventureWorks2017.Sales.SalesOrderHeader AS soh
ON c.CustomerID=soh.CustomerID
WHERE MONTH(soh.OrderDate)=4 AND YEAR(soh.OrderDate)=2013
AND RIGHT(p.FirstName, 1) NOT LIKE 'a'
GROUP BY p.FirstName, p.LastName
ORDER BY 3 DESC) as muskiApril
ORDER BY muskiApril.Vrijednost) AS sq2
UNION
SELECT * FROM
(SELECT TOP 1 *
FROM
(SELECT TOP 3 p.FirstName, p.LastName, SUM(soh.TotalDue) Vrijednost,
'pegla' Nagrada
FROM AdventureWorks2017.Person.Person AS p
INNER JOIN AdventureWorks2017.Sales.Customer AS c
ON p.BusinessEntityID=c.PersonID
INNER JOIN AdventureWorks2017.Sales.SalesOrderHeader AS soh
ON c.CustomerID=soh.CustomerID
WHERE MONTH(soh.OrderDate)=5 AND YEAR(soh.OrderDate)=2013
AND RIGHT(p.FirstName, 1)='a'
GROUP BY p.FirstName, p.LastName
ORDER BY 3 DESC) as zeneMaj
ORDER BY zeneMaj.Vrijednost) AS sq3
UNION
SELECT * FROM
(SELECT TOP 1 *
FROM
(SELECT TOP 3 p.FirstName, p.LastName, SUM(soh.TotalDue) Vrijednost,
'multicooker' Nagrada
FROM AdventureWorks2017.Person.Person AS p
INNER JOIN AdventureWorks2017.Sales.Customer AS c
ON p.BusinessEntityID=c.PersonID
INNER JOIN AdventureWorks2017.Sales.SalesOrderHeader AS soh
ON c.CustomerID=soh.CustomerID
WHERE MONTH(soh.OrderDate)=5 AND YEAR(soh.OrderDate)=2013
AND RIGHT(p.FirstName, 1) NOT LIKE 'a'
GROUP BY p.FirstName, p.LastName
ORDER BY 3 DESC) as muskiMaj
ORDER BY muskiMaj.Vrijednost) AS sq4
)
AS finalq
ORDER BY finalq.Vrijednost DESC




--6. Dokument teorijski_ispit 29JUN22, preimenovati vašim brojem indeksa, te u tom --dokumentu izraditi
--pitanja.
--20 bodova
--SQL skriptu (bila prazna ili ne) imenovati Vašim brojem indeksa npr IB200001.sql, --teorijski dokument imenovan
--Vašim brojem indexa npr IB200001.docx upload-ovati ODVOJEDNO na ftp u folder Upload.
--Maksimalan broj bodova:100
--Prag prolaznosti: 55