
drop table if exists movies_doc_small;
drop table if exists people_doc_small;

-- create table movies_doc (properties jsonb not null);
create table movies_doc_small (properties jsonb not null);

-- insert into movies_doc select * from make_movies_doc(false);
insert into movies_doc_small select * from make_movies_doc(true);

-- create table people_doc (properties jsonb not null);
create table people_doc_small (properties jsonb not null);

-- insert into people_doc select * from make_people_doc(false);
insert into people_doc_small select * from make_people_doc(true);
