--
-- PostgreSQL database dump
--

\restrict ziILwSngphrZYP1TqxjQjTG8DrpLulMKtMab9FAg9bpYUXIPqwSMhHJHwvpMwLj

-- Dumped from database version 15.18
-- Dumped by pg_dump version 18.3

-- Started on 2026-05-25 15:17:51 CEST

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
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
-- TOC entry 215 (class 1259 OID 24776)
-- Name: country; Type: TABLE; Schema: public; Owner: scrapoo
--

CREATE TABLE public.country (
    id integer NOT NULL,
    name character varying(50)
);


ALTER TABLE public.country OWNER TO scrapoo;

--
-- TOC entry 214 (class 1259 OID 24775)
-- Name: country_id_seq; Type: SEQUENCE; Schema: public; Owner: scrapoo
--

CREATE SEQUENCE public.country_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.country_id_seq OWNER TO scrapoo;

--
-- TOC entry 3462 (class 0 OID 0)
-- Dependencies: 214
-- Name: country_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: scrapoo
--

ALTER SEQUENCE public.country_id_seq OWNED BY public.country.id;


--
-- TOC entry 217 (class 1259 OID 24783)
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
    url character varying(255),
    country_id integer
);


ALTER TABLE public.film OWNER TO scrapoo;

--
-- TOC entry 226 (class 1259 OID 24834)
-- Name: film_genre; Type: TABLE; Schema: public; Owner: scrapoo
--

CREATE TABLE public.film_genre (
    film_id integer NOT NULL,
    genre_id integer NOT NULL
);


ALTER TABLE public.film_genre OWNER TO scrapoo;

--
-- TOC entry 216 (class 1259 OID 24782)
-- Name: film_id_seq; Type: SEQUENCE; Schema: public; Owner: scrapoo
--

CREATE SEQUENCE public.film_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.film_id_seq OWNER TO scrapoo;

--
-- TOC entry 3463 (class 0 OID 0)
-- Dependencies: 216
-- Name: film_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: scrapoo
--

ALTER SEQUENCE public.film_id_seq OWNED BY public.film.id;


--
-- TOC entry 219 (class 1259 OID 24795)
-- Name: genre; Type: TABLE; Schema: public; Owner: scrapoo
--

CREATE TABLE public.genre (
    id integer NOT NULL,
    name character varying(60)
);


ALTER TABLE public.genre OWNER TO scrapoo;

--
-- TOC entry 218 (class 1259 OID 24794)
-- Name: genre_id_seq; Type: SEQUENCE; Schema: public; Owner: scrapoo
--

CREATE SEQUENCE public.genre_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.genre_id_seq OWNER TO scrapoo;

--
-- TOC entry 3464 (class 0 OID 0)
-- Dependencies: 218
-- Name: genre_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: scrapoo
--

ALTER SEQUENCE public.genre_id_seq OWNED BY public.genre.id;


--
-- TOC entry 221 (class 1259 OID 24802)
-- Name: movie_link; Type: TABLE; Schema: public; Owner: scrapoo
--

CREATE TABLE public.movie_link (
    id integer NOT NULL,
    url character varying(255),
    status character varying(15)
);


ALTER TABLE public.movie_link OWNER TO scrapoo;

--
-- TOC entry 220 (class 1259 OID 24801)
-- Name: movie_link_id_seq; Type: SEQUENCE; Schema: public; Owner: scrapoo
--

CREATE SEQUENCE public.movie_link_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.movie_link_id_seq OWNER TO scrapoo;

--
-- TOC entry 3465 (class 0 OID 0)
-- Dependencies: 220
-- Name: movie_link_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: scrapoo
--

ALTER SEQUENCE public.movie_link_id_seq OWNED BY public.movie_link.id;


--
-- TOC entry 223 (class 1259 OID 24809)
-- Name: person; Type: TABLE; Schema: public; Owner: scrapoo
--

CREATE TABLE public.person (
    id integer NOT NULL,
    name character varying(60) NOT NULL,
    birth_date date,
    url character varying(255),
    occupation character varying(50)
);


ALTER TABLE public.person OWNER TO scrapoo;

--
-- TOC entry 222 (class 1259 OID 24808)
-- Name: person_id_seq; Type: SEQUENCE; Schema: public; Owner: scrapoo
--

CREATE SEQUENCE public.person_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.person_id_seq OWNER TO scrapoo;

--
-- TOC entry 3466 (class 0 OID 0)
-- Dependencies: 222
-- Name: person_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: scrapoo
--

ALTER SEQUENCE public.person_id_seq OWNED BY public.person.id;


--
-- TOC entry 225 (class 1259 OID 24816)
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
-- TOC entry 224 (class 1259 OID 24815)
-- Name: person_in_film_id_seq; Type: SEQUENCE; Schema: public; Owner: scrapoo
--

CREATE SEQUENCE public.person_in_film_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.person_in_film_id_seq OWNER TO scrapoo;

--
-- TOC entry 3467 (class 0 OID 0)
-- Dependencies: 224
-- Name: person_in_film_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: scrapoo
--

ALTER SEQUENCE public.person_in_film_id_seq OWNED BY public.person_in_film.id;


--
-- TOC entry 3289 (class 2604 OID 24779)
-- Name: country id; Type: DEFAULT; Schema: public; Owner: scrapoo
--

ALTER TABLE ONLY public.country ALTER COLUMN id SET DEFAULT nextval('public.country_id_seq'::regclass);


--
-- TOC entry 3290 (class 2604 OID 24786)
-- Name: film id; Type: DEFAULT; Schema: public; Owner: scrapoo
--

ALTER TABLE ONLY public.film ALTER COLUMN id SET DEFAULT nextval('public.film_id_seq'::regclass);


--
-- TOC entry 3291 (class 2604 OID 24798)
-- Name: genre id; Type: DEFAULT; Schema: public; Owner: scrapoo
--

ALTER TABLE ONLY public.genre ALTER COLUMN id SET DEFAULT nextval('public.genre_id_seq'::regclass);


--
-- TOC entry 3292 (class 2604 OID 24805)
-- Name: movie_link id; Type: DEFAULT; Schema: public; Owner: scrapoo
--

ALTER TABLE ONLY public.movie_link ALTER COLUMN id SET DEFAULT nextval('public.movie_link_id_seq'::regclass);


--
-- TOC entry 3293 (class 2604 OID 24812)
-- Name: person id; Type: DEFAULT; Schema: public; Owner: scrapoo
--

ALTER TABLE ONLY public.person ALTER COLUMN id SET DEFAULT nextval('public.person_id_seq'::regclass);


--
-- TOC entry 3294 (class 2604 OID 24819)
-- Name: person_in_film id; Type: DEFAULT; Schema: public; Owner: scrapoo
--

ALTER TABLE ONLY public.person_in_film ALTER COLUMN id SET DEFAULT nextval('public.person_in_film_id_seq'::regclass);


--
-- TOC entry 3296 (class 2606 OID 24781)
-- Name: country country_pkey; Type: CONSTRAINT; Schema: public; Owner: scrapoo
--

ALTER TABLE ONLY public.country
    ADD CONSTRAINT country_pkey PRIMARY KEY (id);


--
-- TOC entry 3298 (class 2606 OID 24788)
-- Name: film film_pkey; Type: CONSTRAINT; Schema: public; Owner: scrapoo
--

ALTER TABLE ONLY public.film
    ADD CONSTRAINT film_pkey PRIMARY KEY (id);


--
-- TOC entry 3300 (class 2606 OID 24800)
-- Name: genre genre_pkey; Type: CONSTRAINT; Schema: public; Owner: scrapoo
--

ALTER TABLE ONLY public.genre
    ADD CONSTRAINT genre_pkey PRIMARY KEY (id);


--
-- TOC entry 3302 (class 2606 OID 24807)
-- Name: movie_link movie_link_pkey; Type: CONSTRAINT; Schema: public; Owner: scrapoo
--

ALTER TABLE ONLY public.movie_link
    ADD CONSTRAINT movie_link_pkey PRIMARY KEY (id);


--
-- TOC entry 3306 (class 2606 OID 24821)
-- Name: person_in_film person_in_film_pkey; Type: CONSTRAINT; Schema: public; Owner: scrapoo
--

ALTER TABLE ONLY public.person_in_film
    ADD CONSTRAINT person_in_film_pkey PRIMARY KEY (id);


--
-- TOC entry 3304 (class 2606 OID 24814)
-- Name: person person_pkey; Type: CONSTRAINT; Schema: public; Owner: scrapoo
--

ALTER TABLE ONLY public.person
    ADD CONSTRAINT person_pkey PRIMARY KEY (id);


--
-- TOC entry 3308 (class 2606 OID 24823)
-- Name: person_in_film uid_person_in_f_films_i_211ffc; Type: CONSTRAINT; Schema: public; Owner: scrapoo
--

ALTER TABLE ONLY public.person_in_film
    ADD CONSTRAINT uid_person_in_f_films_i_211ffc UNIQUE (films_id, persons_id);


--
-- TOC entry 3309 (class 1259 OID 24847)
-- Name: uidx_film_genre_film_id_4131c5; Type: INDEX; Schema: public; Owner: scrapoo
--

CREATE UNIQUE INDEX uidx_film_genre_film_id_4131c5 ON public.film_genre USING btree (film_id, genre_id);


--
-- TOC entry 3310 (class 2606 OID 24789)
-- Name: film film_country_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: scrapoo
--

ALTER TABLE ONLY public.film
    ADD CONSTRAINT film_country_id_fkey FOREIGN KEY (country_id) REFERENCES public.country(id) ON DELETE SET NULL;


--
-- TOC entry 3313 (class 2606 OID 24837)
-- Name: film_genre film_genre_film_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: scrapoo
--

ALTER TABLE ONLY public.film_genre
    ADD CONSTRAINT film_genre_film_id_fkey FOREIGN KEY (film_id) REFERENCES public.film(id) ON DELETE CASCADE;


--
-- TOC entry 3314 (class 2606 OID 24842)
-- Name: film_genre film_genre_genre_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: scrapoo
--

ALTER TABLE ONLY public.film_genre
    ADD CONSTRAINT film_genre_genre_id_fkey FOREIGN KEY (genre_id) REFERENCES public.genre(id) ON DELETE CASCADE;


--
-- TOC entry 3311 (class 2606 OID 24824)
-- Name: person_in_film person_in_film_films_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: scrapoo
--

ALTER TABLE ONLY public.person_in_film
    ADD CONSTRAINT person_in_film_films_id_fkey FOREIGN KEY (films_id) REFERENCES public.film(id) ON DELETE CASCADE;


--
-- TOC entry 3312 (class 2606 OID 24829)
-- Name: person_in_film person_in_film_persons_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: scrapoo
--

ALTER TABLE ONLY public.person_in_film
    ADD CONSTRAINT person_in_film_persons_id_fkey FOREIGN KEY (persons_id) REFERENCES public.person(id) ON DELETE CASCADE;


-- Completed on 2026-05-25 15:17:51 CEST

--
-- PostgreSQL database dump complete
--

\unrestrict ziILwSngphrZYP1TqxjQjTG8DrpLulMKtMab9FAg9bpYUXIPqwSMhHJHwvpMwLj

