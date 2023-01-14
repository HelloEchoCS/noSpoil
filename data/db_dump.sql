--
-- PostgreSQL database dump
--

-- Dumped from database version 14.4
-- Dumped by pg_dump version 14.4

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
-- Name: items; Type: TABLE; Schema: public; Owner: chrisshen
--

CREATE TABLE public.items (
    id integer NOT NULL,
    product_id integer NOT NULL,
    quantity numeric NOT NULL,
    best_before date NOT NULL,
    status text DEFAULT 'in stock'::text NOT NULL,
    CONSTRAINT items_quantity_check CHECK ((quantity >= (0)::numeric))
);


ALTER TABLE public.items OWNER TO chrisshen;

--
-- Name: items_id_seq; Type: SEQUENCE; Schema: public; Owner: chrisshen
--

CREATE SEQUENCE public.items_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.items_id_seq OWNER TO chrisshen;

--
-- Name: items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: chrisshen
--

ALTER SEQUENCE public.items_id_seq OWNED BY public.items.id;


--
-- Name: products; Type: TABLE; Schema: public; Owner: chrisshen
--

CREATE TABLE public.products (
    id integer NOT NULL,
    name text NOT NULL,
    unit text NOT NULL
);


ALTER TABLE public.products OWNER TO chrisshen;

--
-- Name: products_id_seq; Type: SEQUENCE; Schema: public; Owner: chrisshen
--

CREATE SEQUENCE public.products_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.products_id_seq OWNER TO chrisshen;

--
-- Name: products_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: chrisshen
--

ALTER SEQUENCE public.products_id_seq OWNED BY public.products.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: chrisshen
--

CREATE TABLE public.users (
    id integer NOT NULL,
    username text NOT NULL,
    password text NOT NULL,
    session_id text
);


ALTER TABLE public.users OWNER TO chrisshen;

--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: chrisshen
--

CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.users_id_seq OWNER TO chrisshen;

--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: chrisshen
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: items id; Type: DEFAULT; Schema: public; Owner: chrisshen
--

ALTER TABLE ONLY public.items ALTER COLUMN id SET DEFAULT nextval('public.items_id_seq'::regclass);


--
-- Name: products id; Type: DEFAULT; Schema: public; Owner: chrisshen
--

ALTER TABLE ONLY public.products ALTER COLUMN id SET DEFAULT nextval('public.products_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: chrisshen
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Data for Name: items; Type: TABLE DATA; Schema: public; Owner: chrisshen
--

COPY public.items (id, product_id, quantity, best_before, status) FROM stdin;
42	15	24	2023-07-01	consumed
44	21	1	2022-07-29	spoiled
47	14	1	2022-07-29	spoiled
48	9	5	2022-07-26	spoiled
49	20	1	2022-07-14	consumed
50	7	2	2022-07-01	spoiled
52	18	1	2022-08-04	consumed
56	22	1	2022-07-27	spoiled
38	17	1	2022-07-30	spoiled
51	20	3	2022-07-31	spoiled
33	10	2	2022-08-01	consumed
40	19	1	2022-08-02	consumed
32	9	30	2022-08-04	consumed
43	18	2	2022-08-04	consumed
30	7	10	2022-08-05	consumed
46	14	1	2022-08-29	consumed
45	16	2	2022-08-30	consumed
41	19	4	2022-10-11	consumed
54	25	1	2023-01-16	consumed
55	25	1	2023-04-29	consumed
39	13	1	2023-05-31	consumed
57	16	2	2023-09-12	consumed
59	26	3	2022-08-08	spoiled
34	11	5	2022-08-10	spoiled
36	21	2.5	2022-08-16	consumed
31	8	4	2022-08-27	consumed
53	23	1	2022-12-13	consumed
58	15	12	2024-02-02	consumed
61	7	20	2022-08-01	in stock
62	7	5	2022-08-06	in stock
64	8	2	2022-07-01	consumed
65	8	2	2022-07-07	consumed
66	8	1	2022-07-18	consumed
68	8	1	2022-07-20	consumed
67	8	1	2022-07-25	consumed
71	8	3	2022-04-06	consumed
70	8	1	2022-05-02	consumed
69	8	4	2022-06-03	spoiled
72	24	1	2023-09-20	in stock
74	21	1	2022-08-01	consumed
63	8	4	2022-08-31	in stock
75	25	1	2023-06-30	in stock
76	9	2	2022-08-03	in stock
77	10	2	2022-08-07	in stock
78	22	1	2024-01-03	in stock
79	26	5	2022-08-15	in stock
80	23	1	2023-09-21	in stock
73	21	2	2022-08-15	in stock
81	20	1	2022-08-01	consumed
82	20	2	2022-08-08	in stock
83	19	2	2022-08-08	in stock
84	18	4	2022-08-03	in stock
85	17	1	2022-08-02	in stock
86	14	1	2022-07-30	in stock
87	16	4	2022-08-31	in stock
88	15	24	2023-08-23	in stock
89	13	1	2024-01-16	in stock
90	11	4	2022-08-30	in stock
91	8	4	2022-08-15	in stock
92	26	1	2022-08-02	in stock
93	26	4	2022-06-27	consumed
\.


--
-- Data for Name: products; Type: TABLE DATA; Schema: public; Owner: chrisshen
--

COPY public.products (id, name, unit) FROM stdin;
7	Apple	Piece
8	Milk	Liter
9	Cherry	Piece
10	Cilantro	Bunch
11	Onion	Piece
13	Japanese Somen (Dried)	Bag
14	Tofu	Box
15	Coca-cola	Can
16	Orange Juice	Liter
17	Ground Pork	Pound
18	Chicken Breast	Pound
19	Lamb Chops	Pound
20	Lettuce	Box
21	Eggs	Dozen
22	Ketchup	Bottle
24	All Purpose Flour	Bag
25	Spaghetti	Bag
26	Muffin	Piece
23	Mayo	Bottle
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: chrisshen
--

COPY public.users (id, username, password, session_id) FROM stdin;
1	admin	$2a$12$jQSsXaHBfZHnkdsVRkjWCeRbpFNyiA8E0sotBZvHyGy8hLlXgCsRi	e836a63724857e952eaab730d2cf07495773017dea9ce7a6d78a43f03a9250ed
\.


--
-- Name: items_id_seq; Type: SEQUENCE SET; Schema: public; Owner: chrisshen
--

SELECT pg_catalog.setval('public.items_id_seq', 95, true);


--
-- Name: products_id_seq; Type: SEQUENCE SET; Schema: public; Owner: chrisshen
--

SELECT pg_catalog.setval('public.products_id_seq', 28, true);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: chrisshen
--

SELECT pg_catalog.setval('public.users_id_seq', 1, true);


--
-- Name: items items_pkey; Type: CONSTRAINT; Schema: public; Owner: chrisshen
--

ALTER TABLE ONLY public.items
    ADD CONSTRAINT items_pkey PRIMARY KEY (id);


--
-- Name: products products_name_key; Type: CONSTRAINT; Schema: public; Owner: chrisshen
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_name_key UNIQUE (name);


--
-- Name: products products_pkey; Type: CONSTRAINT; Schema: public; Owner: chrisshen
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: chrisshen
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: users users_username_key; Type: CONSTRAINT; Schema: public; Owner: chrisshen
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key UNIQUE (username);


--
-- Name: items items_product_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: chrisshen
--

ALTER TABLE ONLY public.items
    ADD CONSTRAINT items_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

