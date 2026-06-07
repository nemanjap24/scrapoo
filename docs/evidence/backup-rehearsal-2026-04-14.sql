--
-- PostgreSQL database dump
--

\restrict M7sEk77dTDMdVbTDGP6TXH3GDJE7yO9wBP15oR43rq804v6kouRj9MkW4kLffx5

-- Dumped from database version 15.16
-- Dumped by pg_dump version 15.16

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: country; Type: TABLE; Schema: public; Owner: scrapoo
--

CREATE TABLE public.country (
    id integer NOT NULL,
    name character varying(50)
);


ALTER TABLE public.country OWNER TO scrapoo;

--
-- Name: country_id_seq; Type: SEQUENCE; Schema: public; Owner: scrapoo
--

CREATE SEQUENCE public.country_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.country_id_seq OWNER TO scrapoo;

--
-- Name: country_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: scrapoo
--

ALTER SEQUENCE public.country_id_seq OWNED BY public.country.id;


--
-- Name: film; Type: TABLE; Schema: public; Owner: scrapoo
--

CREATE TABLE public.film (
    id integer NOT NULL,
    title character varying(150) NOT NULL,
    original_title character varying(150),
    language character varying(50),
    release_year integer,
    rating double precision,
    num_votes integer,
    url character varying(100),
    country_id integer
);


ALTER TABLE public.film OWNER TO scrapoo;

--
-- Name: film_genre; Type: TABLE; Schema: public; Owner: scrapoo
--

CREATE TABLE public.film_genre (
    film_id integer NOT NULL,
    genre_id integer NOT NULL
);


ALTER TABLE public.film_genre OWNER TO scrapoo;

--
-- Name: film_id_seq; Type: SEQUENCE; Schema: public; Owner: scrapoo
--

CREATE SEQUENCE public.film_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.film_id_seq OWNER TO scrapoo;

--
-- Name: film_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: scrapoo
--

ALTER SEQUENCE public.film_id_seq OWNED BY public.film.id;


--
-- Name: genre; Type: TABLE; Schema: public; Owner: scrapoo
--

CREATE TABLE public.genre (
    id integer NOT NULL,
    name character varying(60)
);


ALTER TABLE public.genre OWNER TO scrapoo;

--
-- Name: genre_id_seq; Type: SEQUENCE; Schema: public; Owner: scrapoo
--

CREATE SEQUENCE public.genre_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.genre_id_seq OWNER TO scrapoo;

--
-- Name: genre_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: scrapoo
--

ALTER SEQUENCE public.genre_id_seq OWNED BY public.genre.id;


--
-- Name: movie_link; Type: TABLE; Schema: public; Owner: scrapoo
--

CREATE TABLE public.movie_link (
    id integer NOT NULL,
    url character varying(100),
    status character varying(15)
);


ALTER TABLE public.movie_link OWNER TO scrapoo;

--
-- Name: movie_link_id_seq; Type: SEQUENCE; Schema: public; Owner: scrapoo
--

CREATE SEQUENCE public.movie_link_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.movie_link_id_seq OWNER TO scrapoo;

--
-- Name: movie_link_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: scrapoo
--

ALTER SEQUENCE public.movie_link_id_seq OWNED BY public.movie_link.id;


--
-- Name: person; Type: TABLE; Schema: public; Owner: scrapoo
--

CREATE TABLE public.person (
    id integer NOT NULL,
    name character varying(60) NOT NULL,
    birth_date date,
    url character varying(100),
    occupation character varying(50)
);


ALTER TABLE public.person OWNER TO scrapoo;

--
-- Name: person_id_seq; Type: SEQUENCE; Schema: public; Owner: scrapoo
--

CREATE SEQUENCE public.person_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.person_id_seq OWNER TO scrapoo;

--
-- Name: person_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: scrapoo
--

ALTER SEQUENCE public.person_id_seq OWNED BY public.person.id;


--
-- Name: person_in_film; Type: TABLE; Schema: public; Owner: scrapoo
--

CREATE TABLE public.person_in_film (
    id integer NOT NULL,
    role character varying(30),
    films_id integer NOT NULL,
    persons_id integer NOT NULL
);


ALTER TABLE public.person_in_film OWNER TO scrapoo;

--
-- Name: person_in_film_id_seq; Type: SEQUENCE; Schema: public; Owner: scrapoo
--

CREATE SEQUENCE public.person_in_film_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.person_in_film_id_seq OWNER TO scrapoo;

--
-- Name: person_in_film_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: scrapoo
--

ALTER SEQUENCE public.person_in_film_id_seq OWNED BY public.person_in_film.id;


--
-- Name: country id; Type: DEFAULT; Schema: public; Owner: scrapoo
--

ALTER TABLE ONLY public.country ALTER COLUMN id SET DEFAULT nextval('public.country_id_seq'::regclass);


--
-- Name: film id; Type: DEFAULT; Schema: public; Owner: scrapoo
--

ALTER TABLE ONLY public.film ALTER COLUMN id SET DEFAULT nextval('public.film_id_seq'::regclass);


--
-- Name: genre id; Type: DEFAULT; Schema: public; Owner: scrapoo
--

ALTER TABLE ONLY public.genre ALTER COLUMN id SET DEFAULT nextval('public.genre_id_seq'::regclass);


--
-- Name: movie_link id; Type: DEFAULT; Schema: public; Owner: scrapoo
--

ALTER TABLE ONLY public.movie_link ALTER COLUMN id SET DEFAULT nextval('public.movie_link_id_seq'::regclass);


--
-- Name: person id; Type: DEFAULT; Schema: public; Owner: scrapoo
--

ALTER TABLE ONLY public.person ALTER COLUMN id SET DEFAULT nextval('public.person_id_seq'::regclass);


--
-- Name: person_in_film id; Type: DEFAULT; Schema: public; Owner: scrapoo
--

ALTER TABLE ONLY public.person_in_film ALTER COLUMN id SET DEFAULT nextval('public.person_in_film_id_seq'::regclass);


--
-- Data for Name: country; Type: TABLE DATA; Schema: public; Owner: scrapoo
--

COPY public.country (id, name) FROM stdin;
6	USA
7	Veľká Británia
8	Rusko
9	Česko
\.


--
-- Data for Name: film; Type: TABLE DATA; Schema: public; Owner: scrapoo
--

COPY public.film (id, title, original_title, language, release_year, rating, num_votes, url, country_id) FROM stdin;
54	Zločiny a poklesky	Crimes and Misdemeanors	Unknown	1989	\N	\N	https://www.csfd.sk/film/32-zlociny-a-poklesky/prehlad/	6
32	Žurov	Журов	Unknown	2009	\N	\N	https://www.csfd.sk/film/16-zurov/prehlad/	8
33	City Beneath the Sea	City Beneath the Sea	Unknown	1971	\N	\N	https://www.csfd.sk/film/18-city-beneath-the-sea/prehlad/	6
34	Five Weeks in a Balloon	Five Weeks in a Balloon	Unknown	1962	\N	\N	https://www.csfd.sk/film/19-five-weeks-in-a-balloon/prehlad/	6
35	Stratený svet	The Lost World	Unknown	1960	\N	\N	https://www.csfd.sk/film/20-strateny-svet/prehlad/	6
42	The Story of Mankind	The Story of Mankind	Unknown	1957	\N	\N	https://www.csfd.sk/film/21-the-story-of-mankind/prehlad/	6
53	Prekliatie žltozeleného škorpióna	The Curse of the Jade Scorpion	Unknown	2001	\N	\N	https://www.csfd.sk/film/33-prekliatie-zltozeleneho-skorpiona/prehlad/	6
55	Pozor na Harryho	Deconstructing Harry	Unknown	1997	\N	\N	https://www.csfd.sk/film/34-pozor-na-harryho/prehlad/	6
36	Vítej doma, Roxy Carmichaelová	Welcome Home, Roxy Carmichael	Unknown	1990	\N	\N	https://www.csfd.sk/film/9-vitej-doma-roxy-carmichaelova/prehlad/	6
56	Všetci hovoria: Milujem ťa	Everyone Says I Love You	Unknown	1996	\N	\N	https://www.csfd.sk/film/36-vsetci-hovoria-milujem-ta/prehlad/	6
57	Hana a jej sestry	Hannah and Her Sisters	Unknown	1986	\N	\N	https://www.csfd.sk/film/38-hana-a-jej-sestry/prehlad/	6
43	Sklenené peklo	The Towering Inferno	Unknown	1974	\N	\N	https://www.csfd.sk/film/23-sklenene-peklo/prehlad/	6
41	Samé jedničky\n\t\t\t\t\t\t\t\t (S02E32)	Samé jedničky\n\t\t\t\t\t\t\t\t (S02E32)	Unknown	2013	\N	\N	https://www.csfd.sk/film/322551-gympl-s-r-ucenim-omezenym/451417-same-jednicky/prehlad/	9
37	Betsyina svatba	Betsy's Wedding	Unknown	1990	\N	\N	https://www.csfd.sk/film/10-betsyina-svatba/prehlad/	6
23	Pripútajte sa, prosím!	Airplane!	Unknown	1980	\N	\N	https://www.csfd.sk/film/2-priputajte-sa-prosim/prehlad/	6
21	Kšeft za veľké prachy	Big Business	Unknown	1988	\N	\N	https://www.csfd.sk/film/3-kseft-za-velke-prachy/prehlad/	6
25	Horúce strely	Hot Shots!	Unknown	1991	\N	\N	https://www.csfd.sk/film/4-horuce-strely/prehlad/	6
27	Horúce strely 2	Hot Shots! Part Deux	Unknown	1993	\N	\N	https://www.csfd.sk/film/5-horuce-strely-2/prehlad/	6
24	Mafia!	Jane Austen's Mafia!	Unknown	1998	\N	\N	https://www.csfd.sk/film/6-mafia/prehlad/	6
26	Bezcitní ľudia	Ruthless People	Unknown	1986	\N	\N	https://www.csfd.sk/film/7-bezcitni-ludia/prehlad/	6
28	Prísne tajné	Top Secret!	Unknown	1984	\N	\N	https://www.csfd.sk/film/8-prisne-tajne/prehlad/	7
29	Dovidenia, zbohom a amen\n\t\t\t\t\t\t\t\t (S11E16)	Goodbye, Farewell and Amen	Unknown	1983	\N	\N	https://www.csfd.sk/film/68850-m-a-s-h/12-dovidenia-zbohom-a-amen/prehlad/	6
30	Sladká sloboda	Sweet Liberty	Unknown	1986	\N	\N	https://www.csfd.sk/film/14-sladka-sloboda/prehlad/	6
31	Aliens from Another Planet	Aliens from Another Planet	Unknown	1982	\N	\N	https://www.csfd.sk/film/15-aliens-from-another-planet/prehlad/	6
22	Pre dobro pacienta...	...First Do No Harm	Unknown	1997	\N	\N	https://www.csfd.sk/film/1-pre-dobro-pacienta/prehlad/	6
40	Čtyři roční období	The Four Seasons	Unknown	1981	\N	\N	https://www.csfd.sk/film/11-ctyri-rocni-obdobi/prehlad/	6
38	Nový život	A New Life	Unknown	1988	\N	\N	https://www.csfd.sk/film/13-novy-zivot/prehlad/	6
39	Po dobrodružství Poseidonu	Beyond the Poseidon Adventure	Unknown	1979	\N	\N	https://www.csfd.sk/film/17-po-dobrodruzstvi-poseidonu/prehlad/	6
48	Roj	The Swarm	Unknown	1978	\N	\N	https://www.csfd.sk/film/22-roj/prehlad/	6
49	Annie Hall	Annie Hall	Unknown	1977	\N	\N	https://www.csfd.sk/film/26-annie-hallova/prehlad/	6
44	Voyage to the Bottom of the Sea	Journey to the Bottom of the Sea	Unknown	1961	\N	\N	https://www.csfd.sk/film/24-voyage-to-the-bottom-of-the-sea/prehlad/	6
45	Alice	Alice	Unknown	1990	\N	\N	https://www.csfd.sk/film/25-alice/prehlad/	6
50	Banáni	Bananas	Unknown	1971	\N	\N	https://www.csfd.sk/film/28-banani/prehlad/	6
46	Iná žena	Another Woman	Unknown	1988	\N	\N	https://www.csfd.sk/film/27-ina-zena/prehlad/	6
47	Výstrely na Broadwayi	Bullets Over Broadway	Unknown	1994	\N	\N	https://www.csfd.sk/film/30-vystrely-na-broadwayi/prehlad/	6
52	Celebrity	Celebrity	Unknown	1998	\N	\N	https://www.csfd.sk/film/31-celebrity/prehlad/	6
51	Danny Rose z Broadwaye	Broadway Danny Rose	Unknown	1984	\N	\N	https://www.csfd.sk/film/29-danny-rose-z-broadwaye/prehlad/	6
\.


--
-- Data for Name: film_genre; Type: TABLE DATA; Schema: public; Owner: scrapoo
--

COPY public.film_genre (film_id, genre_id) FROM stdin;
23	11
22	12
41	11
41	12
21	11
25	16
25	11
25	14
25	15
27	11
27	14
27	15
24	11
24	12
24	13
26	11
28	11
29	11
29	12
29	15
30	11
31	17
32	13
33	17
33	14
34	16
34	18
34	11
35	17
35	18
42	12
42	21
43	19
43	20
43	12
43	14
44	17
44	18
45	16
45	11
45	21
46	12
47	11
47	12
47	13
52	11
52	12
53	11
53	12
53	13
55	11
36	11
36	12
37	11
40	11
40	12
38	11
39	18
39	19
39	12
39	20
48	19
48	20
48	22
48	14
49	16
49	11
50	11
51	11
54	11
54	12
56	16
56	11
56	23
57	16
57	11
57	12
\.


--
-- Data for Name: genre; Type: TABLE DATA; Schema: public; Owner: scrapoo
--

COPY public.genre (id, name) FROM stdin;
11	Komédia
12	Dráma
13	Krimi
14	Akčný
15	Vojnový
16	Romantický
17	Sci-Fi
18	Dobrodružný
19	Katastrofický
20	Thriller
21	Fantasy
22	Horor
23	Muzikál
\.


--
-- Data for Name: movie_link; Type: TABLE DATA; Schema: public; Owner: scrapoo
--

COPY public.movie_link (id, url, status) FROM stdin;
\.


--
-- Data for Name: person; Type: TABLE DATA; Schema: public; Owner: scrapoo
--

COPY public.person (id, name, birth_date, url, occupation) FROM stdin;
1739	Jim Abrahams	\N	https://www.csfd.sk/tvorca/2796-jim-abrahams/	Director
1740	Bette Midler	\N	https://www.csfd.sk/tvorca/572-bette-midler/	Actor
1741	Lily Tomlin	\N	https://www.csfd.sk/tvorca/1896-lily-tomlin/	Actor
1742	Fred Ward	\N	https://www.csfd.sk/tvorca/105-fred-ward/	Actor
1743	Edward Herrmann	\N	https://www.csfd.sk/tvorca/14165-edward-herrmann/	Actor
1744	Michele Placido	\N	https://www.csfd.sk/tvorca/4870-michele-placido/	Actor
1745	Barry Primus	\N	https://www.csfd.sk/tvorca/3427-barry-primus/	Actor
1746	Michael Gross	\N	https://www.csfd.sk/tvorca/2354-michael-gross/	Actor
1747	Deborah Rush	\N	https://www.csfd.sk/tvorca/56966-deborah-rush/	Actor
1748	Nicolas Coster	\N	https://www.csfd.sk/tvorca/13400-nicolas-coster/	Actor
1749	Joe Grifasi	\N	https://www.csfd.sk/tvorca/5304-joe-grifasi/	Actor
1750	John Hancock	\N	https://www.csfd.sk/tvorca/7945-john-hancock/	Actor
1751	Seth Green	\N	https://www.csfd.sk/tvorca/6420-seth-green/	Actor
1752	Leo Burmester	\N	https://www.csfd.sk/tvorca/19917-leo-burmester/	Actor
1753	Lewis Arquette	\N	https://www.csfd.sk/tvorca/19869-lewis-arquette/	Actor
1754	Carmen Argenziano	\N	https://www.csfd.sk/tvorca/2518-carmen-argenziano/	Actor
1755	Mary Gross	\N	https://www.csfd.sk/tvorca/59043-mary-gross/	Actor
1757	Ryan Francis	\N	https://www.csfd.sk/tvorca/102514-ryan-francis/	Actor
1758	Shirley Mitchell	\N	https://www.csfd.sk/tvorca/162028-shirley-mitchell/	Actor
1759	Roy Brocksmith	\N	https://www.csfd.sk/tvorca/205285-roy-brocksmith/	Actor
1760	John Vickery	\N	https://www.csfd.sk/tvorca/207074-john-vickery/	Actor
1761	Everett Quinton	\N	https://www.csfd.sk/tvorca/219293-everett-quinton/	Actor
1763	Ritch Brinkley	\N	https://www.csfd.sk/tvorca/226825-ritch-brinkley/	Actor
1764	Fred Parnes	\N	https://www.csfd.sk/tvorca/294247-fred-parnes/	Actor
1765	Patricia Gaul	\N	https://www.csfd.sk/tvorca/296453-patricia-gaul/	Actor
1766	Al Mancini	\N	https://www.csfd.sk/tvorca/314139-al-mancini/	Actor
1768	Lucy Webb	\N	https://www.csfd.sk/tvorca/355404-lucy-webb/	Actor
1769	Crystal Field	\N	https://www.csfd.sk/tvorca/368200-crystal-field/	Actor
1770	Daniel Gerroll	\N	https://www.csfd.sk/tvorca/376129-daniel-gerroll/	Actor
1771	Lois De Banzie	\N	https://www.csfd.sk/tvorca/383875-lois-de-banzie/	Actor
1772	Chick Hearn	\N	https://www.csfd.sk/tvorca/408146-chick-hearn/	Actor
1773	Andi Chapman	\N	https://www.csfd.sk/tvorca/593228-andi-chapman/	Actor
1774	Tom La Grua	\N	https://www.csfd.sk/tvorca/753920-tom-la-grua/	Actor
1776	Kathryn Janssen	\N	https://www.csfd.sk/tvorca/925221-kathryn-janssen/	Actor
1777	Meryl Streep	\N	https://www.csfd.sk/tvorca/589-meryl-streep/	Actor
1778	Seth Adkins	\N	https://www.csfd.sk/tvorca/9810-seth-adkins/	Actor
1779	Allison Janney	\N	https://www.csfd.sk/tvorca/1847-allison-janney/	Actor
1780	Margo Martindale	\N	https://www.csfd.sk/tvorca/17698-margo-martindale/	Actor
1781	Oni Faida Lampley	\N	https://www.csfd.sk/tvorca/37394-oni-faida-lampley/	Actor
1782	Mairon Bennett	\N	https://www.csfd.sk/tvorca/38627-mairon-bennett/	Actor
1783	Kyra Harper	\N	https://www.csfd.sk/tvorca/49359-kyra-harper/	Actor
1784	Ingrid Veninger	\N	https://www.csfd.sk/tvorca/60601-ingrid-veninger/	Actor
1785	Marcia Bennett	\N	https://www.csfd.sk/tvorca/8038-marcia-bennett/	Actor
1786	Tom Butler	\N	https://www.csfd.sk/tvorca/77300-tom-butler/	Actor
1788	Lynne Griffin	\N	https://www.csfd.sk/tvorca/95705-lynne-griffin/	Actor
1789	Jennifer Podemski	\N	https://www.csfd.sk/tvorca/217702-jennifer-podemski/	Actor
1790	Lorna Wilson	\N	https://www.csfd.sk/tvorca/261042-lorna-wilson/	Actor
1791	Philip Akin	\N	https://www.csfd.sk/tvorca/298289-philip-akin/	Actor
1792	Ann Holloway	\N	https://www.csfd.sk/tvorca/615946-ann-holloway/	Actor
1793	Michael Yarmush	\N	https://www.csfd.sk/tvorca/651058-michael-yarmush/	Actor
1795	Timm Zemanek	\N	https://www.csfd.sk/tvorca/939367-timm-zemanek/	Actor
1796	Tannis Burnett	\N	https://www.csfd.sk/tvorca/953514-tannis-burnett/	Actor
1797	Jerry Zucker	\N	https://www.csfd.sk/tvorca/3142-jerry-zucker/	Director
1798	David Zucker	\N	https://www.csfd.sk/tvorca/3141-david-zucker/	Director
1799	Robert Hays	\N	https://www.csfd.sk/tvorca/416-robert-hays/	Actor
1800	Julie Hagerty	\N	https://www.csfd.sk/tvorca/6454-julie-hagerty/	Actor
1801	Lloyd Bridges	\N	https://www.csfd.sk/tvorca/362-lloyd-bridges/	Actor
1802	Leslie Nielsen	\N	https://www.csfd.sk/tvorca/863-leslie-nielsen/	Actor
1803	Robert Stack	\N	https://www.csfd.sk/tvorca/11462-robert-stack/	Actor
1804	Peter Graves	\N	https://www.csfd.sk/tvorca/13984-peter-graves/	Actor
1806	Jonathan Banks	\N	https://www.csfd.sk/tvorca/16312-jonathan-banks/	Actor
1807	Barbara Billingsley	\N	https://www.csfd.sk/tvorca/23444-barbara-billingsley/	Actor
1808	James Hong	\N	https://www.csfd.sk/tvorca/7180-james-hong/	Actor
1809	Ethel Merman	\N	https://www.csfd.sk/tvorca/2405-ethel-merman/	Actor
1810	Kenneth Tobey	\N	https://www.csfd.sk/tvorca/17999-kenneth-tobey/	Actor
1812	Gregory Itzin	\N	https://www.csfd.sk/tvorca/57550-gregory-itzin/	Actor
1813	Al White	\N	https://www.csfd.sk/tvorca/87183-al-white/	Actor
1816	William Duell	\N	https://www.csfd.sk/tvorca/97874-william-duell/	Actor
1794	Michael G. Brown	\N	https://www.csfd.sk/tvorca/922649-michael-g-brown/	Actor
1756	Maureen McVerry	\N	https://www.csfd.sk/tvorca/85854-maureen-mcverry/	Actor
1762	J.C. Quinn	\N	https://www.csfd.sk/tvorca/226818-j-c-quinn/	Actor
1767	Hunter von Leer	\N	https://www.csfd.sk/tvorca/323791-hunter-von-leer/	Actor
1775	Norma MacMillan	\N	https://www.csfd.sk/tvorca/827759-norma-macmillan/	Actor
1805	Kareem Abdul-Jabbar	\N	https://www.csfd.sk/tvorca/6764-kareem-abdul-jabbar/	Actor
1814	Cyril O'Reilly	\N	https://www.csfd.sk/tvorca/87337-cyril-o-reilly/	Actor
1811	Conrad E. Palmisano	\N	https://www.csfd.sk/tvorca/50882-conrad-e-palmisano/	Actor
1815	Jimmie 'JJ' Walker	\N	https://www.csfd.sk/tvorca/94430-jimmie-jj-walker/	Actor
1817	Rossie Harris	\N	https://www.csfd.sk/tvorca/111221-rossie-harris/	Actor
1818	Nicholas Pryor	\N	https://www.csfd.sk/tvorca/131676-nicholas-pryor/	Actor
1819	Barbara Stuart	\N	https://www.csfd.sk/tvorca/133774-barbara-stuart/	Actor
1820	Herb Vigran	\N	https://www.csfd.sk/tvorca/134966-herb-vigran/	Actor
1821	Joyce Mandel	\N	https://www.csfd.sk/tvorca/136325-joyce-mandel/	Actor
1822	Michelle Stacy	\N	https://www.csfd.sk/tvorca/236014-michelle-stacy/	Actor
1824	Jill Whelan	\N	https://www.csfd.sk/tvorca/249569-jill-whelan/	Actor
1825	Lee Terri	\N	https://www.csfd.sk/tvorca/254579-lee-terri/	Actor
1826	Michael Laurence	\N	https://www.csfd.sk/tvorca/269413-michael-laurence/	Actor
1827	Lee Bryant	\N	https://www.csfd.sk/tvorca/288401-lee-bryant/	Actor
1828	Jason Wingreen	\N	https://www.csfd.sk/tvorca/312947-jason-wingreen/	Actor
1829	Herb Voland	\N	https://www.csfd.sk/tvorca/347304-herb-voland/	Actor
1830	Ann Nelson	\N	https://www.csfd.sk/tvorca/369988-ann-nelson/	Actor
1831	Bill Kirchenbauer	\N	https://www.csfd.sk/tvorca/370586-bill-kirchenbauer/	Actor
1832	Joyce Bulifant	\N	https://www.csfd.sk/tvorca/262216-joyce-bulifant/	Actor
1833	Robert Starr	\N	https://www.csfd.sk/tvorca/429431-robert-starr/	Actor
1834	Mary Mercier	\N	https://www.csfd.sk/tvorca/461789-mary-mercier/	Actor
1835	Marcy Goldman	\N	https://www.csfd.sk/tvorca/542573-marcy-goldman/	Actor
1836	Kitten Natividad	\N	https://www.csfd.sk/tvorca/590024-kitten-natividad/	Actor
1837	Maurice Hill	\N	https://www.csfd.sk/tvorca/667318-maurice-hill/	Actor
1838	Stephen Stucker	\N	https://www.csfd.sk/tvorca/698227-stephen-stucker/	Actor
1839	Leoda Richards	\N	https://www.csfd.sk/tvorca/559694-leoda-richards/	Actor
1840	Frank Ashmore	\N	https://www.csfd.sk/tvorca/746218-frank-ashmore/	Actor
1841	Lorna Patterson	\N	https://www.csfd.sk/tvorca/746245-lorna-patterson/	Actor
1843	Howard Honig	\N	https://www.csfd.sk/tvorca/559638-howard-honig/	Actor
1844	Sig Frohlich	\N	https://www.csfd.sk/tvorca/775828-sig-frohlich/	Actor
1845	Nora Meerbaum	\N	https://www.csfd.sk/tvorca/831002-nora-meerbaum/	Actor
1846	Jay Mohr	\N	https://www.csfd.sk/tvorca/7277-jay-mohr/	Actor
1847	Billy Burke	\N	https://www.csfd.sk/tvorca/5336-billy-burke/	Actor
1848	Christina Applegate	\N	https://www.csfd.sk/tvorca/1929-christina-applegate/	Actor
1849	Pamela Gidley	\N	https://www.csfd.sk/tvorca/2487-pamela-gidley/	Actor
1850	Olympia Dukakis	\N	https://www.csfd.sk/tvorca/6237-olympia-dukakis/	Actor
1851	Jason Fuchs	\N	https://www.csfd.sk/tvorca/20016-jason-fuchs/	Actor
1852	Joe Viterelli	\N	https://www.csfd.sk/tvorca/15223-joe-viterelli/	Actor
1853	Tony Lo Bianco	\N	https://www.csfd.sk/tvorca/5672-tony-lo-bianco/	Actor
1854	Vincent Pastore	\N	https://www.csfd.sk/tvorca/9122-vincent-pastore/	Actor
1855	Marisol Nichols	\N	https://www.csfd.sk/tvorca/6061-marisol-nichols/	Actor
1856	Louis Mandylor	\N	https://www.csfd.sk/tvorca/57431-louis-mandylor/	Actor
1857	Andreas Katsulas	\N	https://www.csfd.sk/tvorca/429-andreas-katsulas/	Actor
1858	Stefan Lysenko	\N	https://www.csfd.sk/tvorca/49441-stefan-lysenko/	Actor
1859	Sofia Milos	\N	https://www.csfd.sk/tvorca/34413-sofia-milos/	Actor
1860	Gerald Emerick	\N	https://www.csfd.sk/tvorca/23251-gerald-emerick/	Actor
1861	Frank Welker	\N	https://www.csfd.sk/tvorca/22967-frank-welker/	Actor
1862	Deep Roy	\N	https://www.csfd.sk/tvorca/30368-deep-roy/	Actor
1863	Sherman Hemsley	\N	https://www.csfd.sk/tvorca/81371-sherman-hemsley/	Actor
1864	Isabel Sanford	\N	https://www.csfd.sk/tvorca/81377-isabel-sanford/	Actor
1865	Larry Laverty	\N	https://www.csfd.sk/tvorca/82627-larry-laverty/	Actor
1866	Karen Leigh Hopkins	\N	https://www.csfd.sk/tvorca/113774-karen-leigh-hopkins/	Actor
1867	Gregory Sierra	\N	https://www.csfd.sk/tvorca/115634-gregory-sierra/	Actor
1868	Carol Ann Susi	\N	https://www.csfd.sk/tvorca/143770-carol-ann-susi/	Actor
1869	Jerry Haleva	\N	https://www.csfd.sk/tvorca/194337-jerry-haleva/	Actor
1871	Philip Suriano	\N	https://www.csfd.sk/tvorca/341948-philip-suriano/	Actor
1872	Ursula Burton	\N	https://www.csfd.sk/tvorca/363783-ursula-burton/	Actor
1873	Anthony Crivello	\N	https://www.csfd.sk/tvorca/424902-anthony-crivello/	Actor
1874	Cate Caplin	\N	https://www.csfd.sk/tvorca/506441-cate-caplin/	Actor
1875	Jason Davis	\N	https://www.csfd.sk/tvorca/550594-jason-davis/	Actor
1876	Vera Lockwood	\N	https://www.csfd.sk/tvorca/701973-vera-lockwood/	Actor
1877	Don Bovingloh	\N	https://www.csfd.sk/tvorca/799361-don-bovingloh/	Actor
1878	Saverio Carubia	\N	https://www.csfd.sk/tvorca/878804-saverio-carubia/	Actor
1879	Charlie Sheen	\N	https://www.csfd.sk/tvorca/487-charlie-sheen/	Actor
1880	Cary Elwes	\N	https://www.csfd.sk/tvorca/395-cary-elwes/	Actor
1881	Valeria Golino	\N	https://www.csfd.sk/tvorca/2455-valeria-golino/	Actor
1882	Kevin Dunn	\N	https://www.csfd.sk/tvorca/7794-kevin-dunn/	Actor
1883	Jon Cryer	\N	https://www.csfd.sk/tvorca/14091-jon-cryer/	Actor
1884	Kristy Swanson	\N	https://www.csfd.sk/tvorca/2115-kristy-swanson/	Actor
1886	Bill Irwin	\N	https://www.csfd.sk/tvorca/84672-bill-irwin/	Actor
1887	Heidi Swedberg	\N	https://www.csfd.sk/tvorca/11644-heidi-swedberg/	Actor
1889	Ryan Stiles	\N	https://www.csfd.sk/tvorca/37516-ryan-stiles/	Actor
1890	Ryan Cutrona	\N	https://www.csfd.sk/tvorca/15484-ryan-cutrona/	Actor
1891	Pat Proft	\N	https://www.csfd.sk/tvorca/7947-pat-proft/	Actor
1892	Cylk Cozart	\N	https://www.csfd.sk/tvorca/23236-cylk-cozart/	Actor
1893	Jimmie Ray Weeks	\N	https://www.csfd.sk/tvorca/18459-jimmie-ray-weeks/	Actor
1894	Charles Barkley	\N	https://www.csfd.sk/tvorca/19881-charles-barkley/	Actor
1823	John O'Leary	\N	https://www.csfd.sk/tvorca/236019-john-o-leary/	Actor
1885	Efrem Zimbalist Jr.	\N	https://www.csfd.sk/tvorca/56043-efrem-zimbalist-jr/	Actor
1888	Bruce A. Young	\N	https://www.csfd.sk/tvorca/10172-bruce-a-young/	Actor
1870	Joseph R. Sicari	\N	https://www.csfd.sk/tvorca/248676-joseph-r-sicari/	Actor
1895	Christopher Doyle	\N	https://www.csfd.sk/tvorca/9249-christopher-doyle/	Actor
1896	Dave Oliver	\N	https://www.csfd.sk/tvorca/9573-dave-oliver/	Actor
1897	Marc Shaiman	\N	https://www.csfd.sk/tvorca/63500-marc-shaiman/	Actor
1899	Sean Kanan	\N	https://www.csfd.sk/tvorca/101951-sean-kanan/	Actor
1900	Steven Chester Prince	\N	https://www.csfd.sk/tvorca/170011-steven-chester-prince/	Actor
1902	Don Lake	\N	https://www.csfd.sk/tvorca/222741-don-lake/	Actor
1904	Rino Thunder	\N	https://www.csfd.sk/tvorca/380757-rino-thunder/	Actor
1905	Tony Lorea	\N	https://www.csfd.sk/tvorca/466348-tony-lorea/	Actor
1906	Judith Kahan	\N	https://www.csfd.sk/tvorca/722935-judith-kahan/	Actor
1907	Mark Arnott	\N	https://www.csfd.sk/tvorca/557619-mark-arnott/	Actor
1909	Judge Reinhold	\N	https://www.csfd.sk/tvorca/472-judge-reinhold/	Actor
1910	Helen Slater	\N	https://www.csfd.sk/tvorca/11632-helen-slater/	Actor
1911	Anita Morris	\N	https://www.csfd.sk/tvorca/23524-anita-morris/	Actor
1912	Bill Pullman	\N	https://www.csfd.sk/tvorca/19-bill-pullman/	Actor
1914	Art Evans	\N	https://www.csfd.sk/tvorca/23252-art-evans/	Actor
1917	Bob Tzudiker	\N	https://www.csfd.sk/tvorca/218454-bob-tzudiker/	Actor
1918	Clarence Felder	\N	https://www.csfd.sk/tvorca/235885-clarence-felder/	Actor
1919	Hanala Sagal	\N	https://www.csfd.sk/tvorca/242540-hanala-sagal/	Actor
1920	Susan Marie Snyder	\N	https://www.csfd.sk/tvorca/284033-susan-marie-snyder/	Actor
1921	Frank Sivero	\N	https://www.csfd.sk/tvorca/289913-frank-sivero/	Actor
1922	Gary Riley	\N	https://www.csfd.sk/tvorca/324408-gary-riley/	Actor
1923	Phyllis Applegate	\N	https://www.csfd.sk/tvorca/324409-phyllis-applegate/	Actor
1924	Art Bonilla	\N	https://www.csfd.sk/tvorca/479886-art-bonilla/	Actor
1925	John Forker	\N	https://www.csfd.sk/tvorca/640997-john-forker/	Actor
1928	Mie Hunt	\N	https://www.csfd.sk/tvorca/825856-mie-hunt/	Actor
1929	Jim Doughan	\N	https://www.csfd.sk/tvorca/833340-jim-doughan/	Actor
1930	Jeannine Bisignano	\N	https://www.csfd.sk/tvorca/959823-jeannine-bisignano/	Actor
1931	Richard Crenna	\N	https://www.csfd.sk/tvorca/380-richard-crenna/	Actor
1932	Brenda Bakke	\N	https://www.csfd.sk/tvorca/5849-brenda-bakke/	Actor
1933	Miguel Ferrer	\N	https://www.csfd.sk/tvorca/2339-miguel-ferrer/	Actor
1934	Rowan Atkinson	\N	https://www.csfd.sk/tvorca/349-rowan-atkinson/	Actor
1935	David Wohl	\N	https://www.csfd.sk/tvorca/370182-david-wohl/	Actor
1936	Mitchell Ryan	\N	https://www.csfd.sk/tvorca/17423-mitchell-ryan/	Actor
1937	Tony Edwards	\N	https://www.csfd.sk/tvorca/19990-tony-edwards/	Actor
1938	James Lew	\N	https://www.csfd.sk/tvorca/22896-james-lew/	Actor
1939	Gerald Okamura	\N	https://www.csfd.sk/tvorca/23857-gerald-okamura/	Actor
1940	Chi Muoi Lo	\N	https://www.csfd.sk/tvorca/16510-chi-muoi-lo/	Actor
1941	Scott Reeves	\N	https://www.csfd.sk/tvorca/14658-scott-reeves/	Actor
1942	Martin Sheen	\N	https://www.csfd.sk/tvorca/488-martin-sheen/	Actor
1943	Clyde Kusatsu	\N	https://www.csfd.sk/tvorca/1866-clyde-kusatsu/	Actor
1944	Shaun Toub	\N	https://www.csfd.sk/tvorca/45658-shaun-toub/	Actor
1945	Ben Lemon	\N	https://www.csfd.sk/tvorca/244056-ben-lemon/	Actor
1947	Greg Michaels	\N	https://www.csfd.sk/tvorca/301357-greg-michaels/	Actor
1948	Bob Vila	\N	https://www.csfd.sk/tvorca/349204-bob-vila/	Actor
1949	Larry Lindsey	\N	https://www.csfd.sk/tvorca/545449-larry-lindsey/	Actor
1950	Raye Hollitt	\N	https://www.csfd.sk/tvorca/586517-raye-hollitt/	Actor
1951	Michael Colyar	\N	https://www.csfd.sk/tvorca/604939-michael-colyar/	Actor
1952	Loren Janes	\N	https://www.csfd.sk/tvorca/740029-loren-janes/	Actor
1953	Nancy Steen	\N	https://www.csfd.sk/tvorca/826237-nancy-steen/	Actor
1954	Stewart Skelton	\N	https://www.csfd.sk/tvorca/844094-stewart-skelton/	Actor
1955	Mark Steen	\N	https://www.csfd.sk/tvorca/847887-mark-steen/	Actor
1956	Val Kilmer	\N	https://www.csfd.sk/tvorca/100-val-kilmer/	Actor
1957	Lucy Gutteridge	\N	https://www.csfd.sk/tvorca/38768-lucy-gutteridge/	Actor
1958	Peter Cushing	\N	https://www.csfd.sk/tvorca/342-peter-cushing/	Actor
1959	Jeremy Kemp	\N	https://www.csfd.sk/tvorca/53343-jeremy-kemp/	Actor
1960	Christopher Villiers	\N	https://www.csfd.sk/tvorca/20323-christopher-villiers/	Actor
1961	Warren Clarke	\N	https://www.csfd.sk/tvorca/11940-warren-clarke/	Actor
1962	Michael Gough	\N	https://www.csfd.sk/tvorca/14623-michael-gough/	Actor
1963	Harry Ditson	\N	https://www.csfd.sk/tvorca/666237-harry-ditson/	Actor
1964	Jim Carter	\N	https://www.csfd.sk/tvorca/94674-jim-carter/	Actor
1965	Eddie Tagoe	\N	https://www.csfd.sk/tvorca/105370-eddie-tagoe/	Actor
1966	Omar Sharif	\N	https://www.csfd.sk/tvorca/2295-omar-sharif/	Actor
1967	Tristam Jelinek	\N	https://www.csfd.sk/tvorca/303258-tristam-jelinek/	Actor
1968	Gertan Klauber	\N	https://www.csfd.sk/tvorca/280704-gertan-klauber/	Actor
1970	John Sharp	\N	https://www.csfd.sk/tvorca/543375-john-sharp/	Actor
1971	Richard Pescud	\N	https://www.csfd.sk/tvorca/615913-richard-pescud/	Actor
1973	Nicola Wright	\N	https://www.csfd.sk/tvorca/647454-nicola-wright/	Actor
1901	Jimmy Lennon Jr.	\N	https://www.csfd.sk/tvorca/185673-jimmy-lennon-jr/	Actor
1903	Annie O'Donnell	\N	https://www.csfd.sk/tvorca/291744-annie-o-donnell/	Actor
1946	Joseph V. Perry	\N	https://www.csfd.sk/tvorca/258528-joseph-v-perry/	Actor
1908	Danny DeVito	\N	https://www.csfd.sk/tvorca/391-danny-devito/	Actor
1913	William G. Schilling	\N	https://www.csfd.sk/tvorca/23390-william-g-schilling/	Actor
1915	J.E. Freeman	\N	https://www.csfd.sk/tvorca/240-j-e-freeman/	Actor
1916	George 'The Animal' Steele	\N	https://www.csfd.sk/tvorca/63130-george-the-animal-steele/	Actor
1926	Arnold F. Turner	\N	https://www.csfd.sk/tvorca/648670-arnold-f-turner/	Actor
1927	J.P. Bumstead	\N	https://www.csfd.sk/tvorca/651396-j-p-bumstead/	Actor
1969	Ian McNeice	\N	https://www.csfd.sk/tvorca/4961-ian-mcneice/	Actor
1972	Mac McDonald	\N	https://www.csfd.sk/tvorca/44283-mac-mcdonald/	Actor
1974	Lisa Gruenberg	\N	https://www.csfd.sk/tvorca/47985-lisa-gruenberg/	Actor
1975	Maxwell Craig	\N	https://www.csfd.sk/tvorca/298590-maxwell-craig/	Actor
1976	Harry Fielder	\N	https://www.csfd.sk/tvorca/298866-harry-fielder/	Actor
1977	Walter Henry	\N	https://www.csfd.sk/tvorca/295517-walter-henry/	Actor
1978	Frank Jakeman	\N	https://www.csfd.sk/tvorca/606163-frank-jakeman/	Actor
1979	Aileen Lewis	\N	https://www.csfd.sk/tvorca/291135-aileen-lewis/	Actor
1980	Reg Thomason	\N	https://www.csfd.sk/tvorca/290052-reg-thomason/	Actor
1981	Alan Alda	\N	https://www.csfd.sk/tvorca/732-alan-alda/	Director
1982	Mike Farrell	\N	https://www.csfd.sk/tvorca/4608-mike-farrell/	Actor
1983	Harry Morgan	\N	https://www.csfd.sk/tvorca/4609-harry-morgan/	Actor
1984	Loretta Swit	\N	https://www.csfd.sk/tvorca/4613-loretta-swit/	Actor
1985	David Ogden Stiers	\N	https://www.csfd.sk/tvorca/4612-david-ogden-stiers/	Actor
1986	Jamie Farr	\N	https://www.csfd.sk/tvorca/4615-jamie-farr/	Actor
1987	William Christopher	\N	https://www.csfd.sk/tvorca/4616-william-christopher/	Actor
1988	Allan Arbus	\N	https://www.csfd.sk/tvorca/54041-allan-arbus/	Actor
1989	Rosalind Chao	\N	https://www.csfd.sk/tvorca/38043-rosalind-chao/	Actor
1990	Kellye Nakahara	\N	https://www.csfd.sk/tvorca/54048-kellye-nakahara/	Actor
1991	Jeff Maxwell	\N	https://www.csfd.sk/tvorca/54047-jeff-maxwell/	Actor
1993	Blake Clark	\N	https://www.csfd.sk/tvorca/60788-blake-clark/	Actor
1994	Dennis Troy	\N	https://www.csfd.sk/tvorca/319818-dennis-troy/	Actor
1995	Kevin Scannell	\N	https://www.csfd.sk/tvorca/370064-kevin-scannell/	Actor
1996	Herb Mitchell	\N	https://www.csfd.sk/tvorca/484592-herb-mitchell/	Actor
1997	Scott Lincoln	\N	https://www.csfd.sk/tvorca/650759-scott-lincoln/	Actor
1998	Judy Farrell	\N	https://www.csfd.sk/tvorca/803750-judy-farrell/	Actor
1999	Enid Kent	\N	https://www.csfd.sk/tvorca/826043-enid-kent/	Actor
2000	Dennis Flood	\N	https://www.csfd.sk/tvorca/873485-dennis-flood/	Actor
2001	Michael Caine	\N	https://www.csfd.sk/tvorca/754-michael-caine/	Actor
2002	Michelle Pfeiffer	\N	https://www.csfd.sk/tvorca/582-michelle-pfeiffer/	Actor
2003	Bob Hoskins	\N	https://www.csfd.sk/tvorca/421-bob-hoskins/	Actor
2004	Lise Hilboldt	\N	https://www.csfd.sk/tvorca/20456-lise-hilboldt/	Actor
2005	Lillian Gish	\N	https://www.csfd.sk/tvorca/797-lillian-gish/	Actor
2006	Saul Rubinek	\N	https://www.csfd.sk/tvorca/7795-saul-rubinek/	Actor
2007	Lois Chiles	\N	https://www.csfd.sk/tvorca/10922-lois-chiles/	Actor
2008	Antony Alda	\N	https://www.csfd.sk/tvorca/12687-antony-alda/	Actor
2009	Timothy Carhart	\N	https://www.csfd.sk/tvorca/13969-timothy-carhart/	Actor
2010	Bryan Clark	\N	https://www.csfd.sk/tvorca/22440-bryan-clark/	Actor
2011	Dann Florek	\N	https://www.csfd.sk/tvorca/16968-dann-florek/	Actor
2013	Lynne Thigpen	\N	https://www.csfd.sk/tvorca/20572-lynne-thigpen/	Actor
2014	Deborah Gibson	\N	https://www.csfd.sk/tvorca/70192-deborah-gibson/	Actor
2015	Linda Thorson	\N	https://www.csfd.sk/tvorca/95683-linda-thorson/	Actor
2016	Christopher Loomis	\N	https://www.csfd.sk/tvorca/219086-christopher-loomis/	Actor
2017	Robert Schenkkan	\N	https://www.csfd.sk/tvorca/252385-robert-schenkkan/	Actor
2018	Diana Agostini	\N	https://www.csfd.sk/tvorca/289220-diana-agostini/	Actor
2019	Polly Rowles	\N	https://www.csfd.sk/tvorca/385320-polly-rowles/	Actor
2020	Bonnie Deroski	\N	https://www.csfd.sk/tvorca/392111-bonnie-deroski/	Actor
2021	Fred Sanders	\N	https://www.csfd.sk/tvorca/610180-fred-sanders/	Actor
2022	Cynthia Burr	\N	https://www.csfd.sk/tvorca/817502-cynthia-burr/	Actor
2023	Irwin Allen	\N	https://www.csfd.sk/tvorca/2797-irwin-allen/	Director
2024	Sobey Martin	\N	https://www.csfd.sk/tvorca/872305-sobey-martin/	Director
2025	Robert Duvall	\N	https://www.csfd.sk/tvorca/199-robert-duvall/	Actor
2026	Whit Bissell	\N	https://www.csfd.sk/tvorca/4464-whit-bissell/	Actor
2027	Lee Meriwether	\N	https://www.csfd.sk/tvorca/5180-lee-meriwether/	Actor
2028	Wesley Lau	\N	https://www.csfd.sk/tvorca/11373-wesley-lau/	Actor
2029	Joe Ryan	\N	https://www.csfd.sk/tvorca/13695-joe-ryan/	Actor
2030	John Hoyt	\N	https://www.csfd.sk/tvorca/13332-john-hoyt/	Actor
2031	Jan Merlin	\N	https://www.csfd.sk/tvorca/216708-jan-merlin/	Actor
2032	Ross Elliott	\N	https://www.csfd.sk/tvorca/228660-ross-elliott/	Actor
2033	Vitina Marcus	\N	https://www.csfd.sk/tvorca/318627-vitina-marcus/	Actor
2034	Fred Beir	\N	https://www.csfd.sk/tvorca/450030-fred-beir/	Actor
2035	Karen Oganesjan	\N	https://www.csfd.sk/tvorca/55170-karen-oganesjan/	Director
2036	Ilja Makarov	\N	https://www.csfd.sk/tvorca/127698-ilja-makarov/	Director
2037	Andrej Panin	\N	https://www.csfd.sk/tvorca/50902-andrej-panin/	Actor
2038	Jelena Safonova	\N	https://www.csfd.sk/tvorca/78187-jelena-safonova/	Actor
2040	Olesja Sudzilovskaja	\N	https://www.csfd.sk/tvorca/78459-olesja-sudzilovskaja/	Actor
2041	Olga Tumajkina	\N	https://www.csfd.sk/tvorca/140222-olga-tumajkina/	Actor
2044	Kirill Safonov	\N	https://www.csfd.sk/tvorca/154912-kirill-safonov/	Actor
2045	Sergej Gazarov	\N	https://www.csfd.sk/tvorca/56865-sergej-gazarov/	Actor
2047	Julija Galkina	\N	https://www.csfd.sk/tvorca/170768-julija-galkina/	Actor
2048	Sergej Beljajev	\N	https://www.csfd.sk/tvorca/135390-sergej-beljajev/	Actor
2049	Igor Jacko	\N	https://www.csfd.sk/tvorca/172431-igor-jacko/	Actor
2050	Igor Zolotovickij	\N	https://www.csfd.sk/tvorca/155641-igor-zolotovickij/	Actor
2051	Konstantin Vorobjov	\N	https://www.csfd.sk/tvorca/134642-konstantin-vorobjov/	Actor
2012	John C. McGinley	\N	https://www.csfd.sk/tvorca/5265-john-c-mcginley/	Actor
2039	Světlana Ivanova	\N	https://www.csfd.sk/tvorca/79471-svetlana-ivanova/	Actor
2042	Světlana Ustinova	\N	https://www.csfd.sk/tvorca/46189-svetlana-ustinova/	Actor
2043	Alexej Ševčenkov	\N	https://www.csfd.sk/tvorca/95900-alexej-sevcenkov/	Actor
2046	Ivan Stěbunov	\N	https://www.csfd.sk/tvorca/23906-ivan-stebunov/	Actor
2052	Dmitrij Blochin	\N	https://www.csfd.sk/tvorca/162224-dmitrij-blochin/	Actor
2053	Andrej Smoljakov	\N	https://www.csfd.sk/tvorca/87051-andrej-smoljakov/	Actor
2054	Olga Pogodina	\N	https://www.csfd.sk/tvorca/122727-olga-pogodina/	Actor
2056	Dmitrij Jendalcev	\N	https://www.csfd.sk/tvorca/123242-dmitrij-jendalcev/	Actor
2058	Natalija Vdovina	\N	https://www.csfd.sk/tvorca/12779-natalija-vdovina/	Actor
2060	Viktor Rakov	\N	https://www.csfd.sk/tvorca/31124-viktor-rakov/	Actor
2062	Olga Volkova	\N	https://www.csfd.sk/tvorca/128770-olga-volkova/	Actor
2064	Igor Vernik	\N	https://www.csfd.sk/tvorca/73858-igor-vernik/	Actor
2065	Michail Gorevoj	\N	https://www.csfd.sk/tvorca/146212-michail-gorevoj/	Actor
2066	Alexandr Makogon	\N	https://www.csfd.sk/tvorca/158653-alexandr-makogon/	Actor
2067	Roman Radov	\N	https://www.csfd.sk/tvorca/155000-roman-radov/	Actor
2068	Sergej Batalov	\N	https://www.csfd.sk/tvorca/164992-sergej-batalov/	Actor
2069	Jevdokija Germanova	\N	https://www.csfd.sk/tvorca/92466-jevdokija-germanova/	Actor
2070	Jurij Curilo	\N	https://www.csfd.sk/tvorca/20315-jurij-curilo/	Actor
2072	Alisa Chazanova	\N	https://www.csfd.sk/tvorca/88324-alisa-chazanova/	Actor
2074	Jevgenija Lapova	\N	https://www.csfd.sk/tvorca/161440-jevgenija-lapova/	Actor
2075	Maxim Artamonov	\N	https://www.csfd.sk/tvorca/169631-maxim-artamonov/	Actor
2076	Ljudmila Gavrilova	\N	https://www.csfd.sk/tvorca/156158-ljudmila-gavrilova/	Actor
2077	Anfisa Vistingauzen	\N	https://www.csfd.sk/tvorca/83557-anfisa-vistingauzen/	Actor
2079	Alexandr Vojevodin	\N	https://www.csfd.sk/tvorca/213291-alexandr-vojevodin/	Actor
2081	Andrej Rapoport	\N	https://www.csfd.sk/tvorca/219562-andrej-rapoport/	Actor
2084	Alja Nikulina	\N	https://www.csfd.sk/tvorca/263172-alja-nikulina/	Actor
2085	Giuliano Di Capua	\N	https://www.csfd.sk/tvorca/263734-giuliano-di-capua/	Actor
2086	Michail Asankin	\N	https://www.csfd.sk/tvorca/156354-michail-asankin/	Actor
2091	Valentina Losovskaja	\N	https://www.csfd.sk/tvorca/292019-valentina-losovskaja/	Actor
2092	Olga Reptuch	\N	https://www.csfd.sk/tvorca/292130-olga-reptuch/	Actor
2093	Darja Belousova	\N	https://www.csfd.sk/tvorca/304707-darja-belousova/	Actor
2094	Alexandr Nikitin	\N	https://www.csfd.sk/tvorca/304838-alexandr-nikitin/	Actor
2095	Vladimir Jumatov	\N	https://www.csfd.sk/tvorca/308118-vladimir-jumatov/	Actor
2096	Stanislav Rjadinskij	\N	https://www.csfd.sk/tvorca/324040-stanislav-rjadinskij/	Actor
2099	Jurij Nifontov	\N	https://www.csfd.sk/tvorca/326142-jurij-nifontov/	Actor
2100	Andrej Sviridov	\N	https://www.csfd.sk/tvorca/327440-andrej-sviridov/	Actor
2103	Alexandr Vdovin	\N	https://www.csfd.sk/tvorca/330362-alexandr-vdovin/	Actor
2104	Marina Ivanova	\N	https://www.csfd.sk/tvorca/330681-marina-ivanova/	Actor
2106	Olga Burlakova	\N	https://www.csfd.sk/tvorca/332472-olga-burlakova/	Actor
2107	Semjon Furman	\N	https://www.csfd.sk/tvorca/332802-semjon-furman/	Actor
2108	Alexandr Oblasov	\N	https://www.csfd.sk/tvorca/334153-alexandr-oblasov/	Actor
2110	Zinaida Zubkova	\N	https://www.csfd.sk/tvorca/341178-zinaida-zubkova/	Actor
2111	Ivan Agapov	\N	https://www.csfd.sk/tvorca/343858-ivan-agapov/	Actor
2116	Marija Buknis	\N	https://www.csfd.sk/tvorca/369226-marija-buknis/	Actor
2117	Natalja Pikula	\N	https://www.csfd.sk/tvorca/412262-natalja-pikula/	Actor
2119	Alexandra Blednaja	\N	https://www.csfd.sk/tvorca/413597-alexandra-blednaja/	Actor
2120	Lana Soul	\N	https://www.csfd.sk/tvorca/425033-lana-soul/	Actor
2121	Olga Bogdanova	\N	https://www.csfd.sk/tvorca/437348-olga-bogdanova/	Actor
2122	Alesja Samochovec	\N	https://www.csfd.sk/tvorca/443208-alesja-samochovec/	Actor
2124	Anatolij Gurev	\N	https://www.csfd.sk/tvorca/444628-anatolij-gurev/	Actor
2057	Pavel Melenčuk	\N	https://www.csfd.sk/tvorca/99070-pavel-melencuk/	Actor
2059	Sergej Juškevič	\N	https://www.csfd.sk/tvorca/130582-sergej-juskevic/	Actor
2061	Věra Voronkova	\N	https://www.csfd.sk/tvorca/157045-vera-voronkova/	Actor
2063	Anna Pěrelešina	\N	https://www.csfd.sk/tvorca/132476-anna-perelesina/	Actor
2071	Anna Banščikova	\N	https://www.csfd.sk/tvorca/136086-anna-banscikova/	Actor
2073	Nikita Jemšanov	\N	https://www.csfd.sk/tvorca/170016-nikita-jemsanov/	Actor
2078	Jekatěrina Semjonova	\N	https://www.csfd.sk/tvorca/200134-jekaterina-semjonova/	Actor
2080	Igor Artašonov	\N	https://www.csfd.sk/tvorca/218760-igor-artasonov/	Actor
2082	Kirill Käro	\N	https://www.csfd.sk/tvorca/165058-kirill-karo/	Actor
2083	Sergej Šechovcov	\N	https://www.csfd.sk/tvorca/258408-sergej-sechovcov/	Actor
2087	Taťjana Rudina	\N	https://www.csfd.sk/tvorca/268809-tatjana-rudina/	Actor
2088	Viktor Rybčinskij	\N	https://www.csfd.sk/tvorca/281751-viktor-rybcinskij/	Actor
2089	Andrej Seňkin	\N	https://www.csfd.sk/tvorca/286397-andrej-senkin/	Actor
2090	Svjatoslav Astramovič	\N	https://www.csfd.sk/tvorca/291394-svjatoslav-astramovic/	Actor
2097	Jevgenij Gerčakov	\N	https://www.csfd.sk/tvorca/324750-jevgenij-gercakov/	Actor
2098	Arťom Smola	\N	https://www.csfd.sk/tvorca/325424-artom-smola/	Actor
2101	Nikolaj Mačulskij	\N	https://www.csfd.sk/tvorca/328481-nikolaj-maculskij/	Actor
2102	Rostislav Beršauer	\N	https://www.csfd.sk/tvorca/328756-rostislav-bersauer/	Actor
2105	Taťjana Piskarjova	\N	https://www.csfd.sk/tvorca/330686-tatjana-piskarjova/	Actor
2109	Zoja Bělochvostik	\N	https://www.csfd.sk/tvorca/335420-zoja-belochvostik/	Actor
2112	Olga Samošina	\N	https://www.csfd.sk/tvorca/345548-olga-samosina/	Actor
2113	Pavel Višňakov	\N	https://www.csfd.sk/tvorca/355518-pavel-visnakov/	Actor
2114	Jurij Šlykov	\N	https://www.csfd.sk/tvorca/360642-jurij-slykov/	Actor
2115	Michail Levčenko	\N	https://www.csfd.sk/tvorca/363955-michail-levcenko/	Actor
2123	Andrej Moskvičjov	\N	https://www.csfd.sk/tvorca/443853-andrej-moskvicjov/	Actor
2125	Sergej Beljakovič	\N	https://www.csfd.sk/tvorca/444715-sergej-beljakovic/	Actor
2126	Natalja Batrak	\N	https://www.csfd.sk/tvorca/68153-natalja-batrak/	Actor
2127	Viktor Grigorjuk	\N	https://www.csfd.sk/tvorca/9708-viktor-grigorjuk/	Actor
2128	Michail Fatejev	\N	https://www.csfd.sk/tvorca/170069-michail-fatejev/	Actor
2129	Vladimir Friedman	\N	https://www.csfd.sk/tvorca/180333-vladimir-friedman/	Actor
2130	Svetlana Nikiforova	\N	https://www.csfd.sk/tvorca/288241-svetlana-nikiforova/	Actor
2131	Galina Agejkina	\N	https://www.csfd.sk/tvorca/444218-galina-agejkina/	Actor
2132	Olga Sizova	\N	https://www.csfd.sk/tvorca/443616-olga-sizova/	Actor
2133	Andrej Karako	\N	https://www.csfd.sk/tvorca/263152-andrej-karako/	Actor
2135	Sergej Vlasov	\N	https://www.csfd.sk/tvorca/330351-sergej-vlasov/	Actor
2139	Vitalij Bykov	\N	https://www.csfd.sk/tvorca/170746-vitalij-bykov/	Actor
2140	Olga Nefjodova	\N	https://www.csfd.sk/tvorca/222458-olga-nefjodova/	Actor
2141	Andrej Dobrovolskij	\N	https://www.csfd.sk/tvorca/443360-andrej-dobrovolskij/	Actor
2143	Anatolij Golub	\N	https://www.csfd.sk/tvorca/291554-anatolij-golub/	Actor
2145	Darja Belousova	\N	https://www.csfd.sk/tvorca/304709-darja-belousova/	Actor
2146	Ramil Sabitov	\N	https://www.csfd.sk/tvorca/296235-ramil-sabitov/	Actor
2147	Xenija Romenkova	\N	https://www.csfd.sk/tvorca/324042-xenija-romenkova/	Actor
2148	Vera Kavalerova	\N	https://www.csfd.sk/tvorca/424472-vera-kavalerova/	Actor
2152	Tamara Mironova	\N	https://www.csfd.sk/tvorca/345345-tamara-mironova/	Actor
2153	Sergej Sosnovskij	\N	https://www.csfd.sk/tvorca/92600-sergej-sosnovskij/	Actor
2155	Dmitrij Muchin	\N	https://www.csfd.sk/tvorca/357777-dmitrij-muchin/	Actor
2156	Alexandr Girenok	\N	https://www.csfd.sk/tvorca/444322-alexandr-girenok/	Actor
2158	Irina Narbekova	\N	https://www.csfd.sk/tvorca/301077-irina-narbekova/	Actor
2161	Oxana Lesnaja	\N	https://www.csfd.sk/tvorca/415652-oxana-lesnaja/	Actor
2162	Galina Petrova	\N	https://www.csfd.sk/tvorca/263449-galina-petrova/	Actor
2163	Valerija Arlanova	\N	https://www.csfd.sk/tvorca/345568-valerija-arlanova/	Actor
2164	Alexandra Komissarova	\N	https://www.csfd.sk/tvorca/422855-alexandra-komissarova/	Actor
2165	Vladimir Badov	\N	https://www.csfd.sk/tvorca/170461-vladimir-badov/	Actor
2168	Ivan Krasko	\N	https://www.csfd.sk/tvorca/157485-ivan-krasko/	Actor
2169	Denis Karasjov	\N	https://www.csfd.sk/tvorca/141486-denis-karasjov/	Actor
2170	Valerij Zelenskij	\N	https://www.csfd.sk/tvorca/413617-valerij-zelenskij/	Actor
2173	Igor Sigov	\N	https://www.csfd.sk/tvorca/343575-igor-sigov/	Actor
2176	Julija Rutberg	\N	https://www.csfd.sk/tvorca/170949-julija-rutberg/	Actor
2177	Alexandr Gusev	\N	https://www.csfd.sk/tvorca/310056-alexandr-gusev/	Actor
2182	Svetlana Zelenkovskaja	\N	https://www.csfd.sk/tvorca/427929-svetlana-zelenkovskaja/	Actor
2183	Galina Polskich	\N	https://www.csfd.sk/tvorca/79429-galina-polskich/	Actor
2188	Jegor Pazenko	\N	https://www.csfd.sk/tvorca/123201-jegor-pazenko/	Actor
2189	Regina Dombrovskaja	\N	https://www.csfd.sk/tvorca/443605-regina-dombrovskaja/	Actor
2190	Darja Baranova	\N	https://www.csfd.sk/tvorca/261835-darja-baranova/	Actor
2191	Andrej Bronnikov	\N	https://www.csfd.sk/tvorca/437122-andrej-bronnikov/	Actor
2193	Alexandr Feklistov	\N	https://www.csfd.sk/tvorca/20004-alexandr-feklistov/	Actor
2195	Alexandr Jefremov	\N	https://www.csfd.sk/tvorca/306796-alexandr-jefremov/	Actor
2196	Anton Starovojtov	\N	https://www.csfd.sk/tvorca/360819-anton-starovojtov/	Actor
2197	Gennadij Fomin	\N	https://www.csfd.sk/tvorca/444167-gennadij-fomin/	Actor
2199	Zoja Antonova	\N	https://www.csfd.sk/tvorca/285851-zoja-antonova/	Actor
2136	Miťa Labuš	\N	https://www.csfd.sk/tvorca/256262-mita-labus/	Actor
2137	Natalja Rogožkina	\N	https://www.csfd.sk/tvorca/224602-natalja-rogozkina/	Actor
2138	Alexandr Ťutin	\N	https://www.csfd.sk/tvorca/259652-alexandr-tutin/	Actor
2142	Denis Paršin	\N	https://www.csfd.sk/tvorca/292022-denis-parsin/	Actor
2144	Oleg Tkačjov	\N	https://www.csfd.sk/tvorca/128497-oleg-tkacjov/	Actor
2149	Ruslan Černěckij	\N	https://www.csfd.sk/tvorca/263906-ruslan-cerneckij/	Actor
2150	Igor Savočkin	\N	https://www.csfd.sk/tvorca/122292-igor-savockin/	Actor
2151	Taťjana Popova	\N	https://www.csfd.sk/tvorca/429714-tatjana-popova/	Actor
2154	Sergej Šimko	\N	https://www.csfd.sk/tvorca/412266-sergej-simko/	Actor
2157	Igor Děnisov	\N	https://www.csfd.sk/tvorca/444676-igor-denisov/	Actor
2159	Nikita Stěpanov	\N	https://www.csfd.sk/tvorca/332476-nikita-stepanov/	Actor
2160	Larisa Maršalova	\N	https://www.csfd.sk/tvorca/327358-larisa-marsalova/	Actor
2166	Vladislav Větrov	\N	https://www.csfd.sk/tvorca/88554-vladislav-vetrov/	Actor
2167	Světlana Kožemjakina	\N	https://www.csfd.sk/tvorca/298183-svetlana-kozemjakina/	Actor
2172	Konstantin Koňuchov	\N	https://www.csfd.sk/tvorca/416531-konstantin-konuchov/	Actor
2174	Tamara Muženko	\N	https://www.csfd.sk/tvorca/375466-tamara-muzenko/	Actor
2175	Alexandra Ťuftěj	\N	https://www.csfd.sk/tvorca/142528-alexandra-tuftej/	Actor
2178	Alexandr Ždanovič	\N	https://www.csfd.sk/tvorca/444025-alexandr-zdanovic/	Actor
2179	Jevgenij Ivkovič	\N	https://www.csfd.sk/tvorca/444629-jevgenij-ivkovic/	Actor
2180	Vitalij Kiščenko	\N	https://www.csfd.sk/tvorca/80638-vitalij-kiscenko/	Actor
2181	Taťjana Kalich	\N	https://www.csfd.sk/tvorca/222457-tatjana-kalich/	Actor
2184	Vitalij Kravčenko	\N	https://www.csfd.sk/tvorca/173530-vitalij-kravcenko/	Actor
2185	Sergej Šulga	\N	https://www.csfd.sk/tvorca/310390-sergej-sulga/	Actor
2186	Andrej Dušečkin	\N	https://www.csfd.sk/tvorca/271546-andrej-duseckin/	Actor
2187	Anatolij Gorjačev	\N	https://www.csfd.sk/tvorca/223274-anatolij-gorjacev/	Actor
2192	Dmitrij Glazačev	\N	https://www.csfd.sk/tvorca/429700-dmitrij-glazacev/	Actor
2194	Maxim Krečetov	\N	https://www.csfd.sk/tvorca/415433-maxim-krecetov/	Actor
2198	Sergej Žuravel	\N	https://www.csfd.sk/tvorca/267506-sergej-zuravel/	Actor
2200	Polina Syrkina	\N	https://www.csfd.sk/tvorca/134903-polina-syrkina/	Actor
2201	Anna Polupanova	\N	https://www.csfd.sk/tvorca/415443-anna-polupanova/	Actor
2202	Valentina Garcujeva	\N	https://www.csfd.sk/tvorca/286832-valentina-garcujeva/	Actor
2203	Jevgenij Nikitin	\N	https://www.csfd.sk/tvorca/359067-jevgenij-nikitin/	Actor
2204	Boris Polunin	\N	https://www.csfd.sk/tvorca/123460-boris-polunin/	Actor
2205	Ivan Mochovikov	\N	https://www.csfd.sk/tvorca/456308-ivan-mochovikov/	Actor
2206	Ivan Pavlov	\N	https://www.csfd.sk/tvorca/456316-ivan-pavlov/	Actor
2207	Inna Dymskaja	\N	https://www.csfd.sk/tvorca/456317-inna-dymskaja/	Actor
2211	Alexandr Bargman	\N	https://www.csfd.sk/tvorca/35999-alexandr-bargman/	Actor
2212	Kirill Mugajskich	\N	https://www.csfd.sk/tvorca/471541-kirill-mugajskich/	Actor
2213	Olga Toropova	\N	https://www.csfd.sk/tvorca/486868-olga-toropova/	Actor
2217	Zinaida Matrosova	\N	https://www.csfd.sk/tvorca/513562-zinaida-matrosova/	Actor
2219	Semjon Ivanov	\N	https://www.csfd.sk/tvorca/584969-semjon-ivanov/	Actor
2221	Alexej Sorov	\N	https://www.csfd.sk/tvorca/593692-alexej-sorov/	Actor
2223	Ljubov Rumjanceva	\N	https://www.csfd.sk/tvorca/655573-ljubov-rumjanceva/	Actor
2224	Stuart Whitman	\N	https://www.csfd.sk/tvorca/15012-stuart-whitman/	Actor
2225	Robert Wagner	\N	https://www.csfd.sk/tvorca/8946-robert-wagner/	Actor
2226	Glenn Corbett	\N	https://www.csfd.sk/tvorca/133793-glenn-corbett/	Actor
2227	Rosemary Forsyth	\N	https://www.csfd.sk/tvorca/20427-rosemary-forsyth/	Actor
2229	Richard Basehart	\N	https://www.csfd.sk/tvorca/58342-richard-basehart/	Actor
2230	Joseph Cotten	\N	https://www.csfd.sk/tvorca/195-joseph-cotten/	Actor
2231	James Darren	\N	https://www.csfd.sk/tvorca/63646-james-darren/	Actor
2232	Paul Stewart	\N	https://www.csfd.sk/tvorca/98179-paul-stewart/	Actor
2233	Tom Drake	\N	https://www.csfd.sk/tvorca/88555-tom-drake/	Actor
2234	Charles Dierkop	\N	https://www.csfd.sk/tvorca/49703-charles-dierkop/	Actor
2235	Lloyd Bochner	\N	https://www.csfd.sk/tvorca/93789-lloyd-bochner/	Actor
2236	Francine York	\N	https://www.csfd.sk/tvorca/102105-francine-york/	Actor
2237	William Bryant	\N	https://www.csfd.sk/tvorca/155002-william-bryant/	Actor
2238	Larry Pennell	\N	https://www.csfd.sk/tvorca/198956-larry-pennell/	Actor
2239	Sheila Allen	\N	https://www.csfd.sk/tvorca/228515-sheila-allen/	Actor
2240	Robert Colbert	\N	https://www.csfd.sk/tvorca/246458-robert-colbert/	Actor
2241	Lawrence Montaigne	\N	https://www.csfd.sk/tvorca/302075-lawrence-montaigne/	Actor
2242	Norman Grabowski	\N	https://www.csfd.sk/tvorca/400350-norman-grabowski/	Actor
2243	George Holmes	\N	https://www.csfd.sk/tvorca/458555-george-holmes/	Actor
2245	Johnny Lee	\N	https://www.csfd.sk/tvorca/852842-johnny-lee/	Actor
2246	Ray Didsbury	\N	https://www.csfd.sk/tvorca/872436-ray-didsbury/	Actor
2247	Red Buttons	\N	https://www.csfd.sk/tvorca/5764-red-buttons/	Actor
2248	Fabian	\N	https://www.csfd.sk/tvorca/71514-fabian/	Actor
2249	Barbara Eden	\N	https://www.csfd.sk/tvorca/5248-barbara-eden/	Actor
2250	Cedric Hardwicke	\N	https://www.csfd.sk/tvorca/7517-cedric-hardwicke/	Actor
2251	Peter Lorre	\N	https://www.csfd.sk/tvorca/842-peter-lorre/	Actor
2252	Richard Haydn	\N	https://www.csfd.sk/tvorca/11331-richard-haydn/	Actor
2254	Billy Gilbert	\N	https://www.csfd.sk/tvorca/82711-billy-gilbert/	Actor
2255	Herbert Marshall	\N	https://www.csfd.sk/tvorca/5454-herbert-marshall/	Actor
2256	Reginald Owen	\N	https://www.csfd.sk/tvorca/93778-reginald-owen/	Actor
2257	Henry Daniell	\N	https://www.csfd.sk/tvorca/84602-henry-daniell/	Actor
2258	Mike Mazurki	\N	https://www.csfd.sk/tvorca/60426-mike-mazurki/	Actor
2259	Vic Tayback	\N	https://www.csfd.sk/tvorca/89475-vic-tayback/	Actor
2260	Roy Jenson	\N	https://www.csfd.sk/tvorca/123670-roy-jenson/	Actor
2261	Raymond Bailey	\N	https://www.csfd.sk/tvorca/134112-raymond-bailey/	Actor
2262	Ronald Long	\N	https://www.csfd.sk/tvorca/287448-ronald-long/	Actor
2263	Scott Seaton	\N	https://www.csfd.sk/tvorca/291240-scott-seaton/	Actor
2264	Alan Caillou	\N	https://www.csfd.sk/tvorca/325666-alan-caillou/	Actor
2265	Hedley Mattingly	\N	https://www.csfd.sk/tvorca/348375-hedley-mattingly/	Actor
2266	Loren Lester	\N	https://www.csfd.sk/tvorca/370935-loren-lester/	Actor
2267	George Sawaya	\N	https://www.csfd.sk/tvorca/401322-george-sawaya/	Actor
2268	Joe Abdullah	\N	https://www.csfd.sk/tvorca/419131-joe-abdullah/	Actor
2269	Mike De Anda	\N	https://www.csfd.sk/tvorca/443005-mike-de-anda/	Actor
2270	Ben Astar	\N	https://www.csfd.sk/tvorca/462529-ben-astar/	Actor
2271	Michael Rennie	\N	https://www.csfd.sk/tvorca/35946-michael-rennie/	Actor
2273	David Hedison	\N	https://www.csfd.sk/tvorca/32100-david-hedison/	Actor
2274	Claude Rains	\N	https://www.csfd.sk/tvorca/2460-claude-rains/	Actor
2275	Fernando Lamas	\N	https://www.csfd.sk/tvorca/67191-fernando-lamas/	Actor
2276	Ray Stricklyn	\N	https://www.csfd.sk/tvorca/95936-ray-stricklyn/	Actor
2209	Larisa Něgrejeva-Cesljak	\N	https://www.csfd.sk/tvorca/456805-larisa-negrejeva-cesljak/	Actor
2210	Světlana Svibilskaja	\N	https://www.csfd.sk/tvorca/467336-svetlana-svibilskaja/	Actor
2214	Michail Stankevič	\N	https://www.csfd.sk/tvorca/492559-michail-stankevic/	Actor
2215	Alexej Ryžkov	\N	https://www.csfd.sk/tvorca/496967-alexej-ryzkov/	Actor
2216	Margarita Šilova	\N	https://www.csfd.sk/tvorca/511086-margarita-silova/	Actor
2220	Georgij Teslja-Gerasimov	\N	https://www.csfd.sk/tvorca/592908-georgij-teslja-gerasimov/	Actor
2222	Vjačeslav Pavljuť	\N	https://www.csfd.sk/tvorca/649237-vjaceslav-pavljut/	Actor
2228	Burr DeBenning	\N	https://www.csfd.sk/tvorca/292058-burr-debenning/	Actor
2244	Edward G. Robinson Jr.	\N	https://www.csfd.sk/tvorca/781810-edward-g-robinson-jr/	Actor
2253	BarBara Luna	\N	https://www.csfd.sk/tvorca/50522-barbara-luna/	Actor
2272	Jill St. John	\N	https://www.csfd.sk/tvorca/21149-jill-st-john/	Actor
2277	Jay Novello	\N	https://www.csfd.sk/tvorca/258521-jay-novello/	Actor
2278	Ian Wolfe	\N	https://www.csfd.sk/tvorca/138859-ian-wolfe/	Actor
2279	Brian Roper	\N	https://www.csfd.sk/tvorca/98010-brian-roper/	Actor
2280	Ben Wright	\N	https://www.csfd.sk/tvorca/123885-ben-wright/	Actor
2281	Bess Flowers	\N	https://www.csfd.sk/tvorca/131978-bess-flowers/	Actor
2282	Bert Stevens	\N	https://www.csfd.sk/tvorca/134899-bert-stevens/	Actor
2284	Sam Harris	\N	https://www.csfd.sk/tvorca/135753-sam-harris/	Actor
2285	Harold Miller	\N	https://www.csfd.sk/tvorca/135762-harold-miller/	Actor
2286	Cosmo Sardo	\N	https://www.csfd.sk/tvorca/181086-cosmo-sardo/	Actor
2287	Peter Fontaine	\N	https://www.csfd.sk/tvorca/290964-peter-fontaine/	Actor
2288	George Pelling	\N	https://www.csfd.sk/tvorca/301053-george-pelling/	Actor
2289	Larry Chance	\N	https://www.csfd.sk/tvorca/338721-larry-chance/	Actor
2290	Gilchrist Stuart	\N	https://www.csfd.sk/tvorca/348379-gilchrist-stuart/	Actor
2291	Murray Pollack	\N	https://www.csfd.sk/tvorca/380910-murray-pollack/	Actor
2292	Owen Song	\N	https://www.csfd.sk/tvorca/467210-owen-song/	Actor
2293	Fred Cavens	\N	https://www.csfd.sk/tvorca/572617-fred-cavens/	Actor
2294	Winona Ryder	\N	https://www.csfd.sk/tvorca/162-winona-ryder/	Actor
2295	Jeff Daniels	\N	https://www.csfd.sk/tvorca/386-jeff-daniels/	Actor
2296	Graham Beckel	\N	https://www.csfd.sk/tvorca/16318-graham-beckel/	Actor
2297	Frances Fisher	\N	https://www.csfd.sk/tvorca/5711-frances-fisher/	Actor
2298	Dinah Manoff	\N	https://www.csfd.sk/tvorca/87114-dinah-manoff/	Actor
2299	Stephen Tobolowsky	\N	https://www.csfd.sk/tvorca/294-stephen-tobolowsky/	Actor
2300	Robby Kiger	\N	https://www.csfd.sk/tvorca/310621-robby-kiger/	Actor
2301	Robin Thomas	\N	https://www.csfd.sk/tvorca/16633-robin-thomas/	Actor
2302	Valerie Landsburg	\N	https://www.csfd.sk/tvorca/22067-valerie-landsburg/	Actor
2303	Carla Gugino	\N	https://www.csfd.sk/tvorca/5842-carla-gugino/	Actor
2304	Angela Paton	\N	https://www.csfd.sk/tvorca/79681-angela-paton/	Actor
2305	Thomas Wilson Brown	\N	https://www.csfd.sk/tvorca/86944-thomas-wilson-brown/	Actor
2306	Rob King	\N	https://www.csfd.sk/tvorca/116498-rob-king/	Actor
2307	Laila Robins	\N	https://www.csfd.sk/tvorca/149414-laila-robins/	Actor
2308	Jim Pirri	\N	https://www.csfd.sk/tvorca/184155-jim-pirri/	Actor
2309	Terrence Evans	\N	https://www.csfd.sk/tvorca/218078-terrence-evans/	Actor
2310	Micole Mercurio	\N	https://www.csfd.sk/tvorca/224604-micole-mercurio/	Actor
2311	Rhonda Aldrich	\N	https://www.csfd.sk/tvorca/242023-rhonda-aldrich/	Actor
2312	John Short	\N	https://www.csfd.sk/tvorca/257940-john-short/	Actor
2313	Ron Perkins	\N	https://www.csfd.sk/tvorca/282468-ron-perkins/	Actor
2314	Carl Steven	\N	https://www.csfd.sk/tvorca/325961-carl-steven/	Actor
2315	Nada Despotovich	\N	https://www.csfd.sk/tvorca/343805-nada-despotovich/	Actor
2316	Vince Trankina	\N	https://www.csfd.sk/tvorca/379536-vince-trankina/	Actor
2317	Joe Nesnow	\N	https://www.csfd.sk/tvorca/385413-joe-nesnow/	Actor
2318	Hal Havins	\N	https://www.csfd.sk/tvorca/416924-hal-havins/	Actor
2319	Stephen Burrows	\N	https://www.csfd.sk/tvorca/424200-stephen-burrows/	Actor
2321	Kevin Skousen	\N	https://www.csfd.sk/tvorca/498804-kevin-skousen/	Actor
2322	Damion Dietz	\N	https://www.csfd.sk/tvorca/572850-damion-dietz/	Actor
2323	Charlie Holliday	\N	https://www.csfd.sk/tvorca/644524-charlie-holliday/	Actor
2324	Amy Moore Davis	\N	https://www.csfd.sk/tvorca/660261-amy-moore-davis/	Actor
2325	Ava Fabian	\N	https://www.csfd.sk/tvorca/687789-ava-fabian/	Actor
2326	Meg Harrington	\N	https://www.csfd.sk/tvorca/753964-meg-harrington/	Actor
2327	Rocky Krakoff	\N	https://www.csfd.sk/tvorca/869726-rocky-krakoff/	Actor
2328	Joey Bishop	\N	https://www.csfd.sk/tvorca/19898-joey-bishop/	Actor
2329	Madeline Kahn	\N	https://www.csfd.sk/tvorca/6475-madeline-kahn/	Actor
2332	Joe Pesci	\N	https://www.csfd.sk/tvorca/460-joe-pesci/	Actor
2333	Molly Ringwald	\N	https://www.csfd.sk/tvorca/586-molly-ringwald/	Actor
2334	Ally Sheedy	\N	https://www.csfd.sk/tvorca/2047-ally-sheedy/	Actor
2335	Burt Young	\N	https://www.csfd.sk/tvorca/16659-burt-young/	Actor
2336	Julie Bovasso	\N	https://www.csfd.sk/tvorca/291812-julie-bovasso/	Actor
2337	Bibi Besch	\N	https://www.csfd.sk/tvorca/98149-bibi-besch/	Actor
2338	Dylan Walsh	\N	https://www.csfd.sk/tvorca/16648-dylan-walsh/	Actor
2339	Frankie Faison	\N	https://www.csfd.sk/tvorca/11947-frankie-faison/	Actor
2341	Tom Mardirosian	\N	https://www.csfd.sk/tvorca/37909-tom-mardirosian/	Actor
2343	Camille Saviola	\N	https://www.csfd.sk/tvorca/58570-camille-saviola/	Actor
2344	Allan Rich	\N	https://www.csfd.sk/tvorca/152473-allan-rich/	Actor
2345	Sully Boyar	\N	https://www.csfd.sk/tvorca/244453-sully-boyar/	Actor
2346	Larry Block	\N	https://www.csfd.sk/tvorca/334040-larry-block/	Actor
2347	Helen Hanft	\N	https://www.csfd.sk/tvorca/391741-helen-hanft/	Actor
2348	Larry Rapp	\N	https://www.csfd.sk/tvorca/770332-larry-rapp/	Actor
2349	Mario Todisco	\N	https://www.csfd.sk/tvorca/853600-mario-todisco/	Actor
2350	Hal Linden	\N	https://www.csfd.sk/tvorca/52217-hal-linden/	Actor
2352	Veronica Hamel	\N	https://www.csfd.sk/tvorca/5841-veronica-hamel/	Actor
2353	John Shea	\N	https://www.csfd.sk/tvorca/6482-john-shea/	Actor
2354	Mary Kay Place	\N	https://www.csfd.sk/tvorca/8778-mary-kay-place/	Actor
2355	Beatrice Alda	\N	https://www.csfd.sk/tvorca/129781-beatrice-alda/	Actor
2320	Joan McMurtrey	\N	https://www.csfd.sk/tvorca/436258-joan-mcmurtrey/	Actor
2330	Anthony LaPaglia	\N	https://www.csfd.sk/tvorca/2511-anthony-lapaglia/	Actor
2331	Catherine O'Hara	\N	https://www.csfd.sk/tvorca/1803-catherine-o-hara/	Actor
2342	Harry L. Seddon	\N	https://www.csfd.sk/tvorca/58374-harry-l-seddon/	Actor
2351	Ann-Margret	\N	https://www.csfd.sk/tvorca/5169-ann-margret/	Actor
2356	Victoria Snow	\N	https://www.csfd.sk/tvorca/14529-victoria-snow/	Actor
2357	John Kozak	\N	https://www.csfd.sk/tvorca/8317-john-kozak/	Actor
2358	Barry Flatman	\N	https://www.csfd.sk/tvorca/9937-barry-flatman/	Actor
2360	Celia Weston	\N	https://www.csfd.sk/tvorca/1835-celia-weston/	Actor
2361	Fiona Reid	\N	https://www.csfd.sk/tvorca/18914-fiona-reid/	Actor
2362	Paul Hecht	\N	https://www.csfd.sk/tvorca/59345-paul-hecht/	Actor
2363	Catherine Disher	\N	https://www.csfd.sk/tvorca/86133-catherine-disher/	Actor
2364	Michael Kirby	\N	https://www.csfd.sk/tvorca/214897-michael-kirby/	Actor
2366	Malcolm Stewart	\N	https://www.csfd.sk/tvorca/283495-malcolm-stewart/	Actor
2367	Deborah Theaker	\N	https://www.csfd.sk/tvorca/507199-deborah-theaker/	Actor
2368	David Eisner	\N	https://www.csfd.sk/tvorca/324374-david-eisner/	Actor
2369	Alec Mapa	\N	https://www.csfd.sk/tvorca/594879-alec-mapa/	Actor
2370	Mark Terry	\N	https://www.csfd.sk/tvorca/601015-mark-terry/	Actor
2371	Janet Bailey	\N	https://www.csfd.sk/tvorca/660759-janet-bailey/	Actor
2373	Cynthia Belliveau	\N	https://www.csfd.sk/tvorca/870707-cynthia-belliveau/	Actor
2374	Eve Crawford	\N	https://www.csfd.sk/tvorca/926794-eve-crawford/	Actor
2375	Sally Field	\N	https://www.csfd.sk/tvorca/541-sally-field/	Actor
2376	Telly Savalas	\N	https://www.csfd.sk/tvorca/2282-telly-savalas/	Actor
2377	Peter Boyle	\N	https://www.csfd.sk/tvorca/359-peter-boyle/	Actor
2378	Jack Warden	\N	https://www.csfd.sk/tvorca/506-jack-warden/	Actor
2379	Shirley Knight	\N	https://www.csfd.sk/tvorca/7664-shirley-knight/	Actor
2380	Shirley Jones	\N	https://www.csfd.sk/tvorca/6258-shirley-jones/	Actor
2381	Karl Malden	\N	https://www.csfd.sk/tvorca/4263-karl-malden/	Actor
2382	Slim Pickens	\N	https://www.csfd.sk/tvorca/50346-slim-pickens/	Actor
2383	Angela Cartwright	\N	https://www.csfd.sk/tvorca/72443-angela-cartwright/	Actor
2384	Mark Harmon	\N	https://www.csfd.sk/tvorca/1802-mark-harmon/	Actor
2385	Dean Raphael Ferrandini	\N	https://www.csfd.sk/tvorca/88981-dean-raphael-ferrandini/	Actor
2386	Paul Picerni	\N	https://www.csfd.sk/tvorca/123056-paul-picerni/	Actor
2387	Patrick Culliton	\N	https://www.csfd.sk/tvorca/305474-patrick-culliton/	Actor
2388	Carol Burnett	\N	https://www.csfd.sk/tvorca/12868-carol-burnett/	Actor
2389	Len Cariou	\N	https://www.csfd.sk/tvorca/59330-len-cariou/	Actor
2390	Sandy Dennis	\N	https://www.csfd.sk/tvorca/6251-sandy-dennis/	Actor
2391	Rita Moreno	\N	https://www.csfd.sk/tvorca/6257-rita-moreno/	Actor
2392	Jack Weston	\N	https://www.csfd.sk/tvorca/11485-jack-weston/	Actor
2393	Bess Armstrong	\N	https://www.csfd.sk/tvorca/6044-bess-armstrong/	Actor
2394	Elizabeth Alda	\N	https://www.csfd.sk/tvorca/129780-elizabeth-alda/	Actor
2395	Jim Abrahams	\N	https://www.csfd.sk/tvorca/2796-jim-abrahams/prehlad/	Director
2396	Bette Midler	\N	https://www.csfd.sk/tvorca/572-bette-midler/prehlad/	Actor
2397	Lily Tomlin	\N	https://www.csfd.sk/tvorca/1896-lily-tomlin/prehlad/	Actor
2398	Fred Ward	\N	https://www.csfd.sk/tvorca/105-fred-ward/prehlad/	Actor
2399	Edward Herrmann	\N	https://www.csfd.sk/tvorca/14165-edward-herrmann/prehlad/	Actor
2400	Michele Placido	\N	https://www.csfd.sk/tvorca/4870-michele-placido/prehlad/	Actor
2401	Barry Primus	\N	https://www.csfd.sk/tvorca/3427-barry-primus/prehlad/	Actor
2402	Michael Gross	\N	https://www.csfd.sk/tvorca/2354-michael-gross/prehlad/	Actor
2403	Deborah Rush	\N	https://www.csfd.sk/tvorca/56966-deborah-rush/prehlad/	Actor
2404	Nicolas Coster	\N	https://www.csfd.sk/tvorca/13400-nicolas-coster/prehlad/	Actor
2405	Joe Grifasi	\N	https://www.csfd.sk/tvorca/5304-joe-grifasi/prehlad/	Actor
2406	John Hancock	\N	https://www.csfd.sk/tvorca/7945-john-hancock/prehlad/	Actor
2407	Seth Green	\N	https://www.csfd.sk/tvorca/6420-seth-green/prehlad/	Actor
2408	Leo Burmester	\N	https://www.csfd.sk/tvorca/19917-leo-burmester/prehlad/	Actor
2409	Lewis Arquette	\N	https://www.csfd.sk/tvorca/19869-lewis-arquette/prehlad/	Actor
2410	Carmen Argenziano	\N	https://www.csfd.sk/tvorca/2518-carmen-argenziano/prehlad/	Actor
2411	Mary Gross	\N	https://www.csfd.sk/tvorca/59043-mary-gross/prehlad/	Actor
2412	Maureen McVerry	\N	https://www.csfd.sk/tvorca/85854-maureen-mcverry/prehlad/	Actor
2413	Ryan Francis	\N	https://www.csfd.sk/tvorca/102514-ryan-francis/prehlad/	Actor
2414	Shirley Mitchell	\N	https://www.csfd.sk/tvorca/162028-shirley-mitchell/prehlad/	Actor
2415	Roy Brocksmith	\N	https://www.csfd.sk/tvorca/205285-roy-brocksmith/prehlad/	Actor
2416	John Vickery	\N	https://www.csfd.sk/tvorca/207074-john-vickery/prehlad/	Actor
2417	Everett Quinton	\N	https://www.csfd.sk/tvorca/219293-everett-quinton/prehlad/	Actor
2418	J.C. Quinn	\N	https://www.csfd.sk/tvorca/226818-j-c-quinn/prehlad/	Actor
2419	Ritch Brinkley	\N	https://www.csfd.sk/tvorca/226825-ritch-brinkley/prehlad/	Actor
2420	Fred Parnes	\N	https://www.csfd.sk/tvorca/294247-fred-parnes/prehlad/	Actor
2421	Patricia Gaul	\N	https://www.csfd.sk/tvorca/296453-patricia-gaul/prehlad/	Actor
2422	Al Mancini	\N	https://www.csfd.sk/tvorca/314139-al-mancini/prehlad/	Actor
2423	Hunter von Leer	\N	https://www.csfd.sk/tvorca/323791-hunter-von-leer/prehlad/	Actor
2424	Lucy Webb	\N	https://www.csfd.sk/tvorca/355404-lucy-webb/prehlad/	Actor
2425	Crystal Field	\N	https://www.csfd.sk/tvorca/368200-crystal-field/prehlad/	Actor
2426	Daniel Gerroll	\N	https://www.csfd.sk/tvorca/376129-daniel-gerroll/prehlad/	Actor
2427	Lois De Banzie	\N	https://www.csfd.sk/tvorca/383875-lois-de-banzie/prehlad/	Actor
2428	Chick Hearn	\N	https://www.csfd.sk/tvorca/408146-chick-hearn/prehlad/	Actor
2429	Andi Chapman	\N	https://www.csfd.sk/tvorca/593228-andi-chapman/prehlad/	Actor
2430	Tom La Grua	\N	https://www.csfd.sk/tvorca/753920-tom-la-grua/prehlad/	Actor
2431	Norma MacMillan	\N	https://www.csfd.sk/tvorca/827759-norma-macmillan/prehlad/	Actor
2365	C. David Johnson	\N	https://www.csfd.sk/tvorca/269467-c-david-johnson/	Actor
2372	Deann DeGruijter	\N	https://www.csfd.sk/tvorca/826935-deann-degruijter/	Actor
2432	Kathryn Janssen	\N	https://www.csfd.sk/tvorca/925221-kathryn-janssen/prehlad/	Actor
2433	Meryl Streep	\N	https://www.csfd.sk/tvorca/589-meryl-streep/prehlad/	Actor
2434	Seth Adkins	\N	https://www.csfd.sk/tvorca/9810-seth-adkins/prehlad/	Actor
2435	Allison Janney	\N	https://www.csfd.sk/tvorca/1847-allison-janney/prehlad/	Actor
2436	Margo Martindale	\N	https://www.csfd.sk/tvorca/17698-margo-martindale/prehlad/	Actor
2437	Oni Faida Lampley	\N	https://www.csfd.sk/tvorca/37394-oni-faida-lampley/prehlad/	Actor
2438	Mairon Bennett	\N	https://www.csfd.sk/tvorca/38627-mairon-bennett/prehlad/	Actor
2439	Kyra Harper	\N	https://www.csfd.sk/tvorca/49359-kyra-harper/prehlad/	Actor
2440	Ingrid Veninger	\N	https://www.csfd.sk/tvorca/60601-ingrid-veninger/prehlad/	Actor
2441	Marcia Bennett	\N	https://www.csfd.sk/tvorca/8038-marcia-bennett/prehlad/	Actor
2442	Tom Butler	\N	https://www.csfd.sk/tvorca/77300-tom-butler/prehlad/	Actor
2443	Sean McCann	\N	https://www.csfd.sk/tvorca/85359-sean-mccann/prehlad/	Actor
2444	Lynne Griffin	\N	https://www.csfd.sk/tvorca/95705-lynne-griffin/prehlad/	Actor
2445	Jennifer Podemski	\N	https://www.csfd.sk/tvorca/217702-jennifer-podemski/prehlad/	Actor
2446	Lorna Wilson	\N	https://www.csfd.sk/tvorca/261042-lorna-wilson/prehlad/	Actor
2447	Philip Akin	\N	https://www.csfd.sk/tvorca/298289-philip-akin/prehlad/	Actor
2448	Ann Holloway	\N	https://www.csfd.sk/tvorca/615946-ann-holloway/prehlad/	Actor
2449	Michael Yarmush	\N	https://www.csfd.sk/tvorca/651058-michael-yarmush/prehlad/	Actor
2450	Michael G. Brown	\N	https://www.csfd.sk/tvorca/922649-michael-g-brown/prehlad/	Actor
2451	Timm Zemanek	\N	https://www.csfd.sk/tvorca/939367-timm-zemanek/prehlad/	Actor
2452	Tannis Burnett	\N	https://www.csfd.sk/tvorca/953514-tannis-burnett/prehlad/	Actor
2453	Jerry Zucker	\N	https://www.csfd.sk/tvorca/3142-jerry-zucker/prehlad/	Director
2454	David Zucker	\N	https://www.csfd.sk/tvorca/3141-david-zucker/prehlad/	Director
2455	Robert Hays	\N	https://www.csfd.sk/tvorca/416-robert-hays/prehlad/	Actor
2456	Julie Hagerty	\N	https://www.csfd.sk/tvorca/6454-julie-hagerty/prehlad/	Actor
2457	Lloyd Bridges	\N	https://www.csfd.sk/tvorca/362-lloyd-bridges/prehlad/	Actor
2458	Leslie Nielsen	\N	https://www.csfd.sk/tvorca/863-leslie-nielsen/prehlad/	Actor
2459	Robert Stack	\N	https://www.csfd.sk/tvorca/11462-robert-stack/prehlad/	Actor
2460	Peter Graves	\N	https://www.csfd.sk/tvorca/13984-peter-graves/prehlad/	Actor
2461	Kareem Abdul-Jabbar	\N	https://www.csfd.sk/tvorca/6764-kareem-abdul-jabbar/prehlad/	Actor
2462	Jonathan Banks	\N	https://www.csfd.sk/tvorca/16312-jonathan-banks/prehlad/	Actor
2463	Barbara Billingsley	\N	https://www.csfd.sk/tvorca/23444-barbara-billingsley/prehlad/	Actor
2464	James Hong	\N	https://www.csfd.sk/tvorca/7180-james-hong/prehlad/	Actor
2465	Ethel Merman	\N	https://www.csfd.sk/tvorca/2405-ethel-merman/prehlad/	Actor
2466	Kenneth Tobey	\N	https://www.csfd.sk/tvorca/17999-kenneth-tobey/prehlad/	Actor
2467	Conrad E. Palmisano	\N	https://www.csfd.sk/tvorca/50882-conrad-e-palmisano/prehlad/	Actor
2468	Gregory Itzin	\N	https://www.csfd.sk/tvorca/57550-gregory-itzin/prehlad/	Actor
2469	Al White	\N	https://www.csfd.sk/tvorca/87183-al-white/prehlad/	Actor
2470	Cyril O'Reilly	\N	https://www.csfd.sk/tvorca/87337-cyril-o-reilly/prehlad/	Actor
2471	Jimmie 'JJ' Walker	\N	https://www.csfd.sk/tvorca/94430-jimmie-jj-walker/prehlad/	Actor
2472	William Duell	\N	https://www.csfd.sk/tvorca/97874-william-duell/prehlad/	Actor
2473	Rossie Harris	\N	https://www.csfd.sk/tvorca/111221-rossie-harris/prehlad/	Actor
2474	Nicholas Pryor	\N	https://www.csfd.sk/tvorca/131676-nicholas-pryor/prehlad/	Actor
2475	Barbara Stuart	\N	https://www.csfd.sk/tvorca/133774-barbara-stuart/prehlad/	Actor
2476	Herb Vigran	\N	https://www.csfd.sk/tvorca/134966-herb-vigran/prehlad/	Actor
2477	Joyce Mandel	\N	https://www.csfd.sk/tvorca/136325-joyce-mandel/prehlad/	Actor
2478	Michelle Stacy	\N	https://www.csfd.sk/tvorca/236014-michelle-stacy/prehlad/	Actor
2479	John O'Leary	\N	https://www.csfd.sk/tvorca/236019-john-o-leary/prehlad/	Actor
2480	Jill Whelan	\N	https://www.csfd.sk/tvorca/249569-jill-whelan/prehlad/	Actor
2481	Lee Terri	\N	https://www.csfd.sk/tvorca/254579-lee-terri/prehlad/	Actor
2482	Michael Laurence	\N	https://www.csfd.sk/tvorca/269413-michael-laurence/prehlad/	Actor
2483	Lee Bryant	\N	https://www.csfd.sk/tvorca/288401-lee-bryant/prehlad/	Actor
2484	Jason Wingreen	\N	https://www.csfd.sk/tvorca/312947-jason-wingreen/prehlad/	Actor
2485	Herb Voland	\N	https://www.csfd.sk/tvorca/347304-herb-voland/prehlad/	Actor
2486	Ann Nelson	\N	https://www.csfd.sk/tvorca/369988-ann-nelson/prehlad/	Actor
2487	Bill Kirchenbauer	\N	https://www.csfd.sk/tvorca/370586-bill-kirchenbauer/prehlad/	Actor
2488	Joyce Bulifant	\N	https://www.csfd.sk/tvorca/262216-joyce-bulifant/prehlad/	Actor
2489	Robert Starr	\N	https://www.csfd.sk/tvorca/429431-robert-starr/prehlad/	Actor
2490	Mary Mercier	\N	https://www.csfd.sk/tvorca/461789-mary-mercier/prehlad/	Actor
2491	Marcy Goldman	\N	https://www.csfd.sk/tvorca/542573-marcy-goldman/prehlad/	Actor
2492	Kitten Natividad	\N	https://www.csfd.sk/tvorca/590024-kitten-natividad/prehlad/	Actor
2493	Maurice Hill	\N	https://www.csfd.sk/tvorca/667318-maurice-hill/prehlad/	Actor
2494	Stephen Stucker	\N	https://www.csfd.sk/tvorca/698227-stephen-stucker/prehlad/	Actor
2495	Leoda Richards	\N	https://www.csfd.sk/tvorca/559694-leoda-richards/prehlad/	Actor
2496	Frank Ashmore	\N	https://www.csfd.sk/tvorca/746218-frank-ashmore/prehlad/	Actor
2497	Lorna Patterson	\N	https://www.csfd.sk/tvorca/746245-lorna-patterson/prehlad/	Actor
2498	Maureen McGovern	\N	https://www.csfd.sk/tvorca/746288-maureen-mcgovern/prehlad/	Actor
2499	Howard Honig	\N	https://www.csfd.sk/tvorca/559638-howard-honig/prehlad/	Actor
2500	Sig Frohlich	\N	https://www.csfd.sk/tvorca/775828-sig-frohlich/prehlad/	Actor
2501	Nora Meerbaum	\N	https://www.csfd.sk/tvorca/831002-nora-meerbaum/prehlad/	Actor
2502	Jay Mohr	\N	https://www.csfd.sk/tvorca/7277-jay-mohr/prehlad/	Actor
2503	Billy Burke	\N	https://www.csfd.sk/tvorca/5336-billy-burke/prehlad/	Actor
3051	Cynthia Adler	\N	https://www.csfd.sk/tvorca/4864-cynthia-adler/	Actor
2504	Christina Applegate	\N	https://www.csfd.sk/tvorca/1929-christina-applegate/prehlad/	Actor
2505	Pamela Gidley	\N	https://www.csfd.sk/tvorca/2487-pamela-gidley/prehlad/	Actor
2506	Olympia Dukakis	\N	https://www.csfd.sk/tvorca/6237-olympia-dukakis/prehlad/	Actor
2507	Jason Fuchs	\N	https://www.csfd.sk/tvorca/20016-jason-fuchs/prehlad/	Actor
2508	Joe Viterelli	\N	https://www.csfd.sk/tvorca/15223-joe-viterelli/prehlad/	Actor
2509	Tony Lo Bianco	\N	https://www.csfd.sk/tvorca/5672-tony-lo-bianco/prehlad/	Actor
2510	Vincent Pastore	\N	https://www.csfd.sk/tvorca/9122-vincent-pastore/prehlad/	Actor
2511	Marisol Nichols	\N	https://www.csfd.sk/tvorca/6061-marisol-nichols/prehlad/	Actor
2512	Louis Mandylor	\N	https://www.csfd.sk/tvorca/57431-louis-mandylor/prehlad/	Actor
2513	Andreas Katsulas	\N	https://www.csfd.sk/tvorca/429-andreas-katsulas/prehlad/	Actor
2514	Stefan Lysenko	\N	https://www.csfd.sk/tvorca/49441-stefan-lysenko/prehlad/	Actor
2515	Sofia Milos	\N	https://www.csfd.sk/tvorca/34413-sofia-milos/prehlad/	Actor
2516	Gerald Emerick	\N	https://www.csfd.sk/tvorca/23251-gerald-emerick/prehlad/	Actor
2517	Frank Welker	\N	https://www.csfd.sk/tvorca/22967-frank-welker/prehlad/	Actor
2518	Deep Roy	\N	https://www.csfd.sk/tvorca/30368-deep-roy/prehlad/	Actor
2519	Sherman Hemsley	\N	https://www.csfd.sk/tvorca/81371-sherman-hemsley/prehlad/	Actor
2520	Isabel Sanford	\N	https://www.csfd.sk/tvorca/81377-isabel-sanford/prehlad/	Actor
2521	Larry Laverty	\N	https://www.csfd.sk/tvorca/82627-larry-laverty/prehlad/	Actor
2522	Karen Leigh Hopkins	\N	https://www.csfd.sk/tvorca/113774-karen-leigh-hopkins/prehlad/	Actor
2523	Gregory Sierra	\N	https://www.csfd.sk/tvorca/115634-gregory-sierra/prehlad/	Actor
2524	Carol Ann Susi	\N	https://www.csfd.sk/tvorca/143770-carol-ann-susi/prehlad/	Actor
2525	Jerry Haleva	\N	https://www.csfd.sk/tvorca/194337-jerry-haleva/prehlad/	Actor
2526	Joseph R. Sicari	\N	https://www.csfd.sk/tvorca/248676-joseph-r-sicari/prehlad/	Actor
2527	Philip Suriano	\N	https://www.csfd.sk/tvorca/341948-philip-suriano/prehlad/	Actor
2528	Ursula Burton	\N	https://www.csfd.sk/tvorca/363783-ursula-burton/prehlad/	Actor
2529	Anthony Crivello	\N	https://www.csfd.sk/tvorca/424902-anthony-crivello/prehlad/	Actor
2530	Cate Caplin	\N	https://www.csfd.sk/tvorca/506441-cate-caplin/prehlad/	Actor
2531	Jason Davis	\N	https://www.csfd.sk/tvorca/550594-jason-davis/prehlad/	Actor
2532	Vera Lockwood	\N	https://www.csfd.sk/tvorca/701973-vera-lockwood/prehlad/	Actor
2533	Don Bovingloh	\N	https://www.csfd.sk/tvorca/799361-don-bovingloh/prehlad/	Actor
2534	Saverio Carubia	\N	https://www.csfd.sk/tvorca/878804-saverio-carubia/prehlad/	Actor
2535	Charlie Sheen	\N	https://www.csfd.sk/tvorca/487-charlie-sheen/prehlad/	Actor
2536	Cary Elwes	\N	https://www.csfd.sk/tvorca/395-cary-elwes/prehlad/	Actor
2537	Valeria Golino	\N	https://www.csfd.sk/tvorca/2455-valeria-golino/prehlad/	Actor
2538	Kevin Dunn	\N	https://www.csfd.sk/tvorca/7794-kevin-dunn/prehlad/	Actor
2539	Jon Cryer	\N	https://www.csfd.sk/tvorca/14091-jon-cryer/prehlad/	Actor
2540	Kristy Swanson	\N	https://www.csfd.sk/tvorca/2115-kristy-swanson/prehlad/	Actor
2541	Efrem Zimbalist Jr.	\N	https://www.csfd.sk/tvorca/56043-efrem-zimbalist-jr/prehlad/	Actor
2542	Bill Irwin	\N	https://www.csfd.sk/tvorca/84672-bill-irwin/prehlad/	Actor
2543	Heidi Swedberg	\N	https://www.csfd.sk/tvorca/11644-heidi-swedberg/prehlad/	Actor
2544	Bruce A. Young	\N	https://www.csfd.sk/tvorca/10172-bruce-a-young/prehlad/	Actor
2545	Ryan Stiles	\N	https://www.csfd.sk/tvorca/37516-ryan-stiles/prehlad/	Actor
2546	Ryan Cutrona	\N	https://www.csfd.sk/tvorca/15484-ryan-cutrona/prehlad/	Actor
2547	Pat Proft	\N	https://www.csfd.sk/tvorca/7947-pat-proft/prehlad/	Actor
2548	Cylk Cozart	\N	https://www.csfd.sk/tvorca/23236-cylk-cozart/prehlad/	Actor
2549	Jimmie Ray Weeks	\N	https://www.csfd.sk/tvorca/18459-jimmie-ray-weeks/prehlad/	Actor
2550	Charles Barkley	\N	https://www.csfd.sk/tvorca/19881-charles-barkley/prehlad/	Actor
2551	Christopher Doyle	\N	https://www.csfd.sk/tvorca/9249-christopher-doyle/prehlad/	Actor
2552	Dave Oliver	\N	https://www.csfd.sk/tvorca/9573-dave-oliver/prehlad/	Actor
2553	Marc Shaiman	\N	https://www.csfd.sk/tvorca/63500-marc-shaiman/prehlad/	Actor
2554	William O'Leary	\N	https://www.csfd.sk/tvorca/79157-william-o-leary/prehlad/	Actor
2555	Sean Kanan	\N	https://www.csfd.sk/tvorca/101951-sean-kanan/prehlad/	Actor
2556	Steven Chester Prince	\N	https://www.csfd.sk/tvorca/170011-steven-chester-prince/prehlad/	Actor
2557	Jimmy Lennon Jr.	\N	https://www.csfd.sk/tvorca/185673-jimmy-lennon-jr/prehlad/	Actor
2558	Don Lake	\N	https://www.csfd.sk/tvorca/222741-don-lake/prehlad/	Actor
2559	Annie O'Donnell	\N	https://www.csfd.sk/tvorca/291744-annie-o-donnell/prehlad/	Actor
2560	Rino Thunder	\N	https://www.csfd.sk/tvorca/380757-rino-thunder/prehlad/	Actor
2561	Tony Lorea	\N	https://www.csfd.sk/tvorca/466348-tony-lorea/prehlad/	Actor
2562	Judith Kahan	\N	https://www.csfd.sk/tvorca/722935-judith-kahan/prehlad/	Actor
2563	Mark Arnott	\N	https://www.csfd.sk/tvorca/557619-mark-arnott/prehlad/	Actor
2564	Danny DeVito	\N	https://www.csfd.sk/tvorca/391-danny-devito/prehlad/	Actor
2565	Judge Reinhold	\N	https://www.csfd.sk/tvorca/472-judge-reinhold/prehlad/	Actor
2566	Helen Slater	\N	https://www.csfd.sk/tvorca/11632-helen-slater/prehlad/	Actor
2567	Anita Morris	\N	https://www.csfd.sk/tvorca/23524-anita-morris/prehlad/	Actor
2568	Bill Pullman	\N	https://www.csfd.sk/tvorca/19-bill-pullman/prehlad/	Actor
2569	William G. Schilling	\N	https://www.csfd.sk/tvorca/23390-william-g-schilling/prehlad/	Actor
2570	Art Evans	\N	https://www.csfd.sk/tvorca/23252-art-evans/prehlad/	Actor
2571	J.E. Freeman	\N	https://www.csfd.sk/tvorca/240-j-e-freeman/prehlad/	Actor
2572	George 'The Animal' Steele	\N	https://www.csfd.sk/tvorca/63130-george-the-animal-steele/prehlad/	Actor
2573	Bob Tzudiker	\N	https://www.csfd.sk/tvorca/218454-bob-tzudiker/prehlad/	Actor
2574	Clarence Felder	\N	https://www.csfd.sk/tvorca/235885-clarence-felder/prehlad/	Actor
2575	Hanala Sagal	\N	https://www.csfd.sk/tvorca/242540-hanala-sagal/prehlad/	Actor
2576	Susan Marie Snyder	\N	https://www.csfd.sk/tvorca/284033-susan-marie-snyder/prehlad/	Actor
2577	Frank Sivero	\N	https://www.csfd.sk/tvorca/289913-frank-sivero/prehlad/	Actor
2578	Gary Riley	\N	https://www.csfd.sk/tvorca/324408-gary-riley/prehlad/	Actor
2579	Phyllis Applegate	\N	https://www.csfd.sk/tvorca/324409-phyllis-applegate/prehlad/	Actor
2580	Art Bonilla	\N	https://www.csfd.sk/tvorca/479886-art-bonilla/prehlad/	Actor
2581	John Forker	\N	https://www.csfd.sk/tvorca/640997-john-forker/prehlad/	Actor
2582	Arnold F. Turner	\N	https://www.csfd.sk/tvorca/648670-arnold-f-turner/prehlad/	Actor
2583	J.P. Bumstead	\N	https://www.csfd.sk/tvorca/651396-j-p-bumstead/prehlad/	Actor
2584	Mie Hunt	\N	https://www.csfd.sk/tvorca/825856-mie-hunt/prehlad/	Actor
2585	Jim Doughan	\N	https://www.csfd.sk/tvorca/833340-jim-doughan/prehlad/	Actor
2586	Jeannine Bisignano	\N	https://www.csfd.sk/tvorca/959823-jeannine-bisignano/prehlad/	Actor
2587	Richard Crenna	\N	https://www.csfd.sk/tvorca/380-richard-crenna/prehlad/	Actor
2588	Brenda Bakke	\N	https://www.csfd.sk/tvorca/5849-brenda-bakke/prehlad/	Actor
2589	Miguel Ferrer	\N	https://www.csfd.sk/tvorca/2339-miguel-ferrer/prehlad/	Actor
2590	Rowan Atkinson	\N	https://www.csfd.sk/tvorca/349-rowan-atkinson/prehlad/	Actor
2591	David Wohl	\N	https://www.csfd.sk/tvorca/370182-david-wohl/prehlad/	Actor
2592	Mitchell Ryan	\N	https://www.csfd.sk/tvorca/17423-mitchell-ryan/prehlad/	Actor
2593	Tony Edwards	\N	https://www.csfd.sk/tvorca/19990-tony-edwards/prehlad/	Actor
2594	James Lew	\N	https://www.csfd.sk/tvorca/22896-james-lew/prehlad/	Actor
2595	Gerald Okamura	\N	https://www.csfd.sk/tvorca/23857-gerald-okamura/prehlad/	Actor
2596	Chi Muoi Lo	\N	https://www.csfd.sk/tvorca/16510-chi-muoi-lo/prehlad/	Actor
2597	Scott Reeves	\N	https://www.csfd.sk/tvorca/14658-scott-reeves/prehlad/	Actor
2598	Martin Sheen	\N	https://www.csfd.sk/tvorca/488-martin-sheen/prehlad/	Actor
2599	Clyde Kusatsu	\N	https://www.csfd.sk/tvorca/1866-clyde-kusatsu/prehlad/	Actor
2600	Shaun Toub	\N	https://www.csfd.sk/tvorca/45658-shaun-toub/prehlad/	Actor
2601	Ben Lemon	\N	https://www.csfd.sk/tvorca/244056-ben-lemon/prehlad/	Actor
2602	Joseph V. Perry	\N	https://www.csfd.sk/tvorca/258528-joseph-v-perry/prehlad/	Actor
2603	Greg Michaels	\N	https://www.csfd.sk/tvorca/301357-greg-michaels/prehlad/	Actor
2604	Bob Vila	\N	https://www.csfd.sk/tvorca/349204-bob-vila/prehlad/	Actor
2605	Larry Lindsey	\N	https://www.csfd.sk/tvorca/545449-larry-lindsey/prehlad/	Actor
2606	Raye Hollitt	\N	https://www.csfd.sk/tvorca/586517-raye-hollitt/prehlad/	Actor
2607	Michael Colyar	\N	https://www.csfd.sk/tvorca/604939-michael-colyar/prehlad/	Actor
2608	Loren Janes	\N	https://www.csfd.sk/tvorca/740029-loren-janes/prehlad/	Actor
2609	Nancy Steen	\N	https://www.csfd.sk/tvorca/826237-nancy-steen/prehlad/	Actor
2610	Stewart Skelton	\N	https://www.csfd.sk/tvorca/844094-stewart-skelton/prehlad/	Actor
2611	Mark Steen	\N	https://www.csfd.sk/tvorca/847887-mark-steen/prehlad/	Actor
2612	Val Kilmer	\N	https://www.csfd.sk/tvorca/100-val-kilmer/prehlad/	Actor
2613	Lucy Gutteridge	\N	https://www.csfd.sk/tvorca/38768-lucy-gutteridge/prehlad/	Actor
2614	Peter Cushing	\N	https://www.csfd.sk/tvorca/342-peter-cushing/prehlad/	Actor
2615	Jeremy Kemp	\N	https://www.csfd.sk/tvorca/53343-jeremy-kemp/prehlad/	Actor
2616	Christopher Villiers	\N	https://www.csfd.sk/tvorca/20323-christopher-villiers/prehlad/	Actor
2617	Warren Clarke	\N	https://www.csfd.sk/tvorca/11940-warren-clarke/prehlad/	Actor
2618	Michael Gough	\N	https://www.csfd.sk/tvorca/14623-michael-gough/prehlad/	Actor
2619	Harry Ditson	\N	https://www.csfd.sk/tvorca/666237-harry-ditson/prehlad/	Actor
2620	Jim Carter	\N	https://www.csfd.sk/tvorca/94674-jim-carter/prehlad/	Actor
2621	Eddie Tagoe	\N	https://www.csfd.sk/tvorca/105370-eddie-tagoe/prehlad/	Actor
2622	Omar Sharif	\N	https://www.csfd.sk/tvorca/2295-omar-sharif/prehlad/	Actor
2623	Tristam Jelinek	\N	https://www.csfd.sk/tvorca/303258-tristam-jelinek/prehlad/	Actor
2624	Gertan Klauber	\N	https://www.csfd.sk/tvorca/280704-gertan-klauber/prehlad/	Actor
2625	Ian McNeice	\N	https://www.csfd.sk/tvorca/4961-ian-mcneice/prehlad/	Actor
2626	John Sharp	\N	https://www.csfd.sk/tvorca/543375-john-sharp/prehlad/	Actor
2627	Richard Pescud	\N	https://www.csfd.sk/tvorca/615913-richard-pescud/prehlad/	Actor
2628	Mac McDonald	\N	https://www.csfd.sk/tvorca/44283-mac-mcdonald/prehlad/	Actor
2629	Nicola Wright	\N	https://www.csfd.sk/tvorca/647454-nicola-wright/prehlad/	Actor
2630	Lisa Gruenberg	\N	https://www.csfd.sk/tvorca/47985-lisa-gruenberg/prehlad/	Actor
2631	Maxwell Craig	\N	https://www.csfd.sk/tvorca/298590-maxwell-craig/prehlad/	Actor
2632	Harry Fielder	\N	https://www.csfd.sk/tvorca/298866-harry-fielder/prehlad/	Actor
2633	Walter Henry	\N	https://www.csfd.sk/tvorca/295517-walter-henry/prehlad/	Actor
2634	Frank Jakeman	\N	https://www.csfd.sk/tvorca/606163-frank-jakeman/prehlad/	Actor
2635	Aileen Lewis	\N	https://www.csfd.sk/tvorca/291135-aileen-lewis/prehlad/	Actor
2636	Reg Thomason	\N	https://www.csfd.sk/tvorca/290052-reg-thomason/prehlad/	Actor
2637	Alan Alda	\N	https://www.csfd.sk/tvorca/732-alan-alda/prehlad/	Director
2638	Mike Farrell	\N	https://www.csfd.sk/tvorca/4608-mike-farrell/prehlad/	Actor
2639	Harry Morgan	\N	https://www.csfd.sk/tvorca/4609-harry-morgan/prehlad/	Actor
2640	Loretta Swit	\N	https://www.csfd.sk/tvorca/4613-loretta-swit/prehlad/	Actor
2641	David Ogden Stiers	\N	https://www.csfd.sk/tvorca/4612-david-ogden-stiers/prehlad/	Actor
2642	Jamie Farr	\N	https://www.csfd.sk/tvorca/4615-jamie-farr/prehlad/	Actor
2643	William Christopher	\N	https://www.csfd.sk/tvorca/4616-william-christopher/prehlad/	Actor
2644	Allan Arbus	\N	https://www.csfd.sk/tvorca/54041-allan-arbus/prehlad/	Actor
2645	Rosalind Chao	\N	https://www.csfd.sk/tvorca/38043-rosalind-chao/prehlad/	Actor
2646	Kellye Nakahara	\N	https://www.csfd.sk/tvorca/54048-kellye-nakahara/prehlad/	Actor
2647	Jeff Maxwell	\N	https://www.csfd.sk/tvorca/54047-jeff-maxwell/prehlad/	Actor
2648	G. W. Bailey	\N	https://www.csfd.sk/tvorca/350-g-w-bailey/prehlad/	Actor
2649	Blake Clark	\N	https://www.csfd.sk/tvorca/60788-blake-clark/prehlad/	Actor
2650	Dennis Troy	\N	https://www.csfd.sk/tvorca/319818-dennis-troy/prehlad/	Actor
2651	Kevin Scannell	\N	https://www.csfd.sk/tvorca/370064-kevin-scannell/prehlad/	Actor
2652	Herb Mitchell	\N	https://www.csfd.sk/tvorca/484592-herb-mitchell/prehlad/	Actor
2653	Scott Lincoln	\N	https://www.csfd.sk/tvorca/650759-scott-lincoln/prehlad/	Actor
2654	Judy Farrell	\N	https://www.csfd.sk/tvorca/803750-judy-farrell/prehlad/	Actor
2655	Enid Kent	\N	https://www.csfd.sk/tvorca/826043-enid-kent/prehlad/	Actor
2656	Dennis Flood	\N	https://www.csfd.sk/tvorca/873485-dennis-flood/prehlad/	Actor
2657	Michael Caine	\N	https://www.csfd.sk/tvorca/754-michael-caine/prehlad/	Actor
2658	Michelle Pfeiffer	\N	https://www.csfd.sk/tvorca/582-michelle-pfeiffer/prehlad/	Actor
2659	Bob Hoskins	\N	https://www.csfd.sk/tvorca/421-bob-hoskins/prehlad/	Actor
2660	Lise Hilboldt	\N	https://www.csfd.sk/tvorca/20456-lise-hilboldt/prehlad/	Actor
2661	Lillian Gish	\N	https://www.csfd.sk/tvorca/797-lillian-gish/prehlad/	Actor
2662	Saul Rubinek	\N	https://www.csfd.sk/tvorca/7795-saul-rubinek/prehlad/	Actor
2663	Lois Chiles	\N	https://www.csfd.sk/tvorca/10922-lois-chiles/prehlad/	Actor
2664	Antony Alda	\N	https://www.csfd.sk/tvorca/12687-antony-alda/prehlad/	Actor
2665	Timothy Carhart	\N	https://www.csfd.sk/tvorca/13969-timothy-carhart/prehlad/	Actor
2666	Bryan Clark	\N	https://www.csfd.sk/tvorca/22440-bryan-clark/prehlad/	Actor
2667	Dann Florek	\N	https://www.csfd.sk/tvorca/16968-dann-florek/prehlad/	Actor
2668	John C. McGinley	\N	https://www.csfd.sk/tvorca/5265-john-c-mcginley/prehlad/	Actor
2669	Lynne Thigpen	\N	https://www.csfd.sk/tvorca/20572-lynne-thigpen/prehlad/	Actor
2670	Deborah Gibson	\N	https://www.csfd.sk/tvorca/70192-deborah-gibson/prehlad/	Actor
2671	Linda Thorson	\N	https://www.csfd.sk/tvorca/95683-linda-thorson/prehlad/	Actor
2672	Christopher Loomis	\N	https://www.csfd.sk/tvorca/219086-christopher-loomis/prehlad/	Actor
2673	Robert Schenkkan	\N	https://www.csfd.sk/tvorca/252385-robert-schenkkan/prehlad/	Actor
2674	Diana Agostini	\N	https://www.csfd.sk/tvorca/289220-diana-agostini/prehlad/	Actor
2675	Polly Rowles	\N	https://www.csfd.sk/tvorca/385320-polly-rowles/prehlad/	Actor
2676	Bonnie Deroski	\N	https://www.csfd.sk/tvorca/392111-bonnie-deroski/prehlad/	Actor
2677	Fred Sanders	\N	https://www.csfd.sk/tvorca/610180-fred-sanders/prehlad/	Actor
2678	Cynthia Burr	\N	https://www.csfd.sk/tvorca/817502-cynthia-burr/prehlad/	Actor
2679	Irwin Allen	\N	https://www.csfd.sk/tvorca/2797-irwin-allen/prehlad/	Director
2680	Sobey Martin	\N	https://www.csfd.sk/tvorca/872305-sobey-martin/prehlad/	Director
2681	Robert Duvall	\N	https://www.csfd.sk/tvorca/199-robert-duvall/prehlad/	Actor
2682	Whit Bissell	\N	https://www.csfd.sk/tvorca/4464-whit-bissell/prehlad/	Actor
2683	Lee Meriwether	\N	https://www.csfd.sk/tvorca/5180-lee-meriwether/prehlad/	Actor
2684	Wesley Lau	\N	https://www.csfd.sk/tvorca/11373-wesley-lau/prehlad/	Actor
2685	Joe Ryan	\N	https://www.csfd.sk/tvorca/13695-joe-ryan/prehlad/	Actor
2686	John Hoyt	\N	https://www.csfd.sk/tvorca/13332-john-hoyt/prehlad/	Actor
2687	Jan Merlin	\N	https://www.csfd.sk/tvorca/216708-jan-merlin/prehlad/	Actor
2688	Ross Elliott	\N	https://www.csfd.sk/tvorca/228660-ross-elliott/prehlad/	Actor
2689	Vitina Marcus	\N	https://www.csfd.sk/tvorca/318627-vitina-marcus/prehlad/	Actor
2690	Fred Beir	\N	https://www.csfd.sk/tvorca/450030-fred-beir/prehlad/	Actor
2691	Karen Oganesjan	\N	https://www.csfd.sk/tvorca/55170-karen-oganesjan/prehlad/	Director
2692	Ilja Makarov	\N	https://www.csfd.sk/tvorca/127698-ilja-makarov/prehlad/	Director
2693	Andrej Panin	\N	https://www.csfd.sk/tvorca/50902-andrej-panin/prehlad/	Actor
2694	Jelena Safonova	\N	https://www.csfd.sk/tvorca/78187-jelena-safonova/prehlad/	Actor
2695	Světlana Ivanova	\N	https://www.csfd.sk/tvorca/79471-svetlana-ivanova/prehlad/	Actor
2696	Olesja Sudzilovskaja	\N	https://www.csfd.sk/tvorca/78459-olesja-sudzilovskaja/prehlad/	Actor
2697	Olga Tumajkina	\N	https://www.csfd.sk/tvorca/140222-olga-tumajkina/prehlad/	Actor
2698	Světlana Ustinova	\N	https://www.csfd.sk/tvorca/46189-svetlana-ustinova/prehlad/	Actor
2699	Alexej Ševčenkov	\N	https://www.csfd.sk/tvorca/95900-alexej-sevcenkov/prehlad/	Actor
2700	Kirill Safonov	\N	https://www.csfd.sk/tvorca/154912-kirill-safonov/prehlad/	Actor
2701	Sergej Gazarov	\N	https://www.csfd.sk/tvorca/56865-sergej-gazarov/prehlad/	Actor
2702	Ivan Stěbunov	\N	https://www.csfd.sk/tvorca/23906-ivan-stebunov/prehlad/	Actor
2703	Julija Galkina	\N	https://www.csfd.sk/tvorca/170768-julija-galkina/prehlad/	Actor
2704	Sergej Beljajev	\N	https://www.csfd.sk/tvorca/135390-sergej-beljajev/prehlad/	Actor
2705	Igor Jacko	\N	https://www.csfd.sk/tvorca/172431-igor-jacko/prehlad/	Actor
2706	Igor Zolotovickij	\N	https://www.csfd.sk/tvorca/155641-igor-zolotovickij/prehlad/	Actor
2707	Konstantin Vorobjov	\N	https://www.csfd.sk/tvorca/134642-konstantin-vorobjov/prehlad/	Actor
2708	Dmitrij Blochin	\N	https://www.csfd.sk/tvorca/162224-dmitrij-blochin/prehlad/	Actor
2709	Andrej Smoljakov	\N	https://www.csfd.sk/tvorca/87051-andrej-smoljakov/prehlad/	Actor
2710	Olga Pogodina	\N	https://www.csfd.sk/tvorca/122727-olga-pogodina/prehlad/	Actor
2711	Stanislav Běljajev	\N	https://www.csfd.sk/tvorca/123617-stanislav-beljajev/prehlad/	Actor
2712	Dmitrij Jendalcev	\N	https://www.csfd.sk/tvorca/123242-dmitrij-jendalcev/prehlad/	Actor
2713	Pavel Melenčuk	\N	https://www.csfd.sk/tvorca/99070-pavel-melencuk/prehlad/	Actor
2714	Natalija Vdovina	\N	https://www.csfd.sk/tvorca/12779-natalija-vdovina/prehlad/	Actor
2715	Sergej Juškevič	\N	https://www.csfd.sk/tvorca/130582-sergej-juskevic/prehlad/	Actor
2716	Viktor Rakov	\N	https://www.csfd.sk/tvorca/31124-viktor-rakov/prehlad/	Actor
2717	Věra Voronkova	\N	https://www.csfd.sk/tvorca/157045-vera-voronkova/prehlad/	Actor
2718	Olga Volkova	\N	https://www.csfd.sk/tvorca/128770-olga-volkova/prehlad/	Actor
2719	Anna Pěrelešina	\N	https://www.csfd.sk/tvorca/132476-anna-perelesina/prehlad/	Actor
2720	Igor Vernik	\N	https://www.csfd.sk/tvorca/73858-igor-vernik/prehlad/	Actor
2721	Michail Gorevoj	\N	https://www.csfd.sk/tvorca/146212-michail-gorevoj/prehlad/	Actor
2722	Alexandr Makogon	\N	https://www.csfd.sk/tvorca/158653-alexandr-makogon/prehlad/	Actor
2723	Roman Radov	\N	https://www.csfd.sk/tvorca/155000-roman-radov/prehlad/	Actor
2724	Sergej Batalov	\N	https://www.csfd.sk/tvorca/164992-sergej-batalov/prehlad/	Actor
2725	Jevdokija Germanova	\N	https://www.csfd.sk/tvorca/92466-jevdokija-germanova/prehlad/	Actor
2726	Jurij Curilo	\N	https://www.csfd.sk/tvorca/20315-jurij-curilo/prehlad/	Actor
2727	Anna Banščikova	\N	https://www.csfd.sk/tvorca/136086-anna-banscikova/prehlad/	Actor
2728	Alisa Chazanova	\N	https://www.csfd.sk/tvorca/88324-alisa-chazanova/prehlad/	Actor
2729	Nikita Jemšanov	\N	https://www.csfd.sk/tvorca/170016-nikita-jemsanov/prehlad/	Actor
2730	Jevgenija Lapova	\N	https://www.csfd.sk/tvorca/161440-jevgenija-lapova/prehlad/	Actor
2731	Maxim Artamonov	\N	https://www.csfd.sk/tvorca/169631-maxim-artamonov/prehlad/	Actor
2732	Ljudmila Gavrilova	\N	https://www.csfd.sk/tvorca/156158-ljudmila-gavrilova/prehlad/	Actor
2733	Anfisa Vistingauzen	\N	https://www.csfd.sk/tvorca/83557-anfisa-vistingauzen/prehlad/	Actor
2734	Jekatěrina Semjonova	\N	https://www.csfd.sk/tvorca/200134-jekaterina-semjonova/prehlad/	Actor
2735	Alexandr Vojevodin	\N	https://www.csfd.sk/tvorca/213291-alexandr-vojevodin/prehlad/	Actor
2736	Igor Artašonov	\N	https://www.csfd.sk/tvorca/218760-igor-artasonov/prehlad/	Actor
2737	Andrej Rapoport	\N	https://www.csfd.sk/tvorca/219562-andrej-rapoport/prehlad/	Actor
2738	Kirill Käro	\N	https://www.csfd.sk/tvorca/165058-kirill-karo/prehlad/	Actor
2739	Sergej Šechovcov	\N	https://www.csfd.sk/tvorca/258408-sergej-sechovcov/prehlad/	Actor
2740	Alja Nikulina	\N	https://www.csfd.sk/tvorca/263172-alja-nikulina/prehlad/	Actor
2741	Giuliano Di Capua	\N	https://www.csfd.sk/tvorca/263734-giuliano-di-capua/prehlad/	Actor
2742	Michail Asankin	\N	https://www.csfd.sk/tvorca/156354-michail-asankin/prehlad/	Actor
2743	Taťjana Rudina	\N	https://www.csfd.sk/tvorca/268809-tatjana-rudina/prehlad/	Actor
2744	Viktor Rybčinskij	\N	https://www.csfd.sk/tvorca/281751-viktor-rybcinskij/prehlad/	Actor
2745	Andrej Seňkin	\N	https://www.csfd.sk/tvorca/286397-andrej-senkin/prehlad/	Actor
2746	Svjatoslav Astramovič	\N	https://www.csfd.sk/tvorca/291394-svjatoslav-astramovic/prehlad/	Actor
2747	Valentina Losovskaja	\N	https://www.csfd.sk/tvorca/292019-valentina-losovskaja/prehlad/	Actor
2748	Olga Reptuch	\N	https://www.csfd.sk/tvorca/292130-olga-reptuch/prehlad/	Actor
2749	Darja Belousova	\N	https://www.csfd.sk/tvorca/304707-darja-belousova/prehlad/	Actor
2750	Alexandr Nikitin	\N	https://www.csfd.sk/tvorca/304838-alexandr-nikitin/prehlad/	Actor
2751	Vladimir Jumatov	\N	https://www.csfd.sk/tvorca/308118-vladimir-jumatov/prehlad/	Actor
2752	Stanislav Rjadinskij	\N	https://www.csfd.sk/tvorca/324040-stanislav-rjadinskij/prehlad/	Actor
2753	Jevgenij Gerčakov	\N	https://www.csfd.sk/tvorca/324750-jevgenij-gercakov/prehlad/	Actor
2754	Arťom Smola	\N	https://www.csfd.sk/tvorca/325424-artom-smola/prehlad/	Actor
2755	Jurij Nifontov	\N	https://www.csfd.sk/tvorca/326142-jurij-nifontov/prehlad/	Actor
2756	Andrej Sviridov	\N	https://www.csfd.sk/tvorca/327440-andrej-sviridov/prehlad/	Actor
2757	Nikolaj Mačulskij	\N	https://www.csfd.sk/tvorca/328481-nikolaj-maculskij/prehlad/	Actor
2758	Rostislav Beršauer	\N	https://www.csfd.sk/tvorca/328756-rostislav-bersauer/prehlad/	Actor
2759	Alexandr Vdovin	\N	https://www.csfd.sk/tvorca/330362-alexandr-vdovin/prehlad/	Actor
2760	Marina Ivanova	\N	https://www.csfd.sk/tvorca/330681-marina-ivanova/prehlad/	Actor
2761	Taťjana Piskarjova	\N	https://www.csfd.sk/tvorca/330686-tatjana-piskarjova/prehlad/	Actor
2762	Olga Burlakova	\N	https://www.csfd.sk/tvorca/332472-olga-burlakova/prehlad/	Actor
2763	Semjon Furman	\N	https://www.csfd.sk/tvorca/332802-semjon-furman/prehlad/	Actor
2764	Alexandr Oblasov	\N	https://www.csfd.sk/tvorca/334153-alexandr-oblasov/prehlad/	Actor
2765	Zoja Bělochvostik	\N	https://www.csfd.sk/tvorca/335420-zoja-belochvostik/prehlad/	Actor
2766	Zinaida Zubkova	\N	https://www.csfd.sk/tvorca/341178-zinaida-zubkova/prehlad/	Actor
2767	Ivan Agapov	\N	https://www.csfd.sk/tvorca/343858-ivan-agapov/prehlad/	Actor
2768	Olga Samošina	\N	https://www.csfd.sk/tvorca/345548-olga-samosina/prehlad/	Actor
2769	Pavel Višňakov	\N	https://www.csfd.sk/tvorca/355518-pavel-visnakov/prehlad/	Actor
2770	Jurij Šlykov	\N	https://www.csfd.sk/tvorca/360642-jurij-slykov/prehlad/	Actor
2771	Michail Levčenko	\N	https://www.csfd.sk/tvorca/363955-michail-levcenko/prehlad/	Actor
2772	Marija Buknis	\N	https://www.csfd.sk/tvorca/369226-marija-buknis/prehlad/	Actor
2773	Natalja Pikula	\N	https://www.csfd.sk/tvorca/412262-natalja-pikula/prehlad/	Actor
2774	Zachar Ronžin	\N	https://www.csfd.sk/tvorca/412263-zachar-ronzin/prehlad/	Actor
2775	Alexandra Blednaja	\N	https://www.csfd.sk/tvorca/413597-alexandra-blednaja/prehlad/	Actor
2776	Lana Soul	\N	https://www.csfd.sk/tvorca/425033-lana-soul/prehlad/	Actor
2777	Olga Bogdanova	\N	https://www.csfd.sk/tvorca/437348-olga-bogdanova/prehlad/	Actor
2778	Alesja Samochovec	\N	https://www.csfd.sk/tvorca/443208-alesja-samochovec/prehlad/	Actor
2779	Andrej Moskvičjov	\N	https://www.csfd.sk/tvorca/443853-andrej-moskvicjov/prehlad/	Actor
2780	Anatolij Gurev	\N	https://www.csfd.sk/tvorca/444628-anatolij-gurev/prehlad/	Actor
2781	Sergej Beljakovič	\N	https://www.csfd.sk/tvorca/444715-sergej-beljakovic/prehlad/	Actor
2782	Natalja Batrak	\N	https://www.csfd.sk/tvorca/68153-natalja-batrak/prehlad/	Actor
2783	Viktor Grigorjuk	\N	https://www.csfd.sk/tvorca/9708-viktor-grigorjuk/prehlad/	Actor
2784	Michail Fatejev	\N	https://www.csfd.sk/tvorca/170069-michail-fatejev/prehlad/	Actor
2785	Vladimir Friedman	\N	https://www.csfd.sk/tvorca/180333-vladimir-friedman/prehlad/	Actor
2786	Svetlana Nikiforova	\N	https://www.csfd.sk/tvorca/288241-svetlana-nikiforova/prehlad/	Actor
2787	Galina Agejkina	\N	https://www.csfd.sk/tvorca/444218-galina-agejkina/prehlad/	Actor
2788	Olga Sizova	\N	https://www.csfd.sk/tvorca/443616-olga-sizova/prehlad/	Actor
2789	Andrej Karako	\N	https://www.csfd.sk/tvorca/263152-andrej-karako/prehlad/	Actor
2790	Alexandr Brankevič	\N	https://www.csfd.sk/tvorca/444202-alexandr-brankevic/prehlad/	Actor
2791	Sergej Vlasov	\N	https://www.csfd.sk/tvorca/330351-sergej-vlasov/prehlad/	Actor
2792	Miťa Labuš	\N	https://www.csfd.sk/tvorca/256262-mita-labus/prehlad/	Actor
2793	Natalja Rogožkina	\N	https://www.csfd.sk/tvorca/224602-natalja-rogozkina/prehlad/	Actor
2794	Alexandr Ťutin	\N	https://www.csfd.sk/tvorca/259652-alexandr-tutin/prehlad/	Actor
2795	Vitalij Bykov	\N	https://www.csfd.sk/tvorca/170746-vitalij-bykov/prehlad/	Actor
2796	Olga Nefjodova	\N	https://www.csfd.sk/tvorca/222458-olga-nefjodova/prehlad/	Actor
2797	Andrej Dobrovolskij	\N	https://www.csfd.sk/tvorca/443360-andrej-dobrovolskij/prehlad/	Actor
2798	Denis Paršin	\N	https://www.csfd.sk/tvorca/292022-denis-parsin/prehlad/	Actor
2799	Anatolij Golub	\N	https://www.csfd.sk/tvorca/291554-anatolij-golub/prehlad/	Actor
2800	Oleg Tkačjov	\N	https://www.csfd.sk/tvorca/128497-oleg-tkacjov/prehlad/	Actor
2801	Darja Belousova	\N	https://www.csfd.sk/tvorca/304709-darja-belousova/prehlad/	Actor
2802	Ramil Sabitov	\N	https://www.csfd.sk/tvorca/296235-ramil-sabitov/prehlad/	Actor
2803	Xenija Romenkova	\N	https://www.csfd.sk/tvorca/324042-xenija-romenkova/prehlad/	Actor
2804	Vera Kavalerova	\N	https://www.csfd.sk/tvorca/424472-vera-kavalerova/prehlad/	Actor
2805	Ruslan Černěckij	\N	https://www.csfd.sk/tvorca/263906-ruslan-cerneckij/prehlad/	Actor
2806	Igor Savočkin	\N	https://www.csfd.sk/tvorca/122292-igor-savockin/prehlad/	Actor
2807	Taťjana Popova	\N	https://www.csfd.sk/tvorca/429714-tatjana-popova/prehlad/	Actor
2808	Tamara Mironova	\N	https://www.csfd.sk/tvorca/345345-tamara-mironova/prehlad/	Actor
2809	Sergej Sosnovskij	\N	https://www.csfd.sk/tvorca/92600-sergej-sosnovskij/prehlad/	Actor
2810	Sergej Šimko	\N	https://www.csfd.sk/tvorca/412266-sergej-simko/prehlad/	Actor
2811	Dmitrij Muchin	\N	https://www.csfd.sk/tvorca/357777-dmitrij-muchin/prehlad/	Actor
2812	Alexandr Girenok	\N	https://www.csfd.sk/tvorca/444322-alexandr-girenok/prehlad/	Actor
2813	Igor Děnisov	\N	https://www.csfd.sk/tvorca/444676-igor-denisov/prehlad/	Actor
2814	Irina Narbekova	\N	https://www.csfd.sk/tvorca/301077-irina-narbekova/prehlad/	Actor
2815	Nikita Stěpanov	\N	https://www.csfd.sk/tvorca/332476-nikita-stepanov/prehlad/	Actor
2816	Larisa Maršalova	\N	https://www.csfd.sk/tvorca/327358-larisa-marsalova/prehlad/	Actor
2817	Oxana Lesnaja	\N	https://www.csfd.sk/tvorca/415652-oxana-lesnaja/prehlad/	Actor
2818	Galina Petrova	\N	https://www.csfd.sk/tvorca/263449-galina-petrova/prehlad/	Actor
2819	Valerija Arlanova	\N	https://www.csfd.sk/tvorca/345568-valerija-arlanova/prehlad/	Actor
2820	Alexandra Komissarova	\N	https://www.csfd.sk/tvorca/422855-alexandra-komissarova/prehlad/	Actor
2821	Vladimir Badov	\N	https://www.csfd.sk/tvorca/170461-vladimir-badov/prehlad/	Actor
2822	Vladislav Větrov	\N	https://www.csfd.sk/tvorca/88554-vladislav-vetrov/prehlad/	Actor
2823	Světlana Kožemjakina	\N	https://www.csfd.sk/tvorca/298183-svetlana-kozemjakina/prehlad/	Actor
2824	Ivan Krasko	\N	https://www.csfd.sk/tvorca/157485-ivan-krasko/prehlad/	Actor
2825	Denis Karasjov	\N	https://www.csfd.sk/tvorca/141486-denis-karasjov/prehlad/	Actor
2826	Valerij Zelenskij	\N	https://www.csfd.sk/tvorca/413617-valerij-zelenskij/prehlad/	Actor
2827	Xenija Lavrova-Glinka	\N	https://www.csfd.sk/tvorca/156356-xenija-lavrova-glinka/prehlad/	Actor
2828	Konstantin Koňuchov	\N	https://www.csfd.sk/tvorca/416531-konstantin-konuchov/prehlad/	Actor
2829	Igor Sigov	\N	https://www.csfd.sk/tvorca/343575-igor-sigov/prehlad/	Actor
2830	Tamara Muženko	\N	https://www.csfd.sk/tvorca/375466-tamara-muzenko/prehlad/	Actor
2831	Alexandra Ťuftěj	\N	https://www.csfd.sk/tvorca/142528-alexandra-tuftej/prehlad/	Actor
2832	Julija Rutberg	\N	https://www.csfd.sk/tvorca/170949-julija-rutberg/prehlad/	Actor
2833	Alexandr Gusev	\N	https://www.csfd.sk/tvorca/310056-alexandr-gusev/prehlad/	Actor
2834	Alexandr Ždanovič	\N	https://www.csfd.sk/tvorca/444025-alexandr-zdanovic/prehlad/	Actor
2835	Jevgenij Ivkovič	\N	https://www.csfd.sk/tvorca/444629-jevgenij-ivkovic/prehlad/	Actor
2836	Vitalij Kiščenko	\N	https://www.csfd.sk/tvorca/80638-vitalij-kiscenko/prehlad/	Actor
2837	Taťjana Kalich	\N	https://www.csfd.sk/tvorca/222457-tatjana-kalich/prehlad/	Actor
2838	Svetlana Zelenkovskaja	\N	https://www.csfd.sk/tvorca/427929-svetlana-zelenkovskaja/prehlad/	Actor
2839	Galina Polskich	\N	https://www.csfd.sk/tvorca/79429-galina-polskich/prehlad/	Actor
2840	Vitalij Kravčenko	\N	https://www.csfd.sk/tvorca/173530-vitalij-kravcenko/prehlad/	Actor
2841	Sergej Šulga	\N	https://www.csfd.sk/tvorca/310390-sergej-sulga/prehlad/	Actor
2842	Andrej Dušečkin	\N	https://www.csfd.sk/tvorca/271546-andrej-duseckin/prehlad/	Actor
2843	Anatolij Gorjačev	\N	https://www.csfd.sk/tvorca/223274-anatolij-gorjacev/prehlad/	Actor
2844	Jegor Pazenko	\N	https://www.csfd.sk/tvorca/123201-jegor-pazenko/prehlad/	Actor
2845	Regina Dombrovskaja	\N	https://www.csfd.sk/tvorca/443605-regina-dombrovskaja/prehlad/	Actor
2846	Darja Baranova	\N	https://www.csfd.sk/tvorca/261835-darja-baranova/prehlad/	Actor
2847	Andrej Bronnikov	\N	https://www.csfd.sk/tvorca/437122-andrej-bronnikov/prehlad/	Actor
2848	Dmitrij Glazačev	\N	https://www.csfd.sk/tvorca/429700-dmitrij-glazacev/prehlad/	Actor
2849	Alexandr Feklistov	\N	https://www.csfd.sk/tvorca/20004-alexandr-feklistov/prehlad/	Actor
2850	Maxim Krečetov	\N	https://www.csfd.sk/tvorca/415433-maxim-krecetov/prehlad/	Actor
2851	Alexandr Jefremov	\N	https://www.csfd.sk/tvorca/306796-alexandr-jefremov/prehlad/	Actor
2852	Anton Starovojtov	\N	https://www.csfd.sk/tvorca/360819-anton-starovojtov/prehlad/	Actor
2853	Gennadij Fomin	\N	https://www.csfd.sk/tvorca/444167-gennadij-fomin/prehlad/	Actor
2854	Sergej Žuravel	\N	https://www.csfd.sk/tvorca/267506-sergej-zuravel/prehlad/	Actor
2855	Zoja Antonova	\N	https://www.csfd.sk/tvorca/285851-zoja-antonova/prehlad/	Actor
2856	Polina Syrkina	\N	https://www.csfd.sk/tvorca/134903-polina-syrkina/prehlad/	Actor
2857	Anna Polupanova	\N	https://www.csfd.sk/tvorca/415443-anna-polupanova/prehlad/	Actor
2858	Valentina Garcujeva	\N	https://www.csfd.sk/tvorca/286832-valentina-garcujeva/prehlad/	Actor
2859	Jevgenij Nikitin	\N	https://www.csfd.sk/tvorca/359067-jevgenij-nikitin/prehlad/	Actor
2860	Boris Polunin	\N	https://www.csfd.sk/tvorca/123460-boris-polunin/prehlad/	Actor
2861	Ivan Mochovikov	\N	https://www.csfd.sk/tvorca/456308-ivan-mochovikov/prehlad/	Actor
2862	Ivan Pavlov	\N	https://www.csfd.sk/tvorca/456316-ivan-pavlov/prehlad/	Actor
2863	Inna Dymskaja	\N	https://www.csfd.sk/tvorca/456317-inna-dymskaja/prehlad/	Actor
2864	Jelena Rodak-Škuratova	\N	https://www.csfd.sk/tvorca/456323-jelena-rodak-skuratova/prehlad/	Actor
2865	Larisa Něgrejeva-Cesljak	\N	https://www.csfd.sk/tvorca/456805-larisa-negrejeva-cesljak/prehlad/	Actor
2866	Světlana Svibilskaja	\N	https://www.csfd.sk/tvorca/467336-svetlana-svibilskaja/prehlad/	Actor
2867	Alexandr Bargman	\N	https://www.csfd.sk/tvorca/35999-alexandr-bargman/prehlad/	Actor
2868	Kirill Mugajskich	\N	https://www.csfd.sk/tvorca/471541-kirill-mugajskich/prehlad/	Actor
2869	Olga Toropova	\N	https://www.csfd.sk/tvorca/486868-olga-toropova/prehlad/	Actor
2870	Michail Stankevič	\N	https://www.csfd.sk/tvorca/492559-michail-stankevic/prehlad/	Actor
2871	Alexej Ryžkov	\N	https://www.csfd.sk/tvorca/496967-alexej-ryzkov/prehlad/	Actor
2872	Margarita Šilova	\N	https://www.csfd.sk/tvorca/511086-margarita-silova/prehlad/	Actor
2873	Zinaida Matrosova	\N	https://www.csfd.sk/tvorca/513562-zinaida-matrosova/prehlad/	Actor
2874	Dmitrij Gotsdiněr	\N	https://www.csfd.sk/tvorca/178670-dmitrij-gotsdiner/prehlad/	Actor
2875	Semjon Ivanov	\N	https://www.csfd.sk/tvorca/584969-semjon-ivanov/prehlad/	Actor
2876	Georgij Teslja-Gerasimov	\N	https://www.csfd.sk/tvorca/592908-georgij-teslja-gerasimov/prehlad/	Actor
2877	Alexej Sorov	\N	https://www.csfd.sk/tvorca/593692-alexej-sorov/prehlad/	Actor
2878	Vjačeslav Pavljuť	\N	https://www.csfd.sk/tvorca/649237-vjaceslav-pavljut/prehlad/	Actor
2879	Ljubov Rumjanceva	\N	https://www.csfd.sk/tvorca/655573-ljubov-rumjanceva/prehlad/	Actor
2880	Stuart Whitman	\N	https://www.csfd.sk/tvorca/15012-stuart-whitman/prehlad/	Actor
2881	Robert Wagner	\N	https://www.csfd.sk/tvorca/8946-robert-wagner/prehlad/	Actor
2882	Glenn Corbett	\N	https://www.csfd.sk/tvorca/133793-glenn-corbett/prehlad/	Actor
2883	Rosemary Forsyth	\N	https://www.csfd.sk/tvorca/20427-rosemary-forsyth/prehlad/	Actor
2884	Burr DeBenning	\N	https://www.csfd.sk/tvorca/292058-burr-debenning/prehlad/	Actor
2885	Richard Basehart	\N	https://www.csfd.sk/tvorca/58342-richard-basehart/prehlad/	Actor
2886	Joseph Cotten	\N	https://www.csfd.sk/tvorca/195-joseph-cotten/prehlad/	Actor
2887	James Darren	\N	https://www.csfd.sk/tvorca/63646-james-darren/prehlad/	Actor
2888	Paul Stewart	\N	https://www.csfd.sk/tvorca/98179-paul-stewart/prehlad/	Actor
2889	Tom Drake	\N	https://www.csfd.sk/tvorca/88555-tom-drake/prehlad/	Actor
2890	Charles Dierkop	\N	https://www.csfd.sk/tvorca/49703-charles-dierkop/prehlad/	Actor
2891	Lloyd Bochner	\N	https://www.csfd.sk/tvorca/93789-lloyd-bochner/prehlad/	Actor
2892	Francine York	\N	https://www.csfd.sk/tvorca/102105-francine-york/prehlad/	Actor
2893	William Bryant	\N	https://www.csfd.sk/tvorca/155002-william-bryant/prehlad/	Actor
2894	Larry Pennell	\N	https://www.csfd.sk/tvorca/198956-larry-pennell/prehlad/	Actor
2895	Sheila Allen	\N	https://www.csfd.sk/tvorca/228515-sheila-allen/prehlad/	Actor
2896	Robert Colbert	\N	https://www.csfd.sk/tvorca/246458-robert-colbert/prehlad/	Actor
2897	Lawrence Montaigne	\N	https://www.csfd.sk/tvorca/302075-lawrence-montaigne/prehlad/	Actor
2898	Norman Grabowski	\N	https://www.csfd.sk/tvorca/400350-norman-grabowski/prehlad/	Actor
2899	George Holmes	\N	https://www.csfd.sk/tvorca/458555-george-holmes/prehlad/	Actor
2900	Edward G. Robinson Jr.	\N	https://www.csfd.sk/tvorca/781810-edward-g-robinson-jr/prehlad/	Actor
2901	Johnny Lee	\N	https://www.csfd.sk/tvorca/852842-johnny-lee/prehlad/	Actor
2902	Ray Didsbury	\N	https://www.csfd.sk/tvorca/872436-ray-didsbury/prehlad/	Actor
2903	Red Buttons	\N	https://www.csfd.sk/tvorca/5764-red-buttons/prehlad/	Actor
2904	Fabian	\N	https://www.csfd.sk/tvorca/71514-fabian/prehlad/	Actor
2905	Barbara Eden	\N	https://www.csfd.sk/tvorca/5248-barbara-eden/prehlad/	Actor
2906	Cedric Hardwicke	\N	https://www.csfd.sk/tvorca/7517-cedric-hardwicke/prehlad/	Actor
2907	Peter Lorre	\N	https://www.csfd.sk/tvorca/842-peter-lorre/prehlad/	Actor
2908	Richard Haydn	\N	https://www.csfd.sk/tvorca/11331-richard-haydn/prehlad/	Actor
2909	BarBara Luna	\N	https://www.csfd.sk/tvorca/50522-barbara-luna/prehlad/	Actor
2910	Billy Gilbert	\N	https://www.csfd.sk/tvorca/82711-billy-gilbert/prehlad/	Actor
2911	Herbert Marshall	\N	https://www.csfd.sk/tvorca/5454-herbert-marshall/prehlad/	Actor
2912	Reginald Owen	\N	https://www.csfd.sk/tvorca/93778-reginald-owen/prehlad/	Actor
2913	Henry Daniell	\N	https://www.csfd.sk/tvorca/84602-henry-daniell/prehlad/	Actor
2914	Mike Mazurki	\N	https://www.csfd.sk/tvorca/60426-mike-mazurki/prehlad/	Actor
2915	Vic Tayback	\N	https://www.csfd.sk/tvorca/89475-vic-tayback/prehlad/	Actor
2916	Roy Jenson	\N	https://www.csfd.sk/tvorca/123670-roy-jenson/prehlad/	Actor
2917	Raymond Bailey	\N	https://www.csfd.sk/tvorca/134112-raymond-bailey/prehlad/	Actor
2918	Ronald Long	\N	https://www.csfd.sk/tvorca/287448-ronald-long/prehlad/	Actor
2919	Scott Seaton	\N	https://www.csfd.sk/tvorca/291240-scott-seaton/prehlad/	Actor
2920	Alan Caillou	\N	https://www.csfd.sk/tvorca/325666-alan-caillou/prehlad/	Actor
2921	Hedley Mattingly	\N	https://www.csfd.sk/tvorca/348375-hedley-mattingly/prehlad/	Actor
2922	Loren Lester	\N	https://www.csfd.sk/tvorca/370935-loren-lester/prehlad/	Actor
2923	George Sawaya	\N	https://www.csfd.sk/tvorca/401322-george-sawaya/prehlad/	Actor
2924	Joe Abdullah	\N	https://www.csfd.sk/tvorca/419131-joe-abdullah/prehlad/	Actor
2925	Mike De Anda	\N	https://www.csfd.sk/tvorca/443005-mike-de-anda/prehlad/	Actor
2926	Ben Astar	\N	https://www.csfd.sk/tvorca/462529-ben-astar/prehlad/	Actor
2927	Michael Rennie	\N	https://www.csfd.sk/tvorca/35946-michael-rennie/prehlad/	Actor
2928	Jill St. John	\N	https://www.csfd.sk/tvorca/21149-jill-st-john/prehlad/	Actor
2929	David Hedison	\N	https://www.csfd.sk/tvorca/32100-david-hedison/prehlad/	Actor
2930	Claude Rains	\N	https://www.csfd.sk/tvorca/2460-claude-rains/prehlad/	Actor
2931	Fernando Lamas	\N	https://www.csfd.sk/tvorca/67191-fernando-lamas/prehlad/	Actor
2932	Ray Stricklyn	\N	https://www.csfd.sk/tvorca/95936-ray-stricklyn/prehlad/	Actor
2933	Jay Novello	\N	https://www.csfd.sk/tvorca/258521-jay-novello/prehlad/	Actor
2934	Ian Wolfe	\N	https://www.csfd.sk/tvorca/138859-ian-wolfe/prehlad/	Actor
2935	Brian Roper	\N	https://www.csfd.sk/tvorca/98010-brian-roper/prehlad/	Actor
2936	Ben Wright	\N	https://www.csfd.sk/tvorca/123885-ben-wright/prehlad/	Actor
2937	Bess Flowers	\N	https://www.csfd.sk/tvorca/131978-bess-flowers/prehlad/	Actor
2938	Bert Stevens	\N	https://www.csfd.sk/tvorca/134899-bert-stevens/prehlad/	Actor
2939	Kenner G. Kemp	\N	https://www.csfd.sk/tvorca/135037-kenner-g-kemp/prehlad/	Actor
2940	Sam Harris	\N	https://www.csfd.sk/tvorca/135753-sam-harris/prehlad/	Actor
2941	Harold Miller	\N	https://www.csfd.sk/tvorca/135762-harold-miller/prehlad/	Actor
2942	Cosmo Sardo	\N	https://www.csfd.sk/tvorca/181086-cosmo-sardo/prehlad/	Actor
2943	Peter Fontaine	\N	https://www.csfd.sk/tvorca/290964-peter-fontaine/prehlad/	Actor
2944	George Pelling	\N	https://www.csfd.sk/tvorca/301053-george-pelling/prehlad/	Actor
2945	Larry Chance	\N	https://www.csfd.sk/tvorca/338721-larry-chance/prehlad/	Actor
2946	Gilchrist Stuart	\N	https://www.csfd.sk/tvorca/348379-gilchrist-stuart/prehlad/	Actor
2947	Murray Pollack	\N	https://www.csfd.sk/tvorca/380910-murray-pollack/prehlad/	Actor
2948	Owen Song	\N	https://www.csfd.sk/tvorca/467210-owen-song/prehlad/	Actor
2949	Fred Cavens	\N	https://www.csfd.sk/tvorca/572617-fred-cavens/prehlad/	Actor
2950	Winona Ryder	\N	https://www.csfd.sk/tvorca/162-winona-ryder/prehlad/	Actor
2951	Jeff Daniels	\N	https://www.csfd.sk/tvorca/386-jeff-daniels/prehlad/	Actor
2952	Graham Beckel	\N	https://www.csfd.sk/tvorca/16318-graham-beckel/prehlad/	Actor
2953	Frances Fisher	\N	https://www.csfd.sk/tvorca/5711-frances-fisher/prehlad/	Actor
2954	Dinah Manoff	\N	https://www.csfd.sk/tvorca/87114-dinah-manoff/prehlad/	Actor
2955	Stephen Tobolowsky	\N	https://www.csfd.sk/tvorca/294-stephen-tobolowsky/prehlad/	Actor
2956	Robby Kiger	\N	https://www.csfd.sk/tvorca/310621-robby-kiger/prehlad/	Actor
2957	Robin Thomas	\N	https://www.csfd.sk/tvorca/16633-robin-thomas/prehlad/	Actor
2958	Valerie Landsburg	\N	https://www.csfd.sk/tvorca/22067-valerie-landsburg/prehlad/	Actor
2959	Carla Gugino	\N	https://www.csfd.sk/tvorca/5842-carla-gugino/prehlad/	Actor
2960	Angela Paton	\N	https://www.csfd.sk/tvorca/79681-angela-paton/prehlad/	Actor
2961	Thomas Wilson Brown	\N	https://www.csfd.sk/tvorca/86944-thomas-wilson-brown/prehlad/	Actor
2962	Rob King	\N	https://www.csfd.sk/tvorca/116498-rob-king/prehlad/	Actor
2963	Laila Robins	\N	https://www.csfd.sk/tvorca/149414-laila-robins/prehlad/	Actor
2964	Jim Pirri	\N	https://www.csfd.sk/tvorca/184155-jim-pirri/prehlad/	Actor
2965	Terrence Evans	\N	https://www.csfd.sk/tvorca/218078-terrence-evans/prehlad/	Actor
2966	Micole Mercurio	\N	https://www.csfd.sk/tvorca/224604-micole-mercurio/prehlad/	Actor
2967	Rhonda Aldrich	\N	https://www.csfd.sk/tvorca/242023-rhonda-aldrich/prehlad/	Actor
2968	John Short	\N	https://www.csfd.sk/tvorca/257940-john-short/prehlad/	Actor
2969	Ron Perkins	\N	https://www.csfd.sk/tvorca/282468-ron-perkins/prehlad/	Actor
2970	Carl Steven	\N	https://www.csfd.sk/tvorca/325961-carl-steven/prehlad/	Actor
2971	Nada Despotovich	\N	https://www.csfd.sk/tvorca/343805-nada-despotovich/prehlad/	Actor
2972	Vince Trankina	\N	https://www.csfd.sk/tvorca/379536-vince-trankina/prehlad/	Actor
2973	Joe Nesnow	\N	https://www.csfd.sk/tvorca/385413-joe-nesnow/prehlad/	Actor
2974	Hal Havins	\N	https://www.csfd.sk/tvorca/416924-hal-havins/prehlad/	Actor
2975	Stephen Burrows	\N	https://www.csfd.sk/tvorca/424200-stephen-burrows/prehlad/	Actor
2976	Joan McMurtrey	\N	https://www.csfd.sk/tvorca/436258-joan-mcmurtrey/prehlad/	Actor
2977	Kevin Skousen	\N	https://www.csfd.sk/tvorca/498804-kevin-skousen/prehlad/	Actor
2978	Damion Dietz	\N	https://www.csfd.sk/tvorca/572850-damion-dietz/prehlad/	Actor
2979	Charlie Holliday	\N	https://www.csfd.sk/tvorca/644524-charlie-holliday/prehlad/	Actor
2980	Amy Moore Davis	\N	https://www.csfd.sk/tvorca/660261-amy-moore-davis/prehlad/	Actor
2981	Ava Fabian	\N	https://www.csfd.sk/tvorca/687789-ava-fabian/prehlad/	Actor
2982	Meg Harrington	\N	https://www.csfd.sk/tvorca/753964-meg-harrington/prehlad/	Actor
2983	Rocky Krakoff	\N	https://www.csfd.sk/tvorca/869726-rocky-krakoff/prehlad/	Actor
2984	Joey Bishop	\N	https://www.csfd.sk/tvorca/19898-joey-bishop/prehlad/	Actor
2985	Madeline Kahn	\N	https://www.csfd.sk/tvorca/6475-madeline-kahn/prehlad/	Actor
2986	Anthony LaPaglia	\N	https://www.csfd.sk/tvorca/2511-anthony-lapaglia/prehlad/	Actor
2987	Catherine O'Hara	\N	https://www.csfd.sk/tvorca/1803-catherine-o-hara/prehlad/	Actor
2988	Joe Pesci	\N	https://www.csfd.sk/tvorca/460-joe-pesci/prehlad/	Actor
2989	Molly Ringwald	\N	https://www.csfd.sk/tvorca/586-molly-ringwald/prehlad/	Actor
2990	Ally Sheedy	\N	https://www.csfd.sk/tvorca/2047-ally-sheedy/prehlad/	Actor
2991	Burt Young	\N	https://www.csfd.sk/tvorca/16659-burt-young/prehlad/	Actor
2992	Julie Bovasso	\N	https://www.csfd.sk/tvorca/291812-julie-bovasso/prehlad/	Actor
2993	Bibi Besch	\N	https://www.csfd.sk/tvorca/98149-bibi-besch/prehlad/	Actor
2994	Dylan Walsh	\N	https://www.csfd.sk/tvorca/16648-dylan-walsh/prehlad/	Actor
2995	Frankie Faison	\N	https://www.csfd.sk/tvorca/11947-frankie-faison/prehlad/	Actor
2996	Samuel L. Jackson	\N	https://www.csfd.sk/tvorca/425-samuel-l-jackson/prehlad/	Actor
2997	Tom Mardirosian	\N	https://www.csfd.sk/tvorca/37909-tom-mardirosian/prehlad/	Actor
2998	Harry L. Seddon	\N	https://www.csfd.sk/tvorca/58374-harry-l-seddon/prehlad/	Actor
2999	Camille Saviola	\N	https://www.csfd.sk/tvorca/58570-camille-saviola/prehlad/	Actor
3000	Allan Rich	\N	https://www.csfd.sk/tvorca/152473-allan-rich/prehlad/	Actor
3001	Sully Boyar	\N	https://www.csfd.sk/tvorca/244453-sully-boyar/prehlad/	Actor
3002	Larry Block	\N	https://www.csfd.sk/tvorca/334040-larry-block/prehlad/	Actor
3003	Helen Hanft	\N	https://www.csfd.sk/tvorca/391741-helen-hanft/prehlad/	Actor
3004	Larry Rapp	\N	https://www.csfd.sk/tvorca/770332-larry-rapp/prehlad/	Actor
3005	Mario Todisco	\N	https://www.csfd.sk/tvorca/853600-mario-todisco/prehlad/	Actor
3006	Hal Linden	\N	https://www.csfd.sk/tvorca/52217-hal-linden/prehlad/	Actor
3007	Ann-Margret	\N	https://www.csfd.sk/tvorca/5169-ann-margret/prehlad/	Actor
3008	Veronica Hamel	\N	https://www.csfd.sk/tvorca/5841-veronica-hamel/prehlad/	Actor
3009	John Shea	\N	https://www.csfd.sk/tvorca/6482-john-shea/prehlad/	Actor
3010	Mary Kay Place	\N	https://www.csfd.sk/tvorca/8778-mary-kay-place/prehlad/	Actor
3011	Beatrice Alda	\N	https://www.csfd.sk/tvorca/129781-beatrice-alda/prehlad/	Actor
3012	Victoria Snow	\N	https://www.csfd.sk/tvorca/14529-victoria-snow/prehlad/	Actor
3013	John Kozak	\N	https://www.csfd.sk/tvorca/8317-john-kozak/prehlad/	Actor
3014	Barry Flatman	\N	https://www.csfd.sk/tvorca/9937-barry-flatman/prehlad/	Actor
3015	Michèle Duquet	\N	https://www.csfd.sk/tvorca/8087-michele-duquet/prehlad/	Actor
3016	Celia Weston	\N	https://www.csfd.sk/tvorca/1835-celia-weston/prehlad/	Actor
3017	Fiona Reid	\N	https://www.csfd.sk/tvorca/18914-fiona-reid/prehlad/	Actor
3018	Paul Hecht	\N	https://www.csfd.sk/tvorca/59345-paul-hecht/prehlad/	Actor
3019	Catherine Disher	\N	https://www.csfd.sk/tvorca/86133-catherine-disher/prehlad/	Actor
3020	Michael Kirby	\N	https://www.csfd.sk/tvorca/214897-michael-kirby/prehlad/	Actor
3021	C. David Johnson	\N	https://www.csfd.sk/tvorca/269467-c-david-johnson/prehlad/	Actor
3022	Malcolm Stewart	\N	https://www.csfd.sk/tvorca/283495-malcolm-stewart/prehlad/	Actor
3023	Deborah Theaker	\N	https://www.csfd.sk/tvorca/507199-deborah-theaker/prehlad/	Actor
3024	David Eisner	\N	https://www.csfd.sk/tvorca/324374-david-eisner/prehlad/	Actor
3025	Alec Mapa	\N	https://www.csfd.sk/tvorca/594879-alec-mapa/prehlad/	Actor
3026	Mark Terry	\N	https://www.csfd.sk/tvorca/601015-mark-terry/prehlad/	Actor
3027	Janet Bailey	\N	https://www.csfd.sk/tvorca/660759-janet-bailey/prehlad/	Actor
3028	Deann DeGruijter	\N	https://www.csfd.sk/tvorca/826935-deann-degruijter/prehlad/	Actor
3029	Cynthia Belliveau	\N	https://www.csfd.sk/tvorca/870707-cynthia-belliveau/prehlad/	Actor
3030	Eve Crawford	\N	https://www.csfd.sk/tvorca/926794-eve-crawford/prehlad/	Actor
3031	Sally Field	\N	https://www.csfd.sk/tvorca/541-sally-field/prehlad/	Actor
3032	Telly Savalas	\N	https://www.csfd.sk/tvorca/2282-telly-savalas/prehlad/	Actor
3033	Peter Boyle	\N	https://www.csfd.sk/tvorca/359-peter-boyle/prehlad/	Actor
3034	Jack Warden	\N	https://www.csfd.sk/tvorca/506-jack-warden/prehlad/	Actor
3035	Shirley Knight	\N	https://www.csfd.sk/tvorca/7664-shirley-knight/prehlad/	Actor
3036	Shirley Jones	\N	https://www.csfd.sk/tvorca/6258-shirley-jones/prehlad/	Actor
3037	Karl Malden	\N	https://www.csfd.sk/tvorca/4263-karl-malden/prehlad/	Actor
3038	Slim Pickens	\N	https://www.csfd.sk/tvorca/50346-slim-pickens/prehlad/	Actor
3039	Angela Cartwright	\N	https://www.csfd.sk/tvorca/72443-angela-cartwright/prehlad/	Actor
3040	Mark Harmon	\N	https://www.csfd.sk/tvorca/1802-mark-harmon/prehlad/	Actor
3041	Dean Raphael Ferrandini	\N	https://www.csfd.sk/tvorca/88981-dean-raphael-ferrandini/prehlad/	Actor
3042	Paul Picerni	\N	https://www.csfd.sk/tvorca/123056-paul-picerni/prehlad/	Actor
3043	Patrick Culliton	\N	https://www.csfd.sk/tvorca/305474-patrick-culliton/prehlad/	Actor
3044	Carol Burnett	\N	https://www.csfd.sk/tvorca/12868-carol-burnett/prehlad/	Actor
3045	Len Cariou	\N	https://www.csfd.sk/tvorca/59330-len-cariou/prehlad/	Actor
3046	Sandy Dennis	\N	https://www.csfd.sk/tvorca/6251-sandy-dennis/prehlad/	Actor
3047	Rita Moreno	\N	https://www.csfd.sk/tvorca/6257-rita-moreno/prehlad/	Actor
3048	Jack Weston	\N	https://www.csfd.sk/tvorca/11485-jack-weston/prehlad/	Actor
3049	Bess Armstrong	\N	https://www.csfd.sk/tvorca/6044-bess-armstrong/prehlad/	Actor
3050	Elizabeth Alda	\N	https://www.csfd.sk/tvorca/129780-elizabeth-alda/prehlad/	Actor
3052	Henry Wills	\N	https://www.csfd.sk/tvorca/179189-henry-wills/	Actor
1787	Sean McCann	\N	https://www.csfd.sk/tvorca/85359-sean-mccann/	Actor
1842	Maureen McGovern	\N	https://www.csfd.sk/tvorca/746288-maureen-mcgovern/	Actor
3053	Libor Kodad	\N	https://www.csfd.sk/tvorca/61293-libor-kodad/	Director
3075	Jordan Haj	\N	https://www.csfd.sk/tvorca/88866-jordan-haj/	Actor
3055	Lucie Benešová	\N	https://www.csfd.sk/tvorca/1093-lucie-benesova/	Actor
3056	Jan Šťastný	\N	https://www.csfd.sk/tvorca/1486-jan-stastny/	Actor
3057	Karel Heřmánek	\N	https://www.csfd.sk/tvorca/1807-karel-hermanek/	Actor
3058	Václav Vydra	\N	https://www.csfd.sk/tvorca/1005-vaclav-vydra/	Actor
3059	Zuzana Bydžovská	\N	https://www.csfd.sk/tvorca/1420-zuzana-bydzovska/	Actor
3060	Ondřej Gregor Brzobohatý	\N	https://www.csfd.sk/tvorca/35459-ondrej-gregor-brzobohaty/	Actor
3061	Jan Révai	\N	https://www.csfd.sk/tvorca/1511-jan-revai/	Actor
3062	Daniela Šinkorová	\N	https://www.csfd.sk/tvorca/26674-daniela-sinkorova/	Actor
3063	Květa Fialová	\N	https://www.csfd.sk/tvorca/1144-kveta-fialova/	Actor
3064	Jana Švandová	\N	https://www.csfd.sk/tvorca/1339-jana-svandova/	Actor
3065	Václav Kopta	\N	https://www.csfd.sk/tvorca/30692-vaclav-kopta/	Actor
3066	Milan Šteindler	\N	https://www.csfd.sk/tvorca/3304-milan-steindler/	Actor
3068	Kamila Sedlárová	\N	https://www.csfd.sk/tvorca/57198-kamila-sedlarova/	Actor
3069	Kristýna Leichtová	\N	https://www.csfd.sk/tvorca/24902-kristyna-leichtova/	Actor
3070	Eva Salvatore Burešová	\N	https://www.csfd.sk/tvorca/93399-eva-salvatore-buresova/	Actor
3071	Ondřej Rychlý	\N	https://www.csfd.sk/tvorca/61783-ondrej-rychly/	Actor
3072	David Gránský	\N	https://www.csfd.sk/tvorca/88865-david-gransky/	Actor
3073	Ivana Korolová	\N	https://www.csfd.sk/tvorca/25005-ivana-korolova/	Actor
3074	Vojtěch Vondráček	\N	https://www.csfd.sk/tvorca/162562-vojtech-vondracek/	Actor
3080	Chantal Poullain	\N	https://www.csfd.sk/tvorca/17188-chantal-poullain/	Actor
3085	Lilian Malkina	\N	https://www.csfd.sk/tvorca/9102-lilian-malkina/	Actor
3088	Anastasia Trmal	\N	https://www.csfd.sk/tvorca/93398-anastasia-trmal/	Actor
3054	Dana Batulková	\N	https://www.csfd.sk/tvorca/7250-dana-batulkova/	Actor
3067	Libuše Švormová	\N	https://www.csfd.sk/tvorca/1344-libuse-svormova/	Actor
3076	Josef Polášek	\N	https://www.csfd.sk/tvorca/26074-josef-polasek/	Actor
3077	Jiří Zapletal	\N	https://www.csfd.sk/tvorca/93396-jiri-zapletal/	Actor
3078	Josef Kubáník	\N	https://www.csfd.sk/tvorca/53981-josef-kubanik/	Actor
3079	Eva Novotná	\N	https://www.csfd.sk/tvorca/54906-eva-novotna/	Actor
3081	Monika Absolonová	\N	https://www.csfd.sk/tvorca/12059-monika-absolonova/	Actor
3082	Robert Nebřenský	\N	https://www.csfd.sk/tvorca/33320-robert-nebrensky/	Actor
3083	Miloslav Mejzlík	\N	https://www.csfd.sk/tvorca/40266-miloslav-mejzlik/	Actor
3084	Hana Gregorová	\N	https://www.csfd.sk/tvorca/1169-hana-gregorova/	Actor
3086	Ludmila Zábršová-Molínová	\N	https://www.csfd.sk/tvorca/47770-ludmila-zabrsova-molinova/	Actor
3087	Jana Altmannová	\N	https://www.csfd.sk/tvorca/1082-jana-altmannova/	Actor
3089	Vojtěch Machuta	\N	https://www.csfd.sk/tvorca/75447-vojtech-machuta/	Actor
3090	Vendula Hlásková	\N	https://www.csfd.sk/tvorca/73517-vendula-hlaskova/	Actor
3091	Karel Heřmánek ml.	\N	https://www.csfd.sk/tvorca/71520-karel-hermanek-ml/	Actor
3092	Natálie Halouzková	\N	https://www.csfd.sk/tvorca/117850-natalie-halouzkova/	Actor
3093	Milan Slepička	\N	https://www.csfd.sk/tvorca/39889-milan-slepicka/	Actor
3094	Fabián Povýšil	\N	https://www.csfd.sk/tvorca/94973-fabian-povysil/	Actor
3095	Jan Maršál	\N	https://www.csfd.sk/tvorca/64591-jan-marsal/	Actor
3096	Marek Dobeš	\N	https://www.csfd.sk/tvorca/8678-marek-dobes/	Actor
3097	Dušan Sitek	\N	https://www.csfd.sk/tvorca/50795-dusan-sitek/	Actor
3098	Lucie Černá	\N	https://www.csfd.sk/tvorca/93622-lucie-cerna/	Actor
3099	Barbora Černá	\N	https://www.csfd.sk/tvorca/93621-barbora-cerna/	Actor
3100	Carol Connors	\N	https://www.csfd.sk/tvorca/971966-carol-connors/	Actor
3101	Kathryn Mullen	\N	https://www.csfd.sk/tvorca/979684-kathryn-mullen/	Actor
3102	Ronald Colman	\N	https://www.csfd.sk/tvorca/760-ronald-colman/	Actor
3103	Hedy Lamarr	\N	https://www.csfd.sk/tvorca/831-hedy-lamarr/	Actor
3104	Groucho Marx	\N	https://www.csfd.sk/tvorca/4198-groucho-marx/	Actor
3105	Harpo Marx	\N	https://www.csfd.sk/tvorca/4200-harpo-marx/	Actor
3106	Chico Marx	\N	https://www.csfd.sk/tvorca/4199-chico-marx/	Actor
3107	Virginia Mayo	\N	https://www.csfd.sk/tvorca/20494-virginia-mayo/	Actor
3108	Agnes Moorehead	\N	https://www.csfd.sk/tvorca/196-agnes-moorehead/	Actor
3109	Vincent Price	\N	https://www.csfd.sk/tvorca/885-vincent-price/	Actor
3110	Charles Coburn	\N	https://www.csfd.sk/tvorca/6279-charles-coburn/	Actor
3111	Cesar Romero	\N	https://www.csfd.sk/tvorca/53238-cesar-romero/	Actor
3112	John Carradine	\N	https://www.csfd.sk/tvorca/4369-john-carradine/	Actor
3113	Dennis Hopper	\N	https://www.csfd.sk/tvorca/236-dennis-hopper/	Actor
3114	Marie Wilson	\N	https://www.csfd.sk/tvorca/93343-marie-wilson/	Actor
3115	Edward Everett Horton	\N	https://www.csfd.sk/tvorca/51043-edward-everett-horton/	Actor
3116	Reginald Gardiner	\N	https://www.csfd.sk/tvorca/23269-reginald-gardiner/	Actor
3117	Marie Windsor	\N	https://www.csfd.sk/tvorca/5522-marie-windsor/	Actor
3120	Franklin Pangborn	\N	https://www.csfd.sk/tvorca/92952-franklin-pangborn/	Actor
3122	David Bond	\N	https://www.csfd.sk/tvorca/8172-david-bond/	Actor
3123	Nick Cravat	\N	https://www.csfd.sk/tvorca/181081-nick-cravat/	Actor
3124	Dani Janssen	\N	https://www.csfd.sk/tvorca/265704-dani-janssen/	Actor
3125	Bobby Watson	\N	https://www.csfd.sk/tvorca/23920-bobby-watson/	Actor
3126	Marvin Miller	\N	https://www.csfd.sk/tvorca/86818-marvin-miller/	Actor
3127	Ziva Rodann	\N	https://www.csfd.sk/tvorca/124562-ziva-rodann/	Actor
3128	William Schallert	\N	https://www.csfd.sk/tvorca/113267-william-schallert/	Actor
3129	Anthony Dexter	\N	https://www.csfd.sk/tvorca/106426-anthony-dexter/	Actor
3130	Melville Cooper	\N	https://www.csfd.sk/tvorca/147278-melville-cooper/	Actor
3131	Fred Kelsey	\N	https://www.csfd.sk/tvorca/152212-fred-kelsey/	Actor
3132	Don Megowan	\N	https://www.csfd.sk/tvorca/199689-don-megowan/	Actor
3133	Abraham Sofaer	\N	https://www.csfd.sk/tvorca/200405-abraham-sofaer/	Actor
3134	Toni Gerry	\N	https://www.csfd.sk/tvorca/220452-toni-gerry/	Actor
3135	Helmut Dantine	\N	https://www.csfd.sk/tvorca/92932-helmut-dantine/	Actor
3136	Sailor Vincent	\N	https://www.csfd.sk/tvorca/269701-sailor-vincent/	Actor
3138	Alexander Lockwood	\N	https://www.csfd.sk/tvorca/315150-alexander-lockwood/	Actor
3139	Paul Kruger	\N	https://www.csfd.sk/tvorca/330516-paul-kruger/	Actor
3140	Reginald Sheffield	\N	https://www.csfd.sk/tvorca/334774-reginald-sheffield/	Actor
3141	Tudor Owen	\N	https://www.csfd.sk/tvorca/336147-tudor-owen/	Actor
3142	Leonard Mudie	\N	https://www.csfd.sk/tvorca/341035-leonard-mudie/	Actor
3143	Jack Henderson	\N	https://www.csfd.sk/tvorca/458554-jack-henderson/	Actor
3144	Austin Green	\N	https://www.csfd.sk/tvorca/575122-austin-green/	Actor
3145	Harry Ruby	\N	https://www.csfd.sk/tvorca/603572-harry-ruby/	Actor
3146	John Guillermin	\N	https://www.csfd.sk/tvorca/2920-john-guillermin/	Director
3148	Paul Newman	\N	https://www.csfd.sk/tvorca/93-paul-newman/	Actor
3149	William Holden	\N	https://www.csfd.sk/tvorca/813-william-holden/	Actor
3119	George E. Stone	\N	https://www.csfd.sk/tvorca/71571-george-e-stone/	Actor
3121	Francis X. Bushman	\N	https://www.csfd.sk/tvorca/85021-francis-x-bushman/	Actor
3137	Richard H. Cutting	\N	https://www.csfd.sk/tvorca/296174-richard-h-cutting/	Actor
3147	Steve McQueen	\N	https://www.csfd.sk/tvorca/854-steve-mcqueen/	Actor
3150	Faye Dunaway	\N	https://www.csfd.sk/tvorca/538-faye-dunaway/	Actor
3151	Fred Astaire	\N	https://www.csfd.sk/tvorca/736-fred-astaire/	Actor
3152	Susan Blakely	\N	https://www.csfd.sk/tvorca/5330-susan-blakely/	Actor
3153	Richard Chamberlain	\N	https://www.csfd.sk/tvorca/1902-richard-chamberlain/	Actor
3154	Jennifer Jones	\N	https://www.csfd.sk/tvorca/820-jennifer-jones/	Actor
3156	Robert Vaughn	\N	https://www.csfd.sk/tvorca/504-robert-vaughn/	Actor
3157	Susan Flannery	\N	https://www.csfd.sk/tvorca/83152-susan-flannery/	Actor
3158	Norman Burton	\N	https://www.csfd.sk/tvorca/11247-norman-burton/	Actor
3159	Jack Collins	\N	https://www.csfd.sk/tvorca/228520-jack-collins/	Actor
3160	Don Gordon	\N	https://www.csfd.sk/tvorca/77694-don-gordon/	Actor
3161	Felton Perry	\N	https://www.csfd.sk/tvorca/107879-felton-perry/	Actor
3162	Dabney Coleman	\N	https://www.csfd.sk/tvorca/6468-dabney-coleman/	Actor
3163	Paul Comi	\N	https://www.csfd.sk/tvorca/17382-paul-comi/	Actor
3164	Jennifer Rhodes	\N	https://www.csfd.sk/tvorca/18122-jennifer-rhodes/	Actor
3165	William Bassett	\N	https://www.csfd.sk/tvorca/154780-william-bassett/	Actor
3167	John Crawford	\N	https://www.csfd.sk/tvorca/156838-john-crawford/	Actor
3168	Olan Soule	\N	https://www.csfd.sk/tvorca/228662-olan-soule/	Actor
3170	Mike Lookinland	\N	https://www.csfd.sk/tvorca/305472-mike-lookinland/	Actor
3171	William Traylor	\N	https://www.csfd.sk/tvorca/318208-william-traylor/	Actor
3172	Paul King	\N	https://www.csfd.sk/tvorca/352375-paul-king/	Actor
3173	David Armstrong	\N	https://www.csfd.sk/tvorca/410046-david-armstrong/	Actor
3174	Dale Johnson	\N	https://www.csfd.sk/tvorca/410444-dale-johnson/	Actor
3175	Scott Newman	\N	https://www.csfd.sk/tvorca/633613-scott-newman/	Actor
3176	Peter Eastman	\N	https://www.csfd.sk/tvorca/560242-peter-eastman/	Actor
3177	Robert Hitchcock	\N	https://www.csfd.sk/tvorca/561705-robert-hitchcock/	Actor
3178	Robert Buckingham	\N	https://www.csfd.sk/tvorca/561466-robert-buckingham/	Actor
3179	Hank Robinson	\N	https://www.csfd.sk/tvorca/559557-hank-robinson/	Actor
3180	Larry Carr	\N	https://www.csfd.sk/tvorca/850960-larry-carr/	Actor
3181	Art Balinger	\N	https://www.csfd.sk/tvorca/872117-art-balinger/	Actor
3182	Don Terwilliger	\N	https://www.csfd.sk/tvorca/565595-don-terwilliger/	Actor
3184	Walter Pidgeon	\N	https://www.csfd.sk/tvorca/4228-walter-pidgeon/	Actor
3185	Joan Fontaine	\N	https://www.csfd.sk/tvorca/786-joan-fontaine/	Actor
3186	Robert Sterling	\N	https://www.csfd.sk/tvorca/131641-robert-sterling/	Actor
3187	Michael Ansara	\N	https://www.csfd.sk/tvorca/123503-michael-ansara/	Actor
3188	Frankie Avalon	\N	https://www.csfd.sk/tvorca/49687-frankie-avalon/	Actor
3189	Mark Slade	\N	https://www.csfd.sk/tvorca/17426-mark-slade/	Actor
3190	Regis Toomey	\N	https://www.csfd.sk/tvorca/88868-regis-toomey/	Actor
3191	John Litel	\N	https://www.csfd.sk/tvorca/132882-john-litel/	Actor
3193	Robert Easton	\N	https://www.csfd.sk/tvorca/156843-robert-easton/	Actor
3194	Charles Tannen	\N	https://www.csfd.sk/tvorca/177425-charles-tannen/	Actor
3195	Robert Sampson	\N	https://www.csfd.sk/tvorca/219089-robert-sampson/	Actor
3197	Skip Ward	\N	https://www.csfd.sk/tvorca/311785-skip-ward/	Actor
3198	Art Baker	\N	https://www.csfd.sk/tvorca/355028-art-baker/	Actor
3199	Woody Allen	\N	https://www.csfd.sk/tvorca/346-woody-allen/	Director
3200	Mia Farrow	\N	https://www.csfd.sk/tvorca/778-mia-farrow/	Actor
3201	Alec Baldwin	\N	https://www.csfd.sk/tvorca/351-alec-baldwin/	Actor
3202	Blythe Danner	\N	https://www.csfd.sk/tvorca/1859-blythe-danner/	Actor
3203	Judy Davis	\N	https://www.csfd.sk/tvorca/532-judy-davis/	Actor
3204	William Hurt	\N	https://www.csfd.sk/tvorca/423-william-hurt/	Actor
3205	Joe Mantegna	\N	https://www.csfd.sk/tvorca/4902-joe-mantegna/	Actor
3206	June Squibb	\N	https://www.csfd.sk/tvorca/103610-june-squibb/	Actor
3207	Bernadette Peters	\N	https://www.csfd.sk/tvorca/5077-bernadette-peters/	Actor
3208	Cybill Shepherd	\N	https://www.csfd.sk/tvorca/2272-cybill-shepherd/	Actor
3209	Gwen Verdon	\N	https://www.csfd.sk/tvorca/38886-gwen-verdon/	Actor
3211	Holland Taylor	\N	https://www.csfd.sk/tvorca/21152-holland-taylor/	Actor
3212	Julie Kavner	\N	https://www.csfd.sk/tvorca/11585-julie-kavner/	Actor
3213	Robin Bartlett	\N	https://www.csfd.sk/tvorca/20375-robin-bartlett/	Actor
3214	Rachel Miner	\N	https://www.csfd.sk/tvorca/23034-rachel-miner/	Actor
3215	Caroline Aaron	\N	https://www.csfd.sk/tvorca/24712-caroline-aaron/	Actor
3216	James Toback	\N	https://www.csfd.sk/tvorca/7896-james-toback/	Actor
3217	Elle Macpherson	\N	https://www.csfd.sk/tvorca/2087-elle-macpherson/	Actor
3218	Lisa Marie	\N	https://www.csfd.sk/tvorca/2553-lisa-marie/	Actor
3219	Diane Salinger	\N	https://www.csfd.sk/tvorca/17711-diane-salinger/	Actor
3220	David Spielberg	\N	https://www.csfd.sk/tvorca/68295-david-spielberg/	Actor
3221	Bob Balaban	\N	https://www.csfd.sk/tvorca/13515-bob-balaban/	Actor
3222	Peter Tolan	\N	https://www.csfd.sk/tvorca/39509-peter-tolan/	Actor
3223	Jodi Long	\N	https://www.csfd.sk/tvorca/44495-jodi-long/	Actor
3224	Marceline Hugot	\N	https://www.csfd.sk/tvorca/49048-marceline-hugot/	Actor
3225	Kim Chan	\N	https://www.csfd.sk/tvorca/61999-kim-chan/	Actor
3227	Keye Luke	\N	https://www.csfd.sk/tvorca/118494-keye-luke/	Actor
3228	Ira Wheeler	\N	https://www.csfd.sk/tvorca/214951-ira-wheeler/	Actor
3169	Ernie F. Orsatti	\N	https://www.csfd.sk/tvorca/300241-ernie-f-orsatti/	Actor
3183	Orwin C. Harvey	\N	https://www.csfd.sk/tvorca/931576-orwin-c-harvey/	Actor
3192	Howard McNear	\N	https://www.csfd.sk/tvorca/133746-howard-mcnear/	Actor
3196	David McLean	\N	https://www.csfd.sk/tvorca/259633-david-mclean/	Actor
3210	Patrick O'Neal	\N	https://www.csfd.sk/tvorca/53446-patrick-o-neal/	Actor
3226	James McDaniel	\N	https://www.csfd.sk/tvorca/77038-james-mcdaniel/	Actor
3229	Linda Wallem	\N	https://www.csfd.sk/tvorca/311206-linda-wallem/	Actor
3230	Peggy Miley	\N	https://www.csfd.sk/tvorca/311210-peggy-miley/	Actor
3231	Amy Barrett	\N	https://www.csfd.sk/tvorca/352045-amy-barrett/	Actor
3232	Mary Stein	\N	https://www.csfd.sk/tvorca/437559-mary-stein/	Actor
3234	Gena Rowlands	\N	https://www.csfd.sk/tvorca/6457-gena-rowlands/	Actor
3235	Ian Holm	\N	https://www.csfd.sk/tvorca/171-ian-holm/	Actor
3236	Gene Hackman	\N	https://www.csfd.sk/tvorca/410-gene-hackman/	Actor
3237	Martha Plimpton	\N	https://www.csfd.sk/tvorca/9094-martha-plimpton/	Actor
3238	John Houseman	\N	https://www.csfd.sk/tvorca/6244-john-houseman/	Actor
3239	Philip Bosco	\N	https://www.csfd.sk/tvorca/5918-philip-bosco/	Actor
3240	Harris Yulin	\N	https://www.csfd.sk/tvorca/7929-harris-yulin/	Actor
3241	Frances Conroy	\N	https://www.csfd.sk/tvorca/5747-frances-conroy/	Actor
3242	Fred Melamed	\N	https://www.csfd.sk/tvorca/56769-fred-melamed/	Actor
3243	Kenneth Welsh	\N	https://www.csfd.sk/tvorca/6410-kenneth-welsh/	Actor
3244	Dana Ivey	\N	https://www.csfd.sk/tvorca/1893-dana-ivey/	Actor
3245	Josh Hamilton	\N	https://www.csfd.sk/tvorca/412-josh-hamilton/	Actor
3246	Betty Buckley	\N	https://www.csfd.sk/tvorca/46424-betty-buckley/	Actor
3247	Jack Gelber	\N	https://www.csfd.sk/tvorca/49389-jack-gelber/	Actor
3248	Kathryn Grody	\N	https://www.csfd.sk/tvorca/361851-kathryn-grody/	Actor
3249	Alice Spivak	\N	https://www.csfd.sk/tvorca/367780-alice-spivak/	Actor
3250	Stephen Mailer	\N	https://www.csfd.sk/tvorca/391969-stephen-mailer/	Actor
3251	Noel Behn	\N	https://www.csfd.sk/tvorca/480296-noel-behn/	Actor
3252	Paul Sills	\N	https://www.csfd.sk/tvorca/886774-paul-sills/	Actor
3253	John Cusack	\N	https://www.csfd.sk/tvorca/121-john-cusack/	Actor
3254	Dianne Wiest	\N	https://www.csfd.sk/tvorca/600-dianne-wiest/	Actor
3255	Chazz Palminteri	\N	https://www.csfd.sk/tvorca/454-chazz-palminteri/	Actor
3256	Jennifer Tilly	\N	https://www.csfd.sk/tvorca/593-jennifer-tilly/	Actor
3257	Jim Broadbent	\N	https://www.csfd.sk/tvorca/1836-jim-broadbent/	Actor
3259	Rob Reiner	\N	https://www.csfd.sk/tvorca/3046-rob-reiner/	Actor
3260	Tony Sirico	\N	https://www.csfd.sk/tvorca/9121-tony-sirico/	Actor
3261	Stacey Nelkin	\N	https://www.csfd.sk/tvorca/11880-stacey-nelkin/	Actor
3262	John Ventimiglia	\N	https://www.csfd.sk/tvorca/14409-john-ventimiglia/	Actor
3263	Harvey Fierstein	\N	https://www.csfd.sk/tvorca/8975-harvey-fierstein/	Actor
3264	Edie Falco	\N	https://www.csfd.sk/tvorca/5741-edie-falco/	Actor
3265	Tracey Ullman	\N	https://www.csfd.sk/tvorca/2429-tracey-ullman/	Actor
3266	Debi Mazar	\N	https://www.csfd.sk/tvorca/7403-debi-mazar/	Actor
3267	Lisa Arturo	\N	https://www.csfd.sk/tvorca/45202-lisa-arturo/	Actor
3269	Dayle Haddon	\N	https://www.csfd.sk/tvorca/56585-dayle-haddon/	Actor
3270	Rick Washburn	\N	https://www.csfd.sk/tvorca/80194-rick-washburn/	Actor
3272	Paul Herman	\N	https://www.csfd.sk/tvorca/87138-paul-herman/	Actor
3273	Tony Darrow	\N	https://www.csfd.sk/tvorca/225697-tony-darrow/	Actor
3274	Benay Venuta	\N	https://www.csfd.sk/tvorca/237862-benay-venuta/	Actor
3275	Gene Canfield	\N	https://www.csfd.sk/tvorca/228381-gene-canfield/	Actor
3276	Shannah Laumeister	\N	https://www.csfd.sk/tvorca/228746-shannah-laumeister/	Actor
3277	Howard Erskine	\N	https://www.csfd.sk/tvorca/389041-howard-erskine/	Actor
3278	Jennifer Van Dyck	\N	https://www.csfd.sk/tvorca/389042-jennifer-van-dyck/	Actor
3279	John Di Benedetto	\N	https://www.csfd.sk/tvorca/547672-john-di-benedetto/	Actor
3280	Nina Peterson	\N	https://www.csfd.sk/tvorca/758274-nina-peterson/	Actor
3281	Meghan Strange	\N	https://www.csfd.sk/tvorca/829118-meghan-strange/	Actor
3283	Katharine Ross	\N	https://www.csfd.sk/tvorca/14732-katharine-ross/	Actor
3284	Richard Widmark	\N	https://www.csfd.sk/tvorca/925-richard-widmark/	Actor
3286	Ben Johnson	\N	https://www.csfd.sk/tvorca/68-ben-johnson/	Actor
3287	Lee Grant	\N	https://www.csfd.sk/tvorca/6242-lee-grant/	Actor
3289	Patty Duke	\N	https://www.csfd.sk/tvorca/5323-patty-duke/	Actor
3290	Bradford Dillman	\N	https://www.csfd.sk/tvorca/59463-bradford-dillman/	Actor
3292	Henry Fonda	\N	https://www.csfd.sk/tvorca/784-henry-fonda/	Actor
3293	Cameron Mitchell	\N	https://www.csfd.sk/tvorca/5555-cameron-mitchell/	Actor
3294	Morgan Paull	\N	https://www.csfd.sk/tvorca/20226-morgan-paull/	Actor
3296	Alejandro Rey	\N	https://www.csfd.sk/tvorca/144110-alejandro-rey/	Actor
3297	Arthur Space	\N	https://www.csfd.sk/tvorca/181097-arthur-space/	Actor
3298	John Furlong	\N	https://www.csfd.sk/tvorca/217631-john-furlong/	Actor
3299	Chuck Hayward	\N	https://www.csfd.sk/tvorca/218808-chuck-hayward/	Actor
3300	John Otrin	\N	https://www.csfd.sk/tvorca/325171-john-otrin/	Actor
3301	Steven Marlo	\N	https://www.csfd.sk/tvorca/330255-steven-marlo/	Actor
3302	Tony Haig	\N	https://www.csfd.sk/tvorca/401317-tony-haig/	Actor
3303	Christian Juttner	\N	https://www.csfd.sk/tvorca/405448-christian-juttner/	Actor
3304	Marneen Fields	\N	https://www.csfd.sk/tvorca/516132-marneen-fields/	Actor
3305	Trent Dolan	\N	https://www.csfd.sk/tvorca/595215-trent-dolan/	Actor
3258	Mary-Louise Parker	\N	https://www.csfd.sk/tvorca/578-mary-louise-parker/	Actor
3268	Małgorzata Zajączkowska	\N	https://www.csfd.sk/tvorca/54271-malgorzata-zajaczkowska/	Actor
3271	Peter McRobbie	\N	https://www.csfd.sk/tvorca/86928-peter-mcrobbie/	Actor
3282	Fran McGee	\N	https://www.csfd.sk/tvorca/853637-fran-mcgee/	Actor
3285	Olivia de Havilland	\N	https://www.csfd.sk/tvorca/768-olivia-de-havilland/	Actor
3288	José Ferrer	\N	https://www.csfd.sk/tvorca/2289-jose-ferrer/	Actor
3291	Fred MacMurray	\N	https://www.csfd.sk/tvorca/846-fred-macmurray/	Actor
3295	Don 'Red' Barry	\N	https://www.csfd.sk/tvorca/131658-don-red-barry/	Actor
3306	Doria Cook-Nelson	\N	https://www.csfd.sk/tvorca/646258-doria-cook-nelson/	Actor
3307	Lawrence Moran	\N	https://www.csfd.sk/tvorca/693004-lawrence-moran/	Actor
3308	Bob Harks	\N	https://www.csfd.sk/tvorca/559673-bob-harks/	Actor
3309	Chris Petersen	\N	https://www.csfd.sk/tvorca/855831-chris-petersen/	Actor
3310	Chris Capen	\N	https://www.csfd.sk/tvorca/969392-chris-capen/	Actor
3311	Diane Keaton	\N	https://www.csfd.sk/tvorca/200-diane-keaton/	Actor
3312	Tony Roberts	\N	https://www.csfd.sk/tvorca/476-tony-roberts/	Actor
3313	Carol Kane	\N	https://www.csfd.sk/tvorca/7233-carol-kane/	Actor
3314	Shelley Duvall	\N	https://www.csfd.sk/tvorca/2096-shelley-duvall/	Actor
3315	Janet Margolin	\N	https://www.csfd.sk/tvorca/56033-janet-margolin/	Actor
3316	Colleen Dewhurst	\N	https://www.csfd.sk/tvorca/4345-colleen-dewhurst/	Actor
3317	Christopher Walken	\N	https://www.csfd.sk/tvorca/149-christopher-walken/	Actor
3318	John Glover	\N	https://www.csfd.sk/tvorca/18357-john-glover/	Actor
3319	Jeff Goldblum	\N	https://www.csfd.sk/tvorca/126-jeff-goldblum/	Actor
3320	William Callaway	\N	https://www.csfd.sk/tvorca/13523-william-callaway/	Actor
3321	Truman Capote	\N	https://www.csfd.sk/tvorca/9086-truman-capote/	Actor
3322	Shelley Hack	\N	https://www.csfd.sk/tvorca/14029-shelley-hack/	Actor
3324	Sigourney Weaver	\N	https://www.csfd.sk/tvorca/172-sigourney-weaver/	Actor
3325	Tracey Walter	\N	https://www.csfd.sk/tvorca/53621-tracey-walter/	Actor
3326	Laurie Bird	\N	https://www.csfd.sk/tvorca/68228-laurie-bird/	Actor
3327	Walter Bernstein	\N	https://www.csfd.sk/tvorca/80323-walter-bernstein/	Actor
3328	Paul Simon	\N	https://www.csfd.sk/tvorca/80659-paul-simon/	Actor
3329	John Dennis Johnston	\N	https://www.csfd.sk/tvorca/154974-john-dennis-johnston/	Actor
3330	Rashel Novikoff	\N	https://www.csfd.sk/tvorca/209571-rashel-novikoff/	Actor
3331	Lucy Lee Flippin	\N	https://www.csfd.sk/tvorca/250633-lucy-lee-flippin/	Actor
3332	Johnny Haymer	\N	https://www.csfd.sk/tvorca/287660-johnny-haymer/	Actor
3333	Paula Trueman	\N	https://www.csfd.sk/tvorca/304507-paula-trueman/	Actor
3334	Mary Boylan	\N	https://www.csfd.sk/tvorca/311786-mary-boylan/	Actor
3335	Mark Lenard	\N	https://www.csfd.sk/tvorca/324488-mark-lenard/	Actor
3336	Russell Horton	\N	https://www.csfd.sk/tvorca/324967-russell-horton/	Actor
3337	Hy Anzell	\N	https://www.csfd.sk/tvorca/341033-hy-anzell/	Actor
3338	Donald Symington	\N	https://www.csfd.sk/tvorca/370333-donald-symington/	Actor
3339	Roger Newman	\N	https://www.csfd.sk/tvorca/389899-roger-newman/	Actor
3340	Humphrey Davis	\N	https://www.csfd.sk/tvorca/442392-humphrey-davis/	Actor
3341	Gary Allen	\N	https://www.csfd.sk/tvorca/503169-gary-allen/	Actor
3342	Dick Cavett	\N	https://www.csfd.sk/tvorca/317307-dick-cavett/	Actor
3343	Rick Petrucelli	\N	https://www.csfd.sk/tvorca/649126-rick-petrucelli/	Actor
3344	Gary Mule Deer	\N	https://www.csfd.sk/tvorca/782803-gary-mule-deer/	Actor
3345	Charles Levin	\N	https://www.csfd.sk/tvorca/844211-charles-levin/	Actor
3346	Louise Lasser	\N	https://www.csfd.sk/tvorca/7400-louise-lasser/	Actor
3347	Jacobo Morales	\N	https://www.csfd.sk/tvorca/16543-jacobo-morales/	Actor
3348	Charlotte Rae	\N	https://www.csfd.sk/tvorca/10299-charlotte-rae/	Actor
3349	Axel Anderson	\N	https://www.csfd.sk/tvorca/14789-axel-anderson/	Actor
3350	Allen Garfield	\N	https://www.csfd.sk/tvorca/14277-allen-garfield/	Actor
3351	Sylvester Stallone	\N	https://www.csfd.sk/tvorca/33-sylvester-stallone/	Actor
3352	Anthony Caso	\N	https://www.csfd.sk/tvorca/47919-anthony-caso/	Actor
3354	Mary Jo Catlett	\N	https://www.csfd.sk/tvorca/100014-mary-jo-catlett/	Actor
3355	Beeson Carroll	\N	https://www.csfd.sk/tvorca/232303-beeson-carroll/	Actor
3357	Dan Frazer	\N	https://www.csfd.sk/tvorca/239658-dan-frazer/	Actor
3359	Jack Axelrod	\N	https://www.csfd.sk/tvorca/321696-jack-axelrod/	Actor
3360	Eddie Barth	\N	https://www.csfd.sk/tvorca/346080-eddie-barth/	Actor
3361	Conrad Bain	\N	https://www.csfd.sk/tvorca/346082-conrad-bain/	Actor
3362	Ed Crowley	\N	https://www.csfd.sk/tvorca/370575-ed-crowley/	Actor
3364	Nicholas Saunders	\N	https://www.csfd.sk/tvorca/440669-nicholas-saunders/	Actor
3366	Nick Apollo Forte	\N	https://www.csfd.sk/tvorca/371066-nick-apollo-forte/	Actor
3367	Sandy Baron	\N	https://www.csfd.sk/tvorca/17034-sandy-baron/	Actor
3368	Corbett Monica	\N	https://www.csfd.sk/tvorca/371068-corbett-monica/	Actor
3369	Jackie Gayle	\N	https://www.csfd.sk/tvorca/371071-jackie-gayle/	Actor
3370	Morty Gunty	\N	https://www.csfd.sk/tvorca/371073-morty-gunty/	Actor
3371	Will Jordan	\N	https://www.csfd.sk/tvorca/37271-will-jordan/	Actor
3372	Howard Storm	\N	https://www.csfd.sk/tvorca/17139-howard-storm/	Actor
3373	Jack Rollins	\N	https://www.csfd.sk/tvorca/33299-jack-rollins/	Actor
3374	Milton Berle	\N	https://www.csfd.sk/tvorca/23203-milton-berle/	Actor
3375	Michael Badalucco	\N	https://www.csfd.sk/tvorca/16305-michael-badalucco/	Actor
3377	Danny Aiello	\N	https://www.csfd.sk/tvorca/731-danny-aiello/	Actor
3378	Robert Weil	\N	https://www.csfd.sk/tvorca/307820-robert-weil/	Actor
3379	Ronald Maccone	\N	https://www.csfd.sk/tvorca/341947-ronald-maccone/	Actor
3380	Paul Greco	\N	https://www.csfd.sk/tvorca/371074-paul-greco/	Actor
3381	Frank Renzulli	\N	https://www.csfd.sk/tvorca/371075-frank-renzulli/	Actor
3382	Carl Pistilli	\N	https://www.csfd.sk/tvorca/448438-carl-pistilli/	Actor
3383	Mark Hardwick	\N	https://www.csfd.sk/tvorca/712474-mark-hardwick/	Actor
3384	Gloria Parker	\N	https://www.csfd.sk/tvorca/747370-gloria-parker/	Actor
3353	Jára Kohout	\N	https://www.csfd.sk/tvorca/1601-jara-kohout/	Actor
3356	René Enríquez	\N	https://www.csfd.sk/tvorca/235531-rene-enriquez/	Actor
3358	Tigre Pérez	\N	https://www.csfd.sk/tvorca/283691-tigre-perez/	Actor
3363	Carlos Montalbán	\N	https://www.csfd.sk/tvorca/432364-carlos-montalban/	Actor
3365	Miguel Ángel Suárez	\N	https://www.csfd.sk/tvorca/481689-miguel-angel-suarez/	Actor
3376	Sammy Davis Jr.	\N	https://www.csfd.sk/tvorca/765-sammy-davis-jr/	Actor
1898	William O'Leary	\N	https://www.csfd.sk/tvorca/79157-william-o-leary/	Actor
1992	G. W. Bailey	\N	https://www.csfd.sk/tvorca/350-g-w-bailey/	Actor
2055	Stanislav Běljajev	\N	https://www.csfd.sk/tvorca/123617-stanislav-beljajev/	Actor
2118	Zachar Ronžin	\N	https://www.csfd.sk/tvorca/412263-zachar-ronzin/	Actor
2134	Alexandr Brankevič	\N	https://www.csfd.sk/tvorca/444202-alexandr-brankevic/	Actor
2171	Xenija Lavrova-Glinka	\N	https://www.csfd.sk/tvorca/156356-xenija-lavrova-glinka/	Actor
2208	Jelena Rodak-Škuratova	\N	https://www.csfd.sk/tvorca/456323-jelena-rodak-skuratova/	Actor
2218	Dmitrij Gotsdiněr	\N	https://www.csfd.sk/tvorca/178670-dmitrij-gotsdiner/	Actor
2283	Kenner G. Kemp	\N	https://www.csfd.sk/tvorca/135037-kenner-g-kemp/	Actor
3118	Cathy O'Donnell	\N	https://www.csfd.sk/tvorca/4294-cathy-o-donnell/	Actor
3155	O.J. Simpson	\N	https://www.csfd.sk/tvorca/2280-o-j-simpson/	Actor
3166	George D. Wallace	\N	https://www.csfd.sk/tvorca/155258-george-d-wallace/	Actor
3233	Dylan O'Sullivan Farrow	\N	https://www.csfd.sk/tvorca/642398-dylan-o-sullivan-farrow/	Actor
2340	Samuel L. Jackson	\N	https://www.csfd.sk/tvorca/425-samuel-l-jackson/	Actor
2359	Michèle Duquet	\N	https://www.csfd.sk/tvorca/8087-michele-duquet/	Actor
3323	Beverly D'Angelo	\N	https://www.csfd.sk/tvorca/5380-beverly-d-angelo/	Actor
3385	Gina DeAngeles	\N	https://www.csfd.sk/tvorca/816923-gina-deangeles/	Actor
3386	Hank Azaria	\N	https://www.csfd.sk/tvorca/2346-hank-azaria/	Actor
3387	Sam Rockwell	\N	https://www.csfd.sk/tvorca/2389-sam-rockwell/	Actor
3388	Kenneth Branagh	\N	https://www.csfd.sk/tvorca/147-kenneth-branagh/	Actor
3389	Donald Trump	\N	https://www.csfd.sk/tvorca/14676-donald-trump/	Actor
3390	Aleksa Palladino	\N	https://www.csfd.sk/tvorca/35250-aleksa-palladino/	Actor
3391	Leonardo Dicaprio	\N	https://www.csfd.sk/tvorca/769-leonardo-dicaprio/	Actor
3392	Melanie Griffith	\N	https://www.csfd.sk/tvorca/801-melanie-griffith/	Actor
3393	Famke Janssen	\N	https://www.csfd.sk/tvorca/1839-famke-janssen/	Actor
3394	Michael Lerner	\N	https://www.csfd.sk/tvorca/12116-michael-lerner/	Actor
3395	Charlize Theron	\N	https://www.csfd.sk/tvorca/340-charlize-theron/	Actor
3396	Larry Pine	\N	https://www.csfd.sk/tvorca/18790-larry-pine/	Actor
3397	Gretchen Mol	\N	https://www.csfd.sk/tvorca/2364-gretchen-mol/	Actor
3398	Irina Pantaeva	\N	https://www.csfd.sk/tvorca/5120-irina-pantaeva/	Actor
3399	Karen Duffy	\N	https://www.csfd.sk/tvorca/12171-karen-duffy/	Actor
3400	Jeffrey Wright	\N	https://www.csfd.sk/tvorca/2284-jeffrey-wright/	Actor
3401	Aida Turturro	\N	https://www.csfd.sk/tvorca/5700-aida-turturro/	Actor
3402	Dylan Baker	\N	https://www.csfd.sk/tvorca/13309-dylan-baker/	Actor
3403	Douglas Mcgrath	\N	https://www.csfd.sk/tvorca/3417-douglas-mcgrath/	Actor
3404	Marylouise Burke	\N	https://www.csfd.sk/tvorca/4543-marylouise-burke/	Actor
3405	Adam Alexi Malle	\N	https://www.csfd.sk/tvorca/25046-adam-alexi-malle/	Actor
3406	J K Simmons	\N	https://www.csfd.sk/tvorca/1828-j-k-simmons/	Actor
3407	Polly Adams	\N	https://www.csfd.sk/tvorca/6168-polly-adams/	Actor
3408	Debra Messing	\N	https://www.csfd.sk/tvorca/2189-debra-messing/	Actor
3409	Bebe Neuwirth	\N	https://www.csfd.sk/tvorca/17703-bebe-neuwirth/	Actor
3410	Ian Somerhalder	\N	https://www.csfd.sk/tvorca/2205-ian-somerhalder/	Actor
3411	Greg Mottola	\N	https://www.csfd.sk/tvorca/34029-greg-mottola/	Actor
3412	Yolonda Ross	\N	https://www.csfd.sk/tvorca/37458-yolonda-ross/	Actor
3413	Adrian Grenier	\N	https://www.csfd.sk/tvorca/16267-adrian-grenier/	Actor
3414	Wood Harris	\N	https://www.csfd.sk/tvorca/39526-wood-harris/	Actor
3415	Lorri Bagley	\N	https://www.csfd.sk/tvorca/42467-lorri-bagley/	Actor
3416	Kali Hawk	\N	https://www.csfd.sk/tvorca/56055-kali-hawk/	Actor
3417	Marian Seldes	\N	https://www.csfd.sk/tvorca/58687-marian-seldes/	Actor
3418	Teresa Depriest	\N	https://www.csfd.sk/tvorca/61462-teresa-depriest/	Actor
3419	Sanny Van Heteren	\N	https://www.csfd.sk/tvorca/78989-sanny-van-heteren/	Actor
3420	Becky Ann Baker	\N	https://www.csfd.sk/tvorca/81765-becky-ann-baker/	Actor
3421	Patti D Arbanville	\N	https://www.csfd.sk/tvorca/81856-patti-d-arbanville/	Actor
3422	Andre Gregory	\N	https://www.csfd.sk/tvorca/85037-andre-gregory/	Actor
3423	Kate Burton	\N	https://www.csfd.sk/tvorca/96056-kate-burton/	Actor
3424	David Blaine	\N	https://www.csfd.sk/tvorca/63962-david-blaine/	Actor
3425	Bruno Gunn	\N	https://www.csfd.sk/tvorca/99172-bruno-gunn/	Actor
3426	Sam Gray	\N	https://www.csfd.sk/tvorca/107947-sam-gray/	Actor
3427	Ramsey Faragallah	\N	https://www.csfd.sk/tvorca/150911-ramsey-faragallah/	Actor
3428	Carmen Dell Orefice	\N	https://www.csfd.sk/tvorca/198788-carmen-dell-orefice/	Actor
3429	Rick Mowat	\N	https://www.csfd.sk/tvorca/204162-rick-mowat/	Actor
3430	Angel Caban	\N	https://www.csfd.sk/tvorca/219048-angel-caban/	Actor
3431	David Margulies	\N	https://www.csfd.sk/tvorca/222693-david-margulies/	Actor
3432	Frederique Van Der Wal	\N	https://www.csfd.sk/tvorca/234163-frederique-van-der-wal/	Actor
3433	Ned Eisenberg	\N	https://www.csfd.sk/tvorca/243497-ned-eisenberg/	Actor
3434	John Carter	\N	https://www.csfd.sk/tvorca/293887-john-carter/	Actor
3435	Frank Pellegrino	\N	https://www.csfd.sk/tvorca/301158-frank-pellegrino/	Actor
3436	Jim Moody	\N	https://www.csfd.sk/tvorca/315347-jim-moody/	Actor
3437	Donna Hanover	\N	https://www.csfd.sk/tvorca/351692-donna-hanover/	Actor
3438	John Costelloe	\N	https://www.csfd.sk/tvorca/361819-john-costelloe/	Actor
3439	Isaac Mizrahi	\N	https://www.csfd.sk/tvorca/370027-isaac-mizrahi/	Actor
3440	Frederick Rolf	\N	https://www.csfd.sk/tvorca/370568-frederick-rolf/	Actor
3441	Julie Halston	\N	https://www.csfd.sk/tvorca/377051-julie-halston/	Actor
3442	Gerry Becker	\N	https://www.csfd.sk/tvorca/384904-gerry-becker/	Actor
3443	Kathleen Doyle	\N	https://www.csfd.sk/tvorca/389924-kathleen-doyle/	Actor
3444	Dan Moran	\N	https://www.csfd.sk/tvorca/389926-dan-moran/	Actor
3445	Lela Edgar	\N	https://www.csfd.sk/tvorca/415363-lela-edgar/	Actor
3446	Frank Licari	\N	https://www.csfd.sk/tvorca/432171-frank-licari/	Actor
3447	Ralph Kinnard	\N	https://www.csfd.sk/tvorca/435909-ralph-kinnard/	Actor
3448	Mary Samuels	\N	https://www.csfd.sk/tvorca/498810-mary-samuels/	Actor
3449	Ingrid Rogers	\N	https://www.csfd.sk/tvorca/533851-ingrid-rogers/	Actor
3450	Ted Neustadt	\N	https://www.csfd.sk/tvorca/538489-ted-neustadt/	Actor
3451	Steven Randazzo	\N	https://www.csfd.sk/tvorca/550892-steven-randazzo/	Actor
3452	Robert Cuccioli	\N	https://www.csfd.sk/tvorca/563592-robert-cuccioli/	Actor
3453	Clebert Ford	\N	https://www.csfd.sk/tvorca/606571-clebert-ford/	Actor
3454	Carmen Canivell	\N	https://www.csfd.sk/tvorca/607084-carmen-canivell/	Actor
3455	Brian Mccormack	\N	https://www.csfd.sk/tvorca/634365-brian-mccormack/	Actor
3456	Gigi Williams	\N	https://www.csfd.sk/tvorca/648270-gigi-williams/	Actor
3457	Diana C Zollicoffer	\N	https://www.csfd.sk/tvorca/649665-diana-c-zollicoffer/	Actor
3458	Jay Alan Christianson	\N	https://www.csfd.sk/tvorca/709648-jay-alan-christianson/	Actor
3459	Carlos Valencia	\N	https://www.csfd.sk/tvorca/723333-carlos-valencia/	Actor
3460	Sonita Henry	\N	https://www.csfd.sk/tvorca/767086-sonita-henry/	Actor
3461	Adam Sietz	\N	https://www.csfd.sk/tvorca/813739-adam-sietz/	Actor
3462	Renee Lippin	\N	https://www.csfd.sk/tvorca/885104-renee-lippin/	Actor
3463	Mary Catherine Wright	\N	https://www.csfd.sk/tvorca/895338-mary-catherine-wright/	Actor
3464	John Tormey	\N	https://www.csfd.sk/tvorca/9628-john-tormey/	Actor
3465	Elizabeth Berkley	\N	https://www.csfd.sk/tvorca/8415-elizabeth-berkley/	Actor
3466	Peter Gerety	\N	https://www.csfd.sk/tvorca/51383-peter-gerety/	Actor
3467	Helen Hunt	\N	https://www.csfd.sk/tvorca/553-helen-hunt/	Actor
3468	Wallace Shawn	\N	https://www.csfd.sk/tvorca/8270-wallace-shawn/	Actor
3469	Dan Aykroyd	\N	https://www.csfd.sk/tvorca/78-dan-aykroyd/	Actor
3470	Arthur J Nascarella	\N	https://www.csfd.sk/tvorca/69090-arthur-j-nascarella/	Actor
3471	Brian Markinson	\N	https://www.csfd.sk/tvorca/74971-brian-markinson/	Actor
3472	John Schuck	\N	https://www.csfd.sk/tvorca/84236-john-schuck/	Actor
3473	Greg Stebner	\N	https://www.csfd.sk/tvorca/214935-greg-stebner/	Actor
3474	Kaili Vernoff	\N	https://www.csfd.sk/tvorca/240983-kaili-vernoff/	Actor
3475	Judy Gold	\N	https://www.csfd.sk/tvorca/413397-judy-gold/	Actor
3476	Kevin Cahoon	\N	https://www.csfd.sk/tvorca/499126-kevin-cahoon/	Actor
3477	Noah Weisberg	\N	https://www.csfd.sk/tvorca/551738-noah-weisberg/	Actor
3478	Michael Mulheren	\N	https://www.csfd.sk/tvorca/595102-michael-mulheren/	Actor
3479	Irwin Corey	\N	https://www.csfd.sk/tvorca/716622-irwin-corey/	Actor
3480	Martin Landau	\N	https://www.csfd.sk/tvorca/432-martin-landau/	Actor
3481	Claire Bloom	\N	https://www.csfd.sk/tvorca/4288-claire-bloom/	Actor
3482	Anjelica Huston	\N	https://www.csfd.sk/tvorca/127-anjelica-huston/	Actor
3483	Sam Waterston	\N	https://www.csfd.sk/tvorca/2279-sam-waterston/	Actor
3484	Jerry Orbach	\N	https://www.csfd.sk/tvorca/5305-jerry-orbach/	Actor
3485	Jerry Zaks	\N	https://www.csfd.sk/tvorca/3402-jerry-zaks/	Actor
3486	Victor Argo	\N	https://www.csfd.sk/tvorca/18673-victor-argo/	Actor
3487	Nora Ephron	\N	https://www.csfd.sk/tvorca/2887-nora-ephron/	Actor
3488	Mercedes Ruehl	\N	https://www.csfd.sk/tvorca/2373-mercedes-ruehl/	Actor
3489	Daryl Hannah	\N	https://www.csfd.sk/tvorca/285-daryl-hannah/	Actor
3490	Myla Pitt	\N	https://www.csfd.sk/tvorca/46950-myla-pitt/	Actor
3491	Joanna Gleason	\N	https://www.csfd.sk/tvorca/60513-joanna-gleason/	Actor
3492	Rebecca Schull	\N	https://www.csfd.sk/tvorca/196302-rebecca-schull/	Actor
3493	Thomas Bolster	\N	https://www.csfd.sk/tvorca/214924-thomas-bolster/	Actor
3494	Kenny Vance	\N	https://www.csfd.sk/tvorca/302008-kenny-vance/	Actor
3495	Sylvia Kauders	\N	https://www.csfd.sk/tvorca/306576-sylvia-kauders/	Actor
3496	Anna Berger	\N	https://www.csfd.sk/tvorca/466919-anna-berger/	Actor
3497	Dolores Sutton	\N	https://www.csfd.sk/tvorca/484361-dolores-sutton/	Actor
3498	Maggie Wagner	\N	https://www.csfd.sk/tvorca/514406-maggie-wagner/	Actor
3499	Martin Bergmann	\N	https://www.csfd.sk/tvorca/567612-martin-bergmann/	Actor
3500	Avner Eisenberg	\N	https://www.csfd.sk/tvorca/686586-avner-eisenberg/	Actor
3501	Matthew T Gitkin	\N	https://www.csfd.sk/tvorca/638658-matthew-t-gitkin/	Actor
3502	Grace Phillips	\N	https://www.csfd.sk/tvorca/745460-grace-phillips/	Actor
3503	Kirstie Alley	\N	https://www.csfd.sk/tvorca/514-kirstie-alley/	Actor
3504	Richard Benjamin	\N	https://www.csfd.sk/tvorca/3484-richard-benjamin/	Actor
3505	Lynn Cohen	\N	https://www.csfd.sk/tvorca/17166-lynn-cohen/	Actor
3506	Billy Crystal	\N	https://www.csfd.sk/tvorca/382-billy-crystal/	Actor
3507	Mariel Hemingway	\N	https://www.csfd.sk/tvorca/5387-mariel-hemingway/	Actor
3508	Amy Irving	\N	https://www.csfd.sk/tvorca/4826-amy-irving/	Actor
3509	Julia Louis Dreyfus	\N	https://www.csfd.sk/tvorca/37853-julia-louis-dreyfus/	Actor
3510	Tobey Maguire	\N	https://www.csfd.sk/tvorca/1820-tobey-maguire/	Actor
3511	Demi Moore	\N	https://www.csfd.sk/tvorca/305-demi-moore/	Actor
3512	Elisabeth Shue	\N	https://www.csfd.sk/tvorca/116-elisabeth-shue/	Actor
3513	Stanley Tucci	\N	https://www.csfd.sk/tvorca/2227-stanley-tucci/	Actor
3514	Robin Williams	\N	https://www.csfd.sk/tvorca/510-robin-williams/	Actor
3515	Chris Bauer	\N	https://www.csfd.sk/tvorca/1977-chris-bauer/	Actor
3516	Peter Jacobson	\N	https://www.csfd.sk/tvorca/20870-peter-jacobson/	Actor
3517	Eric Bogosian	\N	https://www.csfd.sk/tvorca/13518-eric-bogosian/	Actor
3518	Jennifer Garner	\N	https://www.csfd.sk/tvorca/5231-jennifer-garner/	Actor
3519	Paul Giamatti	\N	https://www.csfd.sk/tvorca/4853-paul-giamatti/	Actor
3520	Gene Saks	\N	https://www.csfd.sk/tvorca/11449-gene-saks/	Actor
3521	Jonathan Lapaglia	\N	https://www.csfd.sk/tvorca/41891-jonathan-lapaglia/	Actor
3522	Elisabeth Rohm	\N	https://www.csfd.sk/tvorca/50931-elisabeth-rohm/	Actor
3523	Joseph P Reidy	\N	https://www.csfd.sk/tvorca/58052-joseph-p-reidy/	Actor
3524	Adam Rose	\N	https://www.csfd.sk/tvorca/84627-adam-rose/	Actor
3525	Eric Lloyd	\N	https://www.csfd.sk/tvorca/85813-eric-lloyd/	Actor
3526	Arden Myrin	\N	https://www.csfd.sk/tvorca/257284-arden-myrin/	Actor
3527	Robert Harper	\N	https://www.csfd.sk/tvorca/262540-robert-harper/	Actor
3528	Marvin Chatinover	\N	https://www.csfd.sk/tvorca/264366-marvin-chatinover/	Actor
3529	Hazelle Goodman	\N	https://www.csfd.sk/tvorca/331731-hazelle-goodman/	Actor
3530	Waltrudis Buck	\N	https://www.csfd.sk/tvorca/395822-waltrudis-buck/	Actor
3531	Irving Metzman	\N	https://www.csfd.sk/tvorca/465344-irving-metzman/	Actor
3532	Tim Realbuto	\N	https://www.csfd.sk/tvorca/478473-tim-realbuto/	Actor
3533	Victoria Hale	\N	https://www.csfd.sk/tvorca/488627-victoria-hale/	Actor
3534	Irwin Charone	\N	https://www.csfd.sk/tvorca/925486-irwin-charone/	Actor
3535	Edward Norton	\N	https://www.csfd.sk/tvorca/18-edward-norton/	Actor
3536	Drew Barrymore	\N	https://www.csfd.sk/tvorca/90-drew-barrymore/	Actor
3537	Natasha Lyonne	\N	https://www.csfd.sk/tvorca/1876-natasha-lyonne/	Actor
3538	Gaby Hoffmann	\N	https://www.csfd.sk/tvorca/51984-gaby-hoffmann/	Actor
3539	Natalie Portman	\N	https://www.csfd.sk/tvorca/158-natalie-portman/	Actor
3540	Lukas Haas	\N	https://www.csfd.sk/tvorca/7663-lukas-haas/	Actor
3541	Goldie Hawn	\N	https://www.csfd.sk/tvorca/66-goldie-hawn/	Actor
3542	Julia Roberts	\N	https://www.csfd.sk/tvorca/4-julia-roberts/	Actor
3543	Billy Crudup	\N	https://www.csfd.sk/tvorca/6496-billy-crudup/	Actor
3544	Tim Roth	\N	https://www.csfd.sk/tvorca/477-tim-roth/	Actor
3545	Andrea Piedimonte Bodini	\N	https://www.csfd.sk/tvorca/38847-andrea-piedimonte-bodini/	Actor
3546	Susan Misner	\N	https://www.csfd.sk/tvorca/35263-susan-misner/	Actor
3547	Christy Carlson Romano	\N	https://www.csfd.sk/tvorca/25461-christy-carlson-romano/	Actor
3548	Patrick Cranshaw	\N	https://www.csfd.sk/tvorca/37967-patrick-cranshaw/	Actor
3549	Isiah Whitlock Jr	\N	https://www.csfd.sk/tvorca/39067-isiah-whitlock-jr/	Actor
3550	Paolo Seganti	\N	https://www.csfd.sk/tvorca/48952-paolo-seganti/	Actor
3551	Robert Knepper	\N	https://www.csfd.sk/tvorca/30890-robert-knepper/	Actor
3552	Myra Lucretia Taylor	\N	https://www.csfd.sk/tvorca/297912-myra-lucretia-taylor/	Actor
3553	Edward Hibbert	\N	https://www.csfd.sk/tvorca/312786-edward-hibbert/	Actor
3554	Michael Mark	\N	https://www.csfd.sk/tvorca/469543-michael-mark/	Actor
3555	Robert Khakh	\N	https://www.csfd.sk/tvorca/495189-robert-khakh/	Actor
3556	Malinda Farrington	\N	https://www.csfd.sk/tvorca/733157-malinda-farrington/	Actor
3557	Nancy Ticotin	\N	https://www.csfd.sk/tvorca/967608-nancy-ticotin/	Actor
3558	Joseph Tudisco	\N	https://www.csfd.sk/tvorca/979746-joseph-tudisco/	Actor
3559	Barbara Hershey	\N	https://www.csfd.sk/tvorca/549-barbara-hershey/	Actor
3560	Carrie Fisher	\N	https://www.csfd.sk/tvorca/542-carrie-fisher/	Actor
3561	Maureen O Sullivan	\N	https://www.csfd.sk/tvorca/4782-maureen-o-sullivan/	Actor
3562	Lloyd Nolan	\N	https://www.csfd.sk/tvorca/4477-lloyd-nolan/	Actor
3563	Max Von Sydow	\N	https://www.csfd.sk/tvorca/505-max-von-sydow/	Actor
3564	Lewis Black	\N	https://www.csfd.sk/tvorca/21557-lewis-black/	Actor
3565	J T Walsh	\N	https://www.csfd.sk/tvorca/1944-j-t-walsh/	Actor
3566	John Turturro	\N	https://www.csfd.sk/tvorca/503-john-turturro/	Actor
3567	Richard Jenkins	\N	https://www.csfd.sk/tvorca/8109-richard-jenkins/	Actor
3568	Daniel Stern	\N	https://www.csfd.sk/tvorca/497-daniel-stern/	Actor
3569	Paul Bates	\N	https://www.csfd.sk/tvorca/18313-paul-bates/	Actor
3570	Christian Clemenson	\N	https://www.csfd.sk/tvorca/107870-christian-clemenson/	Actor
3571	Soon Yi Previn	\N	https://www.csfd.sk/tvorca/587986-soon-yi-previn/	Actor
\.


--
-- Data for Name: person_in_film; Type: TABLE DATA; Schema: public; Owner: scrapoo
--

COPY public.person_in_film (id, role, films_id, persons_id) FROM stdin;
6667	director	21	1739
6668	actor	21	1740
6669	actor	21	1741
6670	actor	21	1742
6671	actor	21	1743
6672	actor	21	1744
6673	actor	21	1745
6674	actor	21	1746
6675	actor	21	1747
6676	actor	21	1748
6677	actor	21	1749
6678	actor	21	1750
6679	actor	21	1751
6680	actor	21	1752
6681	actor	21	1753
6682	actor	21	1754
6683	actor	21	1755
6684	actor	21	1756
6685	actor	21	1757
6686	actor	21	1758
6687	actor	21	1759
6688	actor	21	1760
6689	actor	21	1761
6690	actor	21	1762
6691	actor	21	1763
6692	actor	21	1764
6693	actor	21	1765
6694	actor	21	1766
6695	actor	21	1767
6696	actor	21	1768
6697	actor	21	1769
6698	actor	21	1770
6699	actor	21	1771
6700	actor	21	1772
6701	actor	21	1773
6702	actor	21	1774
6703	actor	21	1775
6704	actor	21	1776
6705	director	25	1739
6706	actor	25	1879
6707	actor	25	1880
6708	actor	25	1881
6709	actor	25	1801
6710	actor	25	1882
6711	actor	25	1883
6712	actor	25	1884
6713	actor	25	1885
6714	actor	25	1886
6715	actor	25	1887
6716	actor	25	1888
6717	actor	25	1889
6718	actor	25	1890
6719	actor	25	1891
6720	actor	25	1892
6721	actor	25	1893
6722	actor	25	1894
6723	actor	25	1895
6724	actor	25	1896
6725	actor	25	1897
6726	actor	25	1898
6727	actor	25	1899
6728	actor	25	1900
6729	actor	25	1901
6730	actor	25	1869
6731	actor	25	1902
6732	actor	25	1903
6733	actor	25	1904
6734	actor	25	1905
6735	actor	25	1906
6736	actor	25	1907
6737	director	27	1739
6738	actor	27	1879
6739	actor	27	1801
6740	actor	27	1881
6741	actor	27	1931
6742	actor	27	1932
6743	actor	27	1933
6744	actor	27	1934
6745	actor	27	1935
6746	actor	27	1889
6747	actor	27	1936
6748	actor	27	1937
6749	actor	27	1938
6750	actor	27	1939
6751	actor	27	1940
6752	actor	27	1941
6753	actor	27	1942
6754	actor	27	1857
6755	actor	27	1943
6756	actor	27	1944
6757	actor	27	1867
6758	actor	27	1869
6759	actor	27	1945
6760	actor	27	1946
6761	actor	27	1947
6762	actor	27	1948
6763	actor	27	1949
6764	actor	27	1950
6765	actor	27	1951
6766	actor	27	1906
6767	actor	27	1952
6768	actor	27	1953
6769	actor	27	1954
6770	actor	27	1955
6771	director	24	1739
6772	actor	24	1846
6773	actor	24	1847
6774	actor	24	1848
6775	actor	24	1849
6776	actor	24	1850
6777	actor	24	1801
6778	actor	24	1851
6779	actor	24	1852
6780	actor	24	1853
6781	actor	24	1854
6782	actor	24	1855
6783	actor	24	1856
6784	actor	24	1778
6785	actor	24	1857
6786	actor	24	1858
6787	actor	24	1859
6788	actor	24	1860
6789	actor	24	1861
6790	actor	24	1862
6791	actor	24	1863
6792	actor	24	1864
6793	actor	24	1865
6794	actor	24	1866
6795	actor	24	1867
6796	actor	24	1868
6797	actor	24	1869
6798	actor	24	1870
6799	actor	24	1871
6800	actor	24	1872
6801	actor	24	1873
6802	actor	24	1874
6803	actor	24	1875
6804	actor	24	1876
6805	actor	24	1877
6806	actor	24	1878
6807	director	26	1739
6808	director	26	1798
6809	director	26	1797
6810	actor	26	1908
6811	actor	26	1740
6812	actor	26	1909
6813	actor	26	1910
6814	actor	26	1911
6815	actor	26	1912
6816	actor	26	1913
6817	actor	26	1914
6818	actor	26	1915
6819	actor	26	1916
6820	actor	26	1917
6821	actor	26	1918
6822	actor	26	1919
6823	actor	26	1920
6824	actor	26	1921
6825	actor	26	1922
6826	actor	26	1923
6827	actor	26	1924
6828	actor	26	1925
6829	actor	26	1926
6830	actor	26	1927
6831	actor	26	1928
6832	actor	26	1929
6833	actor	26	1776
6834	actor	26	1930
6835	director	28	1739
6836	director	28	1798
6837	director	28	1797
6838	actor	28	1956
6839	actor	28	1957
6840	actor	28	1958
6841	actor	28	1959
6842	actor	28	1960
6843	actor	28	1961
6844	actor	28	1962
6845	actor	28	1963
6846	actor	28	1964
6847	actor	28	1965
6848	actor	28	1966
6849	actor	28	1967
6850	actor	28	1968
6851	actor	28	1969
6852	actor	28	1970
6853	actor	28	1971
6854	actor	28	1972
6855	actor	28	1973
6856	actor	28	1974
6857	actor	28	1975
6858	actor	28	1976
6859	actor	28	1977
6860	actor	28	1978
6861	actor	28	1979
6862	actor	28	1980
6863	actor	28	3100
6864	actor	28	3101
6865	director	29	1981
6866	actor	29	1982
6867	actor	29	1983
6868	actor	29	1984
6869	actor	29	1985
6870	actor	29	1986
6871	actor	29	1987
6872	actor	29	1988
6873	actor	29	1989
6874	actor	29	1990
6875	actor	29	1991
6876	actor	29	1992
6877	actor	29	1993
6878	actor	29	1994
6879	actor	29	1995
6880	actor	29	1996
6881	actor	29	1997
6882	actor	29	1998
6883	actor	29	1999
6884	actor	29	2000
6885	director	30	1981
6886	actor	30	2001
6887	actor	30	2002
6888	actor	30	2003
6889	actor	30	2004
6890	actor	30	2005
6891	actor	30	2006
6892	actor	30	2007
6893	actor	30	2008
6894	actor	30	1752
6895	actor	30	2009
6896	actor	30	2010
6897	actor	30	2011
6898	actor	30	2012
6899	actor	30	2013
6900	actor	30	2014
6901	actor	30	2015
6902	actor	30	2016
6903	actor	30	2017
6904	actor	30	2018
6905	actor	30	2019
6906	actor	30	2020
6907	actor	30	2021
6908	actor	30	2022
6909	director	31	2023
6910	director	31	2024
6911	actor	31	2025
6912	actor	31	2026
6913	actor	31	2027
6914	actor	31	2028
6915	actor	31	2029
6916	actor	31	2030
6917	actor	31	2031
6918	actor	31	2032
6919	actor	31	2033
6920	actor	31	2034
6921	director	32	2035
6922	director	32	2036
6923	actor	32	2037
6924	actor	32	2038
6925	actor	32	2039
6926	actor	32	2040
6927	actor	32	2041
6928	actor	32	2042
6929	actor	32	2043
6930	actor	32	2044
6931	actor	32	2045
6932	actor	32	2046
6933	actor	32	2047
6934	actor	32	2048
6935	actor	32	2049
6936	actor	32	2050
6937	actor	32	2051
6938	actor	32	2052
6939	actor	32	2053
6940	actor	32	2054
6941	actor	32	2055
6942	actor	32	2056
6943	actor	32	2057
6944	actor	32	2058
6945	actor	32	2059
6946	actor	32	2060
6947	actor	32	2061
6948	actor	32	2062
6949	actor	32	2063
6950	actor	32	2064
6951	actor	32	2065
6952	actor	32	2066
6953	actor	32	2067
6954	actor	32	2068
6955	actor	32	2069
6956	actor	32	2070
6957	actor	32	2071
6958	actor	32	2072
6959	actor	32	2073
6960	actor	32	2074
6961	actor	32	2075
6962	actor	32	2076
6963	actor	32	2077
6964	actor	32	2078
6965	actor	32	2079
6966	actor	32	2080
6967	actor	32	2081
6968	actor	32	2082
6969	actor	32	2083
6970	actor	32	2084
6971	actor	32	2085
6972	actor	32	2086
6973	actor	32	2087
6974	actor	32	2088
6975	actor	32	2089
6976	actor	32	2090
6977	actor	32	2091
6978	actor	32	2092
6979	actor	32	2093
6980	actor	32	2094
6981	actor	32	2095
6982	actor	32	2096
6983	actor	32	2097
6984	actor	32	2098
6985	actor	32	2099
6986	actor	32	2100
6987	actor	32	2101
6988	actor	32	2102
6989	actor	32	2103
6990	actor	32	2104
6991	actor	32	2105
6992	actor	32	2106
6993	actor	32	2107
6994	actor	32	2108
6995	actor	32	2109
6996	actor	32	2110
6997	actor	32	2111
6998	actor	32	2112
6999	actor	32	2113
7000	actor	32	2114
7001	actor	32	2115
7002	actor	32	2116
7003	actor	32	2117
7004	actor	32	2118
7005	actor	32	2119
7006	actor	32	2120
7007	actor	32	2121
7008	actor	32	2122
7009	actor	32	2123
7010	actor	32	2124
7011	actor	32	2125
7012	actor	32	2126
7013	actor	32	2127
7014	actor	32	2128
7015	actor	32	2129
7016	actor	32	2130
7017	actor	32	2131
7018	actor	32	2132
7019	actor	32	2133
7020	actor	32	2134
7021	actor	32	2135
7022	actor	32	2136
7023	actor	32	2137
7024	actor	32	2138
7025	actor	32	2139
7026	actor	32	2140
7027	actor	32	2141
7028	actor	32	2142
7029	actor	32	2143
7030	actor	32	2144
7031	actor	32	2145
7032	actor	32	2146
7033	actor	32	2147
7034	actor	32	2148
7035	actor	32	2149
7036	actor	32	2150
7037	actor	32	2151
7038	actor	32	2152
7039	actor	32	2153
7040	actor	32	2154
7041	actor	32	2155
7042	actor	32	2156
7043	actor	32	2157
7044	actor	32	2158
7045	actor	32	2159
7046	actor	32	2160
7047	actor	32	2161
7048	actor	32	2162
7049	actor	32	2163
7050	actor	32	2164
7051	actor	32	2165
7052	actor	32	2166
7053	actor	32	2167
7054	actor	32	2168
7055	actor	32	2169
7056	actor	32	2170
7057	actor	32	2171
7058	actor	32	2172
7059	actor	32	2173
7060	actor	32	2174
7061	actor	32	2175
7062	actor	32	2176
7063	actor	32	2177
7064	actor	32	2178
7065	actor	32	2179
7066	actor	32	2180
7067	actor	32	2181
7068	actor	32	2182
7069	actor	32	2183
7070	actor	32	2184
7071	actor	32	2185
7072	actor	32	2186
7073	actor	32	2187
7074	actor	32	2188
7075	actor	32	2189
7076	actor	32	2190
7077	actor	32	2191
7078	actor	32	2192
7079	actor	32	2193
7080	actor	32	2194
7081	actor	32	2195
7082	actor	32	2196
7083	actor	32	2197
7084	actor	32	2198
7085	actor	32	2199
7086	actor	32	2200
7087	actor	32	2201
7088	actor	32	2202
7089	actor	32	2203
7090	actor	32	2204
7091	actor	32	2205
7092	actor	32	2206
7093	actor	32	2207
7094	actor	32	2208
7095	actor	32	2209
7096	actor	32	2210
7097	actor	32	2211
7098	actor	32	2212
7099	actor	32	2213
7100	actor	32	2214
7101	actor	32	2215
7102	actor	32	2216
7103	actor	32	2217
7104	actor	32	2218
7105	actor	32	2219
7106	actor	32	2220
7107	actor	32	2221
7108	actor	32	2222
7109	actor	32	2223
7110	director	33	2023
7111	actor	33	2224
7112	actor	33	2225
7113	actor	33	2226
7114	actor	33	2227
7115	actor	33	2228
7116	actor	33	2229
7117	actor	33	2230
7118	actor	33	2231
7119	actor	33	2232
7120	actor	33	2026
7121	actor	33	2233
7122	actor	33	2234
7123	actor	33	2235
7124	actor	33	2236
7125	actor	33	2237
7126	actor	33	2238
7127	actor	33	2239
7128	actor	33	2240
7129	actor	33	2241
7130	actor	33	2242
7131	actor	33	2243
7132	actor	33	2244
7133	actor	33	2245
7134	actor	33	2246
7135	director	34	2023
7136	actor	34	2247
7137	actor	34	2248
7138	actor	34	2249
7139	actor	34	2250
7140	actor	34	2251
7141	actor	34	2252
7142	actor	34	2253
7143	actor	34	2254
7144	actor	34	2255
7145	actor	34	2256
7146	actor	34	2257
7147	actor	34	2258
7148	actor	34	2259
7149	actor	34	2260
7150	actor	34	2261
7151	actor	34	2239
7152	actor	34	2262
7153	actor	34	2263
7154	actor	34	2264
7155	actor	34	2265
7156	actor	34	2266
7157	actor	34	2267
7158	actor	34	2268
7159	actor	34	2269
7160	actor	34	2270
7161	director	35	2023
7162	actor	35	2271
7163	actor	35	2272
7164	actor	35	2273
7165	actor	35	2274
7166	actor	35	2275
7167	actor	35	2252
7168	actor	35	2276
7169	actor	35	2277
7170	actor	35	2278
7171	actor	35	2279
7172	actor	35	2280
7173	actor	35	2281
7174	actor	35	2282
7175	actor	35	2283
7176	actor	35	2284
7177	actor	35	2285
7178	actor	35	2286
7179	actor	35	2287
7180	actor	35	2288
7181	actor	35	2033
7182	actor	35	2289
7183	actor	35	2290
7184	actor	35	2291
7185	actor	35	2292
7186	actor	35	2293
7187	director	42	2023
7188	actor	42	3102
7189	actor	42	3103
7190	actor	42	3104
7191	actor	42	3105
7192	actor	42	3106
7193	actor	42	3107
7194	actor	42	3108
7195	actor	42	3109
7196	actor	42	2251
7197	actor	42	3110
7198	actor	42	2250
7199	actor	42	3111
7200	actor	42	3112
7201	actor	42	3113
7202	actor	42	3114
7203	actor	42	3115
7204	actor	42	3116
7205	actor	42	3117
7206	actor	42	3118
7207	actor	42	3119
7208	actor	42	3120
7209	actor	42	2257
7210	actor	42	3121
7211	actor	42	3122
7212	actor	42	3123
7213	actor	42	3124
7214	actor	42	3125
7215	actor	42	3126
7216	actor	42	3127
7217	actor	42	3128
7218	actor	42	3129
7219	actor	42	2284
7220	actor	42	3130
7221	actor	42	3131
7222	actor	42	3132
7223	actor	42	3133
7224	actor	42	3134
7225	actor	42	3135
7226	actor	42	3136
7227	actor	42	3137
7228	actor	42	3138
7229	actor	42	3139
7230	actor	42	3140
7231	actor	42	3141
7232	actor	42	3142
7233	actor	42	3143
7234	actor	42	3144
7235	actor	42	3145
7236	director	43	3146
7237	actor	43	3147
7238	actor	43	3148
7239	actor	43	3149
7240	actor	43	3150
7241	actor	43	3151
7242	actor	43	3152
7243	actor	43	3153
7244	actor	43	3154
7245	actor	43	3155
7246	actor	43	3156
7247	actor	43	2225
7248	actor	43	3157
7249	actor	43	2239
7250	actor	43	3158
7251	actor	43	3159
7252	actor	43	3160
7253	actor	43	3161
7254	actor	43	1867
7255	actor	43	3162
7256	actor	43	3163
7257	actor	43	3164
7258	actor	43	3165
7259	actor	43	3166
7260	actor	43	3167
7261	actor	43	2032
7262	actor	43	3168
7263	actor	43	3169
7264	actor	43	3170
7265	actor	43	2387
7266	actor	43	3171
7267	actor	43	3172
7268	actor	43	2242
7269	actor	43	3173
7270	actor	43	3174
7271	actor	43	3175
7272	actor	43	3176
7273	actor	43	1839
7274	actor	43	3177
7275	actor	43	3178
7276	actor	43	3179
7277	actor	43	1842
7278	actor	43	3180
7279	actor	43	3181
7280	actor	43	3182
7281	actor	43	1776
7282	actor	43	3183
7283	director	44	2023
7284	actor	44	3184
7285	actor	44	3185
7286	actor	44	2249
7287	actor	44	2251
7288	actor	44	3186
7289	actor	44	3187
7290	actor	44	3188
7291	actor	44	3189
7292	actor	44	2257
7293	actor	44	2234
7294	actor	44	3190
7295	actor	44	3191
7296	actor	44	3192
7297	actor	44	3193
7298	actor	44	3194
7299	actor	44	3195
7300	actor	44	3196
7301	actor	44	3197
7302	actor	44	3198
7303	actor	44	3178
7304	director	45	3199
7305	actor	45	3200
7306	actor	45	3201
7307	actor	45	3202
7308	actor	45	3203
7309	actor	45	3204
7310	actor	45	3205
7311	actor	45	3206
7312	actor	45	3207
7313	actor	45	3208
7314	actor	45	3209
7315	actor	45	3210
7316	actor	45	3211
7317	actor	45	3212
7318	actor	45	3213
7319	actor	45	3214
7320	actor	45	3215
7321	actor	45	3216
7322	actor	45	3217
7323	actor	45	3218
7324	actor	45	3219
7325	actor	45	3220
7326	actor	45	3221
7327	actor	45	3222
7328	actor	45	3223
7329	actor	45	3224
7330	actor	45	3225
7331	actor	45	3226
7332	actor	45	3227
7333	actor	45	3228
7334	actor	45	3229
7335	actor	45	3230
7336	actor	45	3231
7337	actor	45	3232
7338	actor	45	3233
7339	director	46	3199
7340	actor	46	3234
7341	actor	46	3200
7342	actor	46	3235
7343	actor	46	3202
7344	actor	46	3236
7345	actor	46	3237
7346	actor	46	3238
7347	actor	46	2390
7348	actor	46	1985
7349	actor	46	3239
7350	actor	46	3240
7351	actor	46	3241
7352	actor	46	3242
7353	actor	46	3243
7354	actor	46	3244
7355	actor	46	3245
7356	actor	46	3246
7357	actor	46	3247
7358	actor	46	2364
7359	actor	46	3248
7360	actor	46	3249
7361	actor	46	3250
7362	actor	46	3251
7363	actor	46	3252
7364	director	47	3199
7365	actor	47	3253
7366	actor	47	3254
7367	actor	47	3255
7368	actor	47	3256
7369	actor	47	3257
7370	actor	47	3258
7371	actor	47	1852
3010	director	41	3053
3011	actor	41	3054
3012	actor	41	3055
3013	actor	41	3056
3014	actor	41	3057
3015	actor	41	3058
3016	actor	41	3059
3017	actor	41	3060
3018	actor	41	3061
3019	actor	41	3062
3020	actor	41	3063
3021	actor	41	3064
3022	actor	41	3065
3023	actor	41	3066
3024	actor	41	3067
3025	actor	41	3068
3026	actor	41	3069
3027	actor	41	3070
3028	actor	41	3071
3029	actor	41	3072
3030	actor	41	3073
3031	actor	41	3074
3032	actor	41	3075
3033	actor	41	3076
3034	actor	41	3077
3035	actor	41	3078
3036	actor	41	3079
3037	actor	41	3080
3038	actor	41	3081
3039	actor	41	3082
3040	actor	41	3083
3041	actor	41	3084
3042	actor	41	3085
3043	actor	41	3086
3044	actor	41	3087
3045	actor	41	3088
3046	actor	41	3089
3047	actor	41	3090
3048	actor	41	3091
3049	actor	41	3092
3050	actor	41	3093
3051	actor	41	3094
3052	actor	41	3095
3053	actor	41	3096
3054	actor	41	3097
3055	actor	41	3098
3056	actor	41	3099
7919	director	23	1797
7920	director	23	1798
7921	director	23	1739
7922	actor	23	1799
7923	actor	23	1800
7924	actor	23	1801
7925	actor	23	1802
7926	actor	23	1804
7927	actor	23	1805
7928	actor	23	1841
7929	actor	23	1803
7930	actor	23	1838
7931	actor	23	1840
7932	actor	23	1806
7933	actor	23	1807
7934	actor	23	1827
7935	actor	23	1832
7936	actor	23	1835
7937	actor	23	1817
7938	actor	23	1837
7939	actor	23	1808
7940	actor	23	1843
7941	actor	23	1812
7942	actor	23	1826
7943	actor	23	1842
7944	actor	23	1845
7945	actor	23	1834
7946	actor	23	1809
7947	actor	23	1830
7948	actor	23	1823
7949	actor	23	1814
7950	actor	23	1818
7951	actor	23	1811
7952	actor	23	1822
7953	actor	23	1833
7954	actor	23	1819
7955	actor	23	1825
7956	actor	23	1810
7957	actor	23	1829
7958	actor	23	1815
7959	actor	23	1824
7960	actor	23	1813
7961	actor	23	1828
7962	actor	23	3051
7963	actor	23	1816
7964	actor	23	1844
7965	actor	23	1831
7966	actor	23	1821
7967	actor	23	1836
7968	actor	23	1820
7969	actor	23	3052
7993	director	22	1739
7994	actor	22	1777
7995	actor	22	1742
7996	actor	22	1778
7997	actor	22	1779
7998	actor	22	1780
7999	actor	22	1781
8000	actor	22	1752
8001	actor	22	1782
8002	actor	22	1783
8003	actor	22	1784
8004	actor	22	1785
8005	actor	22	1786
8006	actor	22	1787
8007	actor	22	1788
8008	actor	22	1789
8009	actor	22	1790
8010	actor	22	1791
8011	actor	22	1792
8012	actor	22	1793
8013	actor	22	1794
8014	actor	22	1795
8015	actor	22	1796
7372	actor	47	2378
7373	actor	47	3259
7374	actor	47	3260
7375	actor	47	3261
7376	actor	47	3262
7377	actor	47	3263
7378	actor	47	3264
7379	actor	47	3265
7380	actor	47	3266
7381	actor	47	3267
7382	actor	47	3268
7383	actor	47	3269
7384	actor	47	3270
7385	actor	47	3271
7386	actor	47	3272
7387	actor	47	3273
7388	actor	47	3274
7389	actor	47	3275
7390	actor	47	3276
7391	actor	47	3277
7392	actor	47	3278
7393	actor	47	3279
7394	actor	47	3280
7395	actor	47	3281
7396	actor	47	3282
7397	director	52	3199
7398	actor	52	2360
7399	actor	52	3386
7400	actor	52	3387
7401	actor	52	3388
7402	actor	52	3389
7403	actor	52	3203
7404	actor	52	3390
7405	actor	52	3391
7406	actor	52	3392
7407	actor	52	3393
7408	actor	52	3394
7409	actor	52	3205
7410	actor	52	2294
7411	actor	52	3395
7412	actor	52	3396
7413	actor	52	3397
7414	actor	52	3398
7415	actor	52	3399
7416	actor	52	3400
7417	actor	52	1779
7418	actor	52	3401
7419	actor	52	3402
7420	actor	52	3403
7421	actor	52	3404
7422	actor	52	3405
7423	actor	52	3406
7424	actor	52	3407
7425	actor	52	3408
7426	actor	52	3409
7427	actor	52	3260
7428	actor	52	3410
7429	actor	52	3411
7430	actor	52	3412
7431	actor	52	3413
7432	actor	52	3414
7433	actor	52	3415
7434	actor	52	3223
7435	actor	52	3416
7436	actor	52	3269
7437	actor	52	3417
7438	actor	52	3418
7439	actor	52	3419
7440	actor	52	3420
7441	actor	52	3421
7442	actor	52	3422
7443	actor	52	3271
7444	actor	52	3423
7445	actor	52	3424
7446	actor	52	3425
7447	actor	52	3426
7448	actor	52	3427
7449	actor	52	3428
7450	actor	52	3429
7451	actor	52	3430
7452	actor	52	3431
7453	actor	52	3273
7454	actor	52	3432
7455	actor	52	3433
7456	actor	52	3434
7457	actor	52	3435
7458	actor	52	3436
7459	actor	52	3437
7460	actor	52	3438
7461	actor	52	3439
7462	actor	52	3440
7463	actor	52	3441
7464	actor	52	3442
7465	actor	52	3277
7466	actor	52	3443
7467	actor	52	3444
7468	actor	52	3445
7469	actor	52	3446
7470	actor	52	3447
7471	actor	52	3448
7472	actor	52	3449
7473	actor	52	3450
7474	actor	52	3451
7475	actor	52	3452
7476	actor	52	3453
7477	actor	52	3454
7478	actor	52	3455
7479	actor	52	3456
7480	actor	52	3457
7481	actor	52	3458
7482	actor	52	3459
7483	actor	52	3460
7484	actor	52	3461
7485	actor	52	3462
7486	actor	52	3463
7487	actor	52	3558
7488	director	53	3199
7489	actor	53	3464
7490	actor	53	3465
7491	actor	53	3466
7492	actor	53	3467
7493	actor	53	3468
7494	actor	53	3469
7495	actor	53	1985
7496	actor	53	3470
7497	actor	53	3395
7498	actor	53	3471
7499	actor	53	3472
7500	actor	53	3427
7501	actor	53	3473
7502	actor	53	3228
7503	actor	53	3474
7504	actor	53	3277
7505	actor	53	3444
7506	actor	53	3475
7507	actor	53	3476
7508	actor	53	3477
7509	actor	53	3478
7510	actor	53	3479
7511	director	55	3199
7512	actor	55	3503
7513	actor	55	3504
7514	actor	55	3505
7515	actor	55	3506
7516	actor	55	3203
7517	actor	55	3215
7518	actor	55	3507
7519	actor	55	3357
7520	actor	55	3508
7521	actor	55	3509
7522	actor	55	3510
7523	actor	55	3511
7524	actor	55	3512
7525	actor	55	3513
7526	actor	55	3514
7527	actor	55	3239
7528	actor	55	3212
7529	actor	55	3221
7530	actor	55	3515
7531	actor	55	3516
7532	actor	55	3517
7533	actor	55	3518
7534	actor	55	3519
7535	actor	55	3520
7536	actor	55	3260
7537	actor	55	3521
7538	actor	55	3522
7539	actor	55	3523
7540	actor	55	3524
7541	actor	55	3525
7542	actor	55	3271
7543	actor	55	3273
7544	actor	55	3526
7545	actor	55	3527
7546	actor	55	3528
7547	actor	55	3529
7548	actor	55	3337
7549	actor	55	3440
7550	actor	55	3444
7551	actor	55	3530
7552	actor	55	3531
7553	actor	55	3532
7554	actor	55	3533
7555	actor	55	3534
7556	director	36	1739
7557	actor	36	2294
7558	actor	36	2295
7559	actor	36	2296
7560	actor	36	2297
7561	actor	36	2298
7562	actor	36	2299
7563	actor	36	2300
7564	actor	36	2301
7565	actor	36	2302
7566	actor	36	2303
7567	actor	36	1887
7568	actor	36	2304
7569	actor	36	2305
7570	actor	36	2306
7571	actor	36	2307
7572	actor	36	2308
7573	actor	36	2309
7574	actor	36	2310
7575	actor	36	2311
7576	actor	36	2312
7577	actor	36	2313
7578	actor	36	2314
7579	actor	36	2315
7580	actor	36	2316
7581	actor	36	2317
7582	actor	36	2318
7583	actor	36	2319
7584	actor	36	2320
7585	actor	36	2321
7586	actor	36	2322
7587	actor	36	2323
7588	actor	36	2324
7589	actor	36	2325
7590	actor	36	1907
7591	actor	36	2326
7592	actor	36	2327
7593	director	37	1981
7594	actor	37	2328
7595	actor	37	2329
7596	actor	37	2330
7597	actor	37	2331
7598	actor	37	2332
7599	actor	37	2333
7600	actor	37	2334
7601	actor	37	2335
7602	actor	37	2336
7603	actor	37	1748
7604	actor	37	2337
7605	actor	37	2338
7606	actor	37	2339
7607	actor	37	2340
7608	actor	37	2341
7609	actor	37	2342
7610	actor	37	2343
7611	actor	37	2344
7612	actor	37	2345
7613	actor	37	2346
7614	actor	37	2347
7615	actor	37	2348
7616	actor	37	2349
7617	director	40	1981
7618	actor	40	2388
7619	actor	40	2389
7620	actor	40	2390
7621	actor	40	2391
7622	actor	40	2392
7623	actor	40	2393
7624	actor	40	2394
7625	actor	40	2355
7626	director	38	1981
7627	actor	38	2350
7628	actor	38	2351
7629	actor	38	2352
7630	actor	38	2353
7631	actor	38	2354
7632	actor	38	2355
7633	actor	38	2356
7634	actor	38	2357
7635	actor	38	2358
7636	actor	38	2359
7637	actor	38	2360
7638	actor	38	2361
7639	actor	38	2362
7640	actor	38	1886
7641	actor	38	2363
7642	actor	38	2364
7643	actor	38	2365
7644	actor	38	2366
7645	actor	38	2367
7646	actor	38	2368
7647	actor	38	2369
7648	actor	38	2370
7649	actor	38	2371
7650	actor	38	2372
7651	actor	38	2373
7652	actor	38	2374
7653	director	39	2023
7654	actor	39	2001
7655	actor	39	2375
7656	actor	39	2376
7657	actor	39	2377
7658	actor	39	2378
7659	actor	39	2379
7660	actor	39	2380
7661	actor	39	2381
7662	actor	39	2382
7663	actor	39	2352
7664	actor	39	2383
7665	actor	39	2384
7666	actor	39	2385
7667	actor	39	2386
7668	actor	39	2387
7669	director	48	2023
7670	actor	48	2001
7671	actor	48	3283
7672	actor	48	3284
7673	actor	48	3153
7674	actor	48	3285
7675	actor	48	3286
7676	actor	48	3287
7677	actor	48	3288
7678	actor	48	3289
7679	actor	48	2382
7680	actor	48	3290
7681	actor	48	3291
7682	actor	48	3292
7683	actor	48	3293
7684	actor	48	3294
7685	actor	48	3295
7686	actor	48	3296
7687	actor	48	3297
7688	actor	48	3298
7689	actor	48	3299
7690	actor	48	3169
7691	actor	48	2387
7692	actor	48	3300
7693	actor	48	3301
7694	actor	48	3302
7695	actor	48	3303
7696	actor	48	3304
7697	actor	48	3305
7698	actor	48	3306
7699	actor	48	3307
7700	actor	48	1839
7701	actor	48	3308
7702	actor	48	3309
7703	actor	48	3181
7704	actor	48	3310
7705	director	49	3199
7706	actor	49	3311
7707	actor	49	3312
7708	actor	49	3313
7709	actor	49	3314
7710	actor	49	3315
7711	actor	49	3316
7712	actor	49	3317
7713	actor	49	3318
7714	actor	49	3319
7715	actor	49	3320
7716	actor	49	3321
7717	actor	49	3322
7718	actor	49	3323
7719	actor	49	3324
7720	actor	49	3325
7721	actor	49	3326
7722	actor	49	3327
7723	actor	49	3328
7724	actor	49	3329
7725	actor	49	3330
7726	actor	49	3331
7727	actor	49	3332
7728	actor	49	3333
7729	actor	49	3334
7730	actor	49	3335
7731	actor	49	3336
7732	actor	49	3337
7733	actor	49	3338
7734	actor	49	3339
7735	actor	49	3340
7736	actor	49	3341
7737	actor	49	3342
7738	actor	49	3343
7739	actor	49	3344
7740	actor	49	3345
7741	actor	49	1776
7742	director	50	3199
7743	actor	50	3346
7744	actor	50	3347
7745	actor	50	3348
7746	actor	50	3349
7747	actor	50	3350
7748	actor	50	3351
7749	actor	50	1908
7750	actor	50	3352
7751	actor	50	3353
7752	actor	50	3354
7753	actor	50	3355
7754	actor	50	3356
7755	actor	50	3357
7756	actor	50	3358
7757	actor	50	3359
7758	actor	50	3337
7759	actor	50	3360
7760	actor	50	3361
7761	actor	50	3362
7762	actor	50	3363
7763	actor	50	3364
7764	actor	50	3365
7765	director	51	3199
7766	actor	51	3200
7767	actor	51	3366
7768	actor	51	3367
7769	actor	51	3368
7770	actor	51	3369
7771	actor	51	3370
7772	actor	51	3371
7773	actor	51	3372
7774	actor	51	3373
7775	actor	51	3374
7776	actor	51	3375
7777	actor	51	3376
7778	actor	51	3377
7779	actor	51	2343
7780	actor	51	3378
7781	actor	51	3379
7782	actor	51	3380
7783	actor	51	3381
7784	actor	51	3382
7785	actor	51	3383
7786	actor	51	3384
7787	actor	51	3385
7788	director	54	3199
7789	actor	54	3480
7790	actor	54	1981
7791	actor	54	3481
7792	actor	54	3215
7793	actor	54	3482
7794	actor	54	3483
7795	actor	54	3200
7796	actor	54	3484
7797	actor	54	3485
7798	actor	54	3241
7799	actor	54	3486
7800	actor	54	3487
7801	actor	54	3213
7802	actor	54	3488
7803	actor	54	3489
7804	actor	54	3490
7805	actor	54	3242
7806	actor	54	3491
7807	actor	54	3492
7808	actor	54	3493
7809	actor	54	3494
7810	actor	54	3337
7811	actor	54	3495
7812	actor	54	3496
7813	actor	54	3497
7814	actor	54	3498
7815	actor	54	3499
7816	actor	54	3233
7817	actor	54	3500
7818	actor	54	3501
7819	actor	54	3502
7820	director	56	3199
7821	actor	56	3535
7822	actor	56	3536
7823	actor	56	3537
7824	actor	56	1981
7825	actor	56	3538
7826	actor	56	3539
7827	actor	56	3540
7828	actor	56	3541
7829	actor	56	3542
7830	actor	56	3543
7831	actor	56	3544
7832	actor	56	1985
7833	actor	56	3545
7834	actor	56	3260
7835	actor	56	3546
7836	actor	56	3547
7837	actor	56	3548
7838	actor	56	3549
7839	actor	56	3550
7840	actor	56	3551
7841	actor	56	3552
7842	actor	56	3553
7843	actor	56	3440
7844	actor	56	3530
7845	actor	56	3554
7846	actor	56	3555
7847	actor	56	3556
7848	actor	56	3557
7849	director	57	3199
7850	actor	57	3559
7851	actor	57	3560
7852	actor	57	2001
7853	actor	57	3200
7854	actor	57	3254
7855	actor	57	3561
7856	actor	57	3562
7857	actor	57	3563
7858	actor	57	3564
7859	actor	57	3509
7860	actor	57	3212
7861	actor	57	3565
7862	actor	57	3566
7863	actor	57	3567
7864	actor	57	3242
7865	actor	57	3568
7866	actor	57	3569
7867	actor	57	3312
7868	actor	57	3483
7869	actor	57	3491
7870	actor	57	3570
7871	actor	57	3228
7872	actor	57	3571
\.


--
-- Name: country_id_seq; Type: SEQUENCE SET; Schema: public; Owner: scrapoo
--

SELECT pg_catalog.setval('public.country_id_seq', 9, true);


--
-- Name: film_id_seq; Type: SEQUENCE SET; Schema: public; Owner: scrapoo
--

SELECT pg_catalog.setval('public.film_id_seq', 57, true);


--
-- Name: genre_id_seq; Type: SEQUENCE SET; Schema: public; Owner: scrapoo
--

SELECT pg_catalog.setval('public.genre_id_seq', 23, true);


--
-- Name: movie_link_id_seq; Type: SEQUENCE SET; Schema: public; Owner: scrapoo
--

SELECT pg_catalog.setval('public.movie_link_id_seq', 1, false);


--
-- Name: person_id_seq; Type: SEQUENCE SET; Schema: public; Owner: scrapoo
--

SELECT pg_catalog.setval('public.person_id_seq', 3571, true);


--
-- Name: person_in_film_id_seq; Type: SEQUENCE SET; Schema: public; Owner: scrapoo
--

SELECT pg_catalog.setval('public.person_in_film_id_seq', 8015, true);


--
-- Name: country country_pkey; Type: CONSTRAINT; Schema: public; Owner: scrapoo
--

ALTER TABLE ONLY public.country
    ADD CONSTRAINT country_pkey PRIMARY KEY (id);


--
-- Name: film film_pkey; Type: CONSTRAINT; Schema: public; Owner: scrapoo
--

ALTER TABLE ONLY public.film
    ADD CONSTRAINT film_pkey PRIMARY KEY (id);


--
-- Name: genre genre_pkey; Type: CONSTRAINT; Schema: public; Owner: scrapoo
--

ALTER TABLE ONLY public.genre
    ADD CONSTRAINT genre_pkey PRIMARY KEY (id);


--
-- Name: movie_link movie_link_pkey; Type: CONSTRAINT; Schema: public; Owner: scrapoo
--

ALTER TABLE ONLY public.movie_link
    ADD CONSTRAINT movie_link_pkey PRIMARY KEY (id);


--
-- Name: person_in_film person_in_film_pkey; Type: CONSTRAINT; Schema: public; Owner: scrapoo
--

ALTER TABLE ONLY public.person_in_film
    ADD CONSTRAINT person_in_film_pkey PRIMARY KEY (id);


--
-- Name: person person_pkey; Type: CONSTRAINT; Schema: public; Owner: scrapoo
--

ALTER TABLE ONLY public.person
    ADD CONSTRAINT person_pkey PRIMARY KEY (id);


--
-- Name: person_in_film uid_person_in_f_films_i_211ffc; Type: CONSTRAINT; Schema: public; Owner: scrapoo
--

ALTER TABLE ONLY public.person_in_film
    ADD CONSTRAINT uid_person_in_f_films_i_211ffc UNIQUE (films_id, persons_id);


--
-- Name: uidx_film_genre_film_id_4131c5; Type: INDEX; Schema: public; Owner: scrapoo
--

CREATE UNIQUE INDEX uidx_film_genre_film_id_4131c5 ON public.film_genre USING btree (film_id, genre_id);


--
-- Name: film film_country_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: scrapoo
--

ALTER TABLE ONLY public.film
    ADD CONSTRAINT film_country_id_fkey FOREIGN KEY (country_id) REFERENCES public.country(id) ON DELETE SET NULL;


--
-- Name: film_genre film_genre_film_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: scrapoo
--

ALTER TABLE ONLY public.film_genre
    ADD CONSTRAINT film_genre_film_id_fkey FOREIGN KEY (film_id) REFERENCES public.film(id) ON DELETE CASCADE;


--
-- Name: film_genre film_genre_genre_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: scrapoo
--

ALTER TABLE ONLY public.film_genre
    ADD CONSTRAINT film_genre_genre_id_fkey FOREIGN KEY (genre_id) REFERENCES public.genre(id) ON DELETE CASCADE;


--
-- Name: person_in_film person_in_film_films_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: scrapoo
--

ALTER TABLE ONLY public.person_in_film
    ADD CONSTRAINT person_in_film_films_id_fkey FOREIGN KEY (films_id) REFERENCES public.film(id) ON DELETE CASCADE;


--
-- Name: person_in_film person_in_film_persons_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: scrapoo
--

ALTER TABLE ONLY public.person_in_film
    ADD CONSTRAINT person_in_film_persons_id_fkey FOREIGN KEY (persons_id) REFERENCES public.person(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict M7sEk77dTDMdVbTDGP6TXH3GDJE7yO9wBP15oR43rq804v6kouRj9MkW4kLffx5

