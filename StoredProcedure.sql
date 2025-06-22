DELIMITER //

CREATE PROCEDURE UpdatePlayerDev_HittingTables()
BEGIN
    -- Step 1: Update HitTraxUsers
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

    -- Step 2: Update HitTraxComplete
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

    -- Step 3: Update BlastSwingSilver
    INSERT INTO PlayerDev.BlastSwingSilver (
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
            FROM PlayerDev.BlastSwingSilver
        );

    -- Step 4: Update HittingBronze
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

    -- Step 5: Update HittingSilver
    INSERT INTO PlayerDev.HittingSilver (
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
        WHERE hs.Id = hb.Id
    );

    -- Step 6: Update HittingGold
    INSERT INTO PlayerDev.HittingGold
    SELECT 
        *,
        1 + ((Velo - EBV1) / (PV + EBV1)) AS SmashFactor, -- Calculate SmashFactor
        metric_swing_speed / metric_peak_hand_speed AS SwingEfficiency -- Calculate SwingEfficiency
    FROM 
        PlayerDev.HittingSilver hs
    WHERE 
        (PV + EBV1) != 0 -- Prevent division by zero for SmashFactor
        AND metric_peak_hand_speed != 0 -- Prevent division by zero for SwingEfficiency
        AND NOT EXISTS (
            SELECT 1
            FROM PlayerDev.HittingGold hg
            WHERE hg.Id = hs.Id
        );
    
    -- Step 7: Update HitTraxSwingSilver
    INSERT INTO PlayerDev.HitTraxSwingSilver (
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
        GD
    )
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
        EBV1 * 2.23694, -- Convert EBV1 to mph
        EBV2 * 2.23694, -- Convert EBV2 to mph
        EBV3 * 2.23694, -- Convert EBV3 to mph
        Dist * 3.28084, -- Convert Dist to feet
        PV * 2.23694, -- Convert PV to mph
        Velo * 2.23694, -- Convert Velo to mph
        RadarVelo * 2.23694, -- Convert RadarVelo to mph
        GD * 2.23694 -- Convert GD to mph
    FROM 
        PlayerDev.HitTraxComplete c
    WHERE NOT EXISTS (
        SELECT 1
        FROM PlayerDev.HitTraxSwingSilver s
        WHERE c.Id = s.Id AND c.UId = s.UId AND c.SnId = s.SnId AND c.SnUId = s.SnUId
    );

    -- Step 8: Update RBI_HitTraxSwingSilver
    INSERT INTO PlayerDev.RBI_HitTraxSwingSilver (
        PlayerName,
        RBI_Player,
        Class,
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
        GD
    )
    SELECT 
        r.PlayerName,
        r.RBI_Player,
        r.Class,
        h.UserName,
        h.Id,
        h.UId,
        h.SId,
        h.SnId,
        h.SnUId,
        h.TS, 
        h.UsUId, 
        h.MS, 
        h.Res,
        h.HT, 
        h.PT,
        h.Fld,
        h.QD,
        h.Elv,
        h.Actv,
        h.MasterID,
        h.Uuid,
        h.SnUuid,
        h.UsUuid,
        h.PitchAngle,
        h.LastModified,
        h.Created,
        h.imported_at,
        h.source_file,
        h.EBV1,
        h.EBV2,
        h.EBV3,
        h.Dist,
        h.PV,
        h.Velo,
        h.RadarVelo,
        h.GD
    FROM 
        PlayerDev.RBI_Players r
    INNER JOIN 
        PlayerDev.HitTraxSwingSilver h
    ON 
        r.PlayerName = h.UserName
    WHERE NOT EXISTS (
        SELECT 1
        FROM PlayerDev.RBI_HitTraxSwingSilver rhs
        WHERE r.PlayerName = rhs.PlayerName AND h.Id = rhs.Id
    );

END //

DELIMITER ;

