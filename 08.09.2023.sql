--1. Kroz SQL kod kreirati bazu podataka sa imenom vašeg broja indeksa. 

create database IB230000

go
use database IB230000

--2. U kreiranoj bazi podataka kreirati tabele sa sljedećom strukturom: 
--a) Prodavaci
--• ProdavacID, cjelobrojna vrijednost i primarni ključ, autoinkrement
--• Ime, 50 UNICODE karaktera (obavezan unos)
--• Prezime, 50 UNICODE karaktera (obavezan unos)
--• OpisPosla, 50 UNICODE karaktera (obavezan unos)
--• EmailAdresa, 50 UNICODE 
create table Prodavaci
(
  ProdavacID int constraint PK_Prodavaci primary key identity(1,1),
  Ime nvarchar(50) not null,
  Prezime nvarchar(50) not null,
  OpisPosla nvarchar(50) not null,
  EmailAdresa nvarchar(50)

)
--b) Proizvodi
--• ProizvodID, cjelobrojna vrijednost i primarni ključ, autoinkrement
--• Naziv, 50 UNICODE karaktera (obavezan unos)
--• SifraProizvoda, 25 UNICODE karaktera (obavezan unos)
--• Boja, 15 UNICODE karaktera
--• NazivKategorije, 50 UNICODE (obavezan unos)

create table Proizvodi
(
   ProizvodID int constraint PK_Proizvodi  primary key identity(1,1),
   Naziv nvarchar(50) not null,
   SifraProizvoda nvarchar(50) not null,
   Boja nvarchar(15),
   NazivKategorije nvarchar(50) not null

)



--c) ZaglavljeNarudzbe
--• NarudzbaID, cjelobrojna vrijednost i primarni ključ, autoinkrement
--• DatumNarudzbe, polje za unos datuma i vremena (obavezan unos)
--• DatumIsporuke, polje za unos datuma i vremena
--• KreditnaKarticaID, cjelobrojna vrijednost
--• ImeKupca, 50 UNICODE (obavezan unos)
--• PrezimeKupca, 50 UNICODE (obavezan unos)
--• NazivGrada, 30 UNICODE (obavezan unos)
--• ProdavacID, cjelobrojna vrijednost i strani ključ
--• NacinIsporuke, 50 UNICODE (obavezan unos)

create table ZagljavljeNarudzbe
(
   NaruzdbaID int constraint PK_ZN primary key identity(1,1),
   DatumNarudzbe datetime not null,
   DatumIsporuke datetime not null,
   KreditnaKarticaID int,
   ImeKupca nvarchar(50) not null,
   PrezimeKupca nvarchar(50) not null,
   NazivGrada nvarchar(30) not null,
   ProdavacID int constraint FK_ZN foreign key references Prodavaci(ProdavacID),
   NacinIsporuke nvarchar(50) not null
)


--c) DetaljiNarudzbe
--• NarudzbaID, cjelobrojna vrijednost, obavezan unos i strani ključ
--• ProizvodID, cjelobrojna vrijednost, obavezan unos i strani ključ
--• Cijena, novčani tip (obavezan unos),
--• Kolicina, skraćeni cjelobrojni tip (obavezan unos),
--• Popust, novčani tip (obavezan unos)
--• OpisSpecijalnePonude, 255 UNICODE (obavezan unos)


create table DetaljiNarudzbe
(
   NarudzbaID int constraint FK_DN foreign key references ZagljavljeNarudzbe(NaruzdbaID),
   ProizvodID int constraint FK_DN_PR foreign key references Proizvodi(ProizvodID),
   Cijena money not null,
   Kolicina smallint not null,
   Popust money not null,
   OpisSpecijalnePonude nvarchar(255),
   DetaljiNarudzbeID int constraint PK_DN primary key identity(1,1)

)


--**Jedan proizvod se može više puta naručiti, dok jedna narudžba može sadržavati više proizvoda. 
--U okviru jedne narudžbe jedan proizvod se može naručiti više puta.
--7 bodova


--3a. Iz baze podataka AdventureWorks u svoju bazu podataka prebaciti sljedeće podatke:
--a) U tabelu Prodavaci dodati :
--• BusinessEntityID (SalesPerson) -> ProdavacID
--• FirstName -> Ime
--• LastName -> Prezime
--• JobTitle (Employee) -> OpisPosla
--• EmailAddress (EmailAddress) -> EmailAdresa
set identity_insert Prodavaci on
insert into Prodavaci(ProdavacID,Ime,Prezime,OpisPosla,EmailAdresa)
select sp.BusinessEntityID,p.FirstName,p.LastName,e.JobTitle,ea.EmailAddress
from AdventureWorks2017.Sales.SalesPerson as sp inner join AdventureWorks2017.Person.Person as p on
                         sp.BusinessEntityID=p.BusinessEntityID
						                        inner join AdventureWorks2017.HumanResources.Employee as e on
												e.BusinessEntityID=p.BusinessEntityID
												inner join AdventureWorks2017.Person.EmailAddress as ea on
												ea.BusinessEntityID=p.BusinessEntityID
set identity_insert Prodavaci off

--3. Iz baze podataka AdventureWorks u svoju bazu podataka prebaciti sljedeće podatke:
--3b) U tabelu Proizvodi dodati sve proizvode
--• ProductID -> ProizvodID
--• Name -> Naziv
--• ProductNumber -> SifraProizvoda
--• Color -> Boja
--• Name (ProductCategory) -> NazivKategorije

set identity_insert Proizvodi on
insert into Proizvodi(ProizvodID,Naziv,SifraProizvoda,Boja,NazivKategorije)
select p.ProductID,p.Name,p.ProductNumber,p.Color,pc.Name
from AdventureWorks2017.Production.Product as p inner join AdventureWorks2017.Production.ProductSubcategory as ps on
p.ProductSubcategoryID=ps.ProductSubcategoryID
                                                inner join AdventureWorks2017.Production.ProductCategory as pc on
												pc.ProductCategoryID=ps.ProductCategoryID
set identity_insert Proizvodi off




--3c) U tabelu ZaglavljeNarudzbe dodati sve narudžbe
--• SalesOrderID -> NarudzbaID
--• OrderDate -> DatumNarudzbe
--• ShipDate -> DatumIsporuke
--• CreditCardID -> KreditnaKarticaID
--• FirstName (Person) -> ImeKupca
--• LastName (Person) -> PrezimeKupca
--• City (Address) -> NazivGrada
--• SalesPersonID (SalesOrderHeader) -> ProdavacID
--• Name (ShipMethod) -> NacinIsporuke

set identity_insert ZagljavljeNarudzbe on
insert into ZagljavljeNarudzbe(NaruzdbaID,DatumNarudzbe,DatumIsporuke,KreditnaKarticaID,ImeKupca,PrezimeKupca,NazivGrada,ProdavacID,NacinIsporuke)
select soh.SalesOrderID,soh.OrderDate,soh.ShipDate,soh.CreditCardID,p.FirstName,p.LastName,ad.City,soh.SalesPersonID,sm.Name
from AdventureWorks2017.Sales.SalesOrderHeader as soh inner join AdventureWorks2017.Sales.Customer as c on 
soh.CustomerID=c.CustomerID inner join AdventureWorks2017.Person.Person as p on p.BusinessEntityID=c.PersonID
inner join AdventureWorks2017.Purchasing.ShipMethod as sm on sm.ShipMethodID=soh.ShipMethodID
inner join AdventureWorks2017.Person.Address as ad on ad.AddressID=soh.ShipToAddressID
set identity_insert ZagljavljeNarudzbe off

select* from ZagljavljeNarudzbe

--3d) U tabelu DetaljiNarudzbe dodati sve stavke narudžbe
--• SalesOrderID -> NarudzbaID
--• ProductID -> ProizvodID
--• UnitPrice -> Cijena
--• OrderQty -> Kolicina
--• UnitPriceDiscount -> Popust
--• Description (SpecialOffer) -> OpisSpecijalnePonude

insert into DetaljiNarudzbe(NarudzbaID,ProizvodID,Cijena,Kolicina,Popust,OpisSpecijalnePonude)
select sod.SalesOrderID,sod.ProductID,sod.UnitPrice,sod.OrderQty,sod.UnitPriceDiscount,so.Description
from AdventureWorks2017.Sales.SalesOrderDetail as sod inner join AdventureWorks2017.Sales.SpecialOffer as so on so.SpecialOfferID=sod.SpecialOfferID

select* from DetaljiNarudzbe

--4.
--a)(6 bodova) kreirati pogled v_detalji gdje je korisniku potrebno prikazati --identifikacijski broj narudzbe,
--spojeno ime i prezime kupca, grad isporuke, ukupna vrijednost narudzbe sa popustom i- -bez popusta, te u dodatnom polju informacija da li je narudzba placena karticom --("Placeno karticom" ili "Nije placeno karticom").
--Rezultate sortirati prema vrijednosti narudzbe sa popustom u opadajucem redoslijedu.
--OBAVEZNO kreirati testni slucaj.(Novokreirana baza)
--
go
create or alter  view v_detalji 
as
select zn.NaruzdbaID,CONCAT(zn.ImeKupca,'',zn.PrezimeKupca)as'ime i prezime',zn.NazivGrada,SUM(dn.Kolicina*dn.Cijena*(1-dn.Popust))as'ukupno sa popustom',SUM(dn.Kolicina*dn.Cijena)as'ukupno bez popusta',IIF(zn.KreditnaKarticaID IS null,'nije placeno karticom','placeno karticom')as 'karitcno placanje'
from ZagljavljeNarudzbe as zn inner join DetaljiNarudzbe as dn on zn.NaruzdbaID=dn.NarudzbaID
group by zn.NaruzdbaID,CONCAT(zn.ImeKupca,'',zn.PrezimeKupca),zn.NazivGrada,IIF(zn.KreditnaKarticaID IS null,'nije placeno karticom','placeno karticom')




--b)( 4 bodova) U kreiranoj bazi kreirati wproceduru sp_insert_ZaglavljeNarudzbe kojom- -ce se omoguciti kreiranje nove narudzbe. OBAVEZNO kreirati testni slucaj.--(Novokreirana baza).
--
go
create procedure sp_insert_ZaglavljeNarudzbe
(
   
   @DatumNarudzbe datetime =null,
   @DatumIsporuke datetime,
   @KreditnaKarticaID int =null,
   @ImeKupca nvarchar(50)=null,
   @PrezimeKupca nvarchar(50)=null,
   @NazivGrada nvarchar(30)=null,
   @ProdavacID int,
   @NacinIsporuke nvarchar(50)=null
)
as begin
 insert into ZagljavljeNarudzbe(DatumNarudzbe,DatumIsporuke,KreditnaKarticaID,ImeKupca,PrezimeKupca,NazivGrada,ProdavacID,NacinIsporuke)
 values(@DatumNarudzbe,@DatumIsporuke,@KreditnaKarticaID,@ImeKupca,@PrezimeKupca,@NazivGrada,@ProdavacID,@NacinIsporuke)
 end


 exec sp_insert_ZaglavljeNarudzbe
      @DatumNarudzbe='2025-05-21 00:00:00.000',
	  @DatumIsporuke='2025-05-22 00:00:00.000',
	  @KreditnaKarticaID=null,
	  @ImeKupca='Tarik',
	  @PrezimeKupca='Kisija',
	  @NazivGrada='Sarajevo',
	  @ProdavacID=279,
	  @NacinIsporuke='picibangosem'



--c)(6 bodova) Kreirati upit kojim ce se prikazati ukupan broj proizvoda po --kategorijama. Uslov je da se prikazu samo one kategorije kojima ne pripada vise od --30 proizvoda, a sadrze broj u bilo kojoj od rijeci i ne nalaze se u prodaji.--(AdventureWorks2017)
--
--prikazati:ime kategorije,count proizovda po kategorijama
--uslov: nema vise od 30 proizvoda, sadrze broj u nekoj od rijeci i nisu u prodaji

select pc.Name,COUNT(p.ProductID)as'ukupan broj proizvoda po kategorijama'
from AdventureWorks2017.Production.Product as p inner join AdventureWorks2017.Production.ProductSubcategory as ps on 
                       ps.ProductSubcategoryID=p.ProductSubcategoryID
					                             inner join AdventureWorks2017.Production.ProductCategory as pc on
					  pc.ProductCategoryID=ps.ProductCategoryID
where p.Name like '%[0-9]%'and p.SellEndDate is not null
group by pc.Name
having count(p.ProductID)<=30
order by 2 desc





--d)(7 bodova) Kreirati upit koji ce prikazati uposlenike koji imaju iskustva( radilli- -su na jednom odjelu) a trenutno rade na marketing ili odjelu za nabavku. Osobama -po- prestanku rada na odjelu se upise podatak datuma prestanka rada.
--Rezultat upita treba prikazati ime i prezime uposlenika, odjel na kojem rade.
--(AdventureWorks2017)
--
   --uspolenik znaci ime i prezime  i odjel
   --uslov da su radili bar na 1 odjeliu a trenutno rade marketing il nabavka
select p.FirstName,p.LastName,d.Name
from AdventureWorks2017.HumanResources.Employee as e inner join AdventureWorks2017.HumanResources.EmployeeDepartmentHistory as edh on
                    edh.BusinessEntityID=e.BusinessEntityID
					                                     inner join AdventureWorks2017.HumanResources.Department as d on d.DepartmentID=edh.DepartmentID
														 inner join AdventureWorks2017.Person.Person as p on p.BusinessEntityID=e.BusinessEntityID
WHERE d.Name IN ('MARKETING','purchasing') and edh.EndDate is  null
group by p.FirstName,p.LastName,d.Name,e.BusinessEntityID
having 
(
   select COUNT(*)
   from AdventureWorks2017.HumanResources.EmployeeDepartmentHistory as edh1 
   where edh1.BusinessEntityID=e.BusinessEntityID and edh1.EndDate is not null

)>0



--e)(7 bodova) Kreirati upit kojim ce se prikazati proizvod koji je najvise dana bio u- -prodaji( njegova prodaja je prestala) a pripada kategoriji bicikala. Proizvodu se- -pocetkom i po prestanku prodaje biljezi datum.
--Ukoliko postoji vise proizvoda sa istim vremenskim periodom kao i prvi prikazati ih -u- rezultatima upita.
--(AdventureWorks2017)
--
--prikazati:ime prozivoda, i broj dana u prodaji
--uslovi:najvise dana u prodaji a ona prestala,pripada katgoriji bicikala

select top 1 with ties p.Name ,DATEDIFF(DAY,p.SellStartDate,p.SellEndDate)as'broj dana u prodaji'
from AdventureWorks2017.Production.Product as p inner join AdventureWorks2017.Production.ProductSubcategory as ps on 
                       ps.ProductSubcategoryID=p.ProductSubcategoryID
					                             inner join AdventureWorks2017.Production.ProductCategory as pc on
					  pc.ProductCategoryID=ps.ProductCategoryID
where p.SellEndDate is not null and pc.Name like 'Bikes'
order by 2



--(30 bodova
--5.)
--
--a) (9 bodova) Prikazati nazive odjela na kojima TRENUTNO radi najmanje , odnosno --najvise uposlenika(AdventureWorks2017)
--
--prikazati: nazive odjela i broj radnika
--uslov:radi najmanje i radi najvise randika

select sq1.Name,sq1.[broj uposlenika]
from(
 select top 1 d.Name, count(p.BusinessEntityID)as 'broj uposlenika'
 from AdventureWorks2017.HumanResources.Employee as e inner join AdventureWorks2017.HumanResources.EmployeeDepartmentHistory as edh on
                    edh.BusinessEntityID=e.BusinessEntityID
					                                     inner join AdventureWorks2017.HumanResources.Department as d on d.DepartmentID=edh.DepartmentID
														 inner join AdventureWorks2017.Person.Person as p on p.BusinessEntityID=e.BusinessEntityID
where edh.EndDate is  null
group by d.Name
order by 2 desc
)as sq1
union all
select sq2.Name,sq2.[broj uposlenika]
from
(
select top 1 d.Name, count(p.BusinessEntityID)as 'broj uposlenika'
 from AdventureWorks2017.HumanResources.Employee as e inner join AdventureWorks2017.HumanResources.EmployeeDepartmentHistory as edh on
                    edh.BusinessEntityID=e.BusinessEntityID
					                                     inner join AdventureWorks2017.HumanResources.Department as d on d.DepartmentID=edh.DepartmentID
														 inner join AdventureWorks2017.Person.Person as p on p.BusinessEntityID=e.BusinessEntityID
where edh.EndDate is  null
group by d.Name
order by 2 asc
)as sq2

--b)(10 bodova) Kreirati upit kojim ce se prikazati ukupan broj obradjenih narudzbi i --ukupnu vrijednost narudzbi sa popustom za svakog uposlenika pojedinacno, i to od --zadnje 30% kreiranih datumski kreiranih narudzbi. Rezultate sortirati prema -ukupnoj- vrijednosti u opadajucem redoslijedu.
--(AdventureWorks2017)
--
--ukupan broj obradjenih naruzdbi,ukupan broj narudzbi sa popustom za svkog uposlenika pojedincano
--uslov od zadnjih 30%  naruzdi datumski
--order by 2 desc

select e.BusinessEntityID,COUNT(soh.SalesOrderID)as'ukupna broj obradjenih naruzdbi', SUM(soh.SubTotal)as 'ukupna vrijednost sa popustom'
from AdventureWorks2017.Sales.SalesOrderHeader as soh inner join AdventureWorks2017.Sales.SalesPerson as sp on 
soh.SalesPersonID=sp.BusinessEntityID
                                                       inner join AdventureWorks2017.HumanResources.Employee as e on
e.BusinessEntityID=sp.BusinessEntityID
where soh.OrderDate in
(
   select top 30 PERCENT soh1.OrderDate
   from AdventureWorks2017.Sales.SalesOrderHeader as soh1
   order by soh1.OrderDate desc

)
group by e.BusinessEntityID
order by 3 desc


--f)(12 bodova) Upitom prikazati id autora, ime i prezime, napisano djelo i šifra. --Prikazati samo one zapise gdje adresa autora pocinje sa ISKLJUCIVO 2 broja (Pubs)
--Šifra se sastoji od sljedeći vrijednosti: 
--	1.Prezime po pravilu(prezime od 6 karaktera -> uzeti prva 4 karaktera; prezime -od- 10 karaktera-> uzeti prva 6 karaktera, za sve ostale slucajeve uzeti prva dva --karaktera)
--	2.Ime prva 2 karaktera
--	3.Karakter /
--	4.Zip po pravilu( 2 karaktera sa desne strane ukoliko je zadnja cifra u opsegu --0-5; u suprotnom 2 karaktera sa lijeve strane)
--	5.Karakter /
--	6.State(obrnuta vrijednost)
--	7.Phone(brojevi između space i karaktera -)
--	Primjer : za autora sa id-om 486-29-1786 šifra je LoCh/30/AC585
--			  za autora sa id-om 998-72-3567 šifra je RingAl/52/TU826
--(31 bod)
--


select a.au_id,CONCAT(a.au_fname,' ',a.au_lname)as 'ime i prezime',t.title,
       IIF(LEN(a.au_lname)=6,LEFT(a.au_lname,4),iif(len(a.au_lname)=10,left(a.au_lname,6),left(a.au_lname,2)))+
	   LEFT(a.au_fname,2)+
	   '/'+
	   IIF(RIGHT(a.zip,1)between 0 and 5,RIGHT(a.zip,2),left(a.zip,2))+
	   '/'+
	   REVERSE(a.state)+
	   SUBSTRING(a.phone,5,3)as'sifra'
from pubs.dbo.authors as a inner join pubs.dbo.titleauthor as ta on a.au_id=ta.au_id
                           inner join pubs.dbo.titles as t on t.title_id=ta.title_id