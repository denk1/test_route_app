CREATE DATABASE news
  WITH OWNER = postgres
       ENCODING = 'UTF8'
       TABLESPACE = pg_default
       LC_COLLATE = 'en_US.UTF-8'
       LC_CTYPE = 'en_US.UTF-8'
       CONNECTION LIMIT = -1;

CREATE TABLE article_tag
(
  id_article_tag serial NOT NULL,
  id_tag integer,
  id_news integer,
  CONSTRAINT article_tag_pkey PRIMARY KEY (id_article_tag)
);

CREATE TABLE articles
(
  id serial NOT NULL,
  headline text,
  content text,
  CONSTRAINT articles_pkey PRIMARY KEY (id)
);

CREATE TABLE tags
(
  id serial NOT NULL,
  tag text,
  CONSTRAINT tags_pkey PRIMARY KEY (id)
);

CREATE TABLE users
(
  id serial NOT NULL,
  name text,
  password text,
  CONSTRAINT users_pkey PRIMARY KEY (id)
);

CREATE OR REPLACE VIEW article_tag_view AS 
 SELECT articles.id,
    articles.headline,
    articles.content,
    article_tag.id_tag,
    tags.tag
   FROM articles,
    tags,
    article_tag
  WHERE articles.id = article_tag.id_news AND tags.id = article_tag.id_tag;
