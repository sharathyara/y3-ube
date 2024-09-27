--Inserting old records from old to new table----
insert into curated_schema.user(datetimeoccurred,
                                userid,
                                username,
                                createdby,
                                createddatetime,
                                modifiedby,
                                modifieddatetime,
                                eventtype,
                                created_at)
 select datetimeoccurred,
        userid,
        username,
        createdby,
        createddatetime,
        modifiedby,
        modifieddatetime,
        eventtype,
        created_at from curated_schema.user_old;

DROP table curated_schema.user_old cascade;