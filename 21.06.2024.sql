--1. Kroz SQL kod kreirati bazu podataka sa imenom vaseg broja indeksa

--2. U kreiranoj bazi podataka kreirati tabele sa sljedecom strukturom:
--a)	Uposlenici
--•	UposlenikID, cjelobrojni tip i primarni kljuc, autoinkrement,
--•	Ime 10 UNICODE karaktera obavezan unos,
--•	Prezime 20 UNICODE karaktera obavezan unos
--•	DatumRodjenja polje za unos datuma i vremena obavezan unos
--•	UkupanBrojTeritorija, cjelobrojni tip

create table Uposlenici
(
  UposlenikID int constraint pk_uspolenici primary key identity(1,1),
  Ime nvarchar(10) not null,
  Prezime nvarchar(20) not null,
  DatumRodjenja datetime not null,
  UkupanBrojTeritorija int
)

--b)	Narudzbe
--•	NarudzbaID, cjelobrojni tip i primarni kljuc, autoinkrement
--•	UposlenikID, cjelobrojni tip, strani kljuc,
--•	DatumNarudzbe, polje za unos datuma i vremena,
--•	ImeKompanijeKupca, 40 UNICODE karaktera,
--•	AdresaKupca, 60 UNICODE karaktera

create table Narudzbe
(
   NarudzbaID int constraint pk_narudzbe primary key identity(1,1), 
   UposlenikID int constraint fk_narudzbe_uspolenici foreign key references Uposlenici(UposlenikID), 
   DatumNarudzbe datetime,
   ImeKompanijeKupca nvarchar(40),
   AdresaKupca nvarchar(60)


)

--c) Proizvodi
--•	ProizvodID, cjelobrojni tip i primarni ključ, autoinkrement
--•	NazivProizvoda, 40 UNICODE karaktera (obavezan unos)
--•	NazivKompanijeDobavljaca, 40 UNICODE karaktera
--•	NazivKategorije, 15 UNICODE karaktera

create table Proizvodi
(
   ProizvodID int constraint pk_proizvodi primary key identity(1,1),
   NazivProizvoda nvarchar(40) not null,
   NazivKompanijeDobavljaca nvarchar(40),
   NazivKategorije nvarchar(15)
)

--d) StavkeNarudzbe
--•	NarudzbalD, cjelobrojni tip strani i primami ključ
--•	ProizvodlD, cjelobrojni tip strani i primami ključ
--•	Cijena, novčani tip (obavezan unos)
--•	Kolicina, kratki cjelobrojni tip (obavezan unos)
--•	Popust, real tip podatka (obavezan unos)

create table StavkeNarudzbe 
(
  NarudzbaID int constraint fk_narudzbe_sn foreign key references Narudzbe(NarudzbaID),
  ProizvodID int constraint fk_proizvodi_sn foreign key references Proizvodi(ProizvodID),
  Cijena money not null,
  Kolicina smallint not null,
  Popust real not null
  constraint pk_sn primary key(NarudzbaID,ProizvodID)
)


--4 boda

--3. Iz baze podataka Northwind u svoju bazu podataka prebaciti sljedeće podatke:
--a) U tabelu Uposlenici dodati sve uposlenike
--•	EmployeelD -> UposlenikID
--•	FirstName -> Ime
--•	LastName -> Prezime
--•	BirthDate -> DatumRodjenja
--•	lzračunata vrijednost za svakog uposlenika na osnovu EmployeeTerritories-:----UkupanBrojTeritorija
set identity_insert Uposlenici on
insert into Uposlenici(UposlenikID,Ime,	Prezime,DatumRodjenja,UkupanBrojTeritorija)
select e.EmployeeID,e.FirstName,e.LastName,e.BirthDate,COUNT(et.TerritoryID)
from Northwind.dbo.Employees as e inner join Northwind.dbo.EmployeeTerritories as et on 
et.EmployeeID=e.EmployeeID
group by e.EmployeeID,e.FirstName,e.LastName,e.BirthDate
set identity_insert Uposlenici off


--b) U tabelu Narudzbe dodati sve narudzbe
--•	OrderlD -> NarudzbalD
--•	EmployeelD -> UposlenikID
--•	OrderDate -> DatumNarudzbe
--•	CompanyName -> ImeKompanijeKupca
--•	Address -> AdresaKupca

set identity_insert Narudzbe on
insert into Narudzbe(NarudzbaID,UposlenikID,DatumNarudzbe,ImeKompanijeKupca,AdresaKupca)
select o.OrderID,o.EmployeeID,o.OrderDate,c.CompanyName,c.Address
from Northwind.dbo.Orders as o inner join Northwind.dbo.Customers as c on c.CustomerID=o.CustomerID
set identity_insert Narudzbe off
--c) U tabelu Proizvodi dodati sve proizvode
--•	ProductID -> ProizvodlD
--•	ProductName -> NazivProizvoda
--•	CompanyName -> NazivKompanijeDobavljaca
--•	CategoryName -> NazivKategorije

set identity_insert Proizvodi on
insert into Proizvodi(ProizvodID,NazivProizvoda,NazivKompanijeDobavljaca,NazivKategorije)
select p.ProductID,p.ProductName,s.CompanyName,c.CategoryName
from Northwind.dbo.Products as p inner join Northwind.dbo.Suppliers as s on p.SupplierID=s.SupplierID
inner join Northwind.dbo.Categories as c on p.CategoryID=c.CategoryID
set identity_insert Proizvodi off
--d) U tabelu StavkeNarudzbe dodati sve stavke narudzbe
--•	OrderlD -> NarudzbalD
--•	ProductID -> ProizvodlD
--•	UnitPrice -> Cijena
--•	Quantity -> Kolicina
--•	Discount -> Popust


insert into StavkeNarudzbe(NarudzbaID,ProizvodID,Cijena,Kolicina,Popust)
selecT od.OrderID,od.ProductID,od.UnitPrice,od.Quantity,od.Discount
from Northwind.dbo.[Order Details] as od

--5 bodova

--4. 
--a) (4 boda) U tabelu StavkeNarudzbe dodati 2 nove izračunate kolone: vrijednostNarudzbeSaPopustom i vrijednostNarudzbeBezPopusta. Izzačunate kolonc već čuvaju podatke na osnovu podataka iz kolona! 

alter table StavkeNarudzbe
add vrijednostNarudzbeSaPopustom as Cijena*Kolicina*(1-Popust)

alter table StavkeNarudzbe
add vrijednostNarudzbeBezPopusta as Cijena*Kolicina

--b) (5 bodom) Kreirati pogled v_select_orders kojim ćc se prikazati ukupna zarada po uposlenicima od narudzbi kreiranih u zadnjem kvartalu 1996. godine. Pogledom je potrebno prikazati spojeno ime i prezime uposlenika, ukupna zarada sa popustom zaokrzena na dvije decimale i ukupna zarada bez popusta. Za prikaz ukupnih zarada koristiti OBAVEZNO koristiti izračunate kolone iz zadatka 4a. (Novokreirana baza)

go
create view v_select_orders 
as
select u.Ime,U.Prezime,round(SUM(vrijednostNarudzbeSaPopustom),2)as'sa popustom',SUM(vrijednostNarudzbeBezPopusta)as 'bez popusta'
from Uposlenici as u inner join Narudzbe as n on n.UposlenikID=u.UposlenikID
inner join StavkeNarudzbe as sn on sn.NarudzbaID=n.NarudzbaID
where YEAR(n.DatumNarudzbe)=1996 and MONTH(n.DatumNarudzbe) in(10,11,12)
group by u.Ime,	u.Prezime

--c) (5 boda) Kreirati funkciju f_starijiUposleici koja će vraćati podatke u formi tabele na osnovu proslijedjenog parametra godineStarosti, cjelobrojni tip. Funkcija će vraćati one zapise u kojima su godine starosti kod uposlenika veće od unesene vrijednosti parametra. Potrebno je da se prilikom kreiranja funkcije u rezultatu nalaze sve kolone tabele uposlenici, zajedno sa izračunatim godinama starosti. Provjeriti ispravnost funkcije unošenjem kontrolnih vrijednosti. (Novokreirana baza) 

go
create  function f_starijiUposlenici
(
 @GodineSTarosti int
)
returns table
as return
select DATEDIFF(YEAR,u.DatumRodjenja,GETDATE())as'godine starosti',*
from Uposlenici as u 
where DATEDIFF(YEAR,u.DatumRodjenja,GETDATE())>@GodineSTarosti




--d) (7 bodova) Pronaći najprodavaniji proizvod u 2011 godini. Ulogu najprodavanijeg nosi onaj kojeg je najveći broj komada prodat. (AdventureWorks2017)

select top 1 p.Name,SUM(sod.OrderQty)
from AdventureWorks2017.Sales.SalesOrderHeader as soh inner join AdventureWorks2017.Sales.SalesOrderDetail as sod on
soh.SalesOrderID=sod.SalesOrderID
inner join AdventureWorks2017.Production.Product as p on p.ProductID=sod.ProductID
where YEAR(soh.OrderDate)=2011
group by p.Name
order by 2 desc


--e) (6 bodova) Prikazati ukupan broj proizvoda prema specijalnim ponudama. Potrebno je prebrojati samo one proizvode koji pripadaju kategoriji odjeće. (AdventureWorks2017) 

select sop.SpecialOfferID,COUNT(p.ProductID)
from AdventureWorks2017.Production.Product as p inner join  AdventureWorks2017.Production.ProductSubcategory as ps 
on ps.ProductSubcategoryID=p.ProductSubcategoryID
inner join AdventureWorks2017.Production.ProductCategory as pc on pc.ProductCategoryID=ps.ProductcategoryID
inner join AdventureWorks2017.Sales.SpecialOfferProduct as sop on sop.ProductID=p.ProductID
where pc.Name like 'clothing'
group by sop.SpecialOfferID

--f) (8 bodova) Prikazati najskuplji proizvod (List Price) u svakoj kategoriji. (AdventureWorks2017) 

select pc.name,p.Name,p.ListPrice
from AdventureWorks2017.Production.Product as p inner join  AdventureWorks2017.Production.ProductSubcategory as ps 
on ps.ProductSubcategoryID=p.ProductSubcategoryID
inner join AdventureWorks2017.Production.ProductCategory as pc on pc.ProductCategoryID=ps.ProductcategoryID
where p.ListPrice=
(
    select max(p1.ListPrice)
   from AdventureWorks2017.Production.Product as p1 inner join  AdventureWorks2017.Production.ProductSubcategory as ps1 
on ps1.ProductSubcategoryID=p1.ProductSubcategoryID
inner join AdventureWorks2017.Production.ProductCategory as pc1 on pc1.ProductCategoryID=ps1.ProductcategoryID
  where pc1.ProductCategoryID=pc.ProductCategoryID
)



--g) (8 bodova) Prikazati proizvode čija je maloprodajna cijena (List Price) manja od prosječne maloprodajne cijene kategorije proizvoda kojoj pripada. (AdventureWorks2017) 

select p.Name,p.ListPrice
from AdventureWorks2017.Production.Product as p inner join  AdventureWorks2017.Production.ProductSubcategory as ps 
on ps.ProductSubcategoryID=p.ProductSubcategoryID
inner join AdventureWorks2017.Production.ProductCategory as pc on pc.ProductCategoryID=ps.ProductcategoryID
where p.ListPrice <
(
   select AVG(p1.ListPrice)
   from AdventureWorks2017.Production.Product as p1 inner join  AdventureWorks2017.Production.ProductSubcategory as ps1 
on ps1.ProductSubcategoryID=p1.ProductSubcategoryID
inner join AdventureWorks2017.Production.ProductCategory as pc1 on pc1.ProductCategoryID=ps1.ProductcategoryID
  where pc1.ProductCategoryID=pc.ProductCategoryID
)
order by 2 desc

--43 boda

--5. 
--a) (12 bodova) Pronaći najprodavanije proizvode, koji nisu na lisli top 10 najprodavanijih proizvoda u zadnjih 11 godina. (AdventureWorks2017) 

select top 10 p.Name,SUM(sod.OrderQty)
from AdventureWorks2017.Production.Product as p inner join AdventureWorks2017.Sales.SalesOrderDetail as sod on
sod.ProductID=p.ProductID
inner join AdventureWorks2017.Sales.SalesOrderHeader as soh on soh.SalesOrderID=sod.SalesOrderID
where DATEDIFF(YEAR,soh.OrderDate,GETDATE())<=11 and  p.ProductID not in
(
   select top 10 p1.ProductID
   from AdventureWorks2017.Production.Product as p1 inner join AdventureWorks2017.Sales.SalesOrderDetail as sod1 on
sod1.ProductID=p1.ProductID
inner join AdventureWorks2017.Sales.SalesOrderHeader as soh1 on soh1.SalesOrderID=sod1.SalesOrderID
   where DATEDIFF(YEAR,soh1.OrderDate,GETDATE())<=11
   group by p1.ProductID
   order by SUM(sod1.OrderQty) desc
)
group by p.Name
order by 2 desc
--b) (16 bodova) Prikazati ime i prezime kupca, id narudzbe, te ukupnu vrijednost narudzbe sa popustom (zaokruzenu na dvije decimale), uz uslov da su na nivou pojedine narudžbe naručeni proizvodi iz svih kategorija. (AdventureWorks2017) 


select pp.FirstName,pp.LastName,soh.SalesOrderID,round(SUM(sod.UnitPrice*sod.OrderQty*(1-sod.UnitPriceDiscount)),2)
from AdventureWorks2017.Production.Product as p inner join AdventureWorks2017.Production.ProductSubcategory as ps 
on ps.ProductSubcategoryID=p.ProductSubcategoryID
inner join AdventureWorks2017.Production.ProductCategory as pc on pc.ProductCategoryID=ps.ProductcategoryID
inner join AdventureWorks2017.Sales.SalesOrderDetail as sod on sod.ProductID= p.ProductID
inner join AdventureWorks2017.Sales.SalesOrderHeader as soh on soh.SalesOrderID=sod.SalesOrderID
inner join AdventureWorks2017.Sales.Customer as c on c.CustomerID=soh.CustomerID
inner join AdventureWorks2017.Person.Person as pp on pp.BusinessEntityID=c.PersonID
group by pp.FirstName,pp.LastName,soh.SalesOrderID
having COUNT(distinct pc.ProductCategoryID)=
(
 select COUNT(*)
 from AdventureWorks2017.Production.ProductCategory as pc1
)

--28 bodova 

--6. Dokument teorijski_ispit 21 JUN24, preimcnovati vašim brojem indeksa, te u tom dokumentu izraditi pitanja. 

--20 bodova 
