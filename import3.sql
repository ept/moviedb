create or replace function make_movies_doc(only_top_titles boolean) returns setof jsonb AS $$
select jsonb_strip_nulls(jsonb_build_object(
    'id',                   movies.id,
    'title',                movies.title,
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
left join top_titles on top_titles.title = movies.title
where series_id is null and not is_series and properties->>'suspended' is null and movies.title ~ '\(\d{4}[^\)]*\)$'
    and (top_titles.title is not null or not only_top_titles)
$$ language sql;


create or replace function make_people_doc(only_top_titles boolean) returns setof jsonb AS $$
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
            'movie_id', movie_id, 'title', movies.title) order by movies.properties->>'year', movies.title) as items
        from credits
        join movies on movies.id = movie_id
        left join top_titles on top_titles.title = movies.title
        where series_id is null and not is_series and movies.properties->>'suspended' is null
            and movies.title ~ '\(\d{4}[^\)]*\)$' -- same filtering condition as for movies_doc
            and type <> 'miscellaneous'
            and (top_titles.title is not null or not only_top_titles)
        group by person_id, type
    ) credits2 group by person_id
) credits3 on credits3.person_id = people.id
$$ language sql;
