
--1. Kroz SQL kod kreirati bazu podataka sa imenom vašeg broja indeksa.
create database IB230000

go
use IB230000
--2. U kreiranoj bazi podataka kreirati tabele sa sljedećom strukturom:
--a) Prodavaci
--• ProdavacID, cjelobrojna vrijednost i primarni ključ, autoinkrement
--• Ime, 50 UNICODE (obavezan unos)
--• Prezime, 50 UNICODE (obavezan unos)
--• OpisPosla, 50 UNICODE karaktera (obavezan unos)
--• EmailAdresa, 50 UNICODE karaktera

create table Prodavaci
(
  ProdavacID int constraint Pk_Prodavaci primary key identity(1,1),
  Ime nvarchar(50) not null,
  Prezime nvarchar(50) not null,
  OpisPosla nvarchar(50) not null,
  EmailAdresa nvarchar(50) not null
  )

--b) Proizvodi
--• ProizvodID, cjelobrojna vrijednost i primarni ključ, autoinkrement
--• Naziv, 50 UNICODE karaktera (obavezan unos)
--• SifraProizvoda, 25 UNICODE karaktera (obavezan unos)
--• Boja, 15 UNICODE karaktera
--• NazivPodkategorije, 50 UNICODE (obavezan unos)

create table Proizvodi
(
  ProizvodID int constraint PK_Proizvodi primary key identity(1,1),
  Naziv nvarchar(50) not null,
  SifraProizvoda  nvarchar(25) not null,
  Boja nvarchar(15),
  NazivPodkategorije nvarchar(50) not null
)


--c) ZaglavljeNarudzbe
--• NarudzbaID, cjelobrojna vrijednost i primarni ključ, autoinkrement
--• DatumNarudzbe, polje za unos datuma i vremena (obavezan unos)
--• DatumIsporuke, polje za unos datuma i vremena
--• KreditnaKarticaID, cjelobrojna vrijednost
--• ImeKupca, 50 UNICODE (obavezan unos)
--• PrezimeKupca, 50 UNICODE (obavezan unos)
--• NazivGradaIsporuke, 30 UNICODE (obavezan unos)
--• ProdavacID, cjelobrojna vrijednost, strani ključ
--• NacinIsporuke, 50 UNICODE (obavezan unos)

create table ZaglavljeNarudzbe
(
  NarudzbaID int constraint PK_ZN primary key identity(1,1),
  DatumNarudzbe datetime not null,
  DatumIsporuke datetime ,
  KreditnaKarticaID int,
  ImeKupca nvarchar(50) not null,
  Prezime nvarchar(50) not null,
  NazivGradaIsporuke nvarchar(30) not null,
  ProdavacID int constraint fk_zn foreign key references Prodavaci(ProdavacID),
  NacinIsporuke nvarchar(50) not null

)


--d) DetaljiNarudzbe
--• NarudzbaID, cjelobrojna vrijednost, obavezan unos i strani ključ
--• ProizvodID, cjelobrojna vrijednost, obavezan unos i strani ključ
--• Cijena, novčani tip (obavezan unos),
--• Kolicina, skraćeni cjelobrojni tip (obavezan unos),
--• Popust, novčani tip (obavezan unos)
--• OpisSpecijalnePonude, 255 UNICODE (obavezan unos)
--**Jedan proizvod se može više puta naručiti, dok -jednanarudžba'možesadržavati'više''- proizvoda. U okviru jedne
--narudžbe jedan proizvod se može naručiti više puta.

create table DetaljiNarudzbe
(
  NarudzbaID int constraint fk_dn foreign key references ZaglavljeNarudzbe(NarudzbaID),
  ProizvodID int constraint fk_dn__pr foreign key references Proizvodi(ProizvodID),
  Cijena money not null,
  Kolicina smallint not null,
  Popust money not null,
  OpisSpecijalnePonude nvarchar(255) not null,
  DetaljiNarudzbeID  int constraint pk_dn primary key identity(1,1)
)




--9 bodova
--3. Iz baze podataka AdventureWorks u svoju bazu podatakaprebacitisljedeće'podatke:
--a) U tabelu Prodavaci dodati sve prodavače
--• BusinessEntityID (SalesPerson) -> ProdavacID
--• FirstName (Person) -> Ime
--• LastName (Person) -> Prezime
--• JobTitle (Employee) -> OpisPosla
--• EmailAddress (EmailAddress) -> EmailAdresa

set identity_insert Prodavaci on
insert into Prodavaci(ProdavacID,Ime,Prezime,OpisPosla,EmailAdresa)
select sp.BusinessEntityID,p.FirstName,p.LastName,e.JobTitle,ea.EmailAddress
from AdventureWorks2017.Sales.SalesPerson as sp inner join	AdventureWorks2017.Person.Person as p on sp.BusinessEntityID=p.BusinessEntityID
                                                inner join AdventureWorks2017.Person.EmailAddress as ea on ea.BusinessEntityID=p.BusinessEntityID
												 inner join AdventureWorks2017.HumanResources.Employee as e on e.BusinessEntityID=p.BusinessEntityID
set identity_insert Prodavaci off


--b) U tabelu Proizvodi dodati sve proizvode
--• ProductID (Product)-> ProizvodID
--• Name (Product)-> Naziv
--• ProductNumber (Product)-> SifraProizvoda
--• Color (Product)-> Boja
--• Name (ProductSubategory) -> NazivPodkategorije

set identity_insert Proizvodi on
insert into Proizvodi(ProizvodID,Naziv,SifraProizvoda,Boja,NazivPodkategorije) 
selecT p.ProductID,p.Name,p.ProductNumber,p.Color,pc.Name
from AdventureWorks2017.Production.Product as p inner join AdventureWorks2017.Production.ProductSubcategory as pc on p.ProductSubcategoryID=pc.ProductSubcategoryID

set identity_insert Proizvodi off



--c) U tabelu ZaglavljeNarudzbe dodati sve narudžbe
--• SalesOrderID (SalesOrderHeader) -> NarudzbaID
--• OrderDate (SalesOrderHeader)-> DatumNarudzbe
--• ShipDate (SalesOrderHeader)-> DatumIsporuke
--• CreditCardID(SalesOrderID)-> KreditnaKarticaID
--• FirstName (Person) -> ImeKupca
--• LastName (Person) -> PrezimeKupca
--• City (Address) -> NazivGradaIsporuke
--• SalesPersonID (SalesOrderHeader)-> ProdavacID
--• Name (ShipMethod)-> NacinIsporuke

set identity_insert ZaglavljeNarudzbe on
insert into ZaglavljeNarudzbe(NarudzbaID,DatumNarudzbe,DatumIsporuke,KreditnaKarticaID,ImeKupca,Prezime,NazivGradaIsporuke,ProdavacID,NacinIsporuke)
select soh.SalesOrderID,soh.OrderDate,soh.ShipDate,soh.CreditCardID,p.FirstName,p.LastName,ad.City,soh.SalesPersonID,sm.Name
from AdventureWorks2017.Sales.SalesOrderHeader as soh inner join AdventureWorks2017.Sales.Customer as c on c.CustomerID=soh.CustomerID
                                                      inner join AdventureWorks2017.Person.Person as p on p.BusinessEntityID=c.PersonID
													  inner join AdventureWorks2017.Person.Address as ad on ad.AddressID=soh.ShipToAddressID
													  inner join AdventureWorks2017.Purchasing.ShipMethod as sm on sm.ShipMethodID=soh.ShipMethodID
set identity_insert ZaglavljeNarudzbe off


--d) U tabelu DetaljiNarudzbe dodati sve stavke narudžbe
--• SalesOrderID (SalesOrderDetail)-> NarudzbaID
--• ProductID (SalesOrderDetail)-> ProizvodID
--• UnitPrice (SalesOrderDetail)-> Cijena
--• OrderQty (SalesOrderDetail)-> Kolicina
--• UnitPriceDiscount (SalesOrderDetail)-> Popust
--• Description (SpecialOffer) -> OpisSpecijalnePonude
--10 bodova

insert into DetaljiNarudzbe(NarudzbaID,ProizvodID,Cijena,Kolicina,Popust,OpisSpecijalnePonude) 
select sod.SalesOrderID,sod.ProductID,sod.UnitPrice,sod.OrderQty,sod.UnitPriceDiscount,so.Description
from AdventureWorks2017.Sales.SalesOrderDetail as sod inner join AdventureWorks2017.Sales.SpecialOffer as so on
so.SpecialOfferID=sod.SpecialOfferID



--4.
--a) (6 bodova) Kreirati funkciju f_detalji u formi --tabelegdje''korisnikuslanjem''parametra identifikacijski
--broj narudžbe će biti ispisano spojeno ime i prezime --kupca,grad''isporuke,ukupna''vrijednost narudžbe
--sa popustom, te poruka da li je narudžba plaćena karticom --iline.''Korisnikmože''dobiti 2 poruke „Plaćeno
--karticom“ ili „Nije plaćeno karticom“.
--OBAVEZNO kreirati testni slučaj. (Novokreirana baza)
go
create function f_detalji
(
 @NarudzbaID int
)
returns table 
as return
select CONCAT(zn.ImeKupca,' ',zn.Prezime)as 'ime prezime',
       zn.NazivGradaIsporuke,SUM(dn.Cijena*dn.Kolicina*(1-dn.Popust))as 'ukupno s popustom ',
	   IIF(zn.KreditnaKarticaID IS null,'nije placeno karticom','placeno karticom')as 'karticno placanje'
from ZaglavljeNarudzbe as zn inner join DetaljiNarudzbe as dn on zn.NarudzbaID=dn.NarudzbaID
where zn.NarudzbaID=@NarudzbaID
group by CONCAT(zn.ImeKupca,' ',zn.Prezime), zn.NazivGradaIsporuke,IIF(zn.KreditnaKarticaID IS null,'nije placeno karticom','placeno karticom')

select*
from f_detalji(43659)


--b) (4 bodova) U kreiranoj bazi -kreiratiproceduru'sp_insert_DetaljiNarudzbekojom'će''- se omogućiti insert
--nove stavke narudžbe. OBAVEZNO kreirati testni slučaj. (Novokreirana baza)
go
create or alter procedure sp_insert_DetaljiNarudzbe
(
  @NarudzbaID int,
  @ProizvodID int,
  @Cijena money =null,
  @Kolicina smallint =null,
  @Popust money =null,
  @OpisSpecijalnePonude nvarchar(255) =null
  )
  as 
  begin
  insert into DetaljiNarudzbe
  values(@NarudzbaID,@ProizvodID,@Cijena,@Kolicina,@Popust,@OpisSpecijalnePonude)
  end

  exec sp_insert_DetaljiNarudzbe @NarudzbaID=46165,@ProizvodID=778,@Cijena=10,@Kolicina=10,@Popust=0.1,@OpisSpecijalnePonude='opis'
  
  


--c) (6 bodova) Kreirati upit kojim će se prikazati --ukupanbroj''proizvodapo''kategorijama. Korisnicima se
--treba ispisati o kojoj kategoriji se radi. Uslov je da --seprikažu''samoone''kategorije kojima pripada više
--od 30 proizvoda, te da nazivi proizvoda se sastoje od 3 riječi, -asadrže'broju'bilo''- kojoj od riječi i još
--uvijek se nalaze u prodaji. Također, ukupan broj -proizvodapo'kategorijamamora'biti''- veći od 50.
--(AdventureWorks2017)

select pc.Name,COUNT(p.ProductID)as 'broj prozivoda po aktegorijama'
from AdventureWorks2017.Production.Product as p inner join AdventureWorks2017.Production.ProductSubcategory as ps on
                  p.ProductSubcategoryID=ps.ProductSubcategoryID
				                                 inner join AdventureWorks2017.Production.ProductCategory as pc on
		          pc.ProductCategoryID=ps.ProductCategoryID
where LEN(p.Name)-LEN(REPLACE(p.name,' ',''))=2 and p.Name like '%[0-9]%' and p.SellEndDate is null
group by pc.Name
having COUNT(p.ProductID)>50


--d) (7 bodova) Za potrebe menadžmenta kompanije potrebno je -kreiratiupit'kojim će'se''- prikazati proizvodi
--koji trenutno nisu u prodaji i ne pripada kategoriji bicikala, --kakobi''ihponovno''vratili u prodaju.
--Proizvodu se početkom i po prestanku prodaje zabilježi --datum.Osnovni''uslovza''ponovno povlačenje u
--prodaju je to da je ukupna prodana količina za svaki proizvod pojedinačno --bilaveć'''od 200 komada.
--Kao rezultat upita očekuju se podaci u formatu --npr.Laptop''300komitd.''(AdventureWorks2017)


selecT p.Name, CAST(SUM(sod.OrderQty)AS  nvarchar)+' kom' as 'ukupan broj komada'
from AdventureWorks2017.Production.Product as p inner join AdventureWorks2017.Production.ProductSubcategory as ps on
                  p.ProductSubcategoryID=ps.ProductSubcategoryID
				                                 inner join AdventureWorks2017.Production.ProductCategory as pc on
		          pc.ProductCategoryID=ps.ProductCategoryID
				                                 inner join AdventureWorks2017.Sales.SalesOrderDetail as sod on
												 sod.ProductID=p.ProductID
where p.SellEndDate is not null and pc.Name not like 'Bikes'
group by p.Name
having SUM(sod.OrderQty)>=200




--e) (7 bodova) Kreirati upit kojim će se --prikazatiidentifikacijski''brojnarudžbe,''spojeno ime i prezime kupca,
--te ukupna vrijednost narudžbe koju je kupac platio. Uslov je --daje''oddatuma''narudžbe do datuma
--isporuke proteklo manje dana od prosječnog broja dana koji --jebio''potrebanza''isporuku svih narudžbi.
--(AdventureWorks2017)
--30 bodova


selecT sod.SalesOrderID,CONCAT(p.FirstName, ' ',p.LastName)as 'ime i repzime',sum(sod.TotalDue) as 'ukupna vrijednost naruzbe'
from AdventureWorks2017.Sales.Customer as c inner join AdventureWorks2017.Person.Person as p on c.PersonID=p.BusinessEntityID
                                            inner join AdventureWorks2017.Sales.SalesOrderHeader as sod on sod.CustomerID=c.CustomerID

where DATEDIFF(DAY,sod.OrderDate,sod.ShipDate)<
(
select AVG(cast(DATEDIFF(DAY,soh.OrderDate,soh.ShipDate)as float))
from AdventureWorks2017.Sales.SalesOrderHeader as soh
)
group by  sod.SalesOrderID,CONCAT(p.FirstName, ' ',p.LastName)


--5.
--a) (9 bodova) Kreirati upit koji će prikazati one naslove --kojihje''ukupnoprodano''više od 30 komada a
--napisani su od strane autora koji su napisali 2 -ilivišedjela/'romana.U'rezultatima''- upita prikazati naslov
--i ukupnu prodanu količinu. (Pubs)


select t.title, SUM(s.qty)as'ukupna prodana kolicina'
from pubs.dbo.titles as t inner join pubs.dbo.titleauthor as ta on t.title_id=ta.title_id
                          inner join pubs.dbo.authors as a on ta.au_id=a.au_id
						  inner join pubs.dbo.sales as s on s.title_id=t.title_id
where ta.au_id in
(
  selecT ta1.au_id
  from pubs.dbo.titleauthor as ta1
  group by ta1.au_id
  having COUNT(ta1.au_id)>=2
)
group by t.title
having SUM(s.qty)>30

--b) (10 bodova) Kreirati upit koji će u % prikazati koliko --jenarudžbi''(odukupnog''broja kreiranih)
--isporučeno na svaku od teritorija pojedinačno. Npr --Australia20.2%,''Canada12.01%''itd. Vrijednosti
--dobijenih postotaka zaokružiti na dvije decimale --idodati'znak'%.''(AdventureWorks2017)



select
    sq1.Name,
    cast(cast(round(
        cast(sq1.UkupanBrojNarudzbi as float) * 100.0 / (select count(sohh.SalesOrderID) from AdventureWorks2017.Sales.SalesOrderHeader as sohh),
        2
    ) AS decimal(10,2)) as nvarchar) + '%'as 'procenat'
from
(
    select
        st.Name,
        count(soh.SalesOrderID) as UkupanBrojNarudzbi
    from AdventureWorks2017.Sales.SalesOrderHeader as soh
    inner join AdventureWorks2017.Sales.SalesTerritory as st on soh.TerritoryID = st.TerritoryID
    group by st.Name
) as sq1;

--c) (12 bodova) Kreirati upit koji će prikazati osobe koje --imajuredovne''prihodea''nemaju vanredne, i one
--koje imaju vanredne a nemaju redovne. Lista treba da sadrži --spojenoime''iprezime''osobe, grad i adresu
--stanovanja i ukupnu vrijednost ostvarenih prihoda -(zaredovne'koristitineto).'Pored''- navedenih podataka
--potrebno je razgraničiti kategorije u novom polju pod --nazivomOpis''nanačin''"ISKLJUČIVO
--VANREDNI" za one koji imaju samo vanredne prihode, ili "ISKLJUČIVO --REDOVNI"za''on''koji
--imaju samo redovne prihode. Konačne rezultate sortirati prema --opisuabecedno''ipo''ukupnoj vrijednosti
--ostvarenih prihoda u opadajućem redoslijedu. (prihodi)
--31 bod

select *
from
(
    select 
        concat(o.ime, ' ', o.prezime) as 'ime prezime',
        g.grad,
        o.adresa,
        sum(rp.neto) as 'ukupno prihoda',
        'iskljucivo redovni' as opis
    from prihodi.dbo.osoba as o
    inner join prihodi.dbo.redovniprihodi as rp on rp.osobaid = o.osobaid
    inner join prihodi.dbo.grad as g on g.gradid = o.gradid
    where o.osobaid not in
    (
        select vp.osobaid
        from prihodi.dbo.vanredniprihodi as vp
		where  vp.OsobaID IS NOT NULL
    )
    group by concat(o.ime, ' ', o.prezime), g.grad, o.adresa

    union

    select 
        concat(o.ime, ' ', o.prezime) as 'ime prezime',
        g.grad,
        o.adresa,
        sum(vp.iznosvanrednogprihoda) as 'ukupno prihoda',
        'iskljucivo vandredni' as opis
    from prihodi.dbo.osoba as o
    inner join prihodi.dbo.vanredniprihodi as vp on vp.osobaid = o.osobaid
    inner join prihodi.dbo.grad as g on g.gradid = o.gradid
    where o.osobaid not in
    (
        select rp.osobaid
        from prihodi.dbo.redovniprihodi as rp
		WHERE rp.OsobaID IS NOT NULL

    )
    group by concat(o.ime, ' ', o.prezime), g.grad, o.adresa
) as sq
order by sq.[ukupno prihoda] desc




--6. Dokument teorijski_ispit 14JUL23, preimenovati vašim brojem --indeksa,te''utom''dokumentu izraditi pitanja.
--20 bodova
--SQL skriptu (bila prazna ili ne) imenovati Vašim --brojemindeksa''nprIB210001.sql,''teorijski dokument imenovan
--Vašim brojem indexa npr IB210001.docx upload-ovati ODVOJEDNO na ftpufolder'Upload.
--Maksimalan broj bodova:100
--Prag prolaznosti: 55