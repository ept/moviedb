-- This SQL script sets up a bunch of Postgres tables into which we can import the result
-- of parsing the IMDB data files.

-- Tables into which raw data is loaded
drop table if exists top_titles;
drop table if exists titles;
drop table if exists names;
drop table if exists attributes;
drop table if exists movies_raw;
drop table if exists actors;
drop table if exists actresses;
drop table if exists cinematographers;
drop table if exists composers;
drop table if exists costume_designers;
drop table if exists directors;
drop table if exists editors;
drop table if exists miscellaneous;
drop table if exists producers;
drop table if exists production_designers;
drop table if exists writers;
drop table if exists certificates;
drop table if exists color_info;
drop table if exists countries;
drop table if exists distributors;
drop table if exists genres;
drop table if exists keywords;
drop table if exists language;
drop table if exists locations;
drop table if exists production_companies;
drop table if exists release_dates;
drop table if exists running_times;
drop table if exists sound_mix;
drop table if exists special_effects_companies;
drop table if exists technical;

-- Tables that are derived from the above
drop table if exists credits;
drop table if exists movies;
drop table if exists people;
drop table if exists movies_doc;
drop table if exists movies_doc_small;
drop table if exists people_doc;
drop table if exists people_doc_small;
drop type  if exists credit_type;

-- Re-create fresh tables
create table top_titles (title text not null);
create table titles     (id int, title text not null,     hexid text);
create table names      (id int, name text not null,      hexid text);
create table attributes (id int, attribute text not null, hexid text);
create table movies_raw (id int not null, year_from int, year_to int, attr_id int);
create table actors               (name_id int not null, title_id int not null, attr_id int, character text, position int);
create table actresses            (name_id int not null, title_id int not null, attr_id int, character text, position int);
create table cinematographers     (name_id int not null, title_id int not null, attr_id int);
create table composers            (name_id int not null, title_id int not null, attr_id int);
create table costume_designers    (name_id int not null, title_id int not null, attr_id int);
create table directors            (name_id int not null, title_id int not null, attr_id int);
create table editors              (name_id int not null, title_id int not null, attr_id int);
create table miscellaneous        (name_id int not null, title_id int not null, attr_id int);
create table producers            (name_id int not null, title_id int not null, attr_id int);
create table production_designers (name_id int not null, title_id int not null, attr_id int);
create table writers              (name_id int not null, title_id int not null, attr_id int, line_order int, group_order int, subgroup_order int);
create table certificates              (title_id int not null, value text not null, attr_id int);
create table color_info                (title_id int not null, value text not null, attr_id int);
create table countries                 (title_id int not null, value text not null, attr_id int);
create table distributors              (title_id int not null, value text not null, attr_id int);
create table genres                    (title_id int not null, value text not null, attr_id int);
create table keywords                  (title_id int not null, value text not null, attr_id int);
create table language                  (title_id int not null, value text not null, attr_id int);
create table locations                 (title_id int not null, value text not null, attr_id int);
create table production_companies      (title_id int not null, value text not null, attr_id int);
create table release_dates             (title_id int not null, value text not null, attr_id int);
create table running_times             (title_id int not null, value text not null, attr_id int);
create table sound_mix                 (title_id int not null, value text not null, attr_id int);
create table special_effects_companies (title_id int not null, value text not null, attr_id int);
create table technical                 (title_id int not null, value text not null, attr_id int);
