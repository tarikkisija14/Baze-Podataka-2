 --1 Kreirati bazu za svojim brojm indeksa

create database IB230000

go 
use  IB230000
--2 U kreiranoj bazi podataka kreirati tabele slijedecom strukturom
--a)	Uposlenici
--•	UposlenikID, 9 karaktera fiksne duzine i primarni kljuc,
--•	Ime 20 karaktera obavezan unos,
--•	Prezime 20 karaktera obavezan unos
--•	DatumZaposlenja polje za unos datuma i vremena obavezan unos
--•	Opis posla 50 karaktera obavezan unos

create table Uposlenici
(
UposlenikID char(9) constraint pk_uposlenici primary key,
Ime varchar(20) not null,
Prezime varchar(20) not null,
DatumZaposlenja datetime not null,
Opis  varchar(50)
)

--b)	Naslovi
--•	NaslovID 6 karaktera primarni kljuc,
--•	Naslov 80 karaktera obavezan unos,
--•	Tip 12 karaktera fiksne duzine obavezan unos
--•	Cijena novcani tip podatka,
--•	NazivIzdavaca 40 karaktera,
--•	GradIzdavaca 20 karaktera,
--•	DrzavaIzdavaca 30 karaktera

create table Naslovi
(

   NaslovID varchar(6)constraint pk_naslovi primary key,
	Naslov varchar(80) not null ,
	Tip char(12)not null, 
   Cijena money,
   NazivIzdavaca varchar(40) ,
  GradIzdavaca varchar(20) ,
  DrzavaIzdavaca varchar(30) 

)


--c)	Prodaja
--•	ProdavnicaID 4 karktera fiksne duzine, strani i primarni kljuc
--•	Broj narudzbe 20 karaktera primarni kljuc,
--•	NaslovID 6 karaktera strani i primarni kljuc
--•	DatumNarudzbe polje za unos datuma i vremena obavezan unos
--•	Kolicina skraceni cjelobrojni tip obavezan unos

create table Prodaja
(
 ProdavnicaID char(4) constraint FK_Prodaja_prodavnice foreign key references Prodavnice(ProdavnicaID),
 BrojNaruzdbe varchar(20),
 NaslovID varchar(6) constraint FK_Prodaja_Naslovi foreign key references Naslovi(NaslovID),
 DatumNaruzdbe datetime not null,
 Kolicina smallint not null,
 constraint PK_Prodaja primary key(ProdavnicaID,BrojNaruzdbe,NaslovID)
 )




--d)	Prodavnice
--•	ProdavnicaID 4 karaktera fiksne duzine primarni kljuc
--•	NazivProdavnice 40 karaktera
--•	Grad 40 karaktera
create table Prodavnice
(

ProdavnicaId char(4) constraint PK_prodavnice primary key,
NazivProdavnice varchar(40),
Grad varchar(40)
)



--3 Iz baze podataka pubs u svoju bazu prebaciti slijedece podatke
--a)	U tabelu Uposlenici dodati sve uposlenike
--•	emp_id -> UposlenikID
--•	fname -> Ime
--•	lname -> Prezime
--•	hire_date - > DatumZaposlenja
--•	job_desc - > Opis posla

insert into Uposlenici(UposlenikID,Ime,Prezime,	DatumZaposlenja,Opis)
selecT e.emp_id,e.fname,e.lname,e.hire_date,j.job_desc
from pubs.dbo.employee as e inner join pubs.dbo.jobs as j on j.job_id=e.job_id

select* from Uposlenici


--b)	U tabelu naslovi dodati sve naslove, na mjestu gdje nema pohranjenih podataka o --nazivima izdavaca zamijeniti vrijednost sa nepoznat izdavac
--•	Title_id -> NaslovID
--•	Title->Naslov
--•	Type->Tip
--•	Price->Cijena
--•	Pub_name->NazivIzdavaca
--•	City->GradIzdavaca
--•	Country-DrzavaIzdavaca

insert into Naslovi(NaslovID,Naslov,Tip,Cijena,NazivIzdavaca,GradIzdavaca,DrzavaIzdavaca)
select t.title_id,t.title,t.type,t.price,ISNULL(p.pub_name, 'nepoznat izdavac'),p.city,p.country
from pubs.dbo.titles as t left join pubs.dbo.publishers as p on p.pub_id=t.pub_id


--c)	U tabelu prodaja dodati sve stavke iz tabele prodaja
--•	Stor_id->ProdavnicaID
--•	Order_num->BrojNarudzbe
--•	titleID->NaslovID,
--•	ord_date->DatumNarudzbe
--•	qty->Kolicinaproda

insert into Prodaja(ProdavnicaID,BrojNaruzdbe,NaslovID,DatumNaruzdbe,Kolicina)
selecT s.stor_id,s.ord_num,s.title_id,s.ord_date,s.qty
from pubs.dbo.sales as s

--d)	U tabelu prodavnice dodati sve prodavnice
--•	Stor_id->prodavnicaID
--•	Store_name->NazivProdavnice
--•	City->Grad

insert into Prodavnice(ProdavnicaId,NazivProdavnice,Grad)
selecT s.stor_id,s.stor_name,s.city
from pubs.dbo.stores as s


--4
--a)	Kreirati proceduru sp_delete_uposlenik kojom ce se obrisati odredjeni zapis iz --tabele uposlenici. OBAVEZNO kreirati testni slucaj na kreiranu proceduru
go
create or alter procedure sp_delete_uposlenik
(
@UposlenikID char(9)
)
as begin
delete from Uposlenici
where UposlenikID=@UposlenikID
end

select* from Uposlenici

exec sp_delete_uposlenik @UposlenikID='Y-L77953M'

--b)	Kreirati tabelu Uposlenici_log slijedeca struktura
--Uposlenici_log
--•	UposlenikID 9 karaktera fiksne duzine
--•	Ime 20 karaktera
--•	Prezime 20 karakera,
--•	DatumZaposlenja polje za unos datuma i vremena
--•	Opis posla 50 karaktera

create table Uposlenici_log
(
UposlenikID char(9),
Ime varchar(20),
Prezime varchar(20),
DatumZaposlenja datetime,
Opis varchar(50)
)



--c)	Nad tabelom uposlenici kreirati okidac t_ins_Uposlenici koji ce prilikom --birsanja podataka iz tabele Uposlenici izvristi insert podataka u tabelu --Uposlenici_log. OBAVEZNO kreirati tesni slucaj
go
create trigger t_ins_Uposlenici
on Uposlenici
after delete
as
begin
insert into Uposlenici_log
selecT*
from deleted
end

select* from Uposlenici_log

exec sp_delete_uposlenik 'A-R89858F'


--d)	Prikazati sve uposlenike zenskog pola koji imaju vise od 10 godina radnog -staza,- a rade na Production ili Marketing odjelu. Upitom je potrebno pokazati -spojeno -ime i prezime uposlenika, godine radnog staza, te odjel na kojem rade -uposlenici. -Rezultate upita sortirati u rastucem redoslijedu prema nazivu odjela,- te -opadajucem prema godinama radnog staza (AdventureWorks2019)
--prikazti:spojeno imeprezime,godine staza,odjel na kojem rade
--uslovi:zenski pol,imaju vise od 10g radnog staza a rade na produciton ili marketing

select CONCAT(p.FirstName,' ',p.LastName)as'imeprezime',DATEDIFF(YEAR,e.HireDate,GETDATE())as 'godine staza',
      d.Name as 'odjel'
from AdventureWorks2017.HumanResources.Employee as e inner join AdventureWorks2017.Person.Person as p on e.BusinessEntityID=p.BusinessEntityID                                                   inner join AdventureWorks2017.HumanResources.EmployeeDepartmentHistory as edh on 
            edh.BusinessEntityID=p.BusinessEntityID
			                                         inner join AdventureWorks2017.HumanResources.Department as d on
													 d.DepartmentID=edh.DepartmentID
where e.Gender='F' and DATEDIFF(YEAR,e.HireDate,GETDATE())>10 and d.Name in ('Production','Marketing')
order by 3 asc,2 desc


--e)	Kreirati upit kojim ce se prikazati koliko ukupno je naruceno komada proizvoda --za svaku narudzbu pojedinacno, te ukupnu vrijednost narudzbe sa i bez popusta. --Uzwti u obzir samo one narudzbe kojima je datum narudzbe do datuma isporuke --proteklo manje od 7 dana (ukljuciti granicnu vrijednost), a isporucene su kupcima --koji zive na podrucju Madrida, Minhena,Seatle. Rezultate upita sortirati po broju- -komada u opadajucem redoslijedu, a vrijednost je potrebno zaokruziti na dvije --decimale (Northwind)
--prikazati:ukupno naruceno proizvoda,ukupna vrijednost sa i bez popusta POJEDINACNO
--uslov:od datuma narudzbe do isporuke manje od 7 dana ili jednako a isporucene kupcima u madridu minehu i seattlu
--sort by broj komada desc 

select o.OrderID,SUM(od.Quantity)as' ukupno naruceno',round(SUM(od.Quantity*od.UnitPrice),2)as 'bez popusta',
      round(SUM(od.Quantity*od.UnitPrice*(1-od.Discount)),2)as 'sa popustom'
from Northwind.dbo.[Order Details] as od inner join Northwind.dbo.Orders as o on od.OrderID=o.OrderID
where DATEDIFF(DAY,o.OrderDate,o.ShippedDate)<=7 and o.ShipCity in('Madrid','Munchen','Seattle')
group by o.OrderID
order by 2 desc


--f)	Napisati upit kojim ce se prikazati brojNarudzbe,datumNarudzbe i sifra. --Prikazati samo one zapise iz tabele Prodaja ciji broj narudzbe ISKLJICIVO POCINJE --jednim slovom, ili zavrsava jednim slovom (Novokreirana baza)
--Sifra se sastoji od slijedecih vrijednosti:
--•	Brojevi (samo brojevi) uzeti iz broja narudzbi,
--•	Karakter /
--•	Zadnja dva karaktera godine narudbze /
--•	Karakter /
--•	Id naslova
--•	Karakter /
--•	Id prodavnice
--Za broj narudzbe 772a sifra je 722/19/PS2091/6380
--Za broj narudzbe N914008 sifra je 914008/19/PS2901/6380


select p.BrojNaruzdbe,p.DatumNaruzdbe,
REPLACE(REPLACE(SUBSTRING(REPLACE(p.BrojNaruzdbe,PATINDEX('%[0-9]%',p.BrojNaruzdbe),LEN(p.BrojNaruzdbe)),PATINDEX('%[0-9]%',REPLACE(p.BrojNaruzdbe,PATINDEX('%[0-9]%',p.BrojNaruzdbe),LEN(p.BrojNaruzdbe))),LEN(p.BrojNaruzdbe)),'a',' ')
   + '/'
   +reverse(right(reverse(year(p.DatumNaruzdbe)),2))
   + '/'
   +p.naslovID
   +'/'
   + p.ProdavnicaID,' ','') as sifra
from Prodaja as  p
where p.BrojNaruzdbe like '[A-Za-z]%' or p.BrojNaruzdbe like '%[A-Za-z]'



--5
--a)	Prikazati nazive odjela gdje radi najmanje odnosno najvise uposlenika --(AdventureWorks2019)
--prikazati: nazive odjela i broj radnika
--uslov:najamnje i najvise ranika

select*
from(
select top 1 d.Name,COUNT(e.BusinessEntityID)as 'brojuposlenika'
from AdventureWorks2017.HumanResources.Employee		as e inner join AdventureWorks2017.HumanResources.EmployeeDepartmentHistory as edh
                      on edh.BusinessEntityID=e.BusinessEntityID
					                                      inner join AdventureWorks2017.HumanResources.Department as d on 
														  d.DepartmentID=edh.DepartmentID
group by d.Name
order by 2 desc
)as sq1
union all
selecT*
from
(
select top 1 d.Name,COUNT(e.BusinessEntityID)as 'brojuposlenika'
from AdventureWorks2017.HumanResources.Employee		as e inner join AdventureWorks2017.HumanResources.EmployeeDepartmentHistory as edh
                      on edh.BusinessEntityID=e.BusinessEntityID
					                                      inner join AdventureWorks2017.HumanResources.Department as d on 
														  d.DepartmentID=edh.DepartmentID
group by d.Name
order by 2 asc
) as sq2



--b)	Prikazati spojeno ime i prezime osobe,spol, ukupnu vrijednost redovnih bruto --prihoda, ukupnu vrijednost vandrednih prihoda, te sumu ukupnih vandrednih prihoda --i ukupnih redovnih prihoda. Uslov je da dolaze iz Latvije, Kine ili Indonezije a --poslodavac kod kojeg rade je registrovan kao javno ustanova (Prihodi)
--prikazati:spojeno imeprezime, ukupnu vrijednosrt redobvrnih bruto ukupnu vandredin te sumu ukupnih vanrednih i ukupnih redovnih
--uslov: dolaze iz latvije kine indonezije a poslavac je ajvna ustanova

selecT CONCAT(o.Ime,' ',o.PrezIme),o.spol,SUM(RP.Bruto)as 'ukupno bruto',SUM(vp.IznosVanrednogPrihoda)as 'ukupno vandredin',
       SUM(RP.Bruto+vp.IznosVanrednogPrihoda)as 'ukupno'
from prihodi.dbo.Osoba as o inner join prihodi.dbo.RedovniPrihodi AS RP ON o.OsobaID=RP.OsobaID
                            inner join prihodi.dbo.VanredniPrihodi as vp on vp.OsobaID=o.OsobaID
							inner join prihodi.dbo.Drzava as d on d.DrzavaID=o.DrzavaID
							inner join prihodi.dbo.Poslodavac as p on p.PoslodavacID=o.PoslodavacID
							inner join prihodi.dbo.TipPoslodavca as tp on tp.TipPoslodavcaID=p.TipPoslodavca
where d.Drzava in('Latvia', 'China', 'Indonesia') and tp.OblikVlasnistva = 'Javno Ustanova'
group by CONCAT(o.Ime,' ',o.PrezIme),o.Spol



--c)	Modificirati prethodni upit 5_b na nacin da se prikazu samo oni zapisi kod -kojih- je suma ukupnih bruto i ukupnih vanderednih prihoda (SumaBruto+SumaNeto) -veca od -10000KM Retultate upita sortirati prema ukupnoj vrijednosti prihoda -obrnuto -abecedno(Prihodi)

selecT CONCAT(o.Ime,' ',o.PrezIme),o.spol,SUM(RP.Bruto)as 'ukupno bruto',SUM(vp.IznosVanrednogPrihoda)as 'ukupno vandredin',
       SUM(RP.Bruto+vp.IznosVanrednogPrihoda)as 'ukupno'
from prihodi.dbo.Osoba as o inner join prihodi.dbo.RedovniPrihodi AS RP ON o.OsobaID=RP.OsobaID
                            inner join prihodi.dbo.VanredniPrihodi as vp on vp.OsobaID=o.OsobaID
							inner join prihodi.dbo.Drzava as d on d.DrzavaID=o.DrzavaID
							inner join prihodi.dbo.Poslodavac as p on p.PoslodavacID=o.PoslodavacID
							inner join prihodi.dbo.TipPoslodavca as tp on tp.TipPoslodavcaID=p.TipPoslodavca
where d.Drzava in('Latvia', 'China', 'Indonesia') and tp.OblikVlasnistva = 'Javno Ustanova'
group by CONCAT(o.Ime,' ',o.PrezIme),o.Spol
having  SUM(RP.Bruto+vp.IznosVanrednogPrihoda)>10000
order by 5 desc, CONCAT(o.Ime,' ',o.PrezIme) desc