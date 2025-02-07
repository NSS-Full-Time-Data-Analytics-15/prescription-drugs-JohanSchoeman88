select count(distinct drug_name)
from drug;

select *
from prescriber

---question 1

select npi, prescription.total_claim_count, nppes_provider_last_org_name
from prescriber
inner join prescription using(npi)
order by total_claim_count desc;

--question 1.b

select prescriber.nppes_provider_last_org_name,
prescriber.nppes_provider_first_name,
prescriber.specialty_description,
prescription.total_claim_count
from prescription
inner join prescriber using(npi)
order by total_claim_count desc;


--question 2

select prescriber.specialty_description, count(distinct prescription.total_claim_count) as distinct_claim_count
from prescription
inner join prescriber using(npi)
group by specialty_description
order by distinct_claim_count desc;

--question 2b

select prescriber.specialty_description, count(prescription.total_claim_count) as total_claim_count,
COUNT(CASE WHEN drug.opioid_drug_flag = 'Y' OR drug.long_acting_opioid_drug_flag = 'Y' THEN 1 END) AS opioid_count
from prescription
inner join prescriber using(npi)
inner join drug on drug.drug_name = prescription.drug_name
group by specialty_description
order by opioid_count desc;


----question 2c challenge

SELECT prescriber.specialty_description
FROM prescriber
LEFT JOIN prescription ON prescriber.npi = prescription.npi
WHERE prescription.npi IS NULL
GROUP BY prescriber.specialty_description;

--question 3
---single most expensive

select max(prescription.total_drug_cost) as max_cost_per, drug.generic_name
from drug
inner join prescription using(drug_name)
group by drug.generic_name
order by max_cost_per desc;

--total cost

select sum(prescription.total_drug_cost) as total_cost, drug.generic_name
from drug
inner join prescription using(drug_name)
group by drug.generic_name
order by total_cost desc;

--question 3.b

SELECT drug.generic_name, 
       ROUND(SUM(prescription.total_drug_cost) / SUM(prescription.total_day_supply * prescription.total_30_day_fill_count), 2) AS cost_per_day
from drug
inner join prescription using(drug_name)
group by drug.generic_name
order by cost_per_day desc;

---question 4
select *
from drug;
select drug_name,
	case 
		when drug.opioid_drug_flag = 'Y' then 'opioid'
		when drug.antibiotic_drug_flag = 'Y' then 'antibiotic'
		else 'neither'
	end as drug_type
from drug;


--question 4 b

select
CASE when drug.opioid_drug_flag = 'Y' then 'opioid'
when drug.antibiotic_drug_flag = 'Y' then 'antibiotic'
else 'neither' end AS drug_type,
CAST(sum(prescription.total_drug_cost) AS money) AS total_cost
from drug
inner join prescription using(drug_name)
group by drug_type
order by total_cost desc;

--question 5
select count(*) as cbsa_tn
from cbsa
where cbsaname ilike '%TN%';

--question 5b
select cbsa.cbsaname, sum(population.population) as total_population
from cbsa
inner join population using(fipscounty)
group by cbsa.cbsaname
order by total_population desc; 
--highest

select cbsa.cbsaname, sum(population.population) as total_population
from cbsa
inner join population using(fipscounty)
group by cbsa.cbsaname
order by total_population asc;
--lowest


--question 5c
select *
from fips_county;

SELECT fips_county.county, population.population
from population
JOIN fips_county ON population.fipscounty = fips_county.fipscounty
left join cbsa ON population.fipscounty = cbsa.fipscounty
where cbsa.fipscounty IS NULL
order by population.population desc;


--question 6

select drug_name, total_claim_count
from prescription
where total_claim_count >= 3000
order by total_claim_count desc;

--question 6b
select *
from drug;

select drug_name, total_claim_count, drug.opioid_drug_flag
from prescription
inner join drug using(drug_name)
where total_claim_count >= 3000
order by total_claim_count desc;

--question 6c
select *
from prescriber;

select drug_name,
	total_claim_count,
	drug.opioid_drug_flag,
	prescriber.nppes_provider_last_org_name,
	prescriber.nppes_provider_first_name
from prescription
inner join drug using(drug_name)
inner join prescriber using(npi)
where total_claim_count >= 3000
order by total_claim_count desc;


---question 7
SELECT prescriber.npi, drug.drug_name,
	specialty_description, prescriber.nppes_provider_city, drug.opioid_drug_flag
from prescription
inner join drug on prescription.drug_name = drug.drug_name
inner join prescriber on prescriber.npi = prescription.npi
where prescriber.specialty_description = 'Pain Management'
  AND prescriber.nppes_provider_city = 'NASHVILLE'
  and drug.opioid_drug_flag = 'Y';


  --question 7b

SELECT prescriber.npi, drug.drug_name, 
       COALESCE(sum(prescription.total_claim_count), 0) AS total_claim_count
FROM prescriber
LEFT join prescription on prescriber.npi = prescription.npi
                        and prescriber.npi = prescription.npi
LEFT JOIN drug on prescription.drug_name = drug.drug_name
GROUP BY prescriber.npi, drug.drug_name
ORDER BY total_claim_count asc;


-- GROUPING SETS QUESTIONS

--question 1
select prescriber.specialty_description, sum(prescription.total_claim_count) as total_claims
from prescriber
inner join prescription using(npi)
where prescriber.specialty_description in ('Pain Management','Interventional Pain Management')
group by prescriber.specialty_description;


--question 2
select prescriber.specialty_description, 
sum(prescription.total_claim_count) AS total_claims
from prescriber
INNER join prescription USING(npi)
where prescriber.specialty_description IN ('Pain Management', 'Interventional Pain Management')
group by prescriber.specialty_description
UNION
SELECT 'Total' AS specialty_description, 
       SUM(prescription.total_claim_count) AS total_claims
FROM prescriber
INNER JOIN prescription USING(npi)
WHERE prescriber.specialty_description IN ('Pain Management', 'Interventional Pain Management');


--questions from BONUS README.
select npi
from prescriber
left join prescription using(npi)
where prescription.npi is null;

question 2a

select drug.generic_name, specialty_description, sum(prescription.total_claim_count) as total_scripts
from prescriber
inner join prescription using(npi)
inner join drug on drug.drug_name = prescription.drug_name
where specialty_description = 'Family Practice'
group by drug.generic_name, specialty_description
order by total_scripts desc; --- can limit by 5 if wanted 

---question 2b

select drug.generic_name, specialty_description, sum(prescription.total_claim_count) as total_scripts
from prescriber
inner join prescription using(npi)
inner join drug on drug.drug_name = prescription.drug_name
where specialty_description = 'Cardiology'
group by drug.generic_name, specialty_description
order by total_scripts desc; --- can limit by 5 if wanted 

--question 2c

with cardiology_drugs AS (
select drug.generic_name, 
sum(prescription.total_claim_count) AS total_scripts
from prescribe	r
inner join prescription USING(npi)
inner join drug ON drug.drug_name = prescription.drug_name
where prescriber.specialty_description = 'Cardiology'
group by drug.generic_name
),
family_practice_drugs AS (
select drug.generic_name,  sum(prescription.total_claim_count) AS total_scripts
from prescriber
inner join prescription using(npi)
inner join drug on drug.drug_name = prescription.drug_name
where prescriber.specialty_description = 'Family Practice'
group by drug.generic_name
)
select c.generic_name, c.total_scripts AS cardiology_total_scripts, 
    f.total_scripts AS family_practice_total_scripts
from cardiology_drugs as c
inner join family_practice_drugs as f ON c.generic_name = f.generic_name
order by c.total_scripts desc;

--question 3
