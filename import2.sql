-- This SQL script is run after the data files have been imported into Postgres (see import.sh).
-- It cleans up the data and transforms it into a more usable structure.

update titles set id = ('x' || lpad(hexid, 8, '0'))::bit(32)::int;
alter table titles add primary key (id);
alter table titles drop column hexid;

update names set id = ('x' || lpad(hexid, 8, '0'))::bit(32)::int;
alter table names add primary key (id);
alter table names drop column hexid;

update attributes set id = ('x' || lpad(hexid, 8, '0'))::bit(32)::int;
alter table attributes add primary key (id);
alter table attributes drop column hexid;

-- A few duplicates are introduced by having multiple titles that differ only in case.
-- Remove duplicates, keeping one of them arbitrarily:
delete from movies_raw where ctid in (select m1.ctid from movies_raw m1 join movies_raw m2 on m1.id = m2.id and m1.ctid < m2.ctid);
alter table movies_raw add primary key (id);
update movies_raw set year_from = null where year_from = 0;
update movies_raw set year_to = null where year_to = 0;
update movies_raw set attr_id = null where attr_id = x'00ffffff'::int;

create table movies (
    id int primary key,
    title text not null,
    series_id int,
    is_series boolean not null default 'false',
    properties jsonb not null
);

-- Find all episodes of series, whose title has the form: "Series Title" (year) {Episode Title}
insert into movies (id, title, series_id, properties) (
    select episodes.id, episode[3], series.id,
        jsonb_strip_nulls(jsonb_build_object(
            'year', raw.year_from, 'year_to', raw.year_to, 'info', attribute,
            'suspended', case when episode[4] = ' {{SUSPENDED}}' then true else null end
        ))
    from (
        select id, regexp_matches(title, '^"(.*)" (\([^\)]+\)) \{([^\{\}]*)\}( \{\{SUSPENDED\}\})?$') as episode from titles
    ) episodes
    join titles series on series.title = '"' || episode[1] || '" ' || episode[2] || coalesce(episode[4], '')
    left join movies_raw raw on raw.id = episodes.id
    left join attributes on attributes.id = raw.attr_id
);

-- Special case: episodes marked suspended, where the series was not suspended
-- (Trying to make this part of the previous query makes it run incredibly slow)
insert into movies (id, title, series_id, properties) (
    select episodes.id, episode[3], series.id,
        jsonb_strip_nulls(jsonb_build_object(
            'year', raw.year_from, 'year_to', raw.year_to,
            'info', attribute, 'suspended', true
        ))
    from (
        select id, regexp_matches(title, '^"(.*)" (\([^\)]+\)) \{([^\{\}]*)\} \{\{SUSPENDED\}\}$') as episode from titles
    ) episodes
    join titles series on series.title = '"' || episode[1] || '" ' || episode[2]
    left join movies_raw raw on raw.id = episodes.id
    left join attributes on attributes.id = raw.attr_id
    left join movies existing on existing.id = episodes.id
    where existing.id is null
);

-- Find all series
insert into movies (id, title, is_series, properties) (
    select series.id, title_parts[1] || ' ' || title_parts[2], 'true',
        jsonb_strip_nulls(jsonb_build_object(
            'year', year_from, 'year_to', year_to, 'info', attribute,
            'suspended', case when title_parts[3] = ' {{SUSPENDED}}' then true else null end
        ))
    from (
        select id, regexp_matches(title, '^"(.*)" (\([^\)]+\))( \{\{SUSPENDED\}\})?$') as title_parts from titles
    ) series
    left join movies_raw raw on raw.id = series.id
    left join attributes on attributes.id = raw.attr_id
);

-- Movies (neither series nor episodes)
insert into movies (id, title, properties) (
    select movs.id, title_parts[1],
        jsonb_strip_nulls(jsonb_build_object(
            'year', year_from, 'year_to', year_to, 'info', attribute,
            'suspended', case when title_parts[2] = ' {{SUSPENDED}}' then true else null end
        ))
    from (
        select id, regexp_matches(title, '^([^"](?:[^\{]|\{[^\{])*)( \{\{SUSPENDED\}\})?$') as title_parts from titles
    ) movs
    left join movies_raw raw on raw.id = movs.id
    left join attributes on attributes.id = raw.attr_id
);

alter table movies add foreign key (series_id) references movies (id);

update actors    set position = null where position = 0;
update actresses set position = null where position = 0;

create table people (
    id int primary key,
    name text not null,
    properties jsonb not null
);

insert into people (
    select name_id, name, json_build_object('gender', 'male')
    from (select distinct name_id from actors) male
    join names on name_id = names.id
);

insert into people (
    select name_id, name, json_build_object('gender', 'female')
    from (select distinct name_id from actresses) female
    join names on name_id = names.id
) on conflict do nothing;

insert into people (select id, name, '{}'::jsonb from names) on conflict do nothing;

create type credit_type as enum (
    'actor', 'cinematographer', 'composer', 'costume_designer', 'director',
    'editor', 'miscellaneous', 'producer', 'production_designer', 'writer'
);

create table credits (
    person_id int not null,
    movie_id int not null,
    type credit_type not null,
    properties jsonb not null
);

insert into credits (
    select name_id, title_id, 'actor',
        jsonb_strip_nulls(jsonb_build_object('info', attribute, 'character', character, 'position', position))
    from actors
    left join attributes on attributes.id = attr_id
);

insert into credits (
    select name_id, title_id, 'actor',
        jsonb_strip_nulls(jsonb_build_object('info', attribute, 'character', character, 'position', position))
    from actresses
    left join attributes on attributes.id = attr_id
);

insert into credits (
    select name_id, title_id, 'cinematographer',
        jsonb_strip_nulls(jsonb_build_object('info', attribute))
    from cinematographers
    left join attributes on attributes.id = attr_id
);

insert into credits (
    select name_id, title_id, 'composer',
        jsonb_strip_nulls(jsonb_build_object('info', attribute))
    from composers
    left join attributes on attributes.id = attr_id
);

insert into credits (
    select name_id, title_id, 'costume_designer',
        jsonb_strip_nulls(jsonb_build_object('info', attribute))
    from costume_designers
    left join attributes on attributes.id = attr_id
);

insert into credits (
    select name_id, title_id, 'director',
        jsonb_strip_nulls(jsonb_build_object('info', attribute))
    from directors
    left join attributes on attributes.id = attr_id
);

insert into credits (
    select name_id, title_id, 'editor',
        jsonb_strip_nulls(jsonb_build_object('info', attribute))
    from editors
    left join attributes on attributes.id = attr_id
);

insert into credits (
    select name_id, title_id, 'miscellaneous',
        jsonb_strip_nulls(jsonb_build_object('info', attribute))
    from miscellaneous
    left join attributes on attributes.id = attr_id
);

insert into credits (
    select name_id, title_id, 'producer',
        jsonb_strip_nulls(jsonb_build_object('info', attribute))
    from producers
    left join attributes on attributes.id = attr_id
);

insert into credits (
    select name_id, title_id, 'production_designer',
        jsonb_strip_nulls(jsonb_build_object('info', attribute))
    from production_designers
    left join attributes on attributes.id = attr_id
);

insert into credits (
    select name_id, title_id, 'writer',
        jsonb_strip_nulls(jsonb_build_object(
            'info', attribute, 'line_order', line_order,
            'group_order', group_order, 'subgroup_order', subgroup_order))
    from writers
    left join attributes on attributes.id = attr_id
);

-- If the same person appears in the same type of credit several times in the same movie,
-- delete all but one occurrence arbitrarily. TODO perhaps it would be better to merge them.
delete from credits where ctid in (
    select c1.ctid
    from credits c1
    join credits c2
        on c1.person_id = c2.person_id
        and c1.movie_id = c2.movie_id
        and c1.type = c2.type
        and c1.ctid < c2.ctid
);

-- Delete credits that reference a nonexistent movie, for whatever reason
delete from credits where movie_id in (
    select movie_id from credits
    left join movies on movies.id = movie_id
    where movies.id is null
);

alter table credits add foreign key (person_id) references people (id);
alter table credits add foreign key (movie_id) references movies (id);
create unique index on credits (person_id, movie_id, type);
create index on credits (movie_id);



create table movies_doc (properties jsonb not null);

insert into movies_doc
select jsonb_strip_nulls(jsonb_build_object(
    'id',                   movies.id,
    'title',                title,
    'year',                 properties->'year',
    'actors',               credits_obj->'actor',
    'cinematographers',     credits_obj->'cinematographer',
    'composers',            credits_obj->'composer',
    'costume_designers',    credits_obj->'costume_designer',
    'directors',            credits_obj->'director',
    'editors',              credits_obj->'editor',
    'producers',            credits_obj->'producer',
    'production_designers', credits_obj->'production_designer',
    'writers',              credits_obj->'writer',
    'certificates',         certificate_arr,
    'color_info',           color_info_arr,
    'genres',               genre_arr,
    'keywords',             keyword_arr,
    'language',             language_arr,
    'locations',            location_arr,
    'release_dates',        reldate_obj,
    'running_times',        runtime_arr)) as properties
from movies
left join (
    select movie_id, jsonb_object_agg(type, items) credits_obj from (
        select movie_id, type, jsonb_agg(credits.properties ||
            jsonb_build_object('person_id', person_id, 'name', name)
            order by credits.properties->'position', credits.properties->'line_order',
            credits.properties->'group_order', credits.properties->'subgroup_order', name) as items
        from credits join people on person_id = people.id
        group by movie_id, type
    ) credits2 group by movie_id
) credits3 on credits3.movie_id = movies.id
left join (
    select title_id, jsonb_agg(value order by value) as genre_arr
    from genres group by title_id
) genres2 on genres2.title_id = movies.id
left join (
    select title_id, jsonb_agg(value order by value) as keyword_arr
    from keywords group by title_id
) keywords2 on keywords2.title_id = movies.id
left join (
    select title_id, jsonb_agg(jsonb_strip_nulls(jsonb_build_object(
        'country', split_part(value, ':', 1),
        'certificate', split_part(value, ':', 2),
        'note', attribute)) order by value, attribute) as certificate_arr
    from certificates
    left join attributes on attributes.id = attr_id group by title_id
) certificates2 on certificates2.title_id = movies.id
left join (
    select title_id, jsonb_agg(jsonb_strip_nulls(jsonb_build_object(
        'color_info', value, 'note', attribute)) order by value, attribute) as color_info_arr
    from color_info
    left join attributes on attributes.id = attr_id group by title_id
) color_info2 on color_info2.title_id = movies.id
left join (
    select title_id, jsonb_agg(jsonb_strip_nulls(jsonb_build_object(
        'language', value, 'note', attribute)) order by value, attribute) as language_arr
    from language
    left join attributes on attributes.id = attr_id group by title_id
) language2 on language2.title_id = movies.id
left join (
    select title_id, jsonb_agg(jsonb_strip_nulls(jsonb_build_object(
        'location', value, 'note', attribute)) order by value, attribute) as location_arr
    from locations
    left join attributes on attributes.id = attr_id group by title_id
) locations2 on locations2.title_id = movies.id
left join (
    select title_id, jsonb_object_agg(country, dates) as reldate_obj
    from (
        select title_id, country, jsonb_agg(jsonb_strip_nulls(jsonb_build_object(
            'release_date', date, 'note', attribute)) order by date, attribute) as dates
        from (
            select title_id, country, attribute, case
                when array_length(date, 1) = 3 then (date[1] || ' ' || date[2] || ' ' || date[3])::date::text
                when array_length(date, 1) = 2 then trim(trailing '-01' from ('1 ' || date[1] || ' ' || date[2])::date::text)
                when array_length(date, 1) = 1 then date[1]
                else ''
            end as date
            from (
                select title_id, attribute, split_part(value, ':', 1) as country,
                    regexp_split_to_array(trim(both ' ' from split_part(value, ':', 2)), ' +') as date
                from release_dates
                left join attributes on attributes.id = attr_id
            ) reldates2
        ) reldates3 group by title_id, country
    ) reldates4 group by title_id
) reldates5 on reldates5.title_id = movies.id
left join (
    select title_id, jsonb_agg(jsonb_strip_nulls(jsonb_build_object(
        'running_time', value, 'note', attribute)) order by value, attribute) as runtime_arr
    from running_times
    left join attributes on attributes.id = attr_id group by title_id
) running_times2 on running_times2.title_id = movies.id
where series_id is null and not is_series and properties->>'suspended' is null and title ~ '\(\d{4}[^\)]*\)$';


create table people_doc (properties jsonb not null);

insert into people_doc
select jsonb_strip_nulls(jsonb_build_object(
    'id',                     people.id,
    'name',                   name,
    'gender',                 properties->'gender',
    'actor_in',               credits_obj->'actor',
    'cinematographer_in',     credits_obj->'cinematographer',
    'composer_in',            credits_obj->'composer',
    'costume_designer_in',    credits_obj->'costume_designer',
    'director_in',            credits_obj->'director',
    'editor_in',              credits_obj->'editor',
    'producer_in',            credits_obj->'producer',
    'production_designer_in', credits_obj->'production_designer',
    'writer_in',              credits_obj->'writer')) as properties
from people join (
    select person_id, jsonb_object_agg(type, items) as credits_obj from (
        select person_id, type, jsonb_agg(credits.properties || jsonb_build_object(
            'movie_id', movie_id, 'title', title) order by movies.properties->>'year', title) as items
        from credits
        join movies on movies.id = movie_id
        where series_id is null and not is_series and movies.properties->>'suspended' is null
            and title ~ '\(\d{4}[^\)]*\)$' -- same filtering condition as for movies_doc
            and type <> 'miscellaneous'
        group by person_id, type
    ) credits2 group by person_id
) credits3 on credits3.person_id = people.id;
