/* Buongiorno.
   
   Inizialmente non sapevo bene come affrontare questo test perché non avevo idea di che dati tirar fuori. 
   Proprio per questo alla fine mi son lasciato andare cercando di farmi delle domande proprio come 
   nell'esercitazione finale proposta dal corso SQL.
   Spero quindi che le seguenti query siano sufficenti. 
   
   Ci tengo a fare un'ulteriore approfondimento sulla strana indentazione che ho dato a questo file. L'ho fatto per
   dare una sorta di ordine alle domande che mi sono posto. Infatti le domande indentate fanno (nel mio personale 
   schema mentale) riferimento alla domanda principale (non indentata). Sono consapevole che non è necessario ma 
   lo trovavo più ordinato e sensato. */

-- tutte le domande che mi faccio avendo questi dataset sono:

-- qual'è la percentuale di "verde" che ogni paese ha? Nome, dato
select w.country_name, w.forested_area from world_dataset as w

	-- quale tra questi è il più "verde"? Nome, dato
	select w.country_name, w.forested_area from world_dataset as w
	where w.forested_area is not null
	order by w.forested_area desc
	limit 1
	
	-- quale invece il meno? nome, dato
	with minimo as (select min(w.forested_area) as min_ from world_dataset as w)
	select w.country_name, w.forested_area from world_dataset as w
	where w.forested_area is not null and w.forested_area = (select min_ from minimo)
	order by w.forested_area -- procedimento complicato lo so, ma volevo dinamicità.

-- Quanti sono i paesi che cominciano con la lettera "S"? Tutto il record
select count(*) from world_dataset as w
where w.country_name like 'S%'

-- Quali sono i 10 paesi con un tasso di mortalità infantile più alto? Nome, dato
select w.country_name, w.infant_mortality_1000 from world_dataset as w
where w.infant_mortality_1000 is not null
order by w.infant_mortality_1000 desc
limit 10

	-- Quali invece i 10 con il più basso? Nome, dato
	select w.country_name, w.infant_mortality_1000 from world_dataset as w
	where w.infant_mortality_1000 is not null
	order by w.infant_mortality_1000 
	limit 10

-- Qali sono i 5 paesi con le aspettative di vita più basse? Nome, dato
select w.country_name, w.life_expectancy from world_dataset as w
order by w.life_expectancy 
limit 5

	-- Esiste un riscontro tra questi 5 paesi sopracitati e le regioni di origine dei migranti dispersi?
	with country_bad_LE as (select w.country_name, w.life_expectancy from world_dataset as w
							order by w.life_expectancy limit 5)
	select c.country_name, c.life_expectancy, m.incident_type, m.incident_year from country_bad_LE as c
	join world_missing_migrants_dataset as m
	on m.country_of_origin like '%'||c.country_name||'%'
	
-- Quali sono stati i 5 casi peggiori di migranti dispersi? Tutto il record
select * from world_missing_migrants_dataset as m
where m.number_of_dead is not null
order by m.number_of_dead desc
limit 5

	-- Qunat'è il totale dei morti, dispersi, morti e dispersi, sopravvissuti, donne, bambini e uomini? Dati
	select sum(m.number_of_dead) as total_death, sum(m.min_estimate_num_of_missing) as total_missing_estimate, 
		   sum(m.total_num_of_dead_and_missingint) as total_death_and_missing, sum(m.num_of_survivors) as total_survivors,
		   sum(m.number_of_females) as total_females, sum(m.number_of_children) as total_childrens,
		   sum(m.number_of_males) as total_males
	from world_missing_migrants_dataset as m
	
	-- Qual'è la media dei sopracitati all'anno? Dati
	select round(avg(m.number_of_dead),2) as total_death, round(avg(m.min_estimate_num_of_missing),2) as total_missing_estimate, 
		   round(avg(m.total_num_of_dead_and_missingint),2) as total_death_and_missing, round(avg(m.num_of_survivors),2) as total_survivors,
		   round(avg(m.number_of_females),2) as total_females, round(avg(m.number_of_children),2) as total_childrens,
		   round(avg(m.number_of_males),2) as total_males
	from world_missing_migrants_dataset as m -- sono conspevole della lunghezza della query ma volevo il round a tutit i costi
																	 
	-- Qual'è la media mobile (D2) dei morti dal 2020 al 2023? Anno, dato
	select m.incident_year, round(avg(m.number_of_dead) over (order by m.incident_year rows between 1 preceding and current row),2)
	from world_missing_migrants_dataset as m
	where incident_year >= 2020
	
-- Quali sono invece tutti quelli accaduti nel mediterraneo? Tutto il record
select * from world_missing_migrants_dataset as m
where m.region_of_incident like '%Mediterranean%'
order by m.incident_year

	-- Quanti sono? Dato
	select count(*) as totali_nel_mediterraneo from world_missing_migrants_dataset as m
	where m.region_of_incident like '%Mediterranean%'
	
	-- Qual'è il numero di morti fin'ora registrato? Dato
	select sum(m.number_of_dead) as morti_totali_nel_mediterraneo from world_missing_migrants_dataset as m
	where m.region_of_incident like '%Mediterranean%'
	
	-- Qual'è la media dei sopracitati? Dato
	select round(avg(m.number_of_dead),2) as morti_media_nel_mediterraneo from world_missing_migrants_dataset as m
	where m.region_of_incident like '%Mediterranean%'
	
-- Quali sono le 3 cause di morte più frequenti? Dato
with ordine_delle_cause as (
	select m.cause_of_death, count(*) as casi from world_missing_migrants_dataset as m
	group by m.cause_of_death
	order by casi desc)
select * from ordine_delle_cause limit 3

-- Quali sono invece i 3 paesi d'origine più frequenti da dove i migranti partono? Dato
select m.country_of_origin, count(*) as viaggi_contati from world_missing_migrants_dataset as m
group by m.country_of_origin
order by viaggi_contati desc
limit 3

	-- Che tasso di fertilità, mortalità infatile e materna, aspettative di vita hanno i sopracitati? Dati
	select m.country_of_origin, count(*) as viaggi_contati, w.fertility_rate_avg, 
		w.infant_mortality_1000, w.maternal_mortality_ratio_100000, w.life_expectancy
	from world_missing_migrants_dataset as m
	full join world_dataset as w on m.country_of_origin = w.country_name -- ho usato il full join perché se no mi prendeva un paese non citato in precedenza.
	group by m.country_of_origin, w.fertility_rate_avg, w.infant_mortality_1000, 
			 w.maternal_mortality_ratio_100000, w.life_expectancy
	order by viaggi_contati desc
	limit 3
	
-- Quali sono i 5 paesi che hanno più personale sanitario? Nome e dato
select w.country_name, w.physicians_per_thousent from world_dataset as w
where w.physicians_per_thousent is not null
order by w.physicians_per_thousent desc
limit 5

	-- Quali sono i suoi dati correlati alla vitalità? Nome dati
	select w.country_name, w.physicians_per_thousent, w.birth_rate, w.life_expectancy,
		   w.fertility_rate_avg, w.infant_mortality_1000, w.maternal_mortality_ratio_100000
	from world_dataset as w
	where w.physicians_per_thousent is not null
	order by w.physicians_per_thousent desc
	limit 5
	
-- Quali sono i 10 paesi più ricchi? Tutto il record
select * from world_dataset
where gdp_$ is not null
order by gdp_$ desc
limit 10

	-- Che dati legati all'utilizzo energetico hanno? Nome, PIL, dati enegetici ritenuti rilevanti (ultimo anno, il più vicino al 2023)
	with top_10_country as (select w.country_name, w.gdp_$ from world_dataset as w
						   where w.gdp_$ is not null order by w.gdp_$ desc limit 10)
	select t.*, e.electricity_from_fossil_fuels_twh as e_from_fossil_twh,
		e.electricity_from_nuclear_twh as e_from_nuclear_twh,
		e.electricity_from_renewables_twh as e_from_renewables_twh
	from top_10_country as t
	join global_data_sustainable_energy as e -- south korea non esiste nel dataset riguardante l'energia
	on t.country_name = e.entity
	where e.year = 2020
	order by t.gdp_$ desc
	
-- Quali sono i 10 più poveri? Tutto il record
select * from world_dataset
where gdp_$ is not null
order by gdp_$ 
limit 10

	-- Che dati legati all'utilizzo energetico hanno? Nome, PIL, dati enegetici
	with top_10_country as (select w.country_name, w.gdp_$ from world_dataset as w
						   where w.gdp_$ is not null order by w.gdp_$ limit 10)
	select t.*, e.electricity_from_fossil_fuels_twh as e_from_fossil_twh,
		e.electricity_from_nuclear_twh as e_from_nuclear_twh,
		e.electricity_from_renewables_twh as e_from_renewables_twh
	from top_10_country as t
	join global_data_sustainable_energy as e -- alcuni non esistono nel dataset riguardante l'energia
	on t.country_name = e.entity
	where e.year = 2020
	order by t.gdp_$ 

/* Ci tengo a fare una precisazione prima delle due query successive.

   Le domande che mi sono fatto per avere degli spunti per scrivere le query non le ho pensate con lo scopo preciso di usare 
   un tipo di clausola o un'altra. Perciò ho cercato di fare del mio meglio per ottenere i dati originariamente auto-richiesti.
   
   In questo caso l'output è da prendere con le pinze, perchè il calcolo che ho fatto per valutare il comportamento dei paesi
   riguardo all'energia utilizzata è di gran lunga approssimativo e frutto di un ragionamento fatto senza aver avuto esperienze 
   passate nell'analisi dei dati. Quindi, probabilmente è anche sbagliato. Ho scelto di lasciare comunque le query perché ritengo
   buono il loro svuiluppo.
   
   Infatti si può notale nella prima query qua sotto che le nazioni migliori sono prime perchè sono piccole e consumano poca energia. 
   Il modo che ho scelto per valutare le nazioni è questo (non me ne veniva in mente un'altro):
   	- ho creato un punteggio per l'anno 2000(first_poin) e 2020(last_poin) sottraendo il dato legato all'energia rinnovabile utilizzata 
	  a quello dell'energia fossile.
	- Successivamente ho sottratto il secondo punteggio al primo ed ho ottenuto un valore.
	- I paesi che hanno il valore più basso risultano le più votate al cambiamento energetico verso l'energia rinnovabile.
	
	Sono certo che non è il modo giusto per vedere quali sono i paesi migliori o peggiori. */

-- Quali sono i 10 paesi (con alto ISU) che a livello enegetico si stanno muovendo meglio? Tutto il record
with first_record as (
	select entity,
	abs(electricity_from_fossil_fuels_twh - electricity_from_renewables_twh) as first_point
	from global_data_sustainable_energy
	where year = 2000),
	last_record as (
	select entity,
	abs(electricity_from_fossil_fuels_twh - electricity_from_renewables_twh) as last_point
	from global_data_sustainable_energy
	where year = 2020)
select e.entity, f.first_point, l.last_point,
	   abs(f.first_point - l.last_point) as final_point
from global_data_sustainable_energy as e
inner join first_record as f on e.entity = f.entity
inner join last_record as l on e.entity = l.entity
inner join high_ISU as h on e.entity = h.country
group by e.entity, f.first_point, l.last_point
order by final_point 
limit 10

-- Quali sono i 10 paesi (con alto ISU) che a livello enegetico si stanno muovendo peggio? Tutto il record
with first_record as (
	select entity,
	abs(electricity_from_fossil_fuels_twh - electricity_from_renewables_twh) as first_point
	from global_data_sustainable_energy
	where year = 2000),
	last_record as (
	select entity,
	abs(electricity_from_fossil_fuels_twh - electricity_from_renewables_twh) as last_point
	from global_data_sustainable_energy
	where year = 2020)
select e.entity, f.first_point, l.last_point,
	   abs(f.first_point - l.last_point) as final_point
from global_data_sustainable_energy as e
inner join first_record as f on e.entity = f.entity
inner join last_record as l on e.entity = l.entity
inner join high_ISU as h on e.entity = h.country
group by e.entity, f.first_point, l.last_point
order by final_point desc
limit 10