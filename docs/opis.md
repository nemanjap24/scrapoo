 # Grafová analýza údajov získaných z vybraných webových stránok

  ## Charakteristika projektu

  Projekt sa zaoberá získavaním, ukladaním, spracovaním a analýzou štruktúrovaných údajov z filmovej webovej stránky ČSFD. Aplikácia je navrhnutá ako systém, ktorý dokáže automatizovane
  získavať údaje o filmoch, tvorcoch a ich vzájomných vzťahoch, ukladať ich do databázy a následne nad nimi vykonávať analytické a grafové výpočty.

  Hlavnou myšlienkou projektu je reprezentovať filmové údaje nielen ako klasické databázové záznamy, ale aj ako grafové štruktúry. V takomto grafe môžu byť vrcholmi napríklad osoby, filmy
  alebo krajiny a hranami ich vzťahy, napríklad účasť herca vo filme, réžia filmu alebo spolupráca viacerých tvorcov na rovnakom diele.

  ## Funkcionalita aplikácie

  Aplikácia umožňuje:

  - získavať URL adresy filmov zo sitemap súborov webovej stránky,
  - automatizovane scrapovať detailné stránky filmov,
  - získavať informácie o filmoch, tvorcoch, hercoch, režiséroch, žánroch a krajinách,
  - ukladať získané údaje do relačnej databázy,
  - priebežne obohacovať údaje o osobách, napríklad o dátum narodenia,
  - poskytovať údaje cez REST API,
  - analyzovať uložené dáta pomocou štatistických a grafových metrík,
  - zobrazovať výsledky analýzy v interaktívnom dashboarde.

  ## Získavané údaje

  Zo stránky ČSFD aplikácia získava najmä:

  - názov filmu,
  - originálny názov filmu,
  - rok vydania,
  - krajinu pôvodu,
  - žánre,
  - hodnotenie,
  - URL adresu filmu,
  - režisérov,
  - hercov,
  - základné údaje o osobách,
  - väzby medzi filmami a osobami.

  Tieto údaje sú následne uložené v databáze v štruktúrovanej forme, čo umožňuje ich ďalšie vyhľadávanie, filtrovanie a analýzu.

  ## Dátový model

  Projekt používa relačný databázový model. Hlavné entity sú:

  - `Film` - reprezentuje filmový záznam,
  - `Person` - reprezentuje osobu, napríklad herca alebo režiséra,
  - `Country` - reprezentuje krajinu pôvodu filmu,
  - `Genre` - reprezentuje filmový žáner,
  - `PersonInFilm` - prepájacia entita medzi filmom a osobou, ktorá zároveň uchováva rolu osoby vo filme,
  - `MovieLink` - pomocná entita pre evidenciu filmových URL adries.

  Vzťah medzi filmami a osobami je základom pre grafovú analýzu. Napríklad ak dvaja herci účinkovali v rovnakom filme, aplikácia ich môže prepojiť hranou v grafe spoluprác.

  ## Grafová analýza

  Aplikácia dokáže vytvárať a analyzovať grafové štruktúry pomocou knižnice `NetworkX`.

  Implementované sú najmä tieto typy analýz:

  - graf spoluprác medzi osobami,
  - herecký projekčný graf, kde sú herci prepojení, ak hrali v rovnakom filme,
  - výpočet počtu vrcholov a hrán,
  - hustota grafu,
  - priemerný stupeň vrcholu,
  - centralita osôb v grafe,
  - najsilnejšie spolupráce podľa počtu spoločných filmov,
  - najväčšia komponenta súvislosti,
  - priemerná dĺžka najkratších ciest,
  - priemer grafu,
  - distribúcia stupňov,
  - aproximácia power-law rozdelenia,
  - zhlukovací koeficient,
  - core-like štruktúra siete.

  Tieto metriky umožňujú skúmať vlastnosti filmovej siete, napríklad ktoré osoby sú najviac prepojené, ktoré spolupráce sú najčastejšie alebo či má sieť znaky typické pre reálne sociálne
  grafy.

  ## API vrstva

  Backend aplikácie je implementovaný pomocou frameworku `FastAPI`. API poskytuje endpointy na prístup k filmom, osobám, scrapovacím úlohám a analytickým výsledkom.

  Príklady dostupných funkcionalít cez API:

  - zoznam filmov,
  - zoznam osôb,
  - spustenie scrapovania filmov,
  - sledovanie stavu scrapovacej úlohy,
  - spustenie obohatenia údajov o osobách,
  - prehľad základných metrík,
  - štatistiky podľa krajín,
  - štatistiky podľa rokov alebo dekád vydania,
  - analýza spoluprác,
  - analýza hereckého projekčného grafu.

  ## Spracovanie úloh na pozadí

  Scrapovanie a obohacovanie údajov je riešené ako asynchrónne spracovanie na pozadí pomocou `Celery`.

  Používateľ alebo plánovač môže spustiť scrapovaciu úlohu, ktorá sa zaradí do fronty. Worker následne spracuje sitemap súbory, rozdelí URL adresy filmov na menšie dávky, spustí scraper a
  výsledky uloží do databázy.

  Na plánované spúšťanie úloh sa používa `Celery Beat`.

  ## Dashboard

  Projekt obsahuje aj vizualizačnú časť vytvorenú pomocou `Streamlit`.

  Dashboard zobrazuje:

  - celkový počet filmov a osôb,
  - najproduktívnejších hercov a režisérov,
  - rozdelenie filmov podľa krajín,
  - rozdelenie filmov podľa rokov alebo dekád,
  - graf spoluprác medzi osobami,
  - podrobnejšie grafové metriky hereckej siete.

  Na vizualizácie sa používajú najmä knižnice `Plotly` a `PyVis`.

  ## Použité technológie

  Projekt používa tieto hlavné technológie:

  - `Python` - hlavný programovací jazyk,
  - `FastAPI` - backendové REST API,
  - `Scrapy` - získavanie údajov z webových stránok,
  - `Celery` - spracovanie dlhšie trvajúcich úloh na pozadí,
  - `Celery Beat` - plánované spúšťanie scrapovacích úloh,
  - `Redis` - broker a result backend pre Celery,
  - `PostgreSQL` - relačná databáza na ukladanie získaných údajov,
  - `Tortoise ORM` - objektovo-relačné mapovanie pre prácu s databázou,
  - `NetworkX` - tvorba a analýza grafových štruktúr,
  - `NumPy` - pomocné numerické výpočty,
  - `Pandas` - spracovanie dát v dashboarde,
  - `Plotly` - tvorba grafov a vizualizácií,
  - `PyVis` - interaktívna vizualizácia sieťových grafov,
  - `Streamlit` - webový analytický dashboard,
  - `Docker` a `Docker Compose` - kontajnerizácia a lokálne spúšťanie celej aplikácie,
  - `Uvicorn` - ASGI server pre FastAPI aplikáciu.

  ## Architektúra riešenia

  Aplikácia je rozdelená na viacero častí:

  - backend API,
  - scraper,
  - worker pre úlohy na pozadí,
  - plánovač periodických úloh,
  - databázu,
  - Redis frontu,
  - analytický dashboard.

  Takéto rozdelenie umožňuje oddeliť získavanie dát, ich ukladanie, analýzu a vizualizáciu. Zároveň je možné spúšťať časovo náročné operácie mimo hlavného API procesu, čo zlepšuje stabilitu a
  použiteľnosť systému.

  ## Súvis so zadaním bakalárskej práce

  Projekt napĺňa zadanie bakalárskej práce tým, že rieši problematiku získavania štruktúrovaných údajov z webových stránok na konkrétnej doméne filmových dát. Aplikácia získava údaje z
  vybranej webovej stránky, ukladá ich do databázy, poskytuje ich cez API a umožňuje ich analyzovať.

  Dôležitou časťou riešenia je grafová reprezentácia údajov. Vzťahy medzi filmami, hercami a režisérmi sú prirodzene modelovateľné ako graf, čo umožňuje aplikovať metódy sieťovej analýzy a
  získať dodatočné poznatky o štruktúre filmovej databázy.