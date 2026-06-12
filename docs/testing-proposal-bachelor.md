# Navrh testovania pre bakalarsku pracu

Tento dokument sumarizuje navrh testov pre projekt Scrapoo a zaroven popisuje, co bolo doplnene do automatizovanej testovacej sady. Cielom je mat technicky overitelne testy v kode a sucasne textovy zaklad pre kapitolu o testovani v bakalarskej praci.

## 5.1 Testovanie funkcnosti aplikacie

Funkcnost aplikacie je overovana testami, ktore kontroluju, ci hlavne casti systemu reaguju ocakavanym sposobom:

- root endpoint FastAPI aplikacie vracia identifikacnu odpoved,
- health endpoint vracia stav `ok`,
- zoznam filmov vracia aktualny API tvar s polom `genres`,
- zoznam osob vracia filmografiu a vypocitane pole `film_count`,
- status endpointy pre CSFD a TMDB scraping vracaju konzistentny stav pre neznamy task.

Tieto testy su implementovane v `app/tests/test_api_smoke.py`. Ich prinos pre bakalarsku pracu je v tom, ze dokazuju zakladnu prevadzkyschopnost aplikacie po migracii na FastAPI stack.

## 5.2 Testovanie spravnosti ziskavanych udajov

Spravnost ziskavanych udajov sa testuje bez zavislosti od ziveho CSFD webu. Testy pouzivaju kontrolovane HTML vstupy a overuju, ci parser a nasledna persistencia spravne spracuju:

- nazov filmu,
- rok vydania,
- hodnotenie,
- krajinu,
- zanre,
- reziserov,
- hercov,
- vztahy medzi filmami a osobami.

Doplneny bol aj test pre nekompletne vstupne HTML, kde chyba rating a rok. Tento scenar overuje, ze aplikacia nepadne pri nekompletnych datach a ulozi dostupne informacie. To je dolezite, pretoze realne webove stranky nemusia mat vzdy vsetky udaje.

Relevantne testy su v `app/tests/test_e2e_functional_requirements.py`.

## 5.3 Testovanie REST API

REST API je testovane cez `fastapi.testclient.TestClient`. Doplnena sada kontroluje nielen uspesne odpovede, ale aj chybove a validacne scenare:

- pokus o vytvorenie duplicitneho filmu vrati `409 Conflict`,
- neexistujuca osoba vrati `404 Not Found`,
- neplatne hodnoty scraping requestu vracaju `422 Unprocessable Entity`,
- neplatny zdroj analytiky, napriklad `source=unknown`, vracia `422`.

Tieto testy su dolezite pre bakalarsku pracu, pretoze ukazuju, ze API nie je overovane iba na "happy path", ale aj na nespravne vstupy a okrajove pripady.

## 5.4 E2E testovanie

E2E testy overuju spravanie systemu napriec viacerymi vrstvami:

1. parser spracuje HTML,
2. vysledne payloady sa ulozia do databazy,
3. vytvoria sa domenove vztahy medzi filmami, osobami, krajinami a zanrami,
4. analyticka cast nad ulozenymi datami vypocita grafove metriky.

Existujuci E2E test overuje cely tok od parsovania filmovej stranky az po ulozenie vztahov do databazy. Doplneny bol aj scenar opakovaneho spracovania filmu, ktory kontroluje, ze opakovany import aktualizuje existujuci zaznam namiesto vytvarania duplicit.

Prinos pre bakalarsku pracu: E2E testy dokazuju, ze system nie je iba subor izolovanych funkcii, ale jednotlivé komponenty spolu funguju ako jeden celok.

## 5.5 Testovanie grafovych analyz

Grafove analyzy su klucovou castou projektu, preto boli doplnene testy nad kontrolovanymi datasetmi:

- kompletna trojica hercov, kde kazdy spolupracoval s kazdym,
- prazdny graf bez filmov a hercov,
- jednoduchy retazovy graf troch hercov a dvoch filmov.

Testy overuju metriky ako:

- pocet uzlov,
- pocet hran,
- hustota grafu,
- priemerny stupen,
- velkost najvacsej komponenty,
- priemerne zhlukovanie,
- diameter,
- core number.

Tento typ testov je pre bakalarsku pracu velmi hodnotny, pretoze ukazuje, ze analyticke vystupy nie su iba vizualne zobrazenia, ale maju overitelnu matematicku spravnost na znamych vstupoch.

## 5.6 Vyhodnotenie vykonnosti riesenia

Vykonnost nie je vhodne testovat iba ako striktne unit testy s pevnym casovym limitom, pretoze vysledok zavisi od hardveru, Docker prostredia a zataze systemu. Preto bol doplneny performance smoke test, ktory:

- vytvori maly synteticky dataset,
- odmeria cas persistencie,
- odmeria cas vypoctu grafovej analyzy,
- overi, ze spracovanie prebehne a vrati ocakavane grafove pocty.

Tento test nie je absolutny benchmark, ale sluzi ako zaklad pre vykonnostne vyhodnotenie. V bakalarskej praci sa na jeho zaklade da popisat metodika merania:

- pocet spracovanych filmov,
- pocet vytvorenych osob,
- cas ulozenia dat,
- cas vypoctu grafovej analyzy,
- pocet uzlov a hran vo vyslednom grafe.

Pre formalne vyhodnotenie je vhodne doplnit tabulku s meraniami na viacerych velkostiach datasetu, napriklad 20, 100, 500 a 1000 filmov.

Samostatny benchmark skript je dostupny v `scripts/benchmark_graph_analytics.py`. Predvolene pouziva izolovanu SQLite databazu v pamati, takze nemeni produkcnu ani lokalnu PostgreSQL databazu.

Benchmark nezbiera realne data z CSFD. Namiesto toho generuje synteticke data, aby bolo meranie opakovatelne a nezavisle od dostupnosti externej stranky, sietovej latencie alebo anti-bot ochrany. Pre kazdy film vytvara aj umele osoby: dvoch hercov a jedneho rezisera. Tieto osoby sa ukladaju do tabulky `person` a vztahy medzi filmami a osobami sa ukladaju do tabulky `person_in_film`. Grafova analyza teda pracuje nad realne vytvorenymi databazovymi vztahmi, nie nad mockovanym vysledkom.

Predvolene je dataset redsi, aby benchmark dobehol rychlo. Pre realistickejsie meranie je mozne nastavit viac hercov na film alebo priamo cielovy pocet osob. Aktualny TMDB dataset v lokalnej Docker databaze mal 12. 6. 2026 spolu 10 003 filmov a 193 485 osob. Napriklad pri 10 000 filmoch a priblizne 193 000 osobach:

```bash
docker compose exec -T api python scripts/benchmark_graph_analytics.py \
  --sizes 10000 \
  --runs 1 \
  --actor-strategy unique \
  --directors-per-film 1 \
  --target-people 193000 \
  --markdown
```

Volba `--target-people` funguje s `--actor-strategy unique`. Skript vtedy rozdeli hercov medzi filmy tak, aby vysiel cielovy pocet unikatnych osob. Pri 10 000 filmoch, jednom reziserovi na film a cieli 193 000 osob to znamena priemerne 18,3 herca na film. Tento scenar je vykonovo narocnejsi, pretoze herecka projekcia vytvara omnoho viac hran v grafe.

Priklad spustenia:

```bash
docker compose exec -T api python scripts/benchmark_graph_analytics.py --sizes 20 100 500 --runs 3 --markdown
```

Skript pre kazdu velkost datasetu vygeneruje synteticke filmy a osoby, odmeria cas ulozenia dat a odmeria cas vypoctu hereckej projekcie grafu. Volba `--markdown` vypise sumarizacnu tabulku, ktoru je mozne pouzit ako zaklad pre vyhodnotenie v bakalarskej praci.

Benchmark bol spusteny aj pre vacsie datasety s jednym opakovanim v predvolenom redsom nastaveni:

```bash
docker compose exec -T api python scripts/benchmark_graph_analytics.py --sizes 100 1000 5000 10000 --runs 1 --markdown
```

Namerane hodnoty:

| Films | Runs | Avg persist (s) | Avg analysis (s) | Avg films/s | Avg nodes | Avg edges |
|---:|---:|---:|---:|---:|---:|---:|
| 100 | 1 | 0.4115 | 0.0777 | 242.99 | 101.0 | 100.0 |
| 1000 | 1 | 4.6477 | 3.3501 | 215.16 | 1001.0 | 1000.0 |
| 5000 | 1 | 24.9508 | 77.9582 | 200.39 | 5001.0 | 5000.0 |
| 10000 | 1 | 54.2742 | 396.8718 | 184.25 | 10001.0 | 10000.0 |

Z vysledkov vidno, ze ukladanie dat rastie pomerne rovnomerne s poctom filmov. Pri grafovej analyze je narast vyraznejsi, najma pri vacsich datasetoch. Je to ocakavane, pretoze vypocet hereckej projekcie pracuje s grafovou strukturou a pri vacsom pocte uzlov a hran vykonava narocnejsie sietove metriky. Tieto vysledky je vhodne interpretovat ako benchmark nad syntetickymi datami v SQLite prostredi; pre produkcne meranie by bolo vhodne zopakovat test aj nad PostgreSQL databazou.

Benchmark bol spusteny na macbook pro m1 13inch 8gb RAM (2020):


A. Riedky / kontrolovaný benchmark
Ukazuje, ako sa systém správa pri rastúcom počte filmov, ale s menším počtom unikátnych osôb.
```sh
% docker compose exec -T api python scripts/benchmark_graph_analytics.py \
  --sizes 100 1000 5000 \
  --runs 3 \
  --actors-per-film 19 \
  --directors-per-film 1 \
  --actor-strategy chain \
  --markdown
```

| Films | Runs | Avg actors/film | Directors/film | Strategy | Target people | Avg people | Avg relations | Avg persist (s) | Avg analysis (s) | Avg films/s | Avg nodes | Avg edges |
| ----: | ---: | --------------: | -------------: | -------- | ------------: | ---------: | ------------: | --------------: | ---------------: | ----------: | --------: | --------: |
|   100 |    3 |           19.00 |              1 | chain    |               |      218.0 |        2000.0 |          1.4356 |           0.2380 |       69.66 |     118.0 |    1953.0 |
|  1000 |    3 |           19.00 |              1 | chain    |               |     2018.0 |       20000.0 |         15.2474 |          15.8613 |       65.63 |    1018.0 |   18153.0 |
|  5000 |    3 |           19.00 |              1 | chain    |               |    10018.0 |      100000.0 |         98.1663 |         461.6269 |       50.98 |    5018.0 |   90153.0 |

B. Realistickejší záťažový benchmark
```sh
docker compose exec -T api python scripts/benchmark_graph_analytics.py \
  --sizes 100 500 1000 5000 10000 \
  --runs 2 \
  --actors-per-film 19 \
  --directors-per-film 1 \
  --actor-strategy unique \
  --markdown
```
 
| Films | Runs | Avg actors/film | Directors/film | Strategy | Target people | Avg people | Avg relations | Avg persist (s) | Avg analysis (s) | Avg films/s | Avg nodes | Avg edges |
| ----: | ---: | --------------: | -------------: | -------- | ------------: | ---------: | ------------: | --------------: | ---------------: | ----------: | --------: | --------: |
|   100 |    2 |           19.00 |              1 | unique   |               |     2000.0 |        2000.0 |          2.0346 |           0.2099 |       49.15 |    1900.0 |   17100.0 |
|   500 |    2 |           19.00 |              1 | unique   |               |    10000.0 |       10000.0 |         11.6195 |           1.0146 |       43.03 |    9500.0 |   85500.0 |
|  1000 |    2 |           19.00 |              1 | unique   |               |    20000.0 |       20000.0 |         27.2373 |           1.9927 |       36.71 |   19000.0 |  171000.0 |
|  5000 |    2 |           19.00 |              1 | unique   |               |   100000.0 |      100000.0 |        310.5959 |          12.0103 |       16.10 |   95000.0 |  855000.0 |
| 10000 |    2 |           19.00 |              1 | unique   |               |   200000.0 |      200000.0 |       1423.5887 |          28.0008 |        7.07 |  190000.0 | 1710000.0 |

Ukazuje, čo sa deje, keď počet osôb a hrán narastie podobne ako v tvojej reálnej databáze.

Najviac realistický kompromis by bol podľa mňa pool, lebo reálni herci sa opakujú vo viacerých filmoch.
C. Pool
```sh
% docker compose exec -T api python scripts/benchmark_graph_analytics.py \
  --sizes 100 1000 5000 \
  --runs 3 \
  --actors-per-film 19 \
  --directors-per-film 1 \
  --actor-strategy pool \
  --actor-pool-size 50000 \
  --markdown
```

| Films | Runs | Avg actors/film | Directors/film | Strategy | Target people | Avg people | Avg relations | Avg persist (s) | Avg analysis (s) | Avg films/s | Avg nodes | Avg edges |
| ----: | ---: | --------------: | -------------: | -------- | ------------: | ---------: | ------------: | --------------: | ---------------: | ----------: | --------: | --------: |
|   100 |    1 |           19.00 |              1 | pool     |               |     2000.0 |        2000.0 |          1.7007 |           0.2238 |       58.80 |    1900.0 |   17100.0 |
|  1000 |    1 |           19.00 |              1 | pool     |               |    20000.0 |       20000.0 |         27.2577 |           1.9126 |       36.69 |   19000.0 |  171000.0 |
|  5000 |    1 |           19.00 |              1 | pool     |               |    55000.0 |      100000.0 |        241.3979 |          15.5936 |       20.71 |   50000.0 |  658428.0 |

Opis druhov testov:
1. chain

Toto je default.

--actor-strategy chain
Herci sa medzi susednými filmami prekrývajú. Napríklad film 1 má hercov 1,2,3, film 2 má 2,3,4, film 3 má 3,4,5.

Výsledok:

menej unikátnych osôb,
graf je prepojenejší,
vhodné na rýchlejší benchmark grafovej štruktúry,
nie je veľmi realistické pre veľký filmový dataset.
2. unique

--actor-strategy unique
Každý film má vlastnú sadu hercov.

Výsledok:

veľa unikátnych osôb,
každý film vytvorí samostatnú kliku hercov,
dobré na záťažový test veľkého počtu osôb a hrán,
vhodné, ak chceš simulovať stav typu 10000 filmov -> ~193000 osôb.
Toto je najbližšie k tvojmu aktuálnemu cieľu, ak riešiš veľký počet osôb.

3. pool

--actor-strategy pool --actor-pool-size 5000
Herci sa vyberajú z obmedzeného poolu. Napríklad máš 10 000 filmov, ale iba 5 000 možných hercov, ktorí sa opakovane používajú.

Výsledok:

realistickejšie opakovanie známych hercov,
menej unikátnych osôb než unique,
graf je viac prepojený,
môže lepšie simulovať reálne filmové dáta.
Príklad:

docker compose exec -T api python scripts/benchmark_graph_analytics.py \
  --sizes 100 500 1000 5000 \
  --runs 1 \
  --actors-per-film 19 \
  --directors-per-film 1 \
  --actor-strategy pool \
  --actor-pool-size 20000 \
  --markdown



## Ako spustit testy

Testy sa spustaju cez pripraveny skript:

```bash
docker compose exec -T api sh scripts/test_fastapi_stack.sh
```

Skript spusta:

- `app.tests.test_api_smoke`,
- `app.tests.test_e2e_functional_requirements`.

Tento prikaz je vhodne uviest aj v bakalarskej praci ako sposob reprodukovatelneho overenia implementacie.

## Zhrnutie prinosu pre bakalarsku pracu

Doplnena testovacia sada pomaha pokryt sest oblasti:

- zakladnu funkcnost aplikacie,
- spravnost extrakcie a ulozenia udajov,
- spravanie REST API,
- E2E tok od parsovania po databazu,
- matematicku spravnost grafovych analyz,
- zakladne vykonnostne vyhodnotenie.

V praci sa tym da podporit tvrdenie, ze riesenie bolo overene nielen manualnym pouzitim, ale aj automatizovanou sadou testov, ktora kontroluje funkcne, datove, API, analyticke a vykonnostne aspekty systemu.
