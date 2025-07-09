-- Ispit BP II-druga grupa 22.06.2025

--Nemam drugi dio ispita kreaciju tabela,insert,procedure i funkcije jer nije niko uslikao

-- ZADATAK 2: AdventureWorks2017
-- a) Prikazati sve narudžbe iz 2011. koje sadrže tačno jedan proizvod (5 bodova)
-- Zaglavlje: ID narudžbe

select soh.SalesOrderID as 'ID narudzbe'
from AdventureWorks2017.Sales.SalesOrderHeader soh
INNER JOIN AdventureWorks2017.Sales.SalesOrderDetail sod on soh.SalesOrderID = sod.SalesOrderID
where year(soh.OrderDate) = 2011
GROUP BY soh.SalesOrderID
HAVING COUNT(sod.ProductID) = 1

-- b) Prikazati ukupni prihod (kolicina * cijena) i broj narudžbi po kupcu i godini kupovine (7 bodova)
-- Zaglavlje: Kupac, Godina kupovine, Prihod, Broj narudžbi

select c.customerid as 'kupac',
    year(soh.orderdate) as 'godina kupovine',
    sum(sod.orderqty * sod.unitprice) as 'prihod',
    count(distinct soh.salesorderid) as 'broj narudzbi'
from adventureworks2017.sales.salesorderheader soh
inner join adventureworks2017.sales.customer c on soh.customerid = c.customerid
inner join adventureworks2017.sales.salesorderdetail sod on soh.salesorderid = sod.salesorderid
group by c.customerid, year(soh.orderdate);


-- c) Prikazati proizvode koji NIKADA nisu naručeni, cijena im je > 100 i imaju više od 800 komada u skladištu (8 bodova)
-- Zaglavlje: Naziv proizvoda, Cijena, Kolicina

select p.Name as 'Naziv proizvoda', p.ListPrice as 'Cijena', SUM(pi.Quantity) as 'Kolicina'
from AdventureWorks2017.Production.Product p
inner join AdventureWorks2017.Production.ProductInventory pi on p.ProductID = pi.ProductID
where p.ProductID not in
(
select ProductID 
from AdventureWorks2017.Sales.SalesOrderDetail
)
and p.ListPrice > 100
group by p.Name, p.ListPrice
having SUM(pi.Quantity) > 800
order by p.ListPrice DESC

-- ZADATAK 3: Northwind
-- a) Prikazati državu iz koje su narudžbe isporučene najbrže (4 boda)
-- Zaglavlje: Država, Prosječan broj dana

select top  1 ShipCountry as 'drzava',
       avg(datediff(day, OrderDate, ShippedDate)) AS 'prosjecan broj dana'
from Northwind.dbo.Orders
group by ShipCountry
order by 2 asc;

-- b) Prikazati kupce čije su sve narudžbe isporučene u roku kraćem od 5 dana (7 bodova)
-- Zaglavlje: Naziv kompanije kupca

select c.CompanyName 
from Northwind.dbo.Customers as c
where c.CustomerID IN (
    select o.CustomerID
    from Northwind.dbo.Orders AS o
    group by o.CustomerID
    having MAX(DATEDIFF(DAY, o.OrderDate, o.ShippedDate)) < 5
)

-- c) Prikazati kupce koji su naručili samo jednom, i to proizvode kojih ima manje od 20 (7 bodova)
-- Zaglavlje: Naziv kompanije kupca

select c.CompanyName 
from Northwind.dbo.Customers as c
where CustomerID IN (
    select o.CustomerID
    from Northwind.dbo.Orders as o
    inner join Northwind.dbo.[Order Details] as od on o.OrderID = od.OrderID
    group by o.CustomerID
    having count(distinct o.OrderID) = 1 AND MAX(od.Quantity) < 20
)

-- ZADATAK 4: Pubs
-- a) Prikazati naslove koji se nisu prodali ni u jednoj trgovini koja je prodala više od 10 naslova (10 bodova)
-- Zaglavlje: Naslov knjige

select t.title 
from pubs.dbo.titles as t
where t.title_id not in (
    select s.title_id
    from pubs.dbo.sales as s
    where s.stor_id IN (
        select stor_id
        from pubs.dbo.sales
        group by stor_id
        having count(distinct title_id) > 5
    )
)

-- b) Prikazati naslove koji su prodani isključivo u godinama gdje ukupan broj prodatih naslova nije prelazio 80 (10 bodova)
-- Zaglavlje: title (naslov knjige)

select t.title 
from pubs.dbo.titles as t
where t.title_id in (
    select s.title_id
    from pubs.dbo.sales as s
    group by s.title_id, year(s.ord_date)
    having sum(s.qty) < 80
)
and t.title_id not in (
    select s.title_id
    from pubs.dbo.sales AS s
    group by s.title_id, YEAR(s.ord_date)
    having sum(s.qty) >= 80
)
