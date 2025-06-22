 -- Done

-- Data Dictionary: https://docs.google.com/spreadsheets/d/123WQbhHWB29nf6IHryM2ZFNCF6YxmZ5kuNc7qsktiE4/edit?usp=sharing

-- Tables: 
-- 'blast_swing_metrics': 
-- 'blast_team_data': 
-- 'hittrax_session_summaries': HitTrax session csv pull, the aggregation of a user's session. Use case - getting the UserName field to be able to join with the plays table
-- 'hittrax_swing_metrics': HitTrax plays csv pull, there is a record for each swing HitTrax collects. Use case - this is where we extract information from each player's swings recorded by the HitTrax
-- 'HitTraxUsers': HitTrax users we extract from the 'hittrax_session_summaries' table so it the join with the plays table doesn't consume so much compute. Use case - we join this table with the 'HitTraxBronze' table so we have a complete plays table with the users name attached to the record
-- 'HitTraxComplete': Join of the users and plays tables to get complete table to begin work on aggregations
-- 'BlastSwingSilver': fixing the ts data and removing the unneeded fields (fields that expicitely call out the unit)
-- 'HittingBronze': Join of the 'HitTraxComplete' table and the 'BlastSwingSilver'
-- 'HittingSilver': Data units have been converted to what users are used to reading
-- 'HittingGold': Data has been aggregated to create new fields for further insights
-- 'HitTraxSwingSilver': HitTrax swing data only with username. Data units converted to what users are used to reading
-- 'RBI_HitTraxSwingSilver': RBI players only - HitTrax swing data only with username. Data units converted to what users are used to reading

-- Combining the HitTrax tables
-- Does it make more sense to create a new table that is only the username and user id from sessions and then join on userid for the 2 tables so the only additional field we get is the user name for plays? 
-- Don't worry about there being multiple records with the same UserName, we are going to filter by UserName on the dashboard side so it's not going to matter.
-- TEST: Complete
CREATE TABLE PlayerDev.HitTraxUsers AS
SELECT DISTINCT
    Id,
    UId,
    UserName    
FROM 
    PlayerDev.hittrax_session_summaries  

-- After Table is created
-- Test: Complete
INSERT INTO PlayerDev.HitTraxUsers (Id, UId, UserName)
SELECT DISTINCT
    s.Id,
    s.UId,
    s.UserName
FROM PlayerDev.hittrax_session_summaries s
WHERE NOT EXISTS (
    SELECT 1
    FROM PlayerDev.HitTraxUsers u
    WHERE u.Id = s.Id AND u.UId = s.UId AND u.UserName = s.UserName
);

----------------------------------------------------------------------------------------------------------------------------------------

-- Combining the HitTrax tables
-- TEST: Complete
CREATE TABLE PlayerDev.HitTraxComplete AS
SELECT 
    p.*,
    u.UserName
FROM 
    PlayerDev.HitTraxUsers u
JOIN 
    PlayerDev.hittrax_swing_metrics p
ON 
    u.Id = p.SnId AND u.UId = p.SnUid;


-- Combine HitTrax tables once table is created
-- TEST: Complete
INSERT INTO PlayerDev.HitTraxComplete
SELECT 
    p.*,
    u.UserName
FROM 
    PlayerDev.HitTraxUsers u
JOIN 
    PlayerDev.hittrax_swing_metrics p
ON 
    u.Id = p.SnId AND u.UId = p.SnUid
WHERE NOT EXISTS (
    SELECT 1
    FROM PlayerDev.HitTraxComplete c
    WHERE c.SnId = p.SnId AND c.SnUid = p.SnUid
);


----------------------------------------------------------------------------------------------------------------------------------------

-- Create 'blastSwingSilver' table where we fix the TS field issue and eliminate fields that were unecessary
-- TEST: Complete
CREATE TABLE BlastSwingSilver AS
SELECT     
    b.action_id,
    b.blast_id,
    b.player_id,
    b.player_email,
    b.player_name,
    b.academy_id,
    b.has_video,
    b.video_id,
    b.handedness,
    b.sport_id,
    b.sync_timestamp,
    b.equipment_id,
    b.equipment_name,
    b.equipment_nickname,
    b.metric_plane_score,
    b.metric_connection_score,
    b.metric_rotation_score,
    b.metric_early_connection,
    -- Attack Angle
    b.metric_bat_path_angle,
    b.metric_swing_speed,
    b.metric_connection,
    b.metric_vertical_bat_angle,
    -- On-plane efficiency
    b.metric_planar_efficiency,
    b.metric_peak_hand_speed,
    b.metric_power,
    b.metric_rotational_acceleration,
    b.metric_time_to_contact,    
    DATE_FORMAT(
        CONVERT_TZ(CONCAT(b.created_date, ' ', b.created_time), 'UTC', 'America/New_York'), 
        '%Y-%m-%d %H:%i:%s'
    ) AS TimeStamp
FROM 
    PlayerDev.blast_swing_metrics b;



-- 'blastSwingSilver' once table has been created
-- TEST: Complete
INSERT INTO BlastSwingSilver (
    action_id,
    blast_id,
    player_id,
    player_email,
    player_name,
    academy_id,
    has_video,
    video_id,
    handedness,
    sport_id,
    sync_timestamp,
    equipment_id,
    equipment_name,
    equipment_nickname,
    metric_plane_score,
    metric_connection_score,
    metric_rotation_score,
    metric_early_connection,
    metric_bat_path_angle,
    metric_swing_speed,
    metric_connection,
    metric_vertical_bat_angle,
    metric_planar_efficiency,
    metric_peak_hand_speed,
    metric_power,
    metric_rotational_acceleration,
    metric_time_to_contact,
    TimeStamp
)
SELECT     
    b.action_id,
    b.blast_id,
    b.player_id,
    b.player_email,
    b.player_name,
    b.academy_id,
    b.has_video,
    b.video_id,
    b.handedness,
    b.sport_id,
    b.sync_timestamp,
    b.equipment_id,
    b.equipment_name,
    b.equipment_nickname,
    b.metric_plane_score,
    b.metric_connection_score,
    b.metric_rotation_score,
    b.metric_early_connection,
    b.metric_bat_path_angle,
    b.metric_swing_speed,
    b.metric_connection,
    b.metric_vertical_bat_angle,
    b.metric_planar_efficiency,
    b.metric_peak_hand_speed,
    b.metric_power,
    b.metric_rotational_acceleration,
    b.metric_time_to_contact,
    DATE_FORMAT(
        CONVERT_TZ(CONCAT(b.created_date, ' ', b.created_time), 'UTC', 'America/New_York'), 
        '%Y-%m-%d %H:%i:%s'
    ) AS TimeStamp
FROM 
    PlayerDev.blast_swing_metrics b
WHERE 
    CONCAT(b.created_date, ' ', b.created_time) > (
        SELECT MAX(TimeStamp) 
        FROM BlastSwingSilver
    );


----------------------------------------------------------------------------------------------------------------------------------------

-- Combine HitTrax & Blast Tables
-- TEST: Complete
CREATE TABLE PlayerDev.HittingBronze AS
SELECT 
    c.*, b.* 
FROM 
    PlayerDev.HitTraxComplete c
JOIN 
    PlayerDev.BlastSwingSilver b
ON 
    c.UserName = b.player_name AND c.TS = b.TimeStamp;


-- Combine HitTrax tables once table is created
-- TEST: Complete
INSERT INTO PlayerDev.HittingBronze
SELECT 
    c.*, b.* 
FROM 
    PlayerDev.HitTraxComplete c
JOIN 
    PlayerDev.BlastSwingSilver b
ON 
    c.UserName = b.player_name AND c.TS = b.TimeStamp
WHERE NOT EXISTS (
    SELECT 1
    FROM PlayerDev.HittingBronze hb
    WHERE hb.UserName = c.UserName AND hb.TS = c.TS
);

----------------------------------------------------------------------------------------------------------------------------------------

-- Make HitTrax table fields more readable (ex. cm > inch)
-- TEST: Complete
CREATE TABLE PlayerDev.HittingSilver AS
SELECT 
    -- HitTrax fields below
    UserName,
    Id,
    UId,
    SId,
    SnId,
    SnUId,
    TS, 
    UsUId, 
    MS, 
    Res,
    HT, 
    PT,
    Fld,
    QD,
    Elv,
    Actv,
    MasterID,
    Uuid,
    SnUuid,
    UsUuid,
    PitchAngle,
    LastModified,
    Created,
    imported_at,
    source_file,
    EBV1 * 2.23694 AS EBV1,
    EBV2 * 2.23694 AS EBV2,
    EBV3 * 2.23694 AS EBV3,
    Dist * 3.28084 AS Dist,
    PV * 2.23694 AS PV,
    Velo * 2.23694 AS Velo,
    RadarVelo * 2.23694 AS RadarVelo,
    GD * 2.23694 AS GD,
    -- Blast fields below
    action_id,
    blast_id,
    player_id,
    player_email,
    player_name,
    academy_id,
    has_video,
    video_id,
    handedness,
    sport_id,
    sync_timestamp,
    equipment_id,
    equipment_name,
    equipment_nickname,
    metric_plane_score,
    metric_connection_score,
    metric_rotation_score,
    metric_early_connection,
    metric_bat_path_angle,
    metric_swing_speed,
    metric_connection,
    metric_vertical_bat_angle,
    metric_planar_efficiency,
    metric_peak_hand_speed,
    metric_power,
    metric_rotational_acceleration,
    metric_time_to_contact
FROM 
    PlayerDev.HittingBronze;

-- Update the HittingSilver table daily
-- Insert new records from HittingBronze into HittingSilver with converted fields
-- TEST: Complete
INSERT INTO PlayerDev.HittingSilver (
    -- HitTrax fields
    UserName,
    Id,
    UId,
    SId,
    SnId,
    SnUId,
    TS, 
    UsUId, 
    MS, 
    Res,
    HT, 
    PT,
    Fld,
    QD,
    Elv,
    Actv,
    MasterID,
    Uuid,
    SnUuid,
    UsUuid,
    PitchAngle,
    LastModified,
    Created,
    imported_at,
    source_file,
    EBV1,
    EBV2,
    EBV3,
    Dist,
    PV,
    Velo,
    RadarVelo,
    GD,
    -- Blast fields
    action_id,
    blast_id,
    player_id,
    player_email,
    player_name,
    academy_id,
    has_video,
    video_id,
    handedness,
    sport_id,
    sync_timestamp,
    equipment_id,
    equipment_name,
    equipment_nickname,
    metric_plane_score,
    metric_connection_score,
    metric_rotation_score,
    metric_early_connection,
    metric_bat_path_angle,
    metric_swing_speed,
    metric_connection,
    metric_vertical_bat_angle,
    metric_planar_efficiency,
    metric_peak_hand_speed,
    metric_power,
    metric_rotational_acceleration,
    metric_time_to_contact
)
SELECT 
    -- HitTrax fields
    UserName,
    Id,
    UId,
    SId,
    SnId,
    SnUId,
    TS, 
    UsUId, 
    MS, 
    Res,
    HT, 
    PT,
    Fld,
    QD,
    Elv,
    Actv,
    MasterID,
    Uuid,
    SnUuid,
    UsUuid,
    PitchAngle,
    LastModified,
    Created,
    imported_at,
    source_file,
    EBV1 * 2.23694 AS EBV1, -- Convert EBV1 to mph
    EBV2 * 2.23694 AS EBV2, -- Convert EBV2 to mph
    EBV3 * 2.23694 AS EBV3, -- Convert EBV3 to mph
    Dist * 3.28084 AS Dist, -- Convert Dist to feet
    PV * 2.23694 AS PV, -- Convert PV to mph
    Velo * 2.23694 AS Velo, -- Convert Velo to mph
    RadarVelo * 2.23694 AS RadarVelo, -- Convert RadarVelo to mph
    GD * 2.23694 AS GD, -- Convert GD to mph
    -- Blast fields
    action_id,
    blast_id,
    player_id,
    player_email,
    player_name,
    academy_id,
    has_video,
    video_id,
    handedness,
    sport_id,
    sync_timestamp,
    equipment_id,
    equipment_name,
    equipment_nickname,
    metric_plane_score,
    metric_connection_score,
    metric_rotation_score,
    metric_early_connection,
    metric_bat_path_angle,
    metric_swing_speed,
    metric_connection,
    metric_vertical_bat_angle,
    metric_planar_efficiency,
    metric_peak_hand_speed,
    metric_power,
    metric_rotational_acceleration,
    metric_time_to_contact
FROM 
    PlayerDev.HittingBronze hb
WHERE NOT EXISTS (
    SELECT 1
    FROM PlayerDev.HittingSilver hs
    WHERE hs.Id = hb.Id -- Replace `Id` with the unique identifier in your schema
);


----------------------------------------------------------------------------------------------------------------------------------------

-- HittingGold is the complete aggregated table
-- TEST: Complete
CREATE TABLE PlayerDev.HittingGold AS
SELECT 
    *,
    1 + ((Velo - metric_swing_speed) / (PV + metric_swing_speed)) AS SmashFactor,
    metric_swing_speed / metric_peak_hand_speed AS SwingEfficiency
FROM 
    PlayerDev.HittingSilver
WHERE 
    (PV + EBV1) != 0 -- Prevent division by zero for SmashFactor
    AND metric_peak_hand_speed != 0; -- Prevent division by zero for SwingEfficiency


-- For daily updates after table creation
-- TEST: Complete
INSERT INTO PlayerDev.HittingGold
SELECT 
    *,
    1 + ((Velo - metric_swing_speed) / (PV + metric_swing_speed)) AS SmashFactor, -- Calculate SmashFactor
    metric_swing_speed / metric_peak_hand_speed AS SwingEfficiency -- Calculate SwingEfficiency
FROM 
    PlayerDev.HittingSilver hs
WHERE 
    (PV + metric_swing_speed) != 0 -- Prevent division by zero for SmashFactor
    AND metric_peak_hand_speed != 0 -- Prevent division by zero for SwingEfficiency
    AND NOT EXISTS (
        SELECT 1
        FROM PlayerDev.HittingGold hg
        WHERE hg.Id = hs.Id -- Replace 'Id' with your unique identifier
    );

----------------------------------------------------------------------------------------------------------------------------------------

-- Converting the necessary fields to MPH & feet from HitTraxComplete
-- TEST: 
CREATE TABLE PlayerDev.HitTraxSwingSilver AS
SELECT 
    UserName,
    Id,
    UId,
    SId,
    SnId,
    SnUId,
    TS, 
    UsUId, 
    MS, 
    Res,
    HT, 
    PT,
    Fld,
    QD,
    Elv,
    Actv,
    MasterID,
    Uuid,
    SnUuid,
    UsUuid,
    PitchAngle,
    LastModified,
    Created,
    imported_at,
    source_file,
    EBV1 * 2.23694 AS EBV1, -- Convert EBV1 to mph
    EBV2 * 2.23694 AS EBV2, -- Convert EBV2 to mph
    EBV3 * 2.23694 AS EBV3, -- Convert EBV3 to mph
    Dist * 3.28084 AS Dist, -- Convert Dist to feet
    PV * 2.23694 AS PV, -- Convert PV to mph
    Velo * 2.23694 AS Velo, -- Convert Velo to mph
    RadarVelo * 2.23694 AS RadarVelo, -- Convert RadarVelo to mph
    GD * 2.23694 AS GD -- Convert GD to mph
FROM 
    PlayerDev.HitTraxComplete;

----------------------------------------------------------------------------------------------------------------------------------------
-- Converting the necessary fields to MPH & feet from HitTraxComplete - RBI players only
CREATE TABLE RBI_HitTraxSwingSilver AS
SELECT 
    RBI_Players.*,
    HitTraxSwingSilver.*
FROM 
    RBI_Players
INNER JOIN 
    HitTraxSwingSilver
ON 
    RBI_Players.PlayerName = HitTraxSwingSilver.UserName;
