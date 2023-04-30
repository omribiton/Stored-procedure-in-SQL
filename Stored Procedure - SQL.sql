use [EasyMarket]

----Tar 1 Perfect!

create proc SegmentInBrand @Month tinyint, @Year smallint
AS
--  
select B.*, MF.memberCode, Mf.frequency,MF.totalMoney,S.segmentName,S.minFreq,S.totalMoney as StotalMoney
into #MS
from tblBrand B inner join tblMeasuresFor MF on B.brandCode = MF.brandCode cross join tblSegment S
where MF.mMonth = @Month and MF.mYear = @Year 
order by memberCode, brandCode

---
select ms.*
into #AllStigment
from #MS ms
union 
select ms.brandCode,ms.brandName, ms.memberCode, ms.frequency,ms.totalMoney, N'No Segment',0,0
from #MS ms 

---
select Als.*
into #Mioon
from #AllStigment Als
where frequency>minFreq and totalMoney>StotalMoney
order by memberCode, brandCode

--- 
select brandCode,brandName,segmentName, COUNT(memberCode) as NoOfcustomersInSegment, AVG(totalMoney) AvgIncomePerSegment, AVG(frequency) AvgTotalSennInSegment
from (	select * , ROW_NUMBER() over (partition by brandcode, membercode order by minfreq desc, totalmoney desc) as NumStag
		from #Mioon ) RoniAmir
where NumStag = 1
group by brandCode,brandName,segmentName

---- 
exec SegmentInBrand 11,2020



----tar 1 bouns
create proc GenderInBrand @myear smallint
AS
select * 
from (	select B.brandCode,b.brandName,CM.gender
		from tblClubMember CM inner join tblMeasuresFor MF on CM.memberCode=MF.memberCode
		inner join tblBrand B on B.brandCode = MF.brandCode
		where mYear = @myear) X
pivot( count(gender) for gender in (M,F,O) ) as SidorByGender

---- 
exec GenderInBrand 2020


-----tar 2 bonus

create proc BarndByMonth @myear smallint
AS
select B.brandCode,B.brandName,X.mMonth,X.TotalMoneyInMonth,Y.TotalMoneyInYear,X.FreqInMonth,Y.FreqInyear
from -- 
	(select MF.brandCode,MF.mMonth ,round(sum(MF.totalMoney),2) as TotalMoneyInMonth,SUM(MF.frequency) as FreqInMonth
	from tblMeasuresFor MF
	where Mf.mYear = @myear
	group by MF.brandCode,MF.mMonth) X inner join
--- 
	(select MF.brandCode,round(sum(MF.totalMoney),2) as TotalMoneyInYear,SUM(MF.frequency) as FreqInyear
	from tblMeasuresFor MF
	where Mf.mYear = @myear
	group by MF.brandCode)Y
on X.brandCode = Y.brandCode
inner join tblBrand B on X.brandCode = B.brandCode
order by X.brandCode,mMonth 

---- 
exec BarndByMonth 2020

-----tar 3 bonus
create proc BestMonthInBrand @year smallint
as
select B.brandCode,B.brandName,X.mMonth,X.TotalMoneyInMonth,Y.TotalMoneyInYear,X.FreqInMonth,Y.FreqInyear
into #a
from --
	(select MF.brandCode,MF.mMonth ,round(sum(MF.totalMoney),2)  as TotalMoneyInMonth,SUM(MF.frequency) as FreqInMonth
	from tblMeasuresFor MF
	where Mf.mYear = @year
	group by MF.brandCode,MF.mMonth) X inner join
---
	(select MF.brandCode,round(sum(MF.totalMoney),2) as TotalMoneyInYear,SUM(MF.frequency) as FreqInyear
	from tblMeasuresFor MF
	where Mf.mYear = @year
	group by MF.brandCode)Y
on X.brandCode = Y.brandCode
inner join tblBrand B on X.brandCode = B.brandCode 

select X.brandCode,X.brandName,X.mMonth,X.TotalMoneyInMonth,X.TotalMoneyInYear,X.FreqInMonth,X.FreqInyear
from (select * , ROW_NUMBER() over (partition by brandcode order by TotalMoneyInMonth desc , FreqInMonth desc) as NumBrans
		from #a ) X
where NumBrans = 1

----
exec BestMonth 2020
