# Grafová analýza údajov získaných z vybraných webových stránok

## Charakteristika riešenia

Predkladaný projekt predstavuje softvérový systém určený na získavanie, ukladanie, sprístupňovanie a analytické
spracovanie filmových údajov. Hlavným aplikačným prípadom je spracovanie informácií o filmoch, hercoch, režiséroch,
žánroch, krajinách pôvodu a vzťahoch medzi osobami a filmami. Získané údaje sú následne interpretované nielen ako
relačné databázové záznamy, ale aj ako grafová štruktúra vhodná na sieťovú analýzu.

Systém je implementovaný ako kontajnerizovaná webová aplikácia pozostávajúca z backendovej API vrstvy, úloh na pozadí,
databázovej vrstvy, analytického modulu a vizualizačného dashboardu. Primárnym zdrojom údajov je webová stránka ČSFD,
pričom aplikácia zároveň obsahuje samostatnú integračnú vetvu pre získavanie filmových údajov zo služby TMDB
(The Movie Database). Údaje z TMDB sú ukladané do oddelenej databázy, aby bolo možné porovnávať výsledky analýz medzi
zdrojmi bez vzájomného miešania dát.

Z pohľadu zadania bakalárskej práce je jadrom riešenia vytvorenie dátového toku od automatizovaného získavania údajov
až po grafovú analýzu vzťahov. Filmové údaje sú prirodzene vhodné na modelovanie grafmi, pretože vzťah medzi hercom a
filmom, režisérom a filmom alebo medzi dvoma spolupracujúcimi osobami je možné formálne vyjadriť pomocou vrcholov a
hrán.

## Ciele aplikácie

Cieľom aplikácie je vytvoriť funkčný prototyp systému, ktorý:

- automatizovane získava údaje o filmoch a osobách z vybraných zdrojov,
- uchováva získané údaje v relačnej databáze,
- umožňuje spúšťať dlhšie trvajúce získavanie údajov ako úlohy na pozadí,
- poskytuje REST API na prístup k dátam a analytickým výsledkom,
- vytvára grafové reprezentácie vzťahov medzi osobami,
- vypočítava základné aj pokročilejšie grafové metriky,
- zobrazuje výsledky v interaktívnom webovom dashboarde,
- umožňuje prepínať analytický zdroj medzi dátami z ČSFD a dátami z TMDB,
- je spustiteľný v lokálnom prostredí pomocou Docker Compose.

## Architektúra systému

Aplikácia je rozdelená na viacero samostatných komponentov. Toto členenie umožňuje oddeliť časovo náročné získavanie
údajov od obsluhy používateľských požiadaviek a zároveň uľahčuje prevádzku systému v kontajnerizovanom prostredí.

Hlavné komponenty sú:

- **FastAPI backend** - poskytuje REST API, registruje databázové pripojenia a sprístupňuje dátové aj analytické
  koncové body.
- **Scrapy scraper** - získava údaje zo stránok ČSFD a extrahuje filmové a osobné atribúty.
- **TMDB klient** - komunikuje s TMDB API a importuje populárne filmy spolu s hereckým obsadením a režisérmi.
- **Celery worker** - vykonáva úlohy na pozadí, napríklad získavanie filmov, obohacovanie osôb alebo import z TMDB.
- **Celery Beat** - zabezpečuje periodické spúšťanie prednastavených úloh.
- **Redis** - slúži ako broker a result backend pre Celery.
- **PostgreSQL databázy** - uchovávajú získané údaje. Projekt používa samostatnú databázu pre ČSFD a samostatnú
  databázu pre TMDB.
- **Streamlit dashboard** - poskytuje používateľské rozhranie na prezeranie štatistík, grafov a sieťových analýz.

Lokálne spustenie je zabezpečené pomocou Docker Compose. Konfigurácia definuje služby `api`, `worker`, `beat`,
`postgres`, `tmdb-postgres`, `redis` a `dashboard`. Backend je dostupný na porte `8000`, dashboard na porte `8501`,
primárna databáza na porte `5432` a databáza TMDB na porte `5433`.

## Zdroje údajov

### ČSFD

Prvým zdrojom údajov je webová stránka ČSFD. Získavanie údajov začína načítaním sitemap súborov zo sitemap indexu.
Používateľ môže pri spustení úlohy určiť, od ktorého sitemap súboru sa má začať, koľko stránok sa má spracovať a aký
maximálny počet filmov sa má získať. URL adresy filmov sú následne rozdelené na menšie dávky, ktoré sú spracované
pomocou Scrapy.

Scraper extrahuje najmä:

- názov filmu,
- originálny názov filmu,
- rok vydania,
- krajinu pôvodu,
- jazyk,
- hodnotenie,
- počet hlasov, ak je dostupný,
- žánre,
- URL adresu filmu,
- režisérov,
- hercov,
- základné záznamy o osobách,
- väzby medzi filmami a osobami.

Pri získavaní filmov sa osoby ukladajú najprv ako základné záznamy. To umožňuje rýchle vytvorenie vzťahov medzi filmami
a osobami bez nutnosti okamžite navštevovať detailnú stránku každej osoby. Samostatná úloha na obohatenie osôb môže
neskôr doplniť ďalšie údaje, napríklad dátum narodenia.

Scrapy používa knižnicu Twisted, ktorej reaktor nie je vhodné opakovane reštartovať v jednom dlho bežiacom procese.
Preto je samotné spustenie scraperu izolované do pomocného procesu. Celery úloha tým pádom pre každú dávku spustí nový
proces, ktorý vykoná získanie údajov a vráti výsledok vo forme JSON dát.

### TMDB

Druhým zdrojom je TMDB API. Aplikácia umožňuje importovať až 30000 najpopulárnejších filmov podľa triedenia TMDB. Pre
každý film sa získavajú detailné údaje spolu s odpoveďou `credits`, ktorá obsahuje obsadenie a členov štábu.

TMDB integrácia je oddelená od ČSFD v troch rovinách:

- používa samostatné konfiguračné premenné `TMDB_API_KEY` alebo `TMDB_ACCESS_TOKEN`,
- rešpektuje samostatný limit požiadaviek voči TMDB API, predvolene 40 požiadaviek za 10 sekúnd,
- ukladá údaje do samostatnej databázy `scrapoo_tmdb`.

Toto oddelenie umožňuje používať rovnaký dátový model a analytické algoritmy, ale zároveň zachovať pôvod dát. V
dashboarde je možné prepínať medzi zdrojmi ČSFD a TMDB.

## Dátový model

Dátový model je relačný a je implementovaný pomocou Tortoise ORM. Hlavné entity sú:

- **Film** - reprezentuje film. Obsahuje názov, originálny názov, jazyk, rok vydania, hodnotenie, počet hlasov a URL.
- **Person** - reprezentuje osobu, napríklad herca alebo režiséra. Obsahuje meno, dátum narodenia, URL a povolanie.
- **Country** - reprezentuje krajinu pôvodu filmu.
- **Genre** - reprezentuje filmový žáner.
- **PersonInFilm** - prepájacia tabuľka medzi filmom a osobou. Uchováva aj rolu osoby vo filme, napríklad `actor` alebo
  `director`.

Vzťah medzi filmom a osobou je najdôležitejším prvkom modelu pre následnú grafovú analýzu. Z relačných údajov je možné
vytvoriť napríklad bipartitný graf filmov a osôb alebo projekčný graf hercov, v ktorom sú dvaja herci spojení hranou,
ak účinkovali v rovnakom filme.

Rovnaký model je použitý pre primárnu databázu aj pre databázu TMDB. Rozdiel medzi zdrojmi teda nie je v štruktúre dát,
ale v databázovom pripojení, z ktorého analytická vrstva číta.

## Backend a API vrstva

Backend je implementovaný pomocou frameworku FastAPI. Aplikácia používa prefix `/api/v1` a poskytuje niekoľko skupín
koncových bodov API:

- **Health koncové body** - kontrola dostupnosti služby.
- **Movies koncové body** - výpis filmov, vytvorenie filmu, spustenie získavania údajov z ČSFD, sledovanie stavu ČSFD úlohy,
  spustenie TMDB importu a sledovanie stavu TMDB úlohy.
- **People koncové body** - výpis osôb, detail osoby, spustenie obohatenia osôb a sledovanie stavu obohacovacej úlohy.
- **Analytics koncové body** - základný prehľad, štatistiky osôb, štatistiky krajín, rozdelenie podľa rokov alebo dekád,
  analýza spoluprác a analýza hereckého projekčného grafu.

Analytické koncové body podporujú parameter `source`, ktorým sa vyberá databázový zdroj:

- `source=csfd` - používa primárnu databázu naplnenú údajmi z ČSFD,
- `source=tmdb` - používa samostatnú databázu naplnenú údajmi z TMDB.

Týmto spôsobom možno rovnaké analytické operácie aplikovať na dva rôzne dátové súbory.

## Spracovanie úloh na pozadí

Dlhšie trvajúce operácie sú spracované pomocou Celery. Tento prístup zabraňuje blokovaniu HTTP požiadaviek a umožňuje
sledovať stav úlohy pomocou jej identifikátora.

Implementované úlohy zahŕňajú:

- periodické naplánovanie štandardného procesu získavania údajov z ČSFD,
- získanie filmov z ČSFD sitemap súborov,
- spracovanie jednotlivých dávok filmových URL adries,
- obohacovanie údajov o osobách,
- import najpopulárnejších filmov z TMDB.

Výsledok úlohy obsahuje nielen počet uložených filmov a osôb, ale aj čas spracovania a rýchlostné metriky. Pri
získavaní údajov z ČSFD sa evidujú aj URL adresy, ktoré sa nepodarilo spracovať alebo z ktorých nevznikol filmový
záznam. Pri TMDB
importe sa evidujú neúspešné detailné požiadavky na konkrétne filmy vrátane TMDB identifikátora, názvu, URL a chybovej
správy. Tieto informácie sú dôležité na ladenie a opätovné spracovanie neúspešných vstupov.

## Grafová analýza

Analytická časť využíva najmä knižnicu NetworkX. Zo vzťahov medzi filmami a osobami sa konštruujú grafy spoluprác.
Základným príkladom je herecký projekčný graf, v ktorom vrcholy predstavujú osoby a hrana medzi dvoma osobami znamená,
že sa objavili v rovnakom filme. Váha hrany vyjadruje počet spoločných filmov.

Aplikácia vypočítava tieto typy metrík:

- počet vrcholov a hrán,
- hustotu grafu,
- priemerný stupeň vrcholu,
- centralitu osôb,
- najsilnejšie spolupráce podľa počtu spoločných filmov,
- veľkosť najväčšej komponenty súvislosti,
- priemernú dĺžku najkratších ciest,
- priemer grafu, ak je výpočet vzhľadom na veľkosť grafu prakticky možný,
- distribúciu stupňov,
- aproximáciu power-law rozdelenia,
- priemerný zhlukovací koeficient a tranzitivitu,
- core-like štruktúru siete,
- komunitnú štruktúru pomocou Leiden algoritmu.

Pri veľkých grafoch môže byť presný výpočet niektorých metrík príliš náročný. Preto aplikácia používa obmedzenia, ako
je maximálny počet vrcholov pre presný výpočet priemeru alebo maximálna veľkosť obsadenia filmu pri projekcii hercov.
Tieto parametre sú dostupné aj v dashboarde.

## Dashboard

Vizualizačná vrstva je implementovaná pomocou Streamlit. Dashboard komunikuje s analytickými koncovými bodmi FastAPI a
zobrazuje výsledky vo forme tabuliek, metrík a interaktívnych grafov.

Dashboard obsahuje sekcie:

- **Overview** - celkový počet filmov a osôb, najproduktívnejší herci a režiséri, najčastejšie krajiny.
- **People** - štatistiky osôb podľa rolí a minimálneho počtu filmov.
- **Countries** - podiel filmov podľa krajín.
- **Releases** - rozdelenie filmov podľa rokov alebo dekád.
- **Network** - prehľad grafu spoluprác a vizualizácia najsilnejších väzieb.
- **Graph Analysis** - detailnejšia analýza hereckého projekčného grafu vrátane komunít, power-law aproximácie,
  zhlukovania, ciest a core štruktúry.

V bočnom paneli sa nachádza prepínač dátového zdroja. Používateľ môže prepnúť medzi ČSFD a TMDB, pričom dashboard
automaticky posiela príslušný parameter `source` do analytických koncových bodov.

Na vizualizácie sú použité knižnice Plotly a PyVis. Plotly sa používa na stĺpcové, koláčové a bodové grafy, zatiaľ čo
PyVis slúži na interaktívne zobrazenie sieťových grafov.

## Použité technológie

Implementácia využíva kombináciu technológií určených na webový backend, spracovanie úloh, databázovú perzistenciu,
analytické výpočty a vizualizáciu. Hlavné použité technológie sú:

- **Python** - hlavný programovací jazyk aplikácie,
- **FastAPI** - implementácia REST API,
- **Tortoise ORM** - objektovo-relačné mapovanie nad PostgreSQL,
- **PostgreSQL** - relačné databázy pre perzistenciu údajov,
- **Scrapy** - extrakcia údajov z webových stránok,
- **Celery** - asynchrónne spracovanie úloh,
- **Redis** - fronta správ a backend výsledkov pre Celery,
- **NetworkX** - konštrukcia a analýza grafov,
- **NumPy** - numerické výpočty pri vybraných analytických metrikách,
- **python-igraph** - výpočet komunitnej štruktúry pomocou Leiden algoritmu,
- **Pandas** - tabuľkové spracovanie údajov v dashboarde,
- **Plotly** - tvorba interaktívnych grafov,
- **PyVis** - vizualizácia sieťových grafov,
- **Streamlit** - analytický webový dashboard,
- **Docker Compose** - lokálne spustenie a prepojenie služieb.

## Prevádzka a konfigurácia

Projekt je pripravený na lokálne spustenie pomocou Docker Compose. Konfigurácia vytvára všetky potrebné služby:
backend, worker, plánovač, Redis, dve PostgreSQL databázy a dashboard.

Dôležité konfiguračné oblasti sú:

- databázové pripojenie pre ČSFD (`DATABASE_URL`),
- databázové pripojenie pre TMDB (`TMDB_DATABASE_URL`),
- prístupové údaje k TMDB API (`TMDB_API_KEY` alebo `TMDB_ACCESS_TOKEN`),
- limity požiadaviek voči TMDB API,
- veľkosť dávok pri získavaní údajov z ČSFD,
- počet paralelných dávok,
- interval a rozsah periodického procesu získavania údajov.

Konfigurácia je načítaná z premenných prostredia alebo zo súboru `.env`. Citlivé údaje, najmä TMDB API kľúč, by mali
ostať mimo verzionovaného zdrojového kódu.

## Testovanie a overenie

Projekt obsahuje základné automatizované testy pre FastAPI vrstvu a sitemap collector. Testy overujú napríklad
dostupnosť koreňového koncového bodu, health koncový bod, tvar odpovede pri zozname filmov a osôb a správanie stavových
koncových bodov pre neznáme Celery úlohy.

Pre lokálne overenie sa používa príkaz:

```bash
docker compose exec -T api sh scripts/test_fastapi_stack.sh
```

Okrem automatizovaných testov je možné prakticky overiť aj:

- spustenie krátkej úlohy získavania údajov z ČSFD,
- spustenie krátkej TMDB import úlohy,
- kontrolu uložených záznamov v databáze,
- prepínanie zdroja v dashboarde,
- odpovede analytických koncových bodov pre `source=csfd` aj `source=tmdb`.

## Prínos riešenia

Riešenie ukazuje kompletný postup od získania dát z externých zdrojov až po ich grafovú interpretáciu. Prínosom je
najmä:

- praktická implementácia dátového pipeline pre filmové údaje,
- oddelenie rýchleho získavania filmov a pomalšieho obohacovania osôb,
- možnosť porovnať dva dátové zdroje na rovnakom dátovom modeli,
- využitie grafových metrík na analýzu vzťahov medzi osobami,
- interaktívna vizualizácia výsledkov bez potreby samostatnej frontendovej aplikácie,
- kontajnerizované prostredie vhodné na reprodukovateľné spustenie.

## Obmedzenia a možnosti ďalšieho rozvoja

Aktuálne riešenie predstavuje funkčný prototyp, ktorý však má viaceré prirodzené obmedzenia. Kvalita údajov závisí od
dostupnosti a štruktúry externých zdrojov. Pri ČSFD môže zmena HTML štruktúry stránky vyžadovať úpravu scraperu. Pri
TMDB je potrebné rešpektovať API limity a pracovať s platným API kľúčom alebo access tokenom.

Možné rozšírenia zahŕňajú:

- robustnejšie opakovanie neúspešných URL adries,
- samostatný dátový model pre pôvod zdroja pri zlučovaní dát,
- rozšírenie schémy o ďalšie atribúty osôb a filmov,
- export analytických výsledkov,
- perzistentné ukladanie analytických snapshotov,
- detailnejšie porovnanie grafových vlastností medzi ČSFD a TMDB,
- doplnenie používateľského rozhrania na spúšťanie importov priamo z dashboardu.

## Súvis s bakalárskou prácou

Aplikácia je vhodným podkladom pre bakalársku prácu zameranú na získavanie údajov z webových stránok a ich grafovú
analýzu. Spája viacero oblastí softvérového inžinierstva: extrakciu webových údajov, návrh databázového modelu, asynchrónne
spracovanie úloh, návrh REST API, kontajnerizáciu, sieťovú analýzu a vizualizáciu výsledkov.

Z metodického hľadiska projekt umožňuje opísať celý životný cyklus dát: výber zdroja, získanie dát, čistenie a
normalizáciu, uloženie do databázy, transformáciu do grafu, výpočet metrík a interpretáciu výsledkov. Takýto postup
zodpovedá charakteru praktickej bakalárskej práce na Fakulte elektrotechniky a informatiky STU, kde je dôraz kladený
na návrh, implementáciu, overenie a zhodnotenie technického riešenia.
